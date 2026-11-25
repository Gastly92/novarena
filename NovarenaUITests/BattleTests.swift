import XCTest

final class BattleTests: XCTestCase {
  /// Pick Sword Cut, tap Ashka: she drops
  /// from 320 to 276 (60 × 130 ÷ 160 = 48,
  /// at 93% intensity 44). The log is at
  /// the bottom, off screen, so its rows
  /// don't exist to check; `FightTests`
  /// checks the log instead.
  @MainActor
  func testPlaysATurn() {
    let app = App.start(screen: .battle)
    app.buttons["data-ability-0"].tap()
    app.buttons["data-foe-2"].tap()
    let ashka = app.text("Health 276 of 320")
    XCTAssertTrue(ashka.appears())
  }

  @MainActor
  func testFightsAgain() {
    let app = App.start(screen: .battleEnd)
    app.buttons["Fight again"].tap()
    let first = app.buttons["data-ability-0"]
    XCTAssertTrue(first.appears())
  }
}
