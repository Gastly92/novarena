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
  /// party, Gerald leaves, then the fight
  /// has Oswin and Ashka (the second row
  /// of the party, a button, reads her
  /// name first).
  @MainActor
  func testChoosesWhoFights() {
    let app = App.start()
    app.buttons["Choose who fights"].tap()
    let ashka = app.buttons["add-party-1"]
    XCTAssertTrue(ashka.appears())
    ashka.tap()
    app.buttons["data-party-0"].tap()
    app.buttons["Fight"].tap()
    let row = app.buttons["data-unit-1"]
    XCTAssertTrue(row.appears())
    let label = row.label
    XCTAssertTrue(label.hasPrefix("Ashka"))
  }
}
