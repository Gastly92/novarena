@testable import RuleSteward
import XCTest

/// Heals: a mend kind that restores an
/// ally's worn layer, by how it meets the
/// layer's material.
final class HealTests: XCTestCase {
  /// A trained (100%) mend, reaching
  /// across any arena.
  private let heal = Ability(
    "Heal",
    power: 30,
    kind: .mend,
    discipline: .unarmed,
    reach: Fixtures.far
  )

  /// A healer (A), an ally in `layers`
  /// (B) and a slow foe (C), together.
  private func battle(
    _ layers: [Layer],
    healer: [Ability]? = nil
  ) -> Battle {
    Battle(
      party: [
        Fixtures.unit(
          "A",
          abilities: healer
            ?? [Fixtures.poke, heal]
        ),
        Fixtures.unit("B", layers: layers),
      ],
      foes: [Fixtures.unit("C", speed: 50)],
      places: Fixtures.together(3)
    )
  }

  private func layer(
    _ material: Material,
    _ name: String = "Hide"
  ) -> Layer {
    Layer(
      name, material: material, points: 100
    )
  }

  /// Flesh mends fully, without intensity
  /// (92% now): 30 of 30. The forecast
  /// says so first.
  func testMendsAWornLayer() throws {
    var battle = battle([layer(.flesh)])
    battle.units[1].layers = [40]
    let forecast = try battle.forecast(
      1, on: 1
    )
    XCTAssertEqual(
      forecast.strike?.gains,
      [Gain(layer: 0, gained: 30, now: 70)]
    )
    XCTAssertEqual(
      forecast.strike?.losses, []
    )
    try battle.act(1, on: 1)
    let layers = battle.units[1].layers
    XCTAssertEqual(layers, [70])
    XCTAssertEqual(
      battle.log.last?.description,
      "  B's Hide +30 (70)"
    )
  }

  /// Armor mends by half; energy not at
  /// all, so the plate under it mends;
  /// never past whole.
  func testByMaterial() throws {
    var battle = battle([
      layer(.energy, "Shield"),
      layer(.metal, "Plate"),
    ])
    battle.units[1].layers = [50, 90]
    try battle.act(1, on: 1)
    XCTAssertEqual(
      battle.units[1].layers, [50, 100]
    )
  }

  /// Not on a foe, a whole ally, a broken
  /// layer (an exposed unit stays
  /// exposed), or a machine.
  func testBadTargets() {
    var whole = battle([layer(.flesh)])
    Fixtures.expect(.badTarget) {
      try whole.act(1, on: 1)
    }
    Fixtures.expect(.badTarget) {
      try whole.act(1, on: 2)
    }
    var broken = battle([layer(.flesh)])
    broken.units[1].layers = [0]
    Fixtures.expect(.badTarget) {
      try broken.act(1, on: 1)
    }
    var machine = battle([layer(.energy)])
    machine.units[1].layers = [10]
    Fixtures.expect(.badTarget) {
      try machine.act(1, on: 1)
    }
    var unit = machine.units[1]
    XCTAssertTrue(
      unit.mend(30, from: heal).isEmpty
    )
  }

  /// The plain choice heals when that
  /// mends more than its hit wears off.
  func testPlainChoiceHeals() {
    var battle = battle([layer(.flesh)])
    battle.units[1].layers = [40]
    let action = battle.plainChoice?.action
    XCTAssertEqual(action?.ability, 1)
    XCTAssertEqual(action?.target, 1)
  }

  /// A bonus heal goes on the ally it
  /// mends most, after the main action.
  func testBonusHeal() {
    let prayer = Ability(
      "Prayer",
      power: 30,
      kind: .mend,
      discipline: .unarmed,
      bonus: Bonus("prayer"),
      reach: Fixtures.far
    )
    var battle = battle(
      [layer(.flesh)],
      healer: [Fixtures.poke, prayer]
    )
    battle.units[1].layers = [40]
    let turn = battle.plainChoice
    XCTAssertEqual(turn?.action?.target, 2)
    XCTAssertEqual(
      turn?.bonuses.map(\.target), [1]
    )
  }

  /// Padded cloth soaks blows but burns,
  /// and mends by half.
  func testCloth() {
    let crush = Rules.matchup(.crush, .cloth)
    let burn = Rules.matchup(.burn, .cloth)
    XCTAssertEqual(crush.percent, 50)
    XCTAssertEqual(burn.percent, 150)
    XCTAssertTrue(Kind.mend.heals)
    XCTAssertFalse(Kind.burn.heals)
  }
}
