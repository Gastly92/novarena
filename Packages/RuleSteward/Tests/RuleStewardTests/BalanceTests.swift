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
  private let units = Unit.all

  /// Every team of `size`, as indices into
  /// `units`, each in order so no team
  /// appears twice.
  private func teams(
    _ size: Int,
    from first: Int = 0
  ) -> [[Int]] {
    guard size > 0 else {
      return [[]]
    }
    let rest = first..<units.count
    return rest.flatMap { index in
      teams(size - 1, from: index).map {
        [index] + $0
      }
    }
  }

  /// Each unit's share of wins, in
  /// percent, over every battle of teams
  /// of `size`.
  private func rates(_ size: Int) -> [Int] {
    var wins = [Int](
      repeating: 0, count: units.count
    )
    var fought = wins
    let all = teams(size)
    for party in all {
      for foes in all where foes != party {
        var battle = Battle(
          party: party.map { units[$0] },
          foes: foes.map { units[$0] }
        )
        battle.playPlainly(turns: 2000)
        let winner = battle.winner
        XCTAssertNotNil(winner)
        for (side, team) in [
          (Side.party, party), (.foes, foes),
        ] {
          for index in team {
            fought[index] += 1
            wins[index] += winner == side
              ? 1 : 0
          }
        }
      }
    }
    return zip(wins, fought).map {
      $0 * 100 / $1
    }
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
