import XCTest

/// The app under test.
typealias App = XCUIApplication

extension XCUIApplication {
  /// US English and UTC, whatever the
  /// simulator is set to, so dates and
  /// numbers read the same on every runner
  /// (the scheme sets the same for unit and
  /// snapshot tests in `project.yml`).
  static let fixedRegion = [
    "-AppleLanguages", "(en)",
    "-AppleLocale", "en_US",
  ]

  /// Launches the app for a UI test with
  /// `-uiTesting` (the app turns off
  /// animations).
  @MainActor
  static func start(
    arguments: [String] = []
  ) -> XCUIApplication {
    let app = XCUIApplication()
    app.launchArguments = ["-uiTesting"]
      + fixedRegion + arguments
    app.launchEnvironment["TZ"] = "UTC"
    app.launch()
    return app
  }

  /// Launches straight into one screen
  /// (`-showScreen <id>`; see the app's
  /// `ScreenID` and `ScreenHost`).
  @MainActor
  static func start(
    screen: ScreenID,
    arguments: [String] = []
  ) -> XCUIApplication {
    let show = [
      "-showScreen", screen.rawValue,
    ]
    return start(arguments: show + arguments)
  }

  /// A static text, by label or identifier.
  @MainActor
  func text(_ id: String) -> XCUIElement {
    staticTexts[id]
  }
}

extension XCUIElement {
  /// Waits up to `seconds` for the element
  /// to exist.
  @MainActor
  func appears(
    within seconds: TimeInterval = 5
  ) -> Bool {
    waitForExistence(timeout: seconds)
  }
}
