@testable import RuleSteward
import XCTest

final class MovementTests: XCTestCase {
  /// A (party, Move 300) at (100, 400) and
  /// B (a foe, slower) at (`x`, 400), with
  /// `abilities` for A.
  private func duel(
    _ abilities: [Ability] = [jab],
    foe: Unit = Fixtures.unit(
      "B", speed: 50
    ),
    at x: Int = 500
  ) -> Battle {
    Battle(
      party: [
        Fixtures.unit(
          "A", abilities: abilities
        ),
      ],
      foes: [foe],
      places: [
        Point(x: 100, y: 400),
        Point(x: x, y: 400),
      ]
    )
  }

  /// Melee, half a metre edge to edge.
  private static let jab = Ability(
    "Jab", power: 10, delivery: .physical
  )

  func testDeployment() {
    let battle = Battle(
      party: [.gerald, .oswin],
      foes: [.ashka]
    )
    XCTAssertEqual(
      battle.units.map(\.place),
      [
        Point(x: 150, y: 200),
        Point(x: 150, y: 600),
        Point(x: 1050, y: 400),
      ]
    )
  }

  /// Out of reach, it walks up first.
  func testMovesThenActs() throws {
    var battle = duel()
    Fixtures.expect(.outOfReach) {
      try battle.act(0, on: 1)
    }
    try battle.act(Turn(
      before: Point(x: 400, y: 400),
      action: Action(0, on: 1)
    ))
    XCTAssertEqual(
      Fixtures.lines(battle).prefix(3),
      [
        "[100] A",
        "  A moves to (400, 400)",
        "  A: Jab → B",
      ]
    )
    XCTAssertEqual(
      battle.units[0].place,
      Point(x: 400, y: 400)
    )
  }

  /// The move can be split around the
  /// action, as long as the two legs add
  /// up to the Move.
  func testSplitMove() throws {
    let bolt = Ability(
      "Bolt",
      power: 10,
      delivery: .special,
      reach: .ranged(400)
    )
    var battle = duel([bolt])
    let out = Turn(
      before: Point(x: 300, y: 400),
      action: Action(0, on: 1),
      after: Point(x: 200, y: 400)
    )
    try battle.act(out)
    XCTAssertEqual(
      Fixtures.lines(battle).last,
      "  A moves to (200, 400)"
    )
    var far = duel([bolt])
    Fixtures.expect(.tooFar) {
      try far.act(Turn(
        before: Point(x: 300, y: 400),
        after: Point(x: 99, y: 400)
      ))
    }
    XCTAssertTrue(far.log.isEmpty)
  }

  /// Spots outside the arena, or taken by
  /// another unit, are out; a downed
  /// unit's spot is free.
  func testBlocked() throws {
    var battle = duel()
    let spots = [
      Point(x: 39, y: 400),
      Point(x: 100, y: 39),
      Point(x: 381, y: 400),
      Point(x: 100, y: 761),
    ]
    let open = Arena(width: 420, height: 800)
    var edge = Battle(
      party: [Fixtures.unit("A")],
      foes: [Fixtures.unit("B")],
      arena: open,
      places: [
        Point(x: 100, y: 400),
        Point(x: 100, y: 600),
      ]
    )
    for spot in spots {
      Fixtures.expect(.blocked) {
        try edge.act(Turn(before: spot))
      }
    }
    Fixtures.expect(.blocked) {
      try battle.act(Turn(
        before: Point(x: 450, y: 400)
      ))
    }
    try edge.act(Turn(
      before: Point(x: 100, y: 520)
    ))
    XCTAssertEqual(
      edge.units[0].place.y, 520
    )
  }

  func testDownedUnitsDontBlock() throws {
    let smash = Ability(
      "Smash",
      power: 5000,
      delivery: .physical,
      reach: Fixtures.far
    )
    var battle = duel([smash])
    try battle.act(0, on: 1)
    let turn = Turn(
      before: Point(x: 500, y: 400)
    )
    XCTAssertTrue(
      battle.fits(
        battle.units[0], at: turn.before
      )
    )
  }

  /// A turn of only moving, or only
  /// waiting, takes the usual wait.
  func testMovingOnlyTakesTheUsualWait()
    throws {
    var battle = duel()
    try battle.act(Turn(
      before: Point(x: 300, y: 400)
    ))
    try battle.act(Turn())
    XCTAssertEqual(
      battle.units[0].nextTurn, 300
    )
    let forecast = try battle.forecast(
      Turn()
    )
    XCTAssertNil(forecast.strike)
  }

  /// Already in reach, it stays put.
  func testApproachInReach() {
    let battle = duel([Fixtures.poke])
    XCTAssertEqual(
      battle.approach(0, on: 1),
      Turn(action: Action(0, on: 1))
    )
  }

  /// Near enough, it walks just into reach
  /// and acts; too far, it only walks.
  func testApproachWalksUp() throws {
    let battle = duel(at: 700)
    let turn = try XCTUnwrap(
      battle.approach(0, on: 1)
    )
    XCTAssertNil(turn.action)
    XCTAssertEqual(
      turn.before, Point(x: 400, y: 400)
    )
    var walked = battle
    try walked.act(turn)
    let next = try XCTUnwrap(
      walked.approach(0, on: 1)
    )
    // 130 apart edge to edge at most:
    // 40 + 50 + 40.
    XCTAssertEqual(
      next.before, Point(x: 572, y: 400)
    )
    XCTAssertEqual(
      next.action, Action(0, on: 1)
    )
    try walked.act(next)
  }

  /// If the spot it would walk to is
  /// taken, it waits.
  func testApproachBlocked() {
    let battle = Battle(
      party: [
        Fixtures.unit(
          "A", abilities: [Self.jab]
        ),
      ],
      foes: [
        Fixtures.unit("B"),
        Fixtures.unit("Wall", speed: 1),
      ],
      places: [
        Point(x: 100, y: 400),
        Point(x: 700, y: 400),
        Point(x: 420, y: 400),
      ]
    )
    XCTAssertEqual(
      battle.approach(0, on: 1), Turn()
    )
  }

  /// The plain choice picks a foe it can
  /// reach this turn over a bigger hit it
  /// can't.
  func testPlainChoicePrefersReach() {
    let big = Ability(
      "Big", power: 90, delivery: .physical
    )
    let battle = Battle(
      party: [
        Fixtures.unit(
          "A", abilities: [Self.jab, big]
        ),
      ],
      foes: [
        Fixtures.unit("Far", speed: 50),
        Fixtures.unit(
          "Near", speed: 50, size: .huge
        ),
      ],
      places: [
        Point(x: 100, y: 400),
        Point(x: 1100, y: 400),
        Point(x: 500, y: 400),
      ]
    )
    let choice = battle.plainChoice
    XCTAssertEqual(
      choice?.action, Action(1, on: 2)
    )
  }

  /// No approach once the battle is over.
  func testNoApproachOnceOver() {
    var battle = duel(
      [Fixtures.poke],
      foe: Fixtures.unit("B", health: 1)
    )
    battle.playPlainly()
    XCTAssertNil(battle.approach(0, on: 1))
  }

  /// On a tie in time and speed, the
  /// smaller unit goes first.
  func testSmallerGoesFirstOnATie() {
    let battle = Battle(
      party: [Fixtures.unit("Big")],
      foes: [
        Fixtures.unit("Small", size: .small),
      ]
    )
    XCTAssertEqual(battle.queue, [1, 0])
  }
}
