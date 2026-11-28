import XCTest

/// Planning a turn on the battle screen:
/// skills planned and backed away from,
/// cancelled or unpicked; foes walked
/// toward.
final class PlanTests: XCTestCase {
  /// Isolde beside Wren: tap Wren in the
  /// arena (at 730, 380 cm) to plan Chill
  /// Touch, then back away: off once at
  /// the edge, the skill still planned.
  @MainActor
  func testBacksAway() {
    let app = App.start(
      screen: .battleDodging
    )
    tapArena(app, x: 0.6083, y: 0.475)
    let back = app.buttons["back-away"]
    XCTAssertTrue(back.isEnabled)
    back.tap()
    XCTAssertFalse(back.isEnabled)
    let use = app.buttons["use-skill"]
    XCTAssertTrue(use.exists)
  }

  /// A foe picked with the move open: up
  /// close plans a move; in range too.
  @MainActor
  func testApproaches() {
    let app = App.start(
      screen: .battleApproaching
    )
    let status = app.text("move-status")
    let before = status.label
    app.buttons["up-close"].tap()
    XCTAssertNotEqual(status.label, before)
    // Far off, in range stops at the edge
    // of Gerald's move too; it still runs.
    app.buttons["in-range"].tap()
    XCTAssertTrue(
      app.text("data-approached").exists
    )
  }

  /// Tapping the picked skill again unpicks
  /// it, so a tap on Ashka (at 950, 200
  /// cm, where she starts) with the move
  /// open picks her to walk toward, not
  /// to aim at.
  @MainActor
  func testUnpicks() {
    let app = App.start(
      screen: .battleAiming
    )
    app.buttons["data-ability-0"].tap()
    app.buttons["Move"].tap()
    tapArena(app, x: 0.7917, y: 0.25)
    let picked = app.text("data-approached")
    XCTAssertTrue(picked.appears())
  }

  /// Cancel forgets a planned skill, so
  /// its Use button goes.
  @MainActor
  func testCancelsASkill() {
    let app = App.start(
      screen: .battlePlanned
    )
    let use = app.buttons["use-skill"]
    XCTAssertTrue(use.appears())
    app.buttons["Cancel"].tap()
    XCTAssertTrue(
      use.waitForNonExistence(timeout: 5)
    )
  }

  /// Taps the arena there, as fractions of
  /// its width and height.
  @MainActor
  private func tapArena(
    _ app: XCUIApplication,
    x: Double,
    y: Double
  ) {
    let arena = app.buttons["arena"]
    let spot = arena.coordinate(
      withNormalizedOffset: CGVector(
        dx: x, dy: y
      )
    )
    spot.tap()
  }
}
