import Foundation

/// What the app does at launch: read the
/// launch arguments and set UI tests up.
/// Kept out of the `App` so it can be unit
/// tested.
struct AppLaunch {
  /// The UserDefaults suite UI tests use, so
  /// every run starts clean.
  static let testSuite = "uiTesting"

  let isUITesting: Bool
  /// The screen to start on: home, or in UI
  /// tests the one given with
  /// `-showScreen <id>`.
  let screen: ScreenID
  /// Where settings are kept: the phone's,
  /// or in UI tests an emptied suite.
  let defaults: UserDefaults

  init(arguments args: [String]) {
    let testing = args.contains("-uiTesting")
    isUITesting = testing
    let id = args
      .drop { $0 != "-showScreen" }
      .dropFirst()
      .first
    let shown = testing
      ? id.flatMap(ScreenID.init(rawValue:))
      : nil
    screen = shown ?? .home
    defaults = testing
      ? Self.clean(Self.testSuite)
      : .standard
  }

  /// The suite `name`, emptied.
  static func clean(
    _ name: String
  ) -> UserDefaults {
    let clean = UserDefaults(
      suiteName: name
    ) ?? .standard
    clean.removePersistentDomain(
      forName: name
    )
    return clean
  }
}
