@testable import RuleSteward
import XCTest

/// Distances, sizes and reach, in whole
/// numbers.
final class GeometryTests: XCTestCase {
  func testRoots() {
    XCTAssertEqual(Geometry.root(0), 0)
    XCTAssertEqual(Geometry.root(15), 3)
    XCTAssertEqual(Geometry.root(16), 4)
    XCTAssertEqual(Geometry.rootUp(15), 4)
    XCTAssertEqual(Geometry.rootUp(16), 4)
  }

  /// 3 + 4 is 7: within 7, not within 6,
  /// with no square roots taken.
  func testLegsAddUpExactly() {
    XCTAssertTrue(
      Geometry.legs(9, 16, within: 7)
    )
    XCTAssertFalse(
      Geometry.legs(9, 16, within: 6)
    )
    XCTAssertFalse(
      Geometry.legs(100, 0, within: 6)
    )
  }

  /// Never further than asked, and never
  /// past the goal.
  func testToward() {
    let start = Point(x: 0, y: 0)
    let goal = Point(x: 300, y: 400)
    let step = start.toward(goal, by: 100)
    XCTAssertEqual(step, Point(x: 60, y: 80))
    XCTAssertLessThanOrEqual(
      start.squared(to: step), 100 * 100
    )
    XCTAssertEqual(
      start.toward(goal, by: 600), goal
    )
    XCTAssertEqual(
      goal.description, "(300, 400)"
    )
  }

  func testSizes() {
    let radii = [
      Size.small, .medium, .large, .huge,
    ].map(\.radius)
    XCTAssertEqual(radii, [25, 40, 70, 120])
  }

  /// Melee reaches from edge to edge;
  /// ranged from the middle to the
  /// target's edge.
  func testReachLimits() {
    XCTAssertEqual(
      Reach.melee(50).limit(
        from: 25, to: 70
      ),
      145
    )
    XCTAssertEqual(
      Reach.ranged(500).limit(
        from: 25, to: 70
      ),
      570
    )
  }
}
