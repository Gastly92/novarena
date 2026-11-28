@testable import Novarena
import RuleSteward
import XCTest

/// A skill planned like a move: used when
/// asked, or when the turn ends.
@MainActor
final class FightPlanTests: XCTestCase {
  /// A plan is used when the turn ends,
  /// unless it no longer reaches; picking
  /// another skill drops it, and with
  /// none, using does nothing.
  func testPlans() {
    let ends = Fight(stage: .planned)
    XCTAssertTrue(ends.canUse)
    let line = Event.uses(
      "Gerald",
      "Sword Cut",
      target: "Kestrel-9"
    )
    let before = ends.battle.log
      .filter { $0 == line }.count
    ends.endTurn()
    let after = ends.battle.log
      .filter { $0 == line }.count
    XCTAssertEqual(after, before + 1)
    let away = Fight(stage: .planned)
    away.undo()
    XCTAssertFalse(away.canUse)
    away.use()
    XCTAssertFalse(away.battle.hasActed)
    away.choose(1)
    XCTAssertNil(away.aimed)
    let kept = Fight(stage: .planned)
    kept.cancel()
    XCTAssertNil(kept.aimed)
    XCTAssertEqual(kept.chosen, 0)
    XCTAssertNotNil(kept.ghost)
    let uses = kept.battle.log
      .filter { $0 == line }.count
    kept.endTurn()
    let used = kept.battle.log
      .filter { $0 == line }.count
    XCTAssertEqual(used, uses)
    let none = Fight()
    XCTAssertFalse(none.canUse)
    none.use()
    XCTAssertTrue(none.battle.log.isEmpty)
  }

  /// Without a movement pool a unit can't
  /// move; a pool with no measure counts in
  /// steps.
  func testMoveStatus() {
    let none = Fight.moveStatus(
      nil, left: 0, planned: nil
    )
    XCTAssertEqual(none, "Can't move")
    let plain = Pool(.movement, maximum: 300)
    let status = Fight.moveStatus(
      plain, left: 100, planned: nil
    )
    let steps = Measure.step.says(100)
    XCTAssertTrue(status.hasPrefix(steps))
  }

  /// Backing away moves the planned spot to
  /// the edge of the planned skill's reach,
  /// still planned and in reach; with no
  /// plan, nothing moves.
  func testBacksAway() {
    let fight = Fight(stage: .planned)
    let plan = fight.aimed
    let edge = fight.battle.standoff(
      on: 3, with: 0
    )
    fight.backAway()
    XCTAssertEqual(fight.ghost, edge)
    XCTAssertEqual(fight.aimed, plan)
    XCTAssertTrue(fight.canUse)
    let none = Fight()
    none.backAway()
    XCTAssertNil(none.ghost)
  }
}
