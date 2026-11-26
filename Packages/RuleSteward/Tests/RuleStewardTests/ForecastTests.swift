@testable import RuleSteward
import XCTest

final class ForecastTests: XCTestCase {
  /// Gerald (0) and Oswin (1) against Ashka
  /// (2) and Kestrel-9 (3); Gerald's turn.
  private func sample() -> Battle {
    Battle(
      party: [.gerald, .oswin],
      foes: [.ashka, .kestrel]
    )
  }

  /// It says exactly what acting does, and
  /// leaves the battle as it was.
  func testMatchesTheAction() throws {
    let battle = sample()
    let forecast = try battle.forecast(
      0, on: 2
    )
    XCTAssertEqual(
      forecast,
      Forecast(
        hit: 2,
        shieldLost: 0,
        shieldLeft: 0,
        healthLost: 44,
        healthLeft: 276,
        immune: false,
        queue: [2, 3, 1, 0],
        winner: nil
      )
    )
    XCTAssertTrue(battle.log.isEmpty)
    var acted = battle
    try acted.act(0, on: 2)
    XCTAssertEqual(
      acted.units[2].health, 276
    )
    XCTAssertEqual(
      acted.queue, forecast.queue
    )
  }

  /// Against a shield, the shield's loss.
  func testShield() throws {
    let forecast = try sample()
      .forecast(0, on: 3)
    XCTAssertEqual(forecast.hit, 3)
    XCTAssertEqual(forecast.shieldLost, 30)
    XCTAssertEqual(forecast.shieldLeft, 120)
    XCTAssertEqual(forecast.healthLost, 0)
  }

  /// A bodyguard who'd step in takes it.
  func testBodyguardTakesIt() throws {
    let battle = Battle(
      party: [
        Fixtures.unit("Gerald"),
        Fixtures.unit(
          "Guard", passives: [.bodyguard]
        ),
      ],
      foes: [Fixtures.unit("X", speed: 200)]
    )
    let forecast = try battle.forecast(
      0, on: 0
    )
    XCTAssertEqual(forecast.hit, 1)
    XCTAssertEqual(forecast.healthLost, 9)
  }

  func testImmune() throws {
    let flame = Ability(
      "Flame",
      power: 10,
      delivery: .special,
      element: .fire
    )
    let battle = Battle(
      party: [
        Fixtures.unit(
          "Caster", abilities: [flame]
        ),
      ],
      foes: [
        Fixtures.unit(
          "Salamander",
          speed: 50,
          affinities: [.fire: .immune]
        ),
      ]
    )
    let forecast = try battle.forecast(
      0, on: 1
    )
    XCTAssertTrue(forecast.immune)
    XCTAssertEqual(forecast.healthLost, 0)
  }

  /// A finishing blow ends the battle: no
  /// queue, and a winner.
  func testWinner() throws {
    let battle = Battle(
      party: [Fixtures.unit("Gerald")],
      foes: [
        Fixtures.unit(
          "Rat", speed: 50, health: 5
        ),
      ]
    )
    let forecast = try battle.forecast(
      0, on: 1
    )
    XCTAssertEqual(forecast.healthLeft, 0)
    XCTAssertEqual(forecast.winner, .party)
    XCTAssertTrue(forecast.queue.isEmpty)
  }

  func testMistakes() {
    Fixtures.expect(.badTarget) {
      _ = try sample().forecast(0, on: 1)
    }
  }

  func testWeightPercent() {
    XCTAssertEqual(Weight.light.percent, 75)
    XCTAssertEqual(Weight.heavy.percent, 150)
  }
}
