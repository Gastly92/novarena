@testable import RuleSteward
import XCTest

/// Reactions: a dodge by itself, a
/// counterspell when its side says so, and
/// one a round.
final class ReactionTests: XCTestCase {
  /// A unit with `reactions`, stamina and
  /// mana (100 each), a poke and a spell.
  private func unit(
    _ name: String,
    speed: Int = 100,
    reactions: [Reaction] = [],
    passives: [Passive] = []
  ) -> Unit {
    Unit(
      name,
      kind: "test",
      stats: Stats(speed: speed),
      layers: [
        Layer(
          "Hide",
          material: .flesh,
          points: 1000
        ),
      ],
      expertise: [.unarmed: 3],
      abilities: [Fixtures.poke, Self.spell],
      pools: [
        Pool(.movement, maximum: 300),
        Pool(.stamina, maximum: 100),
        Pool(.mana, maximum: 100),
      ],
      passives: passives,
      reactions: reactions
    )
  }

  /// B, who counters spells.
  private var mage: Unit {
    unit("B", reactions: [.counterspell])
  }

  /// A spell (cast) costing 10 mana.
  private static let spell = Ability(
    "Zap",
    power: 10,
    kind: .shock,
    discipline: .unarmed,
    costs: [.mana: 10],
    reach: Fixtures.far,
    measure: .cast
  )

  /// A dodges the first poke each round,
  /// for 40 stamina, but not a spell;
  /// the next poke lands.
  func testDodges() throws {
    var fight = Battle(
      party: [
        unit("A", reactions: [.dodge]),
      ],
      foes: [
        unit("X", speed: 200),
        unit("Y", speed: 190),
      ],
      places: Fixtures.together(3)
    )
    let seen = try fight.forecast(0, on: 0)
    XCTAssertEqual(
      seen.strike?.dodged, true
    )
    try fight.act(0, on: 0)
    try fight.act(0, on: 0)
    XCTAssertEqual(
      Fixtures.lines(fight),
      [
        "[50] X",
        "  X: Poke → A",
        "  A dodges",
        "[52] Y",
        "  Y: Poke → A",
        "  A's Hide -9 (991)",
      ]
    )
    XCTAssertEqual(
      fight.units[0].amount(in: .stamina), 60
    )
    var spelled = Battle(
      party: [
        unit("A", reactions: [.dodge]),
      ],
      foes: [unit("X", speed: 200)],
      places: Fixtures.together(2)
    )
    try spelled.act(1, on: 0)
    XCTAssertFalse(
      Fixtures.lines(spelled).contains(
        "  A dodges"
      )
    )
  }

  /// Without the stamina, no dodge.
  func testTiredDoesNotDodge() {
    let tired = Unit(
      "A",
      kind: "test",
      stats: Stats(speed: 100),
      layers: [],
      expertise: [:],
      abilities: [Fixtures.poke],
      pools: [Pool(.stamina, maximum: 10)],
      reactions: [.dodge]
    )
    let fight = Battle(
      party: [tired],
      foes: [unit("X", speed: 200)],
      places: Fixtures.together(2)
    )
    XCTAssertFalse(
      fight.canReact(fight.units[0], .dodge)
    )
  }

  /// B counters X's spell near it, for 50
  /// mana; X still pays. Said no, it lands.
  /// Not a poke, nor an ability it lacks.
  func testCounters() throws {
    let start = Battle(
      party: [
        unit("A"),
        mage,
      ],
      foes: [unit("X", speed: 200)],
      places: Fixtures.together(3)
    )
    XCTAssertEqual(
      start.counter(1, on: 0), 1
    )
    XCTAssertNil(start.counter(0, on: 0))
    XCTAssertNil(start.counter(1, on: 2))
    XCTAssertNil(start.counter(9, on: 0))
    let seen = try start.forecast(1, on: 0)
    XCTAssertEqual(
      seen.strike?.countered, true
    )
    var fight = start
    try fight.act(1, on: 0)
    XCTAssertEqual(
      Fixtures.lines(fight),
      [
        "[50] X",
        "  X: Zap → A",
        "  B counters it",
      ]
    )
    XCTAssertEqual(
      fight.units[1].amount(in: .mana), 50
    )
    XCTAssertEqual(
      fight.units[2].amount(in: .mana), 90
    )
    XCTAssertEqual(
      fight.units[0].layers, [1000]
    )
    var allowed = start
    try allowed.use(
      1, on: 0, reacting: false
    )
    XCTAssertEqual(
      allowed.units[0].layers, [991]
    )
  }

  /// Not from too far.
  func testCountersNear() {
    let far = Battle(
      party: [
        unit("A"),
        mage,
      ],
      foes: [unit("X", speed: 200)],
      places: [
        Point(x: 100, y: 400),
        Point(x: 100, y: 400),
        Point(x: 1100, y: 400),
      ]
    )
    XCTAssertNil(far.counter(1, on: 0))
  }

  /// A bodyguard who stepped in this round
  /// can't dodge too.
  func testOneARound() throws {
    var fight = Battle(
      party: [
        unit("A"),
        unit(
          "G",
          reactions: [.dodge],
          passives: [.bodyguard]
        ),
      ],
      foes: [
        unit("X", speed: 200),
        unit("Y", speed: 190),
      ],
      places: Fixtures.together(4)
    )
    try fight.act(0, on: 0)
    try fight.act(0, on: 1)
    XCTAssertEqual(
      Fixtures.lines(fight),
      [
        "[50] X",
        "  X: Poke → A",
        "  G guards A",
        "  G's Hide -9 (991)",
        "[52] Y",
        "  Y: Poke → G",
        "  G's Hide -9 (982)",
      ]
    )
  }
}
