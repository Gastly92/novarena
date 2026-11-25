import XCTest

/// Every screen's visible text is
/// translatable (see `LocalizationCheck`).
final class LocalizationTests: XCTestCase {
  override func setUp() {
    continueAfterFailure = true
  }

  @MainActor
  func testEveryScreen() {
    // Text from the rules package (names,
    // abilities, the log) isn't
    // translated yet; it carries a
    // `data-` identifier.
    LocalizationCheck(
      idPrefixes: ["data-"]
    )
    .run(ScreenID.allCases)
  }
}
