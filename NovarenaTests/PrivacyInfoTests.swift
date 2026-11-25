import XCTest

/// The App Store requires a privacy
/// manifest. Keep it true to what the app
/// does: update it (and the privacy page in
/// `site/`) when adding tracking, collected
/// data, or APIs Apple lists as needing a
/// reason.
final class PrivacyInfoTests: XCTestCase {
  func testManifestMatchesTheApp() throws {
    let manifest = try PrivacyManifest()
    XCTAssertFalse(manifest.tracks)
    XCTAssertEqual(
      manifest.collectedTypes, 0
    )
    // No APIs that need a reason yet.
    XCTAssertEqual(manifest.reasons, [:])
  }
}
