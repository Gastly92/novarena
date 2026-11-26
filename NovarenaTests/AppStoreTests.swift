@testable import Novarena
import SwiftUI
import XCTest

/// The App Store screenshots
/// (`AppStoreShots`), from the same screens
/// as the snapshots. The images in
/// `__Snapshots__/AppStoreTests/` are the
/// ones to upload. Search results show the
/// first three, so put the strongest first.
@MainActor
final class AppStoreTests: XCTestCase {
  /// The icon's colors (`app-icon.sh`),
  /// violet at the top so white text on it
  /// reads well.
  private static let colors = [
    Color(
      red: 0.545, green: 0.173, blue: 0.961
    ),
    Color(red: 0, green: 0.706, blue: 0.941),
  ]

  func testScreenshots() throws {
    guard try SnapshotOS.matches() else {
      return
    }
    let home = TestScreens.page(.home)
    let battle = TestScreens.page(
      .battlePlanned
    )
    try AppStoreShots.check(
      [
        Shot(
          name: "1-home",
          caption: "Heroes from every era",
          view: home
        ),
        Shot(
          name: "2-battle",
          caption: "No dice, just tactics",
          view: battle
        ),
      ],
      colors: Self.colors
    )
  }
}
