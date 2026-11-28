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

  /// UI tests get an emptied settings
  /// suite; the app, the phone's.
  func testDefaults() {
    let normal = AppLaunch(arguments: [])
    XCTAssertEqual(
      normal.defaults, .standard
    )
    let first = AppLaunch(arguments: [
      "-uiTesting",
    ])
    first.defaults.set(
      false, forKey: Settings.endsKey
    )
    let next = AppLaunch(arguments: [
      "-uiTesting",
    ])
    XCTAssertNil(
      next.defaults.object(
        forKey: Settings.endsKey
      )
    )
  }
}
