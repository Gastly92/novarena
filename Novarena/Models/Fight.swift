import Foundation
import Observation
import RuleSteward

/// A battle on screen, a step at a time.
/// On the party's turn the player plans a
/// move (dragging or nudging a ghost,
/// which can be moved and undone freely),
/// commits it, picks a skill and a foe in
/// reach, and ends the turn; acting or
/// ending the turn commits a planned move.
/// Foes take their plain choice
/// (`Battle.plainChoice`), played a step
/// at a time (`advance()`), until it's the
/// party's turn again.
@MainActor
@Observable
final class Fight {
  /// The parts of a turn, one shown at a
  /// time.
  enum Panel {
    case move, skills, actions
  }

  private(set) var battle: Battle
  /// The battle as it began, to fight
  /// again.
  private let start: Battle
  /// How the player likes it to play.
  let settings: Settings
  /// The skill picked for the unit on
  /// turn, waiting for a target.
  private(set) var chosen: Int?
  /// Where the unit on turn plans to move,
  /// until it's committed.
  private(set) var ghost: Point?
  /// The skill planned on a unit, from the
  /// planned spot, until it's used
  /// (`use()`).
  private(set) var aimed: Action?
  /// The foe picked to walk toward, with
  /// the move open: up close or in range
  /// (`upClose()`, `inRange()`).
  var approached: Int?
  /// The part of the turn on show.
  var panel = Panel.move
  /// Whether zones are on: taps on units
  /// turn theirs on or off.
  var zoning = false
  /// What's left of the foe's turn being
  /// played, a step at a time.
  var steps: [Step] = []
  /// The log lines the last step added.
  var shown: [String] = []
  /// The units whose zones the arena
  /// shades: where each could hit next
  /// turn, as far as the party knows.
  var watched: Set<Int> = []
  /// Waits between nudges of a held arrow.
  @ObservationIgnored private let wait: Pause
  /// Nudges while an arrow is held.
  @ObservationIgnored private var hold: Hold?
  /// The arrow held, if any.
  @ObservationIgnored private var way: Nudge?

  /// Waits a while, for a held arrow.
  typealias Pause = @Sendable (Duration)
    async -> Void
  /// Nudging while an arrow is held.
  typealias Hold = Task<Void, Never>

  /// The sample battle at `stage`.
  convenience init(
    stage: Stage = .start,
    pause: @escaping Pause = Fight.sleep
  ) {
    self.init(
      stage.battle,
      settings: .manual,
      pause: pause
    )
    play(stage.turns)
    stage.setUp(self)
  }

  /// A battle between `party` and `foes`,
  /// the party with a commander.
  convenience init(
    party: [Unit],
    foes: [Unit],
    settings: Settings = Settings(),
    pause: @escaping Pause = Fight.sleep
  ) {
    self.init(
      Battle(
        party: party,
        foes: foes,
        commander: .party
      ),
      settings: settings,
      pause: pause
    )
  }

  /// `battle`, as it stands, played as
  /// `settings` say.
  init(
    _ battle: Battle,
    settings: Settings,
    pause: @escaping Pause
  ) {
    wait = pause
    start = battle
    self.battle = battle
    self.settings = settings
  }

  /// Plays `turns` turns with the plain
  /// choices, then the foes' turns, up to
  /// the party's.
  func play(_ turns: Int) {
    battle.playPlainly(turns: turns)
    skip()
  }

  /// Waits for a while, really.
  nonisolated static let sleep: Pause = {
    _ = try? await Task.sleep(for: $0)
  }

  /// Picks a skill for the unit on turn;
  /// a plan for another skill goes. The
  /// skill already picked is unpicked (its
  /// plan too), so taps move again.
  func choose(_ ability: Int) {
    guard chosen != ability else {
      chosen = nil
      aimed = nil
      return
    }
    chosen = ability
    if aimed?.ability != ability {
      aimed = nil
    }
  }

  /// Plans a move to `point`, or as far
  /// toward it as the unit on turn can go
  /// (to the edge of its range); its own
  /// spot clears the plan.
  func place(_ point: Point) {
    guard !isFoesTurn, !isCommanding else {
      return
    }
    if point == actor?.place {
      ghost = nil
    } else if let spot = battle.reachable(
      toward: point
    ) {
      ghost = spot
    }
  }

  /// A touch on the arena at `point`: a
  /// drag (once it has `moved`) moves the
  /// plan there; a tap counts once
  /// `lifted`.
  func touch(
    _ point: Point,
    moved: Bool,
    lifted: Bool
  ) {
    if moved {
      place(point)
    } else if lifted {
      tap(point)
    }
  }

  /// Moves the planned spot (or, with none,
  /// the unit's own) `step` centimetres
  /// `way`, if it can go there: not into
  /// a unit it touches.
  func nudge(_ way: Nudge, by step: Int) {
    guard let from = ghost ?? actor?.place
    else { return }
    guard !way.circles else {
      circle(way, from: from, by: step)
      return
    }
    let spot = Point(
      x: from.x + way.offset.x * step,
      y: from.y + way.offset.y * step
    )
    let into = battle.heads(
      from: from, into: spot
    )
    if !into {
      place(spot)
    }
  }

  /// An arrow pressed (nudging now, then
  /// faster and faster while held), or
  /// released (`nil`). Pressing the arrow
  /// already held changes nothing.
  func press(_ way: Nudge?) {
    guard way != self.way else {
      return
    }
    self.way = way
    hold?.cancel()
    hold = nil
    guard let way else {
      return
    }
    hold = Task { [self, wait] in
      var tick = 0
      while !Task.isCancelled {
        // A circling arrow with nothing to
        // circle lets go, so its next press
        // starts again.
        guard !way.circles || circling
        else {
          self.way = nil
          return
        }
        nudge(way, by: Nudge.step(tick))
        await wait(way.delay(after: tick))
        tick += 1
      }
    }
  }

  /// Forgets the planned move.
  func undo() {
    ghost = nil
  }

  /// Walks the planned move. It can't be
  /// undone after. The turn ends if that
  /// leaves nothing to do (`endIfDone`).
  func commit() {
    walk()
    endIfDone()
  }

  /// Walks the planned move.
  private func walk() {
    if let ghost {
      try? battle.move(to: ghost)
    }
    ghost = nil
  }

  /// Plans the picked skill on `target`,
  /// if it reaches from the planned spot;
  /// `use()` carries it out.
  func target(_ target: Int) {
    guard let chosen, inReach(target) else {
      return
    }
    aimed = Action(chosen, on: target)
  }

  /// Forgets the planned skill (the skill
  /// stays picked).
  func cancel() {
    aimed = nil
  }

  /// Carries out the plan (`carryOut()`);
  /// then the turn ends if nothing's left
  /// to do (`endIfDone`).
  func use() {
    carryOut()
    endIfDone()
  }

  /// Walks the planned move, then uses the
  /// planned skill. The skills stay open
  /// while one can still be used (a bonus),
  /// else the actions open. Nothing happens
  /// if it can't reach.
  private func carryOut() {
    guard let aimed, canUse else {
      return
    }
    walk()
    try? battle.use(
      aimed.ability, on: aimed.target
    )
    self.aimed = nil
    chosen = nil
    let left = actor?.unit.abilities.indices
      .contains(where: battle.canUse)
    panel = left == true ? .skills : .actions
  }

  /// Carries out the plan (the planned
  /// skill too, if it reaches) and ends
  /// the turn; then the foes act.
  func endTurn() {
    carryOut()
    try? battle.act(Turn(before: ghost))
    ghost = nil
    aimed = nil
    approached = nil
    chosen = nil
    panel = .move
    shown = []
    foesGo()
  }

  /// The same battle, from the start.
  func restart() {
    battle = start
    aimed = nil
    approached = nil
    chosen = nil
    ghost = nil
    panel = .move
    steps = []
    shown = []
  }

  /// The party's commander gives `order`;
  /// then, if a foe is up, its turn
  /// begins.
  func command(_ order: Order) {
    try? battle.command(order)
    shown = []
    foesGo()
  }

  /// Takes `step` in the battle. A step
  /// that can't be taken (the end, once
  /// someone has won) does nothing.
  func take(
    _ step: Step,
    reacting: Bool = true
  ) {
    switch step {
    case .begin:
      try? battle.beginTurn()
    case let .move(spot):
      try? battle.move(to: spot)
    case let .use(action):
      try? battle.use(
        action.ability,
        on: action.target,
        reacting: reacting
      )
    case .end:
      try? battle.endTurn()
    }
  }
}
