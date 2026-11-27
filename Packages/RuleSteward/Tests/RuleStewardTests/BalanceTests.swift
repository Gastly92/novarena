import RuleSteward
import XCTest

/// The sample units, each against each
/// other one on one, with plain choices on
/// both sides: none should win every
/// fight, and every fight should be close,
/// so tactics decide them.
final class BalanceTests: XCTestCase {
  private let units: [Unit] = [
    .gerald, .ashka, .oswin, .kestrel,
  ]

  /// `first` against `second`: the winner,
  /// and what's left of its layers in
  /// percent.
  private func duel(
    _ first: Unit,
    _ second: Unit
  ) -> (winner: String, left: Int) {
    var battle = Battle(
      party: [first], foes: [second]
    )
    battle.playPlainly(turns: 600)
    let side = battle.winner ?? .foes
    let winner = battle.units.first {
      $0.side == side
    }
    let left = winner.map {
      $0.layers.reduce(0, +) * 100
        / $0.unit.layers.map(\.points)
          .reduce(0, +)
    } ?? 100
    return (winner?.unit.name ?? "", left)
  }

  func testEveryFightIsClose() {
    var wins: [String: Int] = [:]
    for (index, first) in units
      .enumerated() {
      for second in units
        .dropFirst(index + 1) {
        let one = duel(first, second)
        let other = duel(second, first)
        // Which side starts doesn't matter.
        XCTAssertEqual(
          one.winner, other.winner
        )
        XCTAssertLessThanOrEqual(
          one.left, 25
        )
        wins[one.winner, default: 0] += 1
      }
    }
    XCTAssertEqual(
      wins,
      [
        "Gerald": 2, "Oswin": 2,
        "Ashka": 1, "Kestrel-9": 1,
      ]
    )
  }

  /// The other side can win too.
  func testTheFoesCanWin() {
    var battle = Battle(
      party: [.gerald],
      foes: [.oswin]
    )
    battle.playPlainly(turns: 600)
    XCTAssertEqual(
      battle.log.last?.description,
      "The foes win"
    )
  }
}
