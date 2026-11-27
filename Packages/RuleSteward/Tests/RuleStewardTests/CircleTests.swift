@testable import RuleSteward
import XCTest

/// Circling round a unit the planned spot
/// touches.
final class CircleTests: XCTestCase {
  /// A (medium) at (400, 400), B (medium)
  /// at (600, 400): touching at 80 cm.
  private let battle = Battle(
    party: [Fixtures.unit("A")],
    foes: [Fixtures.unit("B", speed: 50)],
    places: [
      Point(x: 400, y: 400),
      Point(x: 600, y: 400),
    ]
  )

  private let side = Point(x: 520, y: 400)

  /// Within 2 cm of B's edge, A touches B.
  func testTouching() {
    XCTAssertEqual(
      battle.touching(side)?.id, 1
    )
    XCTAssertNil(
      battle.touching(Point(x: 500, y: 400))
    )
  }

  /// From B's west side, clockwise on
  /// screen goes up, the other way down,
  /// each kept just clear of B.
  func testCircles() throws {
    let other = battle.units[1]
    let upward = try XCTUnwrap(
      battle.circle(
        from: side,
        round: other,
        clockwise: true,
        by: 10
      )
    )
    XCTAssertEqual(
      upward, Point(x: 520, y: 390)
    )
    let down = battle.circle(
      from: side,
      round: other,
      clockwise: false,
      by: 10
    )
    XCTAssertEqual(
      down, Point(x: 520, y: 410)
    )
    XCTAssertGreaterThanOrEqual(
      upward.squared(to: other.place),
      80 * 80
    )
  }

  /// From B's middle, or with the battle
  /// over, there's no circling.
  func testNowhere() {
    let other = battle.units[1]
    XCTAssertNil(
      battle.circle(
        from: other.place,
        round: other,
        clockwise: true,
        by: 10
      )
    )
    var over = battle
    over.playPlainly()
    XCTAssertNil(over.touching(side))
    XCTAssertNil(
      over.circle(
        from: side,
        round: other,
        clockwise: true,
        by: 10
      )
    )
  }
}
