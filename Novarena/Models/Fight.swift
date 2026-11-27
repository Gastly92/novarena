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
    /// The same, after Sword Cut on
    /// Kestrel-9: the turn still to end.
    case acted
    /// Six turns in.
    case middle
    /// The same, with the danger zone on.
    case danger
    /// Played to the end.
    case end
  }

  /// The parts of a turn, one shown at a
  /// time.
  enum Panel {
    case move, skills, actions
  }

  private(set) var battle: Battle
  /// The skill picked for the unit on
  /// turn, waiting for a target.
  private(set) var chosen: Int?
  /// Where the unit on turn plans to move,
  /// until it's committed.
  private(set) var ghost: Point?
  /// The part of the turn on show.
  var panel = Panel.move
  /// Whether the arena shades where foes
  /// could hit next turn.
  var showsDanger = false
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

  init(
    stage: Stage = .start,
    pause: @escaping Pause = Fight.sleep
  ) {
    wait = pause
    battle = Self.sample()
    switch stage {
    case .start, .moving, .aiming:
      break
    case .planned, .acted:
      battle.playPlainly(turns: 4)
    case .middle, .danger:
      battle.playPlainly(turns: 6)
    case .end:
      battle.playPlainly()
    }
    foesAct()
    stage.setUp(self)
  }

  /// Waits for `time`, really.
  nonisolated static func sleep(
    _ time: Duration
  ) async {
    _ = try? await Task.sleep(for: time)
  }

  /// Gerald and Oswin against Ashka and
  /// Kestrel-9.
  private static func sample() -> Battle {
    Battle(
      party: [.gerald, .oswin],
      foes: [.ashka, .kestrel]
    )
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

  /// What the picked skill would do to
  /// `foe`, from the planned spot, a line
  /// each; none until one is picked, or if
  /// `foe` is down.
  func preview(of foe: Int) -> [String] {
    guard let turn = plan(on: foe) else {
      return []
    }
    do {
      return try battle.forecast(turn)
        .lines(for: foe, in: battle)
    } catch .outOfReach {
      return [
        String(localized: "Out of reach"),
      ]
    } catch {
      return []
    }
  }

  /// Whether the picked skill, from the
  /// planned spot, reaches `foe`.
  func inReach(_ foe: Int) -> Bool {
    let forecast = plan(on: foe).flatMap {
      try? battle.forecast($0)
    }
    return forecast?.strike != nil
  }

  /// The turn order once this turn ends
  /// (with the picked skill on the first
  /// foe it reaches, if any), showing
  /// where the unit on turn lands; none
  /// until something is planned or done,
  /// or if it would end the battle.
  var queueAfter: [BattleUnit] {
    guard chosen != nil || ghost != nil
      || battle.hasActed
    else { return [] }
    let turns = units(.foes)
      .compactMap { plan(on: $0.id) }
      + [Turn(before: ghost)]
    let forecasts = turns.compactMap {
      try? battle.forecast($0)
    }
    let after = forecasts.first {
      $0.strike != nil
    } ?? forecasts.last
    return (after?.queue ?? []).map {
      battle.units[$0]
    }
  }

  /// The rest of the turn using the picked
  /// skill on `foe` from the planned spot;
  /// none until a skill is picked.
  private func plan(on foe: Int) -> Turn? {
    chosen.map {
      Turn(
        before: ghost,
        action: Action($0, on: foe)
      )
    }
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
  /// skill picked, a foe there is its
  /// target; the unit on turn itself clears
  /// the plan; anywhere else it can reach
  /// is planned.
  func tap(_ point: Point) {
    guard let actor else {
      return
    }
    if chosen != nil,
      let foe = units(.foes).first(where: {
        $0.isUp && Self.covers($0, point)
      }) {
      target(foe.id)
    } else if Self.covers(actor, point) {
      ghost = nil
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
    battle = Self.sample()
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
