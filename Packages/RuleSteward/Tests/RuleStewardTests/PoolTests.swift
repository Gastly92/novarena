@testable import RuleSteward
import XCTest

/// Pools, bonus actions, snapping to the
/// edge of a move, and height.
final class PoolTests: XCTestCase {
  /// A unit with these pools and abilities,
  /// at (100, 400), against a slow foe at
  /// (`foe`, 400).
  private func battle(
    pools: [Pool],
    abilities: [Ability] = [Fixtures.poke],
    foe: Int = 700
  ) -> Battle {
    let unit = Unit(
      "A",
      kind: "test",
      stats: Stats(speed: 100),
      layers: [],
      expertise: [:],
      abilities: abilities,
      pools: pools
    )
    return Battle(
      party: [unit],
      foes: [Fixtures.unit("B", speed: 50)],
      places: [
        Point(x: 100, y: 400),
        Point(x: foe, y: 400),
      ]
    )
  }

  private let movement = Pool(
    .movement,
    maximum: 300,
    measure: .step
  )
  private let charge = Pool(
    .charge, maximum: 100, refill: 25
  )

  /// Movement fills each turn; charge gains
  /// its refill and keeps the rest, up to
  /// its maximum.
  func testResetOrCarry() throws {
    let big = Ability(
      "Big",
      power: 10,
      kind: .crush,
      discipline: .unarmed,
      costs: [.charge: 60],
      reach: Fixtures.far
    )
    var fight = battle(
      pools: [movement, charge],
      abilities: [big]
    )
    try fight.move(to: Point(x: 300, y: 400))
    try fight.use(0, on: 1)
    try fight.endTurn()
    var unit = fight.units[0]
    XCTAssertEqual(unit.pools, [100, 40])
    unit.startTurn()
    XCTAssertEqual(unit.pools, [300, 65])
    unit.startTurn()
    unit.startTurn()
    XCTAssertEqual(unit.pools, [300, 100])
    XCTAssertEqual(movement.measure, .step)
    XCTAssertNil(charge.measure)
  }

  /// A charge attack costs stamina and
  /// movement; without enough of either,
  /// it can't be used.
  func testSeveralPools() throws {
    let rush = Ability(
      "Charge",
      power: 10,
      kind: .crush,
      discipline: .unarmed,
      costs: [.movement: 200, .stamina: 30],
      reach: Fixtures.far
    )
    let stamina = Pool(
      .stamina, maximum: 50, refill: 10
    )
    var fight = battle(
      pools: [movement, stamina],
      abilities: [rush]
    )
    XCTAssertTrue(fight.canUse(0))
    try fight.use(0, on: 1)
    XCTAssertEqual(
      fight.units[0].pools, [100, 20]
    )
    XCTAssertEqual(fight.moveLeft, 100)
    let none = battle(
      pools: [movement],
      abilities: [rush]
    )
    XCTAssertFalse(none.canUse(0))
  }

  /// A wizard's cantrips share one use a
  /// turn; a rogue's dagger has its own; the
  /// main action is one a turn as ever.
  func testBonusGroups() throws {
    let cantrip = Bonus("cantrip")
    let spike = bonus("Ice Spike", cantrip)
    let jet = bonus("Water Jet", cantrip)
    let dagger = bonus(
      "Dagger", Bonus("dagger", perTurn: 1)
    )
    var fight = battle(
      pools: [movement],
      abilities: [
        Fixtures.poke, spike, jet, dagger,
      ]
    )
    try fight.use(1, on: 1)
    XCTAssertFalse(fight.canUse(2))
    Fixtures.expect(.acted) {
      try fight.use(2, on: 1)
    }
    try fight.use(3, on: 1)
    XCTAssertFalse(fight.hasActed)
    try fight.use(0, on: 1)
    XCTAssertTrue(fight.hasActed)
    Fixtures.expect(.acted) {
      try fight.use(0, on: 1)
    }
    XCTAssertEqual(cantrip.perTurn, 1)
  }

  private func bonus(
    _ name: String,
    _ group: Bonus
  ) -> Ability {
    Ability(
      name,
      power: 1,
      kind: .crush,
      discipline: .unarmed,
      bonus: group,
      reach: Fixtures.far
    )
  }

  /// A spot out of range snaps to the edge
  /// of it, on the way; one in range stays;
  /// one on someone's middle stops just
  /// short of them on the way (80 cm
  /// between middles); with nobody on
  /// turn, nothing.
  func testSnapsToTheEdge() {
    let fight = battle(pools: [movement])
    XCTAssertEqual(
      fight.reachable(
        toward: Point(x: 1000, y: 400)
      ),
      Point(x: 400, y: 400)
    )
    let near = Point(x: 200, y: 400)
    XCTAssertEqual(
      fight.reachable(toward: near), near
    )
    let crowded = battle(
      pools: [movement], foe: 300
    )
    XCTAssertEqual(
      crowded.reachable(
        toward: Point(x: 300, y: 400)
      ),
      Point(x: 220, y: 400)
    )
    var over = battle(
      pools: [movement],
      foe: 300
    )
    over.playPlainly()
    XCTAssertNil(
      over.reachable(toward: near)
    )
  }

  /// No movement pool, no moving, and no
  /// quicker turn for staying put.
  func testImmobile() throws {
    var fight = battle(pools: [])
    XCTAssertEqual(fight.moveLeft, 0)
    Fixtures.expect(.tooFar) {
      try fight.move(
        to: Point(x: 101, y: 400)
      )
    }
    // Resting gains it nothing: the usual
    // wait, 100 more.
    try fight.endTurn()
    let next = fight.units[0].nextTurn
    XCTAssertEqual(next, 200)
  }

  /// Height counts in distance: a flier
  /// 3 m up is out of a sword's reach.
  func testHeight() {
    let ground = Point(x: 0, y: 0)
    let air = Point(x: 0, y: 0, z: 300)
    XCTAssertEqual(
      ground.squared(to: air), 90_000
    )
    XCTAssertEqual(
      air.description, "(0, 0, 300)"
    )
    XCTAssertEqual(
      ground.toward(air, by: 100),
      Point(x: 0, y: 0, z: 100)
    )
  }
}
