@testable import Novarena
import XCTest

final class AppLaunchTests: XCTestCase {
  func testNormalLaunch() {
    let normal = AppLaunch(arguments: [])
    XCTAssertFalse(normal.isUITesting)
    XCTAssertEqual(normal.screen, .home)
  }

  func testUITestsPickAScreen() {
    let shown = AppLaunch(arguments: [
      "-uiTesting", "-showScreen", "home",
    ])
    XCTAssertTrue(shown.isUITesting)
    XCTAssertEqual(shown.screen, .home)
    let unknown = AppLaunch(arguments: [
      "-uiTesting", "-showScreen", "nope",
    ])
    XCTAssertEqual(unknown.screen, .home)
  }
}
