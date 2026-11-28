@testable import Novarena
import RuleSteward
import XCTest

/// Taps on the arena, by what's selected,
/// and circling round a unit.
@MainActor
final class FightTapsTests: XCTestCase {
  /// With zones on (everyone's shown),
  /// tapping a unit turns its zone off,
  /// and again on; a foe that hasn't shown
  /// anything has none to draw.
  func testZonesByTap() {
    let fight = Fight(stage: .middle)
    fight.showsZones = true
    let ashka = fight.battle.units[2]
    fight.tap(ashka.place)
    XCTAssertFalse(fight.watched.contains(2))
    XCTAssertEqual(fight.zones.count, 3)
    fight.tap(ashka.place)
    XCTAssertTrue(fight.watched.contains(2))
    XCTAssertNil(fight.ghost)
    let start = Fight()
    start.showsZones = true
    XCTAssertEqual(
      start.zones.map(\.side),
      [.party, .party]
    )
  }

  /// With no skill picked, zones off and
  /// the actions open, tapping a unit does
  /// nothing yet.
  func testTapWithoutAMode() {
    let fight = Fight()
    fight.panel = .actions
    fight.tap(fight.battle.units[2].place)
    XCTAssertNil(fight.ghost)
    XCTAssertTrue(fight.watched.isEmpty)
  }

  /// With the move open, tapping a unit
  /// plans a walk to it: as far toward
  /// Ashka as Gerald's range goes, or to
  /// just touch Oswin (65 cm apart). A tap
  /// just beside a unit counts as on it.
  func testWalksToAUnit() {
    let fight = Fight()
    fight.tap(fight.battle.units[2].place)
    XCTAssertEqual(
      fight.ghost, Point(x: 600, y: 200)
    )
    fight.tap(Point(x: 250, y: 540))
    XCTAssertEqual(
      fight.ghost, Point(x: 250, y: 535)
    )
  }

  /// With Sword Cut picked, tapping Ashka
  /// out of reach plans the move just into
  /// reach from where Gerald stands (the
  /// walk the plain choice takes), not to
  /// the edge of his range; tapping her
  /// then strikes.
  func testAimsJustIntoReach() {
    let fight = Fight(stage: .planned)
    let ashka = fight.battle.units[2]
    fight.tap(ashka.place)
    XCTAssertEqual(
      fight.ghost, Point(x: 642, y: 248)
    )
    XCTAssertTrue(fight.inReach(2))
    fight.tap(ashka.place)
    XCTAssertTrue(fight.battle.hasActed)
  }

  /// A heal that reaches Gerald from where
  /// Maren stands, but not from a spot
  /// planned far off, drops the plan.
  func testAimFromWhereItStands() {
    let fight = Fight(stage: .healing)
    fight.place(Point(x: 300, y: 700))
    XCTAssertFalse(fight.inReach(0))
    fight.aim(at: 0)
    XCTAssertNil(fight.ghost)
    XCTAssertTrue(fight.inReach(0))
  }

  /// Touching Oswin from above, the
  /// circling arrows show; clockwise goes
  /// right round him. A nudge down, into
  /// him, doesn't go; one up leaves him.
  func testCircles() throws {
    let fight = Fight(stage: .circling)
    let start = try XCTUnwrap(fight.ghost)
    XCTAssertEqual(
      start, Point(x: 250, y: 535)
    )
    let oswin = fight.battle.units[1].place
    XCTAssertTrue(fight.circling)
    fight.nudge(.south, by: 5)
    XCTAssertEqual(fight.ghost, start)
    let away = Fight(stage: .circling)
    away.nudge(.north, by: 5)
    XCTAssertFalse(away.circling)
    fight.nudge(.clockwise, by: 10)
    let moved = try XCTUnwrap(fight.ghost)
    XCTAssertGreaterThan(moved.x, 250)
    let apart = (moved.x - oswin.x)
      * (moved.x - oswin.x)
      + (moved.y - oswin.y)
      * (moved.y - oswin.y)
    XCTAssertGreaterThanOrEqual(
      apart, 65 * 65
    )
    let free = Fight()
    free.nudge(.clockwise, by: 10)
    XCTAssertNil(free.ghost)
  }

  /// A circling arrow held with nothing to
  /// circle lets go at once, so pressing
  /// it again, once touching Oswin,
  /// circles.
  func testCirclingLetsGo() async {
    let nudged = expectation(
      description: "a nudge"
    )
    nudged.assertForOverFulfill = false
    let fight = Fight { _ in
      nudged.fulfill()
      await Task.yield()
    }
    fight.press(.clockwise)
    await Task.yield()
    fight.place(Point(x: 250, y: 535))
    fight.press(.clockwise)
    await fulfillment(of: [nudged])
    fight.press(nil)
    let x = fight.ghost?.x ?? 0
    XCTAssertGreaterThan(x, 250)
  }
}
