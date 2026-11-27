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
/// (`Battle.plainChoice`) until it's the
/// party's turn again.
@MainActor
@Observable
final class Fight {
  /// How far into the sample battle a
  /// screen starts, for UI tests and
  /// snapshots.
  enum Stage {
    /// Gerald's first turn.
    case start
    /// The same, with a move planned to
    /// (300, 200).
    case moving
    /// The same, skills open, Sword Cut
    /// picked: no foe in reach.
    case aiming
    /// Gerald's second turn, with a move
    /// planned that puts Kestrel-9 in Sword
    /// Cut's reach, but not Ashka.
    case planned
    /// The same, after Sword Cut and
    /// Pommel Strike on Kestrel-9: the
    /// turn still to end.
    case acted
    /// Six turns in.
    case middle
    /// The same, with every zone on.
    case zones
    /// Played to the end.
    case end
    /// Gerald and Maren against the same
    /// foes, five turns in: Maren's turn,
    /// Mend Wounds picked, Gerald's plate
    /// worn and in her reach, every zone
    /// on.
    case healing
  }

  /// The parts of a turn, one shown at a
  /// time.
  enum Panel {
    case move, skills, actions
  }

  private(set) var battle: Battle
  /// Who fights for the party.
  private let party: [Unit]
  /// Who they face.
  private let foes: [Unit]
  /// The skill picked for the unit on
  /// turn, waiting for a target.
  private(set) var chosen: Int?
  /// Where the unit on turn plans to move,
  /// until it's committed.
  private(set) var ghost: Point?
  /// The part of the turn on show.
  var panel = Panel.move
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
      party: stage.party,
      foes: stage.foes,
      pause: pause
    )
    play(stage.turns)
    stage.setUp(self)
  }

  /// A battle between `party` and `foes`,
  /// up to the party's first turn.
  init(
    party: [Unit],
    foes: [Unit],
    pause: @escaping Pause = Fight.sleep
  ) {
    wait = pause
    self.party = party
    self.foes = foes
    battle = Battle(party: party, foes: foes)
    foesAct()
  }

  /// Plays `turns` turns with the plain
  /// choices, then the foes' turns, up to
  /// the party's.
  func play(_ turns: Int) {
    battle.playPlainly(turns: turns)
    foesAct()
  }

  /// Waits for `time`, really.
  nonisolated static func sleep(
    _ time: Duration
  ) async {
    _ = try? await Task.sleep(for: time)
  }

  /// The unit whose turn it is.
  var actor: BattleUnit? {
    battle.next.map { battle.units[$0] }
  }

  /// Everyone up, in turn order.
  var queue: [BattleUnit] {
    battle.queue.map { battle.units[$0] }
  }

  /// One side's units, in list order.
  func units(_ side: Side) -> [BattleUnit] {
    battle.units.filter { $0.side == side }
  }

  /// The latest log lines, newest first.
  var latest: [String] {
    battle.log.suffix(12).reversed().map {
      $0.description.trimmingCharacters(
        in: .whitespaces
      )
    }
  }

  /// Who won, once someone has.
  var outcome: String? {
    battle.winner.map {
      $0 == .party
        ? String(localized: "The party wins")
        : String(localized: "The foes win")
    }
  }

  /// What the planned move would cost, in
  /// centimetres, if one is planned.
  var planned: Int? {
    ghost.map { battle.cost(to: $0) }
  }

  /// What's left of the unit on turn's
  /// movement, before the planned move.
  var moveLeft: Int {
    battle.moveLeft
  }

  /// Picks a skill for the unit on turn.
  func choose(_ ability: Int) {
    chosen = ability
  }

  /// Plans a move to `point`, or as far
  /// toward it as the unit on turn can go
  /// (to the edge of its range); its own
  /// spot clears the plan.
  func place(_ point: Point) {
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

  /// A tap on the arena at `point`: with a
  /// skill picked, a unit there it can be
  /// used on is its target (a foe for an
  /// attack, an ally for a heal); else the
  /// unit on turn itself clears the plan;
  /// another unit's zone turns on or off;
  /// anywhere else it can reach is
  /// planned.
  func tap(_ point: Point) {
    guard let actor else {
      return
    }
    let unit = battle.units.first {
      $0.isUp && Self.covers($0, point)
    }
    if let unit, canAim(at: unit.id) {
      target(unit.id)
    } else if unit?.id == actor.id {
      ghost = nil
    } else if let unit {
      watch(unit.id)
    } else {
      place(point)
    }
  }

  /// Whether `point` is on `unit`'s circle.
  private static func covers(
    _ unit: BattleUnit,
    _ point: Point
  ) -> Bool {
    let radius = unit.unit.size.radius
    let across = point.x - unit.place.x
    let down = point.y - unit.place.y
    return across * across + down * down
      <= radius * radius
  }

  /// Moves the planned spot (or, with none,
  /// the unit's own) `step` centimetres
  /// `way`, if it can go there.
  func nudge(_ way: Nudge, by step: Int) {
    guard let from = ghost ?? actor?.place
    else { return }
    place(Point(
      x: from.x + way.offset.x * step,
      y: from.y + way.offset.y * step
    ))
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
        nudge(way, by: Nudge.step(tick))
        await wait(Nudge.delay(after: tick))
        tick += 1
      }
    }
  }

  /// Forgets the planned move.
  func undo() {
    ghost = nil
  }

  /// Walks the planned move. It can't be
  /// undone after.
  func commit() {
    if let ghost {
      try? battle.move(to: ghost)
    }
    ghost = nil
  }

  /// Uses the picked skill on `target`,
  /// walking the planned move first; the
  /// skills stay open while one can still
  /// be used (a bonus), else the actions
  /// open. Nothing happens if it can't
  /// reach.
  func target(_ target: Int) {
    guard let chosen, inReach(target) else {
      return
    }
    commit()
    try? battle.use(chosen, on: target)
    self.chosen = nil
    let left = actor?.unit.abilities.indices
      .contains(where: battle.canUse)
    panel = left == true ? .skills : .actions
  }

  /// Walks the planned move, if any, and
  /// ends the turn; then the foes act.
  func endTurn() {
    try? battle.act(Turn(before: ghost))
    ghost = nil
    chosen = nil
    panel = .move
    foesAct()
  }

  /// The same battle, from the start.
  func restart() {
    battle = Battle(party: party, foes: foes)
    chosen = nil
    ghost = nil
    panel = .move
    foesAct()
  }

  /// Foes' turns, until the party's (or
  /// the end).
  private func foesAct() {
    while actor?.side == .foes,
      let turn = battle.plainChoice {
      try? battle.act(turn)
    }
  }
}
