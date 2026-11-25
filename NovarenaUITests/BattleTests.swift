import XCTest

final class BattleTests: XCTestCase {
  /// Pick Sword Cut, tap Ashka: the log
  /// shows the hit, and the foes' turns.
  @MainActor
  func testPlaysATurn() {
    let app = App.start(screen: .battle)
    app.buttons["data-ability-0"].tap()
    app.buttons["data-foe-2"].tap()
    let hit = "Gerald: Sword Cut → Ashka"
    XCTAssertTrue(app.text(hit).appears())
    let next = app.text("[111] Ashka")
    XCTAssertTrue(next.exists)
  }

  @MainActor
  func testFightsAgain() {
    let app = App.start(screen: .battleEnd)
    app.buttons["Fight again"].tap()
    let first = app.buttons["data-ability-0"]
    XCTAssertTrue(first.appears())
  }
}
