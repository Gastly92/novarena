import XCTest

final class HomeTests: XCTestCase {
  @MainActor
  func testShowsTheName() {
    let app = App.start()
    let name = app.text("Novarena")
    XCTAssertTrue(name.appears())
  }
}
