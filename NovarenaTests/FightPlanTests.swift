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
    let none = Fight()
    XCTAssertFalse(none.canUse)
    none.use()
    XCTAssertTrue(none.battle.log.isEmpty)
  }
}
