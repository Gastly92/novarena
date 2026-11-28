@testable import Novarena
import XCTest

/// The move pad's arrows, and how a held
/// one speeds up.
final class NudgeTests: XCTestCase {
  func testOffsets() {
    let offsets = Nudge.allCases.map {
      [$0.offset.x, $0.offset.y]
    }
    XCTAssertEqual(
      offsets,
      [
        [0, -1], [-1, 0], [1, 0], [0, 1],
        [0, 0], [0, 0],
      ]
    )
  }

  /// 1 cm for the first ticks, then
  /// smoothly more, up to 20.
  func testSteps() {
    let steps = [0, 6, 7, 20, 28, 100]
      .map(Nudge.step)
    XCTAssertEqual(
      steps, [1, 1, 2, 11, 20, 20]
    )
  }

  /// A pause after the first nudge, so a
  /// tap moves one step (shorter for
  /// circling); then quick repeats.
  func testDelays() {
    let first = Nudge.east.delay(after: 0)
    let next = Nudge.east.delay(after: 1)
    let circling = Nudge.clockwise
    XCTAssertEqual(
      circling.delay(after: 0),
      .milliseconds(150)
    )
    XCTAssertEqual(
      circling.delay(after: 1),
      .milliseconds(30)
    )
    XCTAssertEqual(first, .milliseconds(400))
    XCTAssertEqual(next, .milliseconds(30))
  }
}
