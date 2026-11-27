@testable import RuleSteward
import XCTest

/// Hits wearing down layers: what stops at
/// a break, what carries on, and the
/// knockout once nothing is left.
final class LayerTests: XCTestCase {
  /// A knight: 30 points of metal plate
  /// over a 50-point flesh body.
  private func knight() -> BattleUnit {
    wearing([
      Layer(
        "Plate", material: .metal, points: 30
      ),
      Layer(
        "Body", material: .flesh, points: 50
      ),
    ])
  }

  private func wearing(
    _ layers: [Layer]
  ) -> BattleUnit {
    BattleUnit(
      id: 0,
      side: .foes,
      unit: Fixtures.unit(
        "K", layers: layers
      ),
      place: Point(x: 0, y: 0)
    )
  }

  /// What each layer lost to `amount` of
  /// `ability`.
  private func hit(
    _ amount: Int,
    _ ability: Ability,
    on unit: inout BattleUnit
  ) -> [Int] {
    unit.take(amount, from: ability)
      .map(\.lost)
  }

  /// Slash meets metal at 50% and stops
  /// at the break: the plate soaks it.
  func testSoaksAtTheBreak() {
    var unit = knight()
    let slash = Fixtures.hit(
      "Cut", power: 0, kind: .slash
    )
    XCTAssertEqual(
      hit(100, slash, on: &unit), [30]
    )
    XCTAssertEqual(unit.layers, [0, 50])
    XCTAssertFalse(unit.isExposed)
  }

  /// Crush carries through metal: what the
  /// plate didn't take goes on to the body.
  func testCarries() {
    var unit = knight()
    let crush = Fixtures.hit(
      "Bash", power: 0
    )
    XCTAssertEqual(
      hit(100, crush, on: &unit), [30, 50]
    )
    XCTAssertTrue(unit.isExposed)
    XCTAssertFalse(unit.isOut)
  }

  /// A piercing slash carries on too: 50 of
  /// 100 dealt to the plate, 30 taken, so
  /// 40 of the 100 goes on, at 150% to
  /// flesh.
  func testPierces() {
    var unit = knight()
    let thrust = Ability(
      "Thrust",
      power: 0,
      kind: .slash,
      discipline: .blades,
      pierces: true
    )
    XCTAssertEqual(
      hit(100, thrust, on: &unit), [30, 50]
    )
  }

  /// A ghost blade passes metal by.
  func testIgnores() {
    var unit = knight()
    let ghost = Ability(
      "Ghost Blade",
      power: 0,
      kind: .crush,
      discipline: .blades,
      ignores: [.metal]
    )
    XCTAssertEqual(
      hit(20, ghost, on: &unit), [20]
    )
    XCTAssertEqual(unit.layers, [30, 30])
  }

  /// An immune layer stops the hit cold,
  /// and doesn't count as a hit. Exposed,
  /// a body immune to fire can't be
  /// finished by fire.
  func testImmune() {
    var unit = wearing([
      Layer(
        "Ember",
        material: .ember,
        points: 10,
        matchups: [.burn: .immune]
      ),
    ])
    let fire = Fixtures.hit(
      "Flame", power: 0, kind: .burn
    )
    XCTAssertEqual(
      hit(100, fire, on: &unit), []
    )
    XCTAssertFalse(unit.wasHit)
    let crush = Fixtures.hit(
      "Bash", power: 0
    )
    _ = hit(100, crush, on: &unit)
    XCTAssertTrue(unit.isExposed)
    _ = hit(100, fire, on: &unit)
    XCTAssertFalse(unit.isOut)
    _ = hit(0, crush, on: &unit)
    XCTAssertFalse(unit.isOut)
    _ = hit(1, crush, on: &unit)
    XCTAssertTrue(unit.isOut)
  }

  /// With no layers at all, any hit knocks
  /// out.
  func testBare() {
    var unit = wearing([])
    XCTAssertTrue(unit.isExposed)
    XCTAssertEqual(unit.percent, 0)
    _ = hit(1, Fixtures.poke, on: &unit)
    XCTAssertTrue(unit.isOut)
  }

  /// A recharging layer refills a little
  /// each turn the unit wasn't hit, broken
  /// or not; a regrowing one grows back
  /// each turn, unless broken.
  func testRechargesAndRegrows() {
    var unit = wearing([
      Layer(
        "Shield",
        material: .energy,
        points: 100,
        recharge: 40
      ),
      Layer(
        "Hide",
        material: .flesh,
        points: 100,
        regrows: 15
      ),
    ])
    let crush = Fixtures.hit(
      "Bash", power: 0
    )
    _ = hit(150, crush, on: &unit)
    XCTAssertEqual(unit.layers, [0, 100])
    unit.startTurn()
    XCTAssertEqual(unit.layers, [0, 100])
    unit.startTurn()
    XCTAssertEqual(unit.layers, [40, 100])
    unit.layers = [40, 50]
    unit.startTurn()
    XCTAssertEqual(unit.layers, [80, 65])
    unit.layers = [0, 0]
    unit.startTurn()
    XCTAssertEqual(unit.layers, [40, 0])
    XCTAssertEqual(unit.percent, 20)
  }
}
