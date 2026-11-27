@testable import RuleSteward
import XCTest

final class ForecastTests: XCTestCase {
  /// Gerald (0) and Oswin (1) against Ashka
  /// (2) and Kestrel-9 (3), all in reach;
  /// Gerald's turn.
  private func sample() -> Battle {
    Battle(
      party: [.gerald, .oswin],
      foes: [.ashka, .kestrel],
      places: Fixtures.together(4)
    )
  }

  /// It says exactly what acting does, and
  /// leaves the battle as it was: Sword
  /// Cut, 80 × 120% = 96, at 92% 88, off
  /// Ashka's 250-point hide.
  func testMatchesTheAction() throws {
    let battle = sample()
    let forecast = try battle.forecast(
      0, on: 2
    )
    XCTAssertEqual(
      forecast,
      Forecast(
        strike: Strike(
          hit: 2,
          losses: [
            Loss(
              layer: 0, lost: 88, left: 162
            ),
          ],
          exposes: false,
          knocksOut: false,
          immune: false
        ),
        queue: [2, 3, 1, 0],
        winner: nil
      )
    )
    XCTAssertTrue(battle.log.isEmpty)
    var acted = battle
    try acted.act(0, on: 2)
    let hide = acted.units[2].layers
    XCTAssertEqual(hide, [162])
    XCTAssertEqual(
      acted.queue, forecast.queue
    )
  }

  /// Against layers, what each loses.
  func testLayers() throws {
    let strike = try sample()
      .forecast(0, on: 3).strike
    XCTAssertEqual(strike?.hit, 3)
    XCTAssertEqual(
      strike?.losses,
      [Loss(layer: 0, lost: 88, left: 12)]
    )
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
    let strike = try battle.forecast(
      0, on: 0
    ).strike
    XCTAssertEqual(strike?.hit, 1)
    XCTAssertEqual(
      strike?.losses.first?.lost, 9
    )
  }

  func testImmune() throws {
    let flame = Fixtures.hit(
      "Flame", power: 10, kind: .burn
    )
    let ember = Layer(
      "Ember",
      material: .ember,
      points: 100,
      matchups: [.burn: .immune]
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
          layers: [ember]
        ),
      ]
    )
    let strike = try battle.forecast(
      0, on: 1
    ).strike
    XCTAssertEqual(strike?.immune, true)
    XCTAssertEqual(strike?.losses, [])
  }

  /// Breaking the last layer exposes; it
  /// doesn't knock out.
  func testExposes() throws {
    let battle = Battle(
      party: [Fixtures.unit("Gerald")],
      foes: [
        Fixtures.unit(
          "Rat", speed: 50, hide: 5
        ),
      ]
    )
    let strike = try battle.forecast(
      0, on: 1
    ).strike
    XCTAssertEqual(strike?.exposes, true)
    XCTAssertEqual(strike?.knocksOut, false)
  }

  /// A finishing blow ends the battle: no
  /// queue, and a winner.
  func testWinner() throws {
    let battle = Battle(
      party: [Fixtures.unit("Gerald")],
      foes: [
        Fixtures.unit(
          "Rat", speed: 50, hide: 0
        ),
      ]
    )
    let forecast = try battle.forecast(
      0, on: 1
    )
    XCTAssertEqual(
      forecast.strike?.knocksOut, true
    )
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
