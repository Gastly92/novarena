@testable import RuleSteward
import XCTest

/// Orbiting along the edge of the range.
final class OrbitTests: XCTestCase {
  /// A (300 cm of movement) at (400, 400),
  /// B far off.
  private let battle = Battle(
    party: [Fixtures.unit("A")],
    foes: [Fixtures.unit("B", speed: 50)],
    places: [
      Point(x: 400, y: 400),
      Point(x: 1100, y: 700),
    ]
  )

  /// From the east edge, clockwise on
  /// screen goes down, kept on the edge.
  func testOrbits() throws {
    let edge = Point(x: 700, y: 400)
    XCTAssertTrue(battle.atEdge(edge))
    XCTAssertFalse(
      battle.atEdge(Point(x: 500, y: 400))
    )
    let spot = try XCTUnwrap(
      battle.orbit(
        from: edge, clockwise: true, by: 10
      )
    )
    XCTAssertGreaterThan(spot.y, 400)
    XCTAssertLessThanOrEqual(
      battle.cost(to: spot), 300
    )
  }

  /// From the unit's own spot, or once
  /// it's over, nothing; a unit that can't
  /// move has no edge.
  func testNowhere() {
    XCTAssertNil(
      battle.orbit(
        from: Point(x: 400, y: 400),
        clockwise: true,
        by: 10
      )
    )
    var over = battle
    over.playPlainly()
    XCTAssertNil(
      over.orbit(
        from: Point(x: 700, y: 400),
        clockwise: false,
        by: 10
      )
    )
    XCTAssertFalse(
      over.atEdge(Point(x: 700, y: 400))
    )
  }
}
