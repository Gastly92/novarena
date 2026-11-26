@testable import Novarena
import RuleSteward
import XCTest

/// Arena spots to screen points and back.
final class ArenaMapTests: XCTestCase {
  /// The open arena, 1200 cm, drawn 600
  /// points wide: half a point a
  /// centimetre.
  private let map = ArenaMap(
    .open, width: 600
  )

  func testLocation() {
    XCTAssertEqual(
      map.location(
        of: Point(x: 100, y: 200)
      ),
      CGPoint(x: 50, y: 100)
    )
    XCTAssertEqual(map.points(50), 25)
  }

  /// A tap rounds to the nearest
  /// centimetre.
  func testSpot() {
    let tap = CGPoint(x: 50.4, y: 100.6)
    XCTAssertEqual(
      map.spot(at: tap),
      Point(x: 101, y: 201)
    )
  }

  func testRatio() {
    XCTAssertEqual(
      ArenaMap.ratio(.open), 1.5
    )
  }
}
