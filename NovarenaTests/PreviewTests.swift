@testable import Novarena
import RuleSteward
import XCTest

/// What the battle screen says an ability
/// would do, before it's used.
@MainActor
final class PreviewTests: XCTestCase {
  /// A unit made for one case.
  private static func unit(
    _ name: String,
    health: Int = 300,
    speed: Int = 100,
    abilities: [Ability] = [],
    affinities: [Element: Affinity] = [:]
  ) -> RuleSteward.Unit {
    RuleSteward.Unit(
      name,
      kind: "test",
      stats: Stats(
        health: health,
        attack: 100,
        magic: 100,
        armor: 0,
        resistance: 0,
        speed: speed,
        move: 300
      ),
      abilities: abilities,
      affinities: affinities
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

  func testHealthAndShield() throws {
    let battle = together(
      party: [.gerald, .oswin],
      foes: [.ashka, .kestrel]
    )
    XCTAssertEqual(
      try lines(battle, on: 2),
      ["Health −44, 276 left"]
    )
    XCTAssertEqual(
      try lines(battle, on: 3),
      ["Shield −30, 120 left"]
    )
  }

  func testBodyguardTakesIt() throws {
    let battle = together(
      party: [.gerald],
      foes: [.ashka, .oswin]
    )
    XCTAssertEqual(
      try lines(battle, on: 1),
      [
        "Oswin takes it instead",
        "Health −27, 353 left",
      ]
    )
  }

  func testImmune() throws {
    let flame = Ability(
      "Flame",
      power: 50,
      delivery: .special,
      element: .fire
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

  func testFinishingBlow() throws {
    let battle = together(
      party: [.gerald],
      foes: [
        Self.unit(
          "Rat", health: 10, speed: 50
        ),
      ]
    )
    XCTAssertEqual(
      try lines(battle, on: 1),
      [
        "Health −10, 0 left",
        "Goes down",
        "Wins the battle",
      ]
    )
  }

  /// Too far to reach this turn: it walks.
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

  func testReachLabels() {
    XCTAssertEqual(
      Reach.melee(50).label, "Melee, 50 cm"
    )
    XCTAssertEqual(
      Reach.ranged(500).label, "Range 500 cm"
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
  /// ability is picked. At the start, every
  /// foe is out of Gerald's reach.
  func testFightPreviews() {
    let start = Fight()
    let none = start.preview(of: 2)
    XCTAssertTrue(none.isEmpty)
    XCTAssertTrue(start.queueAfter.isEmpty)
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
