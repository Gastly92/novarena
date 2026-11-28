@testable import RuleSteward
import XCTest

/// Standing off: keeping a foe at the
/// edge of an ability's reach.
final class StandoffTests: XCTestCase {
  /// A shot that reaches 200 cm.
  private static let shot = Fixtures.hit(
    "Shot", power: 10, reach: .ranged(200)
  )

  /// A (shot, poke and a 300 cm move) at
  /// (400, 400); B (medium, 40 cm) at
  /// `foe`.
  private func battle(foe: Point) -> Battle {
    Battle(
      party: [
        Fixtures.unit(
          "A",
          abilities: [
            Fixtures.hit(
              "Jab",
              power: 10,
              reach: .melee(10)
            ),
            Self.shot,
          ]
        ),
      ],
      foes: [Fixtures.unit("B", speed: 50)],
      places: [Point(x: 400, y: 400), foe]
    )
  }

  /// Near B, A backs away to the edge of
  /// the shot (240 cm apart, less 2);
  /// far off, it closes in toward it, as
  /// far as its move goes.
  func testBacksAwayOrCloses() {
    let near = battle(
      foe: Point(x: 500, y: 400)
    )
    XCTAssertEqual(
      near.standoff(on: 1, with: 1),
      Point(x: 262, y: 400)
    )
    let far = battle(
      foe: Point(x: 1000, y: 400)
    )
    XCTAssertEqual(
      far.standoff(on: 1, with: 1),
      Point(x: 700, y: 400)
    )
  }

  /// With no ability picked, the longest
  /// reach is kept: the shot's, not the
  /// jab's.
  func testLongestReach() {
    let near = battle(
      foe: Point(x: 500, y: 400)
    )
    XCTAssertEqual(
      near.standoff(on: 1),
      near.standoff(on: 1, with: 1)
    )
  }

  /// Not on an ally, nor with an ability it
  /// lacks, nor on a unit it doesn't know,
  /// nor standing on one spot.
  func testNone() {
    let near = battle(
      foe: Point(x: 500, y: 400)
    )
    XCTAssertNil(near.standoff(on: 0))
    XCTAssertNil(
      near.standoff(on: 1, with: 9)
    )
    XCTAssertNil(near.standoff(on: 5))
    let same = battle(
      foe: Point(x: 400, y: 400)
    )
    XCTAssertNil(same.standoff(on: 1))
    var over = near
    over.playPlainly()
    XCTAssertNil(over.standoff(on: 1))
  }
}
