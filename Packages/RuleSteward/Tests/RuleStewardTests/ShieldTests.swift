@testable import RuleSteward
import XCTest

final class ShieldTests: XCTestCase {
  private let poke = Fixtures.poke
  private let beam = Ability(
    "Beam",
    power: 10,
    delivery: .special,
    element: .shock
  )

  private func mech() -> BattleUnit {
    BattleUnit(
      id: 0,
      side: .foes,
      unit: .kestrel,
      place: Point(x: 0, y: 0)
    )
  }

  func testShieldTakesBlockedDamageFirst() {
    var unit = mech()
    let taken = unit.take(100, from: poke)
    XCTAssertEqual(taken.shield, 100)
    XCTAssertEqual(taken.health, 0)
    let more = unit.take(80, from: poke)
    XCTAssertEqual(more.shield, 50)
    XCTAssertEqual(more.health, 30)
    XCTAssertEqual(unit.shield, 0)
    XCTAssertEqual(unit.health, 310)
  }

  /// Shock spends the shield twice as fast:
  /// 100 shock takes all 150 points, and the
  /// 25 they didn't cover reach health.
  func testShockBreaksItTwiceAsFast() {
    var unit = mech()
    let taken = unit.take(100, from: beam)
    XCTAssertEqual(taken.shield, 150)
    XCTAssertEqual(taken.health, 25)
  }

  func testUnblockedDamageSkipsIt() {
    let ward = Shield(
      "Ward", points: 100, blocks: [.special]
    )
    var unit = BattleUnit(
      id: 0,
      side: .party,
      unit: Fixtures.unit("W", shield: ward),
      place: Point(x: 0, y: 0)
    )
    let taken = unit.take(40, from: poke)
    XCTAssertEqual(taken.shield, 0)
    XCTAssertEqual(taken.health, 40)
    XCTAssertEqual(unit.shield, 100)
  }

  /// It refills at the start of a turn only
  /// if no damage came since the last one.
  func testItRechargesWhenLeftAlone() {
    var unit = mech()
    _ = unit.take(100, from: poke)
    unit.startTurn()
    XCTAssertEqual(unit.shield, 50)
    unit.startTurn()
    XCTAssertEqual(unit.shield, 150)
  }

  func testHealthDamageStopsTheRecharge() {
    var unit = mech()
    _ = unit.take(200, from: poke)
    unit.startTurn()
    _ = unit.take(10, from: poke)
    unit.startTurn()
    XCTAssertEqual(unit.shield, 0)
  }
}
