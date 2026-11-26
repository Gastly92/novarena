import XCTest

final class BattleTests: XCTestCase {
  /// Pick Sword Cut, tap Ashka: she's out
  /// of reach, so Gerald walks toward her,
  /// and the foes act: Kestrel-9's Arc Beam
  /// takes him from 300 to 241. The log is
  /// at the bottom, off screen, so its rows
  /// don't exist to check; `FightTests`
  /// checks the log instead.
  @MainActor
  func testPlaysATurn() {
    let app = App.start(screen: .battle)
    app.buttons["data-ability-0"].tap()
    app.buttons["data-foe-2"].tap()
    let gerald = app.text(
      "Health 241 of 300"
    )
    XCTAssertTrue(gerald.appears())
  }

  @MainActor
  func testFightsAgain() {
    let app = App.start(screen: .battleEnd)
    app.buttons["Fight again"].tap()
    let first = app.buttons["data-ability-0"]
    XCTAssertTrue(first.appears())
  }
}
