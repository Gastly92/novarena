@testable import RuleSteward
import XCTest

final class TimelineTests: XCTestCase {
  private func unit(
    _ name: String,
    speed: Int = 100
  ) -> Unit {
    Fixtures.unit(name, speed: speed)
  }

  /// Plays `turns` turns, each unit poking
  /// the first foe up.
  private func play(
    _ battle: inout Battle,
    turns: Int
  ) throws {
    for _ in 0..<turns {
      let actor = try XCTUnwrap(battle.next)
      let side = battle.units[actor].side
      let foe = try XCTUnwrap(
        battle.units.first {
          $0.isUp && $0.side != side
        }
      )
      try battle.act(0, on: foe.id)
    }
  }

  /// Speed 125 acts 12 times in 1,000 ticks,
  /// Speed 80 eight times.
  func testFasterUnitsActMoreOften() throws {
    var battle = Battle(
      party: [unit("Fast", speed: 125)],
      foes: [unit("Slow", speed: 80)]
    )
    try play(&battle, turns: 30)
    let turns = battle.log.compactMap {
      if case let .turn(name, tick) = $0,
        tick <= 1000 {
        return name
      }
      return nil
    }
    XCTAssertEqual(
      turns.filter { $0 == "Fast" }.count, 12
    )
    XCTAssertEqual(
      turns.filter { $0 == "Slow" }.count, 8
    )
  }

  /// Same tick: the higher base Speed goes
  /// first (Speeds 141 and 142 both wait
  /// 70 ticks).
  func testTiesGoToHigherSpeed() {
    let battle = Battle(
      party: [unit("A", speed: 141)],
      foes: [unit("B", speed: 142)]
    )
    let turns = battle.units.map(\.nextTurn)
    XCTAssertEqual(turns, [70, 70])
    XCTAssertEqual(battle.next, 1)
  }

  /// Same tick and Speed: the higher health
  /// percent goes first.
  func testTiesThenGoToHealthier() throws {
    var battle = Battle(
      party: [
        unit("A"), unit("B"),
      ],
      foes: [Fixtures.unit("C", speed: 150)]
    )
    // C (Speed 150, tick 66) acts first and
    // hits A; its next turn is after 100.
    try battle.act(0, on: 0)
    XCTAssertEqual(battle.next, 1)
  }

  /// Same tick, Speed and health: the party
  /// goes first.
  func testTiesThenGoToTheParty() {
    let battle = Battle(
      party: [Fixtures.unit("A")],
      foes: [Fixtures.unit("B")]
    )
    XCTAssertEqual(battle.next, 0)
  }

  func testHeavyActionsWaitLonger() throws {
    let heavy = Ability(
      "Slam",
      power: 10,
      delivery: .physical,
      weight: .heavy
    )
    var battle = Battle(
      party: [
        Fixtures.unit(
          "A",
          abilities: [Fixtures.poke, heavy]
        ),
      ],
      foes: [Fixtures.unit("B", speed: 50)]
    )
    try battle.act(1, on: 1)
    let next = battle.units[0].nextTurn
    XCTAssertEqual(next, 250)
    XCTAssertEqual(battle.tick, 100)
  }
}
