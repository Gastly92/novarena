import XCTest

/// Taking turns on the battle screen. The
/// log is at the bottom, off screen, so
/// its rows don't exist to check;
/// `FightTests` checks the log instead.
final class BattleTests: XCTestCase {
  /// Tap the arena at (300, 200) cm, half
  /// a metre right of Gerald, to plan a
  /// move; hold the right arrow to nudge
  /// it; commit it, then end the turn.
  /// Ashka's turn plays a step at a time;
  /// skip the rest, to Oswin's turn.
  @MainActor
  func testMovesAndEndsTheTurn() {
    let app = App.start(screen: .battle)
    tap(app, x: 0.25, y: 0.25)
    let status = app.text("move-status")
    let planned = status.label
    XCTAssertTrue(planned.hasPrefix("Moves"))
    app.buttons["nudge-east"]
      .press(forDuration: 0.6)
    XCTAssertNotEqual(status.label, planned)
    app.buttons["Commit move"].tap()
    app.buttons["Actions"].tap()
    app.buttons["End turn"].tap()
    // Ashka's turn, a step at a time:
    // it has begun; next, she moves.
    app.buttons["Next"].tap()
    let step = app.text("data-step")
    XCTAssertTrue(
      step.label.hasPrefix("Ashka moves")
    )
    app.buttons["Skip to your turn"].tap()
    XCTAssertTrue(isTurn(of: "Oswin", app))
  }

  /// Drag from Gerald to plan a move there.
  @MainActor
  func testDragsAMove() {
    let app = App.start(screen: .battle)
    let commit = app.buttons["Commit move"]
    XCTAssertFalse(commit.isEnabled)
    spot(app, x: 0.208, y: 0.25)
      .press(
        forDuration: 0.2,
        thenDragTo: spot(app, x: 0.3, y: 0.4)
      )
    XCTAssertTrue(commit.isEnabled)
  }

  /// With Sword Cut picked and a move
  /// planned, tap Kestrel-9 in the arena
  /// (at 912, 556 cm): Gerald walks and
  /// hits. The skills stay open for his
  /// Pommel Strike; open the actions and
  /// end the turn instead.
  @MainActor
  func testActsThenEnds() {
    let app = App.start(
      screen: .battlePlanned
    )
    tap(app, x: 0.76, y: 0.695)
    let pommel = app.buttons[
      "data-ability-2"
    ]
    XCTAssertTrue(pommel.appears())
    app.buttons["Actions"].tap()
    app.buttons["End turn"].tap()
    app.buttons["Skip to your turn"].tap()
    XCTAssertTrue(isTurn(of: "Oswin", app))
  }

  /// Undo forgets a planned move.
  @MainActor
  func testUndoes() {
    let app = App.start(
      screen: .battleMoving
    )
    let commit = app.buttons["Commit move"]
    XCTAssertTrue(commit.isEnabled)
    app.buttons["Undo"].tap()
    XCTAssertFalse(commit.isEnabled)
  }

  /// Pick Lunge, then tap Ashka, out of
  /// reach: the move into reach is planned
  /// (not struck yet), and the skills stay
  /// open.
  @MainActor
  func testOutOfReachDoesNothing() {
    let app = App.start(
      screen: .battlePlanned
    )
    app.buttons["data-ability-1"].tap()
    // Ashka, at (717, 333) cm.
    tap(app, x: 0.5975, y: 0.416)
    let end = app.buttons["End turn"]
    XCTAssertFalse(end.exists)
    let lunge = app.buttons["data-ability-1"]
    XCTAssertTrue(lunge.exists)
  }

  /// With Mend Wounds picked, tapping
  /// Gerald's row heals his plate, 7 to
  /// 25.
  @MainActor
  func testHealsFromTheRow() {
    let app = App.start(
      screen: .battleHealing
    )
    // The short actions panel brings the
    // party's rows into view; Mend Wounds
    // stays picked.
    app.buttons["Actions"].tap()
    let gerald = app.buttons["data-unit-0"]
    XCTAssertTrue(gerald.appears())
    gerald.tap()
    let healed = gerald.label
    XCTAssertTrue(
      healed.contains("25 of 190")
    )
  }

  /// The knocked-out section opens to
  /// show who fell.
  @MainActor
  func testOpensTheFallen() {
    let app = App.start(screen: .battleEnd)
    app.buttons["Knocked out"].tap()
    app.swipeUp()
    let ashka = app.text("data-name-2")
    XCTAssertTrue(ashka.appears())
  }

  @MainActor
  func testFightsAgain() {
    let app = App.start(screen: .battleEnd)
    app.buttons["Fight again"].tap()
    let arrow = app.buttons["nudge-east"]
    XCTAssertTrue(arrow.appears())
  }

  /// The info button opens the battle
  /// info sheet; Done closes it.
  @MainActor
  func testShowsBattleInfo() {
    let app = App.start(
      screen: .battleMiddle
    )
    app.buttons["Battle info"].tap()
    let sheet = app.navigationBars[
      "Battle info"
    ]
    XCTAssertTrue(sheet.appears())
    app.buttons["Done"].tap()
    XCTAssertTrue(
      sheet.waitForNonExistence(timeout: 5)
    )
  }

  /// Whether the turn order is titled for
  /// `name`'s turn.
  @MainActor
  private func isTurn(
    of name: String,
    _ app: XCUIApplication
  ) -> Bool {
    let title = app.text("turn-title")
    return title.appears()
      && title.label.contains(name)
  }

  /// A spot in the arena, as fractions of
  /// its width and height.
  @MainActor
  private func spot(
    _ app: XCUIApplication,
    x: Double,
    y: Double
  ) -> XCUICoordinate {
    app.buttons["arena"].coordinate(
      withNormalizedOffset: CGVector(
        dx: x, dy: y
      )
    )
  }

  /// Taps the arena there.
  @MainActor
  private func tap(
    _ app: XCUIApplication,
    x: Double,
    y: Double
  ) {
    spot(app, x: x, y: y).tap()
  }
}
