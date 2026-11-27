@testable import Novarena
import RuleSteward
import XCTest

/// What a fight says about the turn being
/// planned: the move, the skill's reach,
/// and the danger zone.
@MainActor
final class FightPlanTests: XCTestCase {
  /// The move in Gerald's steps (half a
  /// metre each).
  func testMoveStatus() {
    XCTAssertEqual(
      Fight().moveStatus,
      """
      7 steps of movement left. Drag in \
      the arena, or use the arrows.
      """
    )
    XCTAssertEqual(
      Fight(stage: .moving).moveStatus,
      "Moves 1 step, then 6 steps left"
    )
    let fuel = Pool(
      .movement, maximum: 100, measure: .fuel
    )
    XCTAssertEqual(
      Fight.moveStatus(
        fuel, left: 100, planned: 30
      ),
      "Moves 1.2 fuel, then 2.8 fuel left"
    )
    let plain = Pool(.movement, maximum: 100)
    XCTAssertEqual(
      Fight.moveStatus(
        plain, left: 75, planned: 25
      ),
      "Moves 0.5 steps, then 1 step left"
    )
    XCTAssertEqual(
      Fight.moveStatus(
        nil, left: 0, planned: nil
      ),
      "Can't move"
    )
  }

  /// The picked skill's reach, from the
  /// planned spot or where Gerald stands:
  /// Sword Cut, half a metre past his
  /// 25 cm edge.
  func testReach() {
    XCTAssertNil(Fight().reach)
    let aiming = Fight(stage: .aiming)
    XCTAssertEqual(
      aiming.reach?.center,
      Point(x: 250, y: 200)
    )
    XCTAssertEqual(aiming.reach?.radius, 75)
    let planned = Fight(stage: .planned)
    XCTAssertEqual(
      planned.reach?.center,
      Point(x: 817, y: 448)
    )
  }

  /// With the danger zone on, each foe that
  /// has shown something is circled: Ashka
  /// moved 269 cm in a turn and threw a
  /// Fireball (500 cm), Kestrel-9 moved 59
  /// and fired an Arc Beam (450).
  func testZones() {
    XCTAssertTrue(
      Fight(stage: .middle).zones.isEmpty
    )
    let fight = Fight(stage: .danger)
    XCTAssertTrue(fight.showsDanger)
    XCTAssertEqual(
      fight.zones.map(\.radius), [769, 509]
    )
    XCTAssertEqual(
      fight.zones.first?.center,
      Point(x: 717, y: 333)
    )
  }
}
