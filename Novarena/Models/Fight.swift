import Foundation
import Observation
import RuleSteward

/// A battle on screen: the player picks the
/// party's moves, and foes take their plain
/// choice (`Battle.plainChoice`) until it's
/// the party's turn again.
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
    /// Six turns in.
    case middle
    /// Played to the end.
    case end
  }

  private(set) var battle: Battle
  /// The ability picked for the unit on
  /// turn, waiting for a target.
  private(set) var chosen: Int?

  init(stage: Stage = .start) {
    battle = Self.sample()
    switch stage {
    case .start:
      break
    case .aiming:
      chosen = 0
    case .middle:
      battle.playPlainly(turns: 6)
    case .end:
      battle.playPlainly()
    }
    foesAct()
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

  /// Picks the unit on turn's ability.
  func choose(_ ability: Int) {
    chosen = ability
  }

  /// Uses the picked ability on `target`,
  /// then lets the foes act.
  func target(_ target: Int) {
    guard let ability = chosen else {
      return
    }
    chosen = nil
    try? battle.act(ability, on: target)
    foesAct()
  }

  /// The same battle, from the start.
  func restart() {
    battle = Self.sample()
    chosen = nil
    foesAct()
  }

  /// Foes' turns, until the party's (or
  /// the end).
  private func foesAct() {
    while actor?.side == .foes,
      let (ability, target)
        = battle.plainChoice {
      try? battle.act(ability, on: target)
    }
  }
}
