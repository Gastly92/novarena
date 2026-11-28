import RuleSteward
import XCTest

/// Every unit in every team of one to
/// three (a unit can appear more than
/// once), each team against every other of
/// its size, both ways round, with plain
/// choices on both sides. No unit should be
/// good or bad: each should win about half
/// the battles it's in, at every size.
final class BalanceTests: XCTestCase {
  private let simulator = Simulator(
    units: Unit.all
  )

  /// Each unit's share of wins, in
  /// percent, over every battle of teams
  /// of `size`; every battle has a winner.
  private func rates(_ size: Int) -> [Int] {
    let result = simulator.run(size: size)
    XCTAssertEqual(result.undecided, 0)
    return result.rates
  }

  /// One on one: each wins 33% to 66% of
  /// its fights.
  func testOneOnOne() {
    for rate in rates(1) {
      XCTAssertTrue((33...66).contains(rate))
    }
  }

  /// In teams of two and three, each wins
  /// 40% to 60% of the battles it's in.
  func testTeams() {
    for size in 2...3 {
      for rate in rates(size) {
        XCTAssertTrue(
          (40...60).contains(rate)
        )
      }
    }
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
