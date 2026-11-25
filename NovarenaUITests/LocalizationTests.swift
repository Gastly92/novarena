import XCTest

/// Every screen's visible text is
/// translatable (see `LocalizationCheck`).
final class LocalizationTests: XCTestCase {
  override func setUp() {
    continueAfterFailure = true
  }

  @MainActor
  func testEveryScreen() {
    LocalizationCheck().run(
      ScreenID.allCases
    )
  }
}
