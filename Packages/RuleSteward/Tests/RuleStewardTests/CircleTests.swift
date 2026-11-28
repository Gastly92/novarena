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

  /// From B's west side, east heads into
  /// B; west and north don't; away from B
  /// nothing does.
  func testHeads() {
    let east = Point(x: 521, y: 400)
    let west = Point(x: 519, y: 400)
    let north = Point(x: 520, y: 399)
    XCTAssertTrue(
      battle.heads(from: side, into: east)
    )
    XCTAssertFalse(
      battle.heads(from: side, into: west)
    )
    XCTAssertFalse(
      battle.heads(from: side, into: north)
    )
    let free = Point(x: 450, y: 400)
    XCTAssertFalse(
      battle.heads(from: free, into: side)
    )
  }

  /// From B's west side, clockwise on
  /// screen goes up, the other way down,
  /// each kept just clear of B.
  func testCircles() throws {
    let other = battle.units[1]
    let upward = try XCTUnwrap(
      battle.circle(
        from: side, clockwise: true, by: 10
      )
    )
    XCTAssertEqual(
      upward, Point(x: 520, y: 390)
    )
    let down = battle.circle(
      from: side, clockwise: false, by: 10
    )
    XCTAssertEqual(
      down, Point(x: 520, y: 410)
    )
    XCTAssertGreaterThanOrEqual(
      upward.squared(to: other.place),
      80 * 80
    )
  }

  /// Touching nobody, from B's middle,
  /// out of range, or with the battle
  /// over, there's no circling.
  func testNowhere() {
    let middle = battle.units[1].place
    let free = Point(x: 450, y: 400)
    for spot in [free, middle] {
      XCTAssertNil(
        battle.circle(
          from: spot, clockwise: true, by: 10
        )
      )
    }
    let short = Battle(
      party: [Fixtures.unit("A", move: 120)],
      foes: [Fixtures.unit("B", speed: 50)],
      places: [
        Point(x: 400, y: 400),
        Point(x: 600, y: 400),
      ]
    )
    XCTAssertNil(
      short.circle(
        from: side, clockwise: true, by: 10
      )
    )
    var over = battle
    over.playPlainly()
    XCTAssertNil(over.touching(side))
    XCTAssertNil(
      over.circle(
        from: side, clockwise: true, by: 10
      )
    )
  }

  /// B with C on top of it, touching: going
  /// clockwise up B's west side, the spot
  /// passes where B and C meet and goes on
  /// up C's, never overlapping either.
  func testCirclesAGroup() throws {
    let group = Battle(
      party: [Fixtures.unit("A")],
      foes: [
        Fixtures.unit("B", speed: 50),
        Fixtures.unit("C", speed: 50),
      ],
      places: [
        Point(x: 400, y: 400),
        Point(x: 600, y: 400),
        Point(x: 600, y: 320),
      ]
    )
    var spot = side
    for _ in 0..<12 {
      spot = try XCTUnwrap(
        group.circle(
          from: spot, clockwise: true, by: 10
        )
      )
      let mover = group.units[0]
      XCTAssertNil(
        group.blocker(of: mover, at: spot)
      )
    }
    XCTAssertEqual(
      group.touching(spot)?.id, 2
    )
    XCTAssertLessThan(spot.y, 320)
  }
}
