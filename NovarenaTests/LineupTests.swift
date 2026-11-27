@testable import Novarena
import RuleSteward
import XCTest

/// Picking who fights.
@MainActor
final class LineupTests: XCTestCase {
  /// It starts as the sample battle.
  func testStartsAsTheSample() {
    let lineup = Lineup()
    let party = lineup.picks(.party)
    XCTAssertEqual(party, [0, 2])
    let foes = lineup.picks(.foes)
    XCTAssertEqual(foes, [1, 3])
    XCTAssertTrue(lineup.isReady)
    let fight = lineup.fight()
    XCTAssertEqual(
      fight.units(.party).map(\.unit.name),
      ["Gerald", "Oswin"]
    )
  }

  /// Up to three a side, repeats allowed;
  /// a side with nobody isn't ready.
  func testAddsAndRemoves() {
    var lineup = Lineup(party: [4], foes: [])
    XCTAssertFalse(lineup.isReady)
    for _ in 0..<4 {
      lineup.add(1, to: .foes)
    }
    let foes = lineup.picks(.foes)
    XCTAssertEqual(foes, [1, 1, 1])
    XCTAssertFalse(lineup.hasRoom(.foes))
    XCTAssertTrue(lineup.hasRoom(.party))
    lineup.add(0, to: .party)
    let party = lineup.picks(.party)
    XCTAssertEqual(party, [4, 0])
    lineup.remove(at: 0, from: .party)
    lineup.remove(at: 2, from: .foes)
    XCTAssertEqual(
      lineup,
      Lineup(party: [0], foes: [1, 1])
    )
    XCTAssertTrue(lineup.isReady)
    let fight = lineup.fight()
    XCTAssertEqual(
      fight.units(.foes).map(\.unit.name),
      ["Ashka", "Ashka"]
    )
  }
}
