@testable import Novarena
import RuleSteward
import XCTest

/// What the battle screen says an ability
/// would do, before it's used.
@MainActor
final class PreviewTests: XCTestCase {
  /// A unit made for one case: trained
  /// unarmed, in `layers`.
  private static func unit(
    _ name: String,
    speed: Int = 100,
    layers: [Layer] = [],
    abilities: [Ability] = []
  ) -> RuleSteward.Unit {
    RuleSteward.Unit(
      name,
      kind: "test",
      stats: Stats(speed: speed),
      layers: layers,
      expertise: [.unarmed: 3],
      abilities: abilities
    )
  }

  /// A battle with everyone on one spot, so
  /// everyone is in reach.
  private func together(
    party: [RuleSteward.Unit],
    foes: [RuleSteward.Unit]
  ) -> Battle {
    Battle(
      party: party,
      foes: foes,
      places: Array(
        repeating: Point(x: 600, y: 400),
        count: party.count + foes.count
      )
    )
  }

  /// The lines for the first ability on
  /// `target`.
  private func lines(
    _ battle: Battle,
    on target: Int
  ) throws -> [String] {
    try battle.forecast(0, on: target)
      .lines(for: target, in: battle)
  }

  /// Gerald's Sword Cut, 80 × 120% = 96,
  /// at 92% 88: off Ashka's hide (230 to
  /// 142, 61%), or off Kestrel-9's energy
  /// shield (100 to 12). Foes' layers show
  /// in percent.
  func testLayers() throws {
    let battle = together(
      party: [.gerald, .oswin],
      foes: [.ashka, .kestrel]
    )
    XCTAssertEqual(
      try lines(battle, on: 2),
      ["Ember Hide −39%, 61% left"]
    )
    XCTAssertEqual(
      try lines(battle, on: 3),
      ["Energy Shield −88%, 12% left"]
    )
  }

  /// Oswin's Tower Shield, 150 to 62.
  func testBodyguardTakesIt() throws {
    let battle = together(
      party: [.gerald],
      foes: [.ashka, .oswin]
    )
    XCTAssertEqual(
      try lines(battle, on: 1),
      [
        "Oswin takes it instead",
        "Tower Shield −59%, 41% left",
      ]
    )
  }

  /// The party's own layers stay exact;
  /// foes' are in percent, rounded down,
  /// but never 0% while some is left.
  func testExactForTheParty() {
    let battle = Battle(
      party: [.gerald],
      foes: [.ashka]
    )
    let gerald = battle.units[0]
    XCTAssertEqual(
      gerald.says(0, left: 150),
      "Plate 150 of 190"
    )
    XCTAssertEqual(
      gerald.says(0, losing: 40, left: 150),
      "Plate −40, 150 left"
    )
    XCTAssertEqual(
      gerald.says(1, gaining: 20, now: 50),
      "Body +20, now 50"
    )
    let ashka = battle.units[1]
    XCTAssertEqual(
      ashka.says(0, left: 1),
      "Ember Hide 1%"
    )
    XCTAssertEqual(
      ashka.says(0, left: 0),
      "Ember Hide 0%"
    )
  }

  func testImmune() throws {
    let flame = Ability(
      "Flame",
      power: 50,
      kind: .burn,
      discipline: .unarmed
    )
    let battle = together(
      party: [
        Self.unit(
          "Caster", abilities: [flame]
        ),
      ],
      foes: [.ashka]
    )
    XCTAssertEqual(
      try lines(battle, on: 1), ["Immune"]
    )
  }

  /// Breaking the last layer exposes.
  func testExposes() throws {
    let hide = Layer(
      "Hide", material: .flesh, points: 10
    )
    let battle = together(
      party: [.gerald],
      foes: [
        Self.unit(
          "Rat", speed: 50, layers: [hide]
        ),
      ]
    )
    XCTAssertEqual(
      try lines(battle, on: 1),
      [
        "Hide −100%, 0% left",
        "Exposed: the next hit knocks out",
      ]
    )
  }

  /// With nothing left, any hit knocks out.
  func testFinishingBlow() throws {
    let battle = together(
      party: [.gerald],
      foes: [Self.unit("Rat", speed: 50)]
    )
    XCTAssertEqual(
      try lines(battle, on: 1),
      ["Knocked out", "Wins the battle"]
    )
  }

  /// A turn with no action says nothing
  /// about a foe.
  func testNoAction() throws {
    let battle = Battle(
      party: [.gerald],
      foes: [.ashka]
    )
    let lines = try battle.forecast(Turn())
      .lines(for: 1, in: battle)
    XCTAssertTrue(lines.isEmpty)
  }

  /// Costs, a line per pool, by name.
  func testCostLines() {
    let rush = Ability(
      "Rush",
      power: 10,
      kind: .crush,
      discipline: .unarmed,
      costs: [.stamina: 30, .movement: 200]
    )
    XCTAssertEqual(
      rush.costLines,
      [
        "Costs 200 movement",
        "Costs 30 stamina",
      ]
    )
  }

  /// Reach in each skill's own measure.
  func testReachLabels() {
    typealias Unit = RuleSteward.Unit
    let cut = Unit.gerald.abilities[0]
    XCTAssertEqual(
      cut.reachLabel, "Melee, 1 reach"
    )
    let fireball = Unit.ashka.abilities[1]
    XCTAssertEqual(
      fireball.reachLabel, "Range 10 casts"
    )
    let beam = Unit.kestrel.abilities[1]
    XCTAssertEqual(
      beam.reachLabel, "Range 9 arcs"
    )
  }

  func testWeightLabels() {
    let labels = [
      Weight.light, .normal, .heavy,
    ].map(\.label)
    XCTAssertEqual(
      labels, ["Light", nil, "Heavy"]
    )
  }

  /// The screen's previews: none until an
  /// ability is picked; the turn order
  /// after waiting even then. At the
  /// start, every foe is out of Gerald's
  /// reach.
  func testFightPreviews() {
    let start = Fight()
    let none = start.preview(of: 2)
    XCTAssertTrue(none.isEmpty)
    XCTAssertEqual(
      start.queueAfter.last?.unit.name,
      "Gerald"
    )
    let aiming = Fight(stage: .aiming)
    XCTAssertEqual(
      aiming.preview(of: 2),
      ["Out of reach"]
    )
    XCTAssertEqual(
      aiming.queueAfter.map(\.unit.name),
      [
        "Ashka", "Kestrel-9",
        "Oswin", "Gerald",
      ]
    )
  }
}
