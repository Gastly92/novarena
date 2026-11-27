@testable import RuleSteward
import XCTest

/// A turn taken a step at a time.
final class StepTests: XCTestCase {
  /// A (party, Move 300) at (100, 400) and
  /// B (a slower foe) at (700, 400); A's
  /// turn.
  private func duel() -> Battle {
    Battle(
      party: [
        Fixtures.unit(
          "A",
          abilities: [
            Fixtures.poke,
            Ability(
              "Jab",
              power: 10,
              delivery: .physical,
              weight: .heavy,
              reach: Fixtures.far
            ),
          ]
        ),
      ],
      foes: [Fixtures.unit("B", speed: 50)],
      places: [
        Point(x: 100, y: 400),
        Point(x: 700, y: 400),
      ]
    )
  }

  /// The whole Move, in as many legs as it
  /// likes, before and after acting; each
  /// leg costs its length, rounded up.
  func testMovesInLegs() throws {
    var battle = duel()
    XCTAssertEqual(battle.moveLeft, 300)
    let corner = Point(x: 103, y: 404)
    XCTAssertEqual(
      battle.cost(to: corner), 5
    )
    try battle.move(to: corner)
    try battle.move(
      to: Point(x: 200, y: 404)
    )
    XCTAssertEqual(battle.moveLeft, 198)
    XCTAssertEqual(battle.tick, 100)
    try battle.use(0, on: 1)
    XCTAssertTrue(battle.hasActed)
    try battle.move(
      to: Point(x: 398, y: 404)
    )
    XCTAssertEqual(battle.moveLeft, 0)
    Fixtures.expect(.tooFar) {
      try battle.move(
        to: Point(x: 399, y: 404)
      )
    }
    try battle.endTurn()
    XCTAssertFalse(battle.hasActed)
    XCTAssertEqual(
      Fixtures.lines(battle).prefix(6),
      [
        "[100] A",
        "  A moves to (103, 404)",
        "  A moves to (200, 404)",
        "  A: Poke → B",
        "  B -9 (991)",
        "  A moves to (398, 404)",
      ]
    )
  }

  /// One action a turn, whose weight sets
  /// the wait when the turn ends.
  func testOneActionATurn() throws {
    var battle = duel()
    try battle.use(1, on: 1)
    XCTAssertFalse(battle.canUse(0))
    Fixtures.expect(.acted) {
      try battle.use(0, on: 1)
    }
    try battle.endTurn()
    XCTAssertEqual(
      battle.units[0].nextTurn, 250
    )
  }

  /// A step that fails changes nothing: the
  /// turn hasn't begun.
  func testFailedStepsChangeNothing() {
    var battle = duel()
    Fixtures.expect(.tooFar) {
      try battle.move(
        to: Point(x: 500, y: 400)
      )
    }
    Fixtures.expect(.badTarget) {
      try battle.use(1, on: 0)
    }
    XCTAssertTrue(battle.log.isEmpty)
    XCTAssertEqual(battle.tick, 0)
  }

  /// Nothing is on turn once it's over.
  func testNothingOnceOver() {
    var battle = Battle(
      party: [Fixtures.unit("A")],
      foes: [Fixtures.unit("B", health: 1)]
    )
    battle.playPlainly()
    XCTAssertEqual(battle.moveLeft, 0)
    XCTAssertEqual(
      battle.cost(to: Point(x: 0, y: 0)), 0
    )
    Fixtures.expect(.over) {
      try battle.endTurn()
    }
  }
}
