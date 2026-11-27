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

  /// Choose who fights: Ashka joins the
  /// party, Gerald leaves, then the turn
  /// order (always in view) has Oswin and
  /// Ashka against Ashka and Kestrel-9.
  @MainActor
  func testChoosesWhoFights() {
    let app = App.start()
    app.buttons["Choose who fights"].tap()
    let ashka = app.buttons["add-party-1"]
    XCTAssertTrue(ashka.appears())
    ashka.tap()
    app.buttons["data-party-0"].tap()
    app.buttons["start-fight"].tap()
    let first = app.text("data-order-0")
    XCTAssertTrue(first.appears())
    let names = (0..<4).map {
      app.text("data-order-\($0)").label
    }
    let want = [
      "Ashka", "Ashka", "Kestrel-9", "Oswin",
    ]
    XCTAssertEqual(names.sorted(), want)
  }
}
