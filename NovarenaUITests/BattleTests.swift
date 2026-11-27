import XCTest

/// Taking turns on the battle screen. The
/// log is at the bottom, off screen, so
/// its rows don't exist to check;
/// `FightTests` checks the log instead.
final class BattleTests: XCTestCase {
  /// Tap the arena at (300, 200) cm, half
  /// a metre right of Gerald, to plan a
  /// move; hold the right arrow to nudge
  /// it; commit it, then end the turn:
  /// Oswin is next.
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
    let first = app.text("data-order-0")
    XCTAssertEqual(first.label, "Oswin")
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
  /// hits, and the turn waits to be ended.
  @MainActor
  func testActsThenEnds() {
    let app = App.start(
      screen: .battlePlanned
    )
    tap(app, x: 0.76, y: 0.695)
    let end = app.buttons["End turn"]
    XCTAssertTrue(end.appears())
    end.tap()
    let first = app.text("data-order-0")
    XCTAssertEqual(first.label, "Oswin")
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
  /// reach: nothing happens, and the skills
  /// stay open.
  @MainActor
  func testOutOfReachDoesNothing() {
    let app = App.start(
      screen: .battlePlanned
    )
    app.buttons["data-ability-1"].tap()
    app.buttons["data-foe-2"].tap()
    let end = app.buttons["End turn"]
    XCTAssertFalse(end.exists)
    let lunge = app.buttons["data-ability-1"]
    XCTAssertTrue(lunge.exists)
  }

  @MainActor
  func testFightsAgain() {
    let app = App.start(screen: .battleEnd)
    app.buttons["Fight again"].tap()
    let arrow = app.buttons["nudge-east"]
    XCTAssertTrue(arrow.appears())
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
