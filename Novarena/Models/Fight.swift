import Foundation
import Observation
import RuleSteward

/// A battle on screen: the player picks a
/// spot to move to, then an ability and a
/// foe in reach from there (or a foe out of
/// reach, to walk toward it); foes take
/// their plain choice
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
    /// The same, with Sword Cut picked and
    /// a foe still to tap.
    case aiming
    /// Gerald's second turn, with a spot
    /// picked that puts Kestrel-9 in Sword
    /// Cut's reach, but not Ashka.
    case planned
    /// Six turns in.
    case middle
    /// Played to the end.
    case end
  }

  private(set) var battle: Battle
  /// The ability picked for the unit on
  /// turn, waiting for a target.
  private(set) var chosen: Int?
  /// Where the unit on turn will move
  /// first, if it's picked one.
  private(set) var spot: Point?

  init(stage: Stage = .start) {
    battle = Self.sample()
    switch stage {
    case .start:
      break
    case .aiming:
      chosen = 0
    case .planned:
      battle.playPlainly(turns: 4)
    case .middle:
      battle.playPlainly(turns: 6)
    case .end:
      battle.playPlainly()
    }
    foesAct()
    if stage == .planned {
      chosen = 0
      spot = battle.approach(0, on: 3)?
        .before
    }
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

  /// What the picked ability would do to
  /// `foe`, a line each; none until one is
  /// picked, or if `foe` is down.
  func preview(of foe: Int) -> [String] {
    guard let turn = plan(on: foe) else {
      return []
    }
    do {
      return try battle.forecast(turn)
        .lines(for: foe, in: battle)
    } catch .outOfReach {
      let out = String(localized: """
        Out of reach from there
        """)
      return [out]
    } catch {
      return []
    }
  }

  /// Whether the picked ability, from the
  /// picked spot, reaches `foe`.
  func inReach(_ foe: Int) -> Bool {
    let forecast = plan(on: foe).flatMap {
      try? battle.forecast($0)
    }
    return forecast?.strike != nil
  }

  /// The turn order after the planned move
  /// (the picked ability on the first foe
  /// it reaches, or just the move), showing
  /// where the unit on turn lands; none
  /// until an ability or a spot is picked,
  /// or if it would end the battle.
  var queueAfter: [BattleUnit] {
    guard chosen != nil || spot != nil else {
      return []
    }
    let turns = units(.foes)
      .compactMap { plan(on: $0.id) }
      + [Turn(before: spot)]
    let forecasts = turns.compactMap {
      try? battle.forecast($0)
    }
    let planned = forecasts.first {
      $0.strike != nil
    } ?? forecasts.last
    return (planned?.queue ?? []).map {
      battle.units[$0]
    }
  }

  /// The turn using the picked ability on
  /// `foe` takes: from the picked spot, or
  /// walking toward it if none is picked;
  /// none until an ability is picked.
  private func plan(on foe: Int) -> Turn? {
    guard let chosen else {
      return nil
    }
    guard let spot else {
      return battle.approach(chosen, on: foe)
    }
    return Turn(
      before: spot,
      action: Action(chosen, on: foe)
    )
  }

  /// Picks the unit on turn's ability.
  func choose(_ ability: Int) {
    chosen = ability
  }

  /// A tap on the arena at `point`: with an
  /// ability picked, a foe there is its
  /// target; the unit on turn itself clears
  /// the spot; anywhere else it can move to
  /// becomes the spot.
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
      spot = nil
    } else if (try? battle.forecast(
      Turn(before: point)
    )) != nil {
      spot = point
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

  /// Uses the picked ability on `target`,
  /// then lets the foes act. Nothing
  /// happens if it can't be done.
  func target(_ target: Int) {
    guard let turn = plan(on: target),
      (try? battle.act(turn)) != nil
    else { return }
    nextTurn()
  }

  /// Moves to the picked spot, if any, and
  /// ends the turn there without acting.
  func endTurn() {
    try? battle.act(Turn(before: spot))
    nextTurn()
  }

  /// The same battle, from the start.
  func restart() {
    battle = Self.sample()
    chosen = nil
    spot = nil
    foesAct()
  }

  /// Clears the picks and lets the foes
  /// act.
  private func nextTurn() {
    chosen = nil
    spot = nil
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
