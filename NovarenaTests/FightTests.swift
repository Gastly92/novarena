@testable import Novarena
import RuleSteward
import XCTest

@MainActor
final class FightTests: XCTestCase {
  func testStartsOnGeraldsTurn() {
    let fight = Fight()
    let names = fight.queue.map(\.unit.name)
    let order = [
      "Gerald", "Ashka",
      "Kestrel-9", "Oswin",
    ]
    XCTAssertEqual(names, order)
    XCTAssertEqual(fight.actor?.id, 0)
    XCTAssertNil(fight.chosen)
    XCTAssertNil(fight.outcome)
    let foes = fight.units(.foes)
    XCTAssertEqual(foes.map(\.id), [2, 3])
  }

  /// A turn: pick, tap a foe (out of reach,
  /// so Gerald walks toward it), and the
  /// foes act until it's the party's turn
  /// again.
  func testATurnLetsTheFoesAct() {
    let fight = Fight()
    fight.choose(0)
    XCTAssertEqual(fight.chosen, 0)
    fight.target(2)
    XCTAssertNil(fight.chosen)
    XCTAssertEqual(fight.actor?.side, .party)
    let lines = fight.latest
    let hit = "Gerald moves to (500, 200)"
    XCTAssertEqual(
      lines.last, "[105] Gerald"
    )
    XCTAssertTrue(lines.contains(hit))
    XCTAssertTrue(
      lines.contains("[111] Ashka")
    )
  }

  /// Tapping a foe before picking does
  /// nothing.
  func testTargetNeedsAnAbility() {
    let fight = Fight()
    fight.target(2)
    XCTAssertTrue(fight.battle.log.isEmpty)
  }

  func testStagesForTheScreens() {
    let aiming = Fight(stage: .aiming)
    XCTAssertEqual(aiming.chosen, 0)
    let planned = Fight(stage: .planned)
    XCTAssertEqual(planned.actor?.id, 0)
    XCTAssertEqual(
      planned.spot, Point(x: 767, y: 394)
    )
    let middle = Fight(stage: .middle)
    let tick = middle.battle.tick
    XCTAssertGreaterThan(tick, 0)
    let side = middle.actor?.side
    XCTAssertEqual(side, .party)
    let end = Fight(stage: .end)
    let won = "The foes win"
    XCTAssertEqual(end.outcome, won)
    XCTAssertNil(end.actor)
  }

  func testRestartGoesBackToTheStart() {
    let fight = Fight(stage: .end)
    fight.restart()
    XCTAssertNil(fight.outcome)
    XCTAssertTrue(fight.battle.log.isEmpty)
    XCTAssertEqual(fight.actor?.id, 0)
  }

  /// From the planned spot, Sword Cut
  /// reaches Kestrel-9 (its shield takes
  /// 60 × 130 ÷ 230 = 33, at 94% 31) but
  /// not Ashka.
  func testPlannedSpot() {
    let fight = Fight(stage: .planned)
    XCTAssertTrue(fight.inReach(3))
    XCTAssertFalse(fight.inReach(2))
    XCTAssertEqual(
      fight.preview(of: 3),
      ["Shield −31, 119 left"]
    )
    XCTAssertEqual(
      fight.preview(of: 2),
      ["Out of reach from there"]
    )
    // An ally can't be a target.
    XCTAssertTrue(
      fight.preview(of: 1).isEmpty
    )
    let now = fight.queue.map(\.id)
    let after = fight.queueAfter.map(\.id)
    XCTAssertEqual(now.first, 0)
    XCTAssertNotEqual(after, now)
    XCTAssertTrue(after.contains(0))
  }

  /// Tapping a foe out of reach from the
  /// spot does nothing; one in reach is
  /// hit, and the picks clear.
  func testTapTargetsAFoe() {
    let fight = Fight(stage: .planned)
    let count = fight.battle.log.count
    fight.target(2)
    XCTAssertEqual(
      fight.battle.log.count, count
    )
    XCTAssertEqual(fight.chosen, 0)
    let kestrel = fight.battle.units[3]
    fight.tap(kestrel.place)
    XCTAssertNil(fight.chosen)
    XCTAssertNil(fight.spot)
    let hit = "Gerald: Sword Cut → Kestrel-9"
    XCTAssertTrue(fight.latest.contains(hit))
  }

  /// A tap picks a spot it can move to,
  /// ignores one it can't, and a tap on the
  /// unit itself clears it.
  func testTapPicksASpot() {
    let fight = Fight()
    let near = Point(x: 300, y: 200)
    fight.tap(near)
    XCTAssertEqual(fight.spot, near)
    XCTAssertFalse(fight.queueAfter.isEmpty)
    fight.tap(Point(x: 1000, y: 700))
    XCTAssertEqual(fight.spot, near)
    fight.tap(Point(x: 160, y: 210))
    XCTAssertNil(fight.spot)
    XCTAssertTrue(fight.queueAfter.isEmpty)
  }

  /// Ending the turn moves to the spot, if
  /// any, without acting.
  func testEndTurn() {
    let fight = Fight()
    fight.tap(Point(x: 300, y: 200))
    fight.endTurn()
    XCTAssertNil(fight.spot)
    let moved = "Gerald moves to (300, 200)"
    XCTAssertTrue(
      fight.latest.contains(moved)
    )
    XCTAssertEqual(fight.actor?.id, 1)
    let count = fight.battle.log.count
    fight.endTurn()
    XCTAssertGreaterThan(
      fight.battle.log.count, count
    )
  }

  /// Once it's over, taps do nothing and
  /// nothing is planned.
  func testOverIgnoresTaps() {
    let fight = Fight(stage: .end)
    fight.tap(Point(x: 300, y: 200))
    XCTAssertNil(fight.spot)
    fight.choose(0)
    XCTAssertTrue(fight.queueAfter.isEmpty)
  }
}
