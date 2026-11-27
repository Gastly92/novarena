@testable import RuleSteward
import XCTest

/// Planning a move that slides along what
/// stops it: the edge of the range, the
/// arena's walls, and other units.
final class SlideTests: XCTestCase {
  /// A (medium, 300 cm of movement) at
  /// (400, 400), B (medium) at `foe`.
  private func battle(
    foe: Point = Point(x: 1000, y: 400)
  ) -> Battle {
    Battle(
      party: [Fixtures.unit("A")],
      foes: [Fixtures.unit("B", speed: 50)],
      places: [Point(x: 400, y: 400), foe]
    )
  }

  /// Past the edge of the range, the spot
  /// comes back onto it on the way there:
  /// a nudge up from (700, 400) slides
  /// along the curve, a little left.
  func testSlidesAlongTheRange() {
    let fight = battle()
    let spot = fight.reachable(
      toward: Point(x: 700, y: 390)
    )
    XCTAssertEqual(
      spot, Point(x: 699, y: 391)
    )
  }

  /// Into someone, the spot is pushed out
  /// to just touch them (80 cm between
  /// middles), on the side it came from.
  func testSlidesAroundAUnit() throws {
    let fight = battle(
      foe: Point(x: 600, y: 400)
    )
    let spot = try XCTUnwrap(
      fight.reachable(
        toward: Point(x: 540, y: 410)
      )
    )
    XCTAssertEqual(spot.x, 521)
    XCTAssertEqual(spot.y, 414)
    let foe = Point(x: 600, y: 400)
    XCTAssertGreaterThanOrEqual(
      spot.squared(to: foe), 80 * 80
    )
  }

  /// Past a wall, the spot stays inside:
  /// a medium unit's middle 40 cm from it.
  func testStaysInTheArena() {
    let fight = Battle(
      party: [Fixtures.unit("A")],
      foes: [Fixtures.unit("B", speed: 50)],
      places: [
        Point(x: 100, y: 400),
        Point(x: 1000, y: 400),
      ]
    )
    XCTAssertEqual(
      fight.reachable(
        toward: Point(x: 10, y: 400)
      ),
      Point(x: 40, y: 400)
    )
  }

  /// Wedged between the edge of the range
  /// and a unit on it (pushing out of B
  /// leaves the range, pulling back lands
  /// in B), nothing is planned.
  func testWedged() {
    let fight = battle(
      foe: Point(x: 640, y: 400)
    )
    XCTAssertNil(
      fight.reachable(
        toward: Point(x: 680, y: 380)
      )
    )
  }

  /// Rounding outward: away from zero
  /// either way.
  func testOutward() {
    XCTAssertEqual(
      Geometry.outward(7, over: 2), 4
    )
    XCTAssertEqual(
      Geometry.outward(-7, over: 2), -4
    )
  }
}
