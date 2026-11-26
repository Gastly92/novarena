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
}
