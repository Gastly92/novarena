@testable import RuleSteward
import XCTest

/// What each side has seen of the other,
/// and the danger zone it gives.
final class KnowledgeTests: XCTestCase {
  /// Nothing shown at the start; then the
  /// furthest move in a turn (legs added
  /// up) and the abilities used.
  func testRecordsWhatItShows() throws {
    var battle = Battle(
      party: [Fixtures.unit("A")],
      foes: [Fixtures.unit("B", speed: 50)],
      places: [
        Point(x: 100, y: 400),
        Point(x: 1100, y: 400),
      ]
    )
    XCTAssertNil(battle.danger(from: 0))
    for x in [200, 250] {
      try battle.move(
        to: Point(x: x, y: 400)
      )
    }
    try battle.use(0, on: 1)
    try battle.endTurn()
    let unit = battle.units[0]
    XCTAssertEqual(unit.furthest, 150)
    XCTAssertEqual(unit.shown, [0])
    // 150 moved, plus Poke's reach.
    XCTAssertEqual(
      battle.danger(from: 0), 10_150
    )
    XCTAssertNil(battle.danger(from: 1))
  }

  /// A unit that's down is no danger.
  func testDownIsSafe() throws {
    var battle = Battle(
      party: [Fixtures.unit("A")],
      foes: [Fixtures.unit("B", hide: 0)],
      places: Fixtures.together(2)
    )
    try battle.act(0, on: 1)
    XCTAssertNil(battle.danger(from: 1))
  }
}
