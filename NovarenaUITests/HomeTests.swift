import XCTest

final class HomeTests: XCTestCase {
  @MainActor
  func testShowsTheName() {
    let app = App.start()
    let name = app.text("Novarena")
    XCTAssertTrue(name.appears())
  }

  @MainActor
  func testOpensTheBattle() {
    let app = App.start()
    app.buttons["Fight"].tap()
    let bar = app.navigationBars["Battle"]
    XCTAssertTrue(bar.appears())
  }
}
