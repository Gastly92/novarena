import XCTest

final class BattleTests: XCTestCase {
  /// Pick Sword Cut, tap Ashka: she's out
  /// of reach, so Gerald walks toward her,
  /// and the foes act until Oswin's turn,
  /// first in the turn order. The log is
  /// at the bottom, off screen, so its rows
  /// don't exist to check; `FightTests`
  /// checks the log instead.
  @MainActor
  func testPlaysATurn() {
    let app = App.start(screen: .battle)
    app.buttons["data-ability-0"].tap()
    app.buttons["data-foe-2"].tap()
    let first = app.text("data-order-0")
    XCTAssertEqual(first.label, "Oswin")
  }

  /// Tap the arena a little right of
  /// Gerald to pick a spot, then end the
  /// turn there: Oswin is next.
  @MainActor
  func testMovesAndEndsTheTurn() {
    let app = App.start(screen: .battle)
    app.text("data-token-0")
      .coordinate(
        withNormalizedOffset: CGVector(
          dx: 0.5, dy: 0.5
        )
      )
      .withOffset(CGVector(dx: 50, dy: 0))
      .tap()
    let end = app.buttons[
      "Move and end turn"
    ]
    XCTAssertTrue(end.appears())
    end.tap()
    let first = app.text("data-order-0")
    XCTAssertEqual(first.label, "Oswin")
  }

  @MainActor
  func testFightsAgain() {
    let app = App.start(screen: .battleEnd)
    app.buttons["Fight again"].tap()
    let first = app.buttons["data-ability-0"]
    XCTAssertTrue(first.appears())
  }
}
