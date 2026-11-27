@testable import RuleSteward
import XCTest

/// What each side has seen of the other,
/// and the danger zone it gives.
final class KnowledgeTests: XCTestCase {
  /// Nothing shown at the start; then the
  /// furthest move in a turn (legs added
  /// up) and the abilities used.
  func testRecordsWhatItShows() throws {
    var battle = Battle(
      party: [Fixtures.unit("A")],
      foes: [Fixtures.unit("B", speed: 50)],
      places: [
        Point(x: 100, y: 400),
        Point(x: 1100, y: 400),
      ]
    )
    XCTAssertNil(
      battle.danger(from: 0, seenBy: .foes)
    )
    for x in [200, 250] {
      try battle.move(
        to: Point(x: x, y: 400)
      )
    }
    try battle.use(0, on: 1)
    try battle.endTurn()
    let unit = battle.units[0]
    XCTAssertEqual(unit.furthest, 150)
    XCTAssertEqual(unit.shown, [0])
    // 150 moved, plus Poke's reach.
    XCTAssertEqual(
      battle.danger(from: 0, seenBy: .foes),
      10_150
    )
    XCTAssertNil(
      battle.danger(from: 1, seenBy: .party)
    )
  }

  /// Its own side knows it all: its whole
  /// movement next turn, plus its longest
  /// reach, used or not. Sword's melee
  /// reach counts from its 40 cm edge.
  func testOwnSideKnowsAll() {
    let sword = Fixtures.hit(
      "Sword", power: 10, reach: .melee(50)
    )
    let battle = Battle(
      party: [
        Fixtures.unit(
          "A", abilities: [sword]
        ),
      ],
      foes: [Fixtures.unit("B")],
      places: Fixtures.together(2)
    )
    XCTAssertEqual(
      battle.danger(from: 0, seenBy: .party),
      300 + 40 + 50
    )
    XCTAssertNil(
      battle.danger(from: 0, seenBy: .foes)
    )
  }

  /// Heals make a zone of their own, apart
  /// from the danger: a foe's only once
  /// it has used one.
  func testCare() {
    let heal = Ability(
      "Heal",
      power: 30,
      kind: .mend,
      discipline: .unarmed,
      reach: .ranged(200)
    )
    let battle = Battle(
      party: [
        Fixtures.unit(
          "A", abilities: [Fixtures.poke]
        ),
      ],
      foes: [
        Fixtures.unit(
          "B",
          abilities: [Fixtures.poke, heal]
        ),
      ],
      places: Fixtures.together(2)
    )
    XCTAssertEqual(
      battle.care(from: 1, seenBy: .foes),
      300 + 200
    )
    XCTAssertEqual(
      battle.danger(from: 1, seenBy: .foes),
      300 + 10_000
    )
    XCTAssertNil(
      battle.care(from: 1, seenBy: .party)
    )
    XCTAssertNil(
      battle.care(from: 0, seenBy: .party)
    )
  }

  /// A unit with no movement pool reaches
  /// only as far as its skills.
  func testStillUnitReachesFromItsSpot() {
    let turret = Unit(
      "T",
      kind: "test",
      stats: Stats(speed: 100),
      layers: [],
      expertise: [:],
      abilities: [Fixtures.poke],
      pools: []
    )
    let battle = Battle(
      party: [turret],
      foes: [Fixtures.unit("B")],
      places: Fixtures.together(2)
    )
    XCTAssertEqual(
      battle.danger(from: 0, seenBy: .party),
      10_000
    )
  }

  /// A unit that's down is no danger.
  func testDownIsSafe() throws {
    var battle = Battle(
      party: [Fixtures.unit("A")],
      foes: [Fixtures.unit("B", hide: 0)],
      places: Fixtures.together(2)
    )
    try battle.act(0, on: 1)
    XCTAssertNil(
      battle.danger(from: 1, seenBy: .foes)
    )
  }

  /// The round and intensity follow the
  /// clock: the first turns come at tick
  /// 100, round 2, at 93%.
  func testRoundAndIntensity() throws {
    var battle = Battle(
      party: [Fixtures.unit("A")],
      foes: [Fixtures.unit("B")],
      places: Fixtures.together(2)
    )
    XCTAssertEqual(battle.round, 1)
    XCTAssertEqual(battle.intensity, 92)
    try battle.act(0, on: 1)
    XCTAssertEqual(battle.tick, 100)
    XCTAssertEqual(battle.round, 2)
    XCTAssertEqual(battle.intensity, 93)
  }
}
