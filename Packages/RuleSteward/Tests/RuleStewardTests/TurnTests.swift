@testable import RuleSteward
import XCTest

final class TurnTests: XCTestCase {
  private func duel() -> Battle {
    Battle(
      party: [Fixtures.unit("A"), .gerald],
      foes: [Fixtures.unit("B", speed: 50)]
    )
  }

  func testRejectsBadChoices() {
    var battle = duel()
    Fixtures.expect(.noAbility) {
      try battle.act(5, on: 2)
    }
    for target in [1, 9, -1] {
      Fixtures.expect(.badTarget) {
        try battle.act(0, on: target)
      }
    }
    XCTAssertTrue(battle.log.isEmpty)
    XCTAssertEqual(battle.tick, 0)
  }

  /// Gerald's stamina (100, +25 a turn)
  /// pays for five Lunges (40 each), not a
  /// sixth.
  func testAbilitiesCostResource() throws {
    var battle = Battle(
      party: [.gerald],
      foes: [Fixtures.unit("Wall", speed: 1)]
    )
    for _ in 0..<5 {
      try battle.act(1, on: 1)
    }
    XCTAssertEqual(battle.units[0].pool, 0)
    let before = battle.log.count
    Fixtures.expect(.cantAfford) {
      try battle.act(1, on: 1)
    }
    XCTAssertEqual(battle.log.count, before)
    XCTAssertEqual(battle.units[0].pool, 0)
    try battle.act(0, on: 1)
    XCTAssertEqual(battle.units[0].pool, 25)
  }

  func testDownedUnitsLeaveTheFight()
    throws {
    let strong = Ability(
      "Smash",
      power: 2000,
      delivery: .physical
    )
    var battle = Battle(
      party: [
        Fixtures.unit(
          "A", abilities: [strong]
        ),
      ],
      foes: [
        Fixtures.unit("B", speed: 50),
        Fixtures.unit("C", speed: 50),
      ]
    )
    XCTAssertNil(battle.winner)
    try battle.act(0, on: 1)
    XCTAssertFalse(battle.units[1].isUp)
    Fixtures.expect(.badTarget) {
      try battle.act(0, on: 1)
    }
    try battle.act(0, on: 2)
    XCTAssertEqual(battle.winner, .party)
    XCTAssertNil(battle.next)
    XCTAssertNil(battle.plainChoice)
    XCTAssertEqual(
      battle.log.last?.description,
      "The party wins"
    )
    Fixtures.expect(.over) {
      try battle.act(0, on: 1)
    }
  }

  func testImmuneHitsDoNothing() throws {
    var battle = Battle(
      party: [.ashka],
      foes: [
        Fixtures.unit(
          "Torch",
          speed: 200,
          abilities: [
            Ability(
              "Flame",
              power: 50,
              delivery: .special,
              element: .fire
            ),
          ]
        ),
      ]
    )
    try battle.act(0, on: 0)
    XCTAssertEqual(
      Fixtures.lines(battle).last,
      "  Ashka is immune"
    )
    let health = battle.units[0].health
    XCTAssertEqual(health, 320)
  }

  /// Plain choices stop once there's a
  /// winner, however many turns are left.
  func testPlayPlainlyStopsAtTheEnd() {
    var battle = Battle(
      party: [.gerald],
      foes: [Fixtures.unit("B", health: 10)]
    )
    battle.playPlainly(turns: 50)
    XCTAssertEqual(battle.winner, .party)
    // B's turn (3 lines), then Gerald's
    // (5, with the down and the win).
    XCTAssertEqual(battle.log.count, 8)
  }

  /// …and also when the turns run out.
  func testPlayPlainlyStopsAfterTurns() {
    var battle = Battle(
      party: [.gerald],
      foes: [.oswin]
    )
    battle.playPlainly(turns: 1)
    XCTAssertNil(battle.winner)
    XCTAssertEqual(battle.log.count, 3)
  }
}
