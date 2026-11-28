@testable import RuleSteward
import XCTest

/// The commander: a place on the timeline
/// and an order a turn (restore, ward,
/// pass); wards that soak hits.
final class CommanderTests: XCTestCase {
  /// A (party) and B (foes), together,
  /// with the party's commander.
  private func battle() -> Battle {
    Battle(
      party: [Fixtures.unit("A")],
      foes: [Fixtures.unit("B")],
      places: Fixtures.together(2),
      commander: .party
    )
  }

  /// Its first turn ties the units' (100)
  /// and comes first; units wait. Passing
  /// moves its next turn on by 100.
  func testTakesItsTurn() throws {
    var fight = battle()
    XCTAssertTrue(fight.commanderUp)
    XCTAssertEqual(
      fight.commanderSlot(in: fight.queue),
      0
    )
    Fixtures.expect(.commanding) {
      try fight.act(0, on: 1)
    }
    try fight.command(.pass)
    XCTAssertEqual(
      Fixtures.lines(fight),
      ["[100] Commander"]
    )
    XCTAssertFalse(fight.commanderUp)
    XCTAssertEqual(
      fight.commander?.nextTurn, 200
    )
    XCTAssertEqual(
      fight.commanderSlot(in: fight.queue),
      2
    )
    Fixtures.expect(.notCommanding) {
      try fight.command(.pass)
    }
  }

  /// A restore gives back a quarter of the
  /// outermost standing layer, up to whole;
  /// not to a whole layer, a foe, or a unit
  /// with nothing standing.
  func testRestores() throws {
    var fight = battle()
    XCTAssertFalse(
      fight.canCommand(.restore(0))
    )
    XCTAssertFalse(
      fight.canCommand(.restore(1))
    )
    fight.units[0].layers = [500]
    XCTAssertEqual(
      fight.plainOrder, .restore(0)
    )
    try fight.command(.restore(0))
    XCTAssertEqual(
      fight.units[0].layers, [750]
    )
    XCTAssertEqual(
      Fixtures.lines(fight).last,
      "  A's Hide +250 (750)"
    )
    var bare = battle()
    bare.units[0].layers = [0]
    XCTAssertFalse(
      bare.canCommand(.restore(0))
    )
    XCTAssertEqual(bare.plainOrder, .pass)
  }

  /// A ward soaks the next three hits whole,
  /// once a unit a battle; the forecast
  /// shows no loss.
  func testWards() throws {
    var fight = battle()
    try fight.command(.ward(0))
    XCTAssertEqual(fight.units[0].wards, 3)
    XCTAssertEqual(
      Fixtures.lines(fight).last,
      "  A is warded (3 hits)"
    )
    try fight.act(Turn())
    let strike = try fight.forecast(0, on: 0)
      .strike
    XCTAssertEqual(strike?.losses, [])
    try fight.act(0, on: 0)
    XCTAssertEqual(fight.units[0].wards, 2)
    XCTAssertEqual(
      fight.units[0].layers, [1000]
    )
    XCTAssertEqual(
      Fixtures.lines(fight).last,
      "  A's ward holds (2 left)"
    )
    while !fight.commanderUp {
      try fight.act(Turn())
    }
    XCTAssertFalse(
      fight.canCommand(.ward(0))
    )
    XCTAssertFalse(
      fight.canCommand(.ward(1))
    )
  }

  /// The plain order restores the more
  /// worn of two allies.
  func testRestoresTheMostWorn() {
    var fight = Battle(
      party: [
        Fixtures.unit("A"),
        Fixtures.unit("C"),
      ],
      foes: [Fixtures.unit("B")],
      places: Fixtures.together(3),
      commander: .party
    )
    fight.units[0].layers = [800]
    fight.units[1].layers = [300]
    XCTAssertEqual(
      fight.plainOrder, .restore(1)
    )
  }

  /// Played plainly, the commander takes
  /// its turns too.
  func testPlaysPlainly() {
    var fight = battle()
    fight.playPlainly(turns: 3)
    XCTAssertEqual(
      Fixtures.lines(fight).first,
      "[100] Commander"
    )
  }

  /// No commander: never its turn.
  func testNone() {
    var fight = Battle(
      party: [Fixtures.unit("A")],
      foes: [Fixtures.unit("B")],
      places: Fixtures.together(2)
    )
    XCTAssertFalse(fight.commanderUp)
    XCTAssertNil(
      fight.commanderSlot(in: fight.queue)
    )
    Fixtures.expect(.notCommanding) {
      try fight.command(.pass)
    }
  }
}
