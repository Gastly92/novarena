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
    XCTAssertNil(fight.ghost)
    XCTAssertEqual(fight.panel, .move)
    XCTAssertEqual(fight.moveLeft, 350)
    XCTAssertNil(fight.outcome)
    let foes = fight.units(.foes)
    XCTAssertEqual(foes.map(\.id), [2, 3])
  }

  /// A planned move can go anywhere Gerald
  /// can reach, be nudged, and be undone;
  /// a spot out of reach plans the edge of
  /// his range on the way; his own spot
  /// clears the plan.
  func testPlansAMove() {
    let fight = Fight(stage: .moving)
    let spot = Point(x: 300, y: 200)
    XCTAssertEqual(fight.ghost, spot)
    XCTAssertEqual(fight.planned, 50)
    XCTAssertFalse(fight.queueAfter.isEmpty)
    fight.nudge(.east, by: 1)
    XCTAssertEqual(
      fight.ghost, Point(x: 301, y: 200)
    )
    fight.place(Point(x: 1000, y: 700))
    XCTAssertEqual(
      fight.ghost, Point(x: 541, y: 394)
    )
    XCTAssertEqual(fight.planned, 350)
    fight.place(Point(x: 250, y: 200))
    XCTAssertNil(fight.ghost)
    XCTAssertNil(fight.planned)
    fight.nudge(.south, by: 10)
    XCTAssertEqual(
      fight.ghost, Point(x: 250, y: 210)
    )
    fight.undo()
    XCTAssertNil(fight.ghost)
    XCTAssertTrue(fight.queueAfter.isEmpty)
  }

  /// Committing walks the plan, which then
  /// can't be undone; ending the turn lets
  /// the foes act until Oswin's turn.
  func testCommitsThenEnds() {
    let fight = Fight(stage: .moving)
    fight.commit()
    XCTAssertNil(fight.ghost)
    XCTAssertEqual(fight.moveLeft, 300)
    let moved = "Gerald moves to (300, 200)"
    XCTAssertTrue(
      fight.latest.contains(moved)
    )
    fight.commit()
    XCTAssertEqual(fight.moveLeft, 300)
    fight.endTurn()
    XCTAssertEqual(fight.actor?.id, 1)
    XCTAssertEqual(fight.panel, .move)
  }

  /// From the planned spot, Sword Cut
  /// reaches Kestrel-9 (80 × 120% = 96, at
  /// 93% 89, off its 100-point shield,
  /// shown in percent for a foe) but not
  /// Ashka; an ally is no target.
  func testPlannedSpot() {
    let fight = Fight(stage: .planned)
    XCTAssertEqual(fight.actor?.id, 0)
    XCTAssertEqual(fight.panel, .skills)
    XCTAssertTrue(fight.inReach(3))
    XCTAssertFalse(fight.inReach(2))
    XCTAssertEqual(
      fight.preview(of: 3),
      ["Energy Shield −89%, 11% left"]
    )
    XCTAssertEqual(
      fight.preview(of: 2), ["Out of reach"]
    )
    XCTAssertTrue(
      fight.preview(of: 1).isEmpty
    )
    let now = fight.queue.map(\.id)
    let after = fight.queueAfter.map(\.id)
    XCTAssertEqual(now.first, 0)
    XCTAssertNotEqual(after, now)
  }

  /// A foe out of reach can't be targeted;
  /// one in reach, tapped in the arena, is
  /// hit after the walk. The skills stay
  /// open for the Pommel Strike bonus;
  /// once it's used, the actions open.
  func testActs() {
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
    XCTAssertNil(fight.ghost)
    XCTAssertEqual(fight.panel, .skills)
    XCTAssertTrue(fight.battle.hasActed)
    XCTAssertFalse(fight.battle.canUse(0))
    fight.choose(2)
    fight.target(3)
    XCTAssertEqual(fight.panel, .actions)
    XCTAssertFalse(fight.battle.canUse(2))
    let hit = "Gerald: Sword Cut → Kestrel-9"
    XCTAssertTrue(fight.latest.contains(hit))
    XCTAssertEqual(fight.actor?.id, 0)
    XCTAssertFalse(fight.queueAfter.isEmpty)
  }

  /// The acted stage: Sword Cut and the
  /// Pommel Strike done, the turn to end.
  func testActedStage() {
    let fight = Fight(stage: .acted)
    XCTAssertEqual(fight.panel, .actions)
    XCTAssertFalse(fight.battle.canUse(2))
    XCTAssertTrue(fight.battle.hasActed)
    fight.endTurn()
    XCTAssertEqual(fight.actor?.side, .party)
    XCTAssertFalse(fight.battle.hasActed)
  }

  /// Taps: on Gerald clears the plan, on
  /// empty ground plans a move there (on
  /// another unit, see
  /// `FightPlanTests.testWatchesByTapping`).
  func testTaps() {
    let fight = Fight(stage: .moving)
    fight.tap(Point(x: 260, y: 210))
    XCTAssertNil(fight.ghost)
    fight.tap(Point(x: 300, y: 300))
    XCTAssertEqual(
      fight.ghost, Point(x: 300, y: 300)
    )
  }

  /// A touch that moves drags the plan; one
  /// that doesn't is a tap once lifted.
  func testTouches() {
    let fight = Fight()
    let spot = Point(x: 250, y: 300)
    fight.touch(
      spot, moved: false, lifted: false
    )
    XCTAssertNil(fight.ghost)
    fight.touch(
      spot, moved: false, lifted: true
    )
    XCTAssertEqual(fight.ghost, spot)
    let next = Point(x: 260, y: 300)
    fight.touch(
      next, moved: true, lifted: false
    )
    XCTAssertEqual(fight.ghost, next)
  }

  /// Holding an arrow nudges again and
  /// again until it's let go.
  func testHoldingNudges() async {
    let ticks = expectation(
      description: "three waits"
    )
    ticks.expectedFulfillmentCount = 3
    ticks.assertForOverFulfill = false
    let fight = Fight { _ in
      ticks.fulfill()
      await Task.yield()
    }
    fight.press(.east)
    fight.press(.east)
    await fulfillment(of: [ticks])
    fight.press(nil)
    let x = fight.ghost?.x ?? 0
    XCTAssertGreaterThanOrEqual(x, 253)
  }

  /// Tapping a foe before picking does
  /// nothing.
  func testTargetNeedsASkill() {
    let fight = Fight()
    fight.target(2)
    XCTAssertTrue(fight.battle.log.isEmpty)
  }

  func testStagesForTheScreens() {
    let aiming = Fight(stage: .aiming)
    XCTAssertEqual(aiming.chosen, 0)
    XCTAssertEqual(aiming.panel, .skills)
    let middle = Fight(stage: .middle)
    let tick = middle.battle.tick
    XCTAssertGreaterThan(tick, 0)
    let side = middle.actor?.side
    XCTAssertEqual(side, .party)
    let exposed = Fight(stage: .exposed)
    let bare = exposed.battle.units.filter {
      $0.isUp && $0.isExposed
    }
    let names = bare.map(\.unit.name)
    XCTAssertEqual(names, ["Oswin", "Ashka"])
    XCTAssertEqual(exposed.actor?.id, 1)
    let end = Fight(stage: .end)
    let won = "The party wins"
    XCTAssertEqual(end.outcome, won)
    XCTAssertNil(end.actor)
  }

  /// Once it's over, taps and nudges do
  /// nothing and nothing is planned.
  func testOverIgnoresTouches() {
    let fight = Fight(stage: .end)
    fight.tap(Point(x: 300, y: 200))
    fight.nudge(.north, by: 1)
    XCTAssertNil(fight.ghost)
    fight.choose(0)
    XCTAssertTrue(fight.queueAfter.isEmpty)
  }

  func testRestartGoesBackToTheStart() {
    let fight = Fight(stage: .acted)
    fight.restart()
    XCTAssertNil(fight.outcome)
    XCTAssertTrue(fight.battle.log.isEmpty)
    XCTAssertEqual(fight.actor?.id, 0)
    XCTAssertEqual(fight.panel, .move)
  }

  /// Maren's Mend Wounds (30 × 120% = 36,
  /// by half on metal) can only go on an
  /// ally it can mend: Gerald, his plate
  /// at 7. Tapping him in the arena heals
  /// him to 25; the skills stay open for
  /// her Mace Blow.
  func testHeals() {
    let fight = Fight(stage: .healing)
    XCTAssertEqual(fight.actor?.id, 1)
    XCTAssertEqual(
      fight.preview(of: 0),
      ["Plate +18, now 25"]
    )
    let foe = fight.preview(of: 2)
    XCTAssertTrue(foe.isEmpty)
    XCTAssertTrue(fight.canAim(at: 0))
    XCTAssertFalse(fight.canAim(at: 1))
    XCTAssertFalse(fight.canAim(at: 2))
    XCTAssertTrue(fight.inReach(0))
    fight.tap(fight.battle.units[0].place)
    XCTAssertEqual(
      fight.battle.units[0].layers, [25, 60]
    )
    XCTAssertEqual(fight.panel, .skills)
    XCTAssertNil(fight.chosen)
  }

  /// An attack can be aimed at a foe out
  /// of reach, not at an ally; nothing
  /// can be aimed with no skill picked.
  func testAims() {
    let aiming = Fight(stage: .aiming)
    XCTAssertTrue(aiming.canAim(at: 2))
    XCTAssertFalse(aiming.inReach(2))
    XCTAssertFalse(aiming.canAim(at: 1))
    XCTAssertFalse(Fight().canAim(at: 2))
  }

  /// A fight between any units starts at
  /// the party's first turn, and starts
  /// again with the same units.
  func testAnyUnits() {
    let fight = Fight(
      party: [.maren],
      foes: [.oswin, .oswin]
    )
    XCTAssertEqual(
      fight.units(.foes).map(\.unit.name),
      ["Oswin", "Oswin"]
    )
    XCTAssertEqual(fight.actor?.side, .party)
    fight.restart()
    XCTAssertEqual(
      fight.units(.party).map(\.unit.name),
      ["Maren"]
    )
  }
}
