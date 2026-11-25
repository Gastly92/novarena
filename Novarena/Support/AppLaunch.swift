/// What the app does at launch: read the
/// launch arguments and set UI tests up.
/// Kept out of the `App` so it can be unit
/// tested.
struct AppLaunch {
  let isUITesting: Bool
  /// The screen to start on: home, or in UI
  /// tests the one given with
  /// `-showScreen <id>`.
  let screen: ScreenID

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
  }
}
