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
  /// party and Gerald the foes, Gerald
  /// leaves the party, then the turn order
  /// (always in view) has Oswin and Ashka
  /// against Ashka, Kestrel-9 and Gerald.
  @MainActor
  func testChoosesWhoFights() {
    let app = App.start()
    app.buttons["Choose who fights"].tap()
    let ashka = app.buttons["add-party-1"]
    XCTAssertTrue(ashka.appears())
    ashka.tap()
    app.buttons["add-foes-0"].tap()
    app.buttons["data-party-0"].tap()
    app.buttons["start-fight"].tap()
    let first = app.text("data-order-0")
    XCTAssertTrue(first.appears())
    let names = (0..<5).map {
      app.text("data-order-\($0)").label
    }
    let want = [
      "Ashka", "Ashka", "Gerald",
      "Kestrel-9", "Oswin",
    ]
    XCTAssertEqual(names.sorted(), want)
  }

  /// Settings opens from home; turns
  /// ending by themselves is on, and a tap
  /// on its switch turns it off.
  @MainActor
  func testOpensSettings() {
    let app = App.start()
    app.buttons["Settings"].tap()
    let ends = app.switches[
      "End turns by themselves"
    ]
    XCTAssertTrue(ends.appears())
    let shown = ends.value as? String
    XCTAssertEqual(shown, "1")
    let right = CGVector(dx: 0.95, dy: 0.5)
    let knob = ends.coordinate(
      withNormalizedOffset: right
    )
    knob.tap()
    let off = ends.value as? String
    XCTAssertEqual(off, "0")
  }
}
