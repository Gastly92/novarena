@testable import RuleSteward
import XCTest

final class BodyguardTests: XCTestCase {
  /// Gerald (id 0) and a bodyguard (id 1)
  /// against two fast foes who act first,
  /// in the same round.
  private func battle() -> Battle {
    Battle(
      party: [
        Fixtures.unit("Gerald"),
        Fixtures.unit(
          "Guard", passives: [.bodyguard]
        ),
      ],
      foes: [
        Fixtures.unit("X", speed: 200),
        Fixtures.unit("Y", speed: 190),
      ]
    )
  }

  func testTakesFirstHitEachRound() throws {
    var fight = battle()
    try fight.act(0, on: 0)
    try fight.act(0, on: 0)
    XCTAssertEqual(
      Fixtures.lines(fight),
      [
        "[50] X",
        "  X: Poke → Gerald",
        "  Guard guards Gerald",
        "  Guard's Hide -9 (991)",
        "[52] Y",
        "  Y: Poke → Gerald",
        "  Gerald's Hide -9 (991)",
      ]
    )
  }

  func testDoesNotGuardItself() throws {
    var fight = battle()
    try fight.act(0, on: 1)
    XCTAssertFalse(
      Fixtures.lines(fight).contains {
        $0.contains("guards")
      }
    )
  }
}
