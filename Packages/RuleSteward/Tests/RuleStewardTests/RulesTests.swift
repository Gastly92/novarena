@testable import RuleSteward
import XCTest

final class RulesTests: XCTestCase {
  func testWaitIs10000OverSpeed() {
    let wait = { (speed: Int) in
      Rules.wait(
        speed: speed, weight: .normal
      )
    }
    XCTAssertEqual(wait(100), 100)
    XCTAssertEqual(wait(125), 80)
    XCTAssertEqual(wait(80), 125)
    XCTAssertEqual(wait(95), 105)
  }

  func testWeightScalesTheWait() {
    let light = Rules.wait(
      speed: 100, weight: .light
    )
    let heavy = Rules.wait(
      speed: 100, weight: .heavy
    )
    XCTAssertEqual(light, 75)
    XCTAssertEqual(heavy, 150)
  }

  func testIntensityRisesEachRound() {
    let level = Rules.intensity(at:)
    XCTAssertEqual(level(0), 92)
    XCTAssertEqual(level(99), 92)
    XCTAssertEqual(level(100), 93)
    XCTAssertEqual(level(1000), 102)
  }

  /// Power, scaled by expertise, then by
  /// intensity: Gerald (an expert, 120%)
  /// cuts for 80 × 120% = 96, Ashka (a
  /// master of fire, 140%) throws a
  /// Fireball for 90 × 140% = 126.
  func testDamageFormula() {
    let cut = Unit.gerald.abilities[0]
    XCTAssertEqual(
      Rules.damage(
        cut, by: .gerald, intensity: 100
      ),
      96
    )
    let fireball = Unit.ashka.abilities[1]
    XCTAssertEqual(
      Rules.damage(
        fireball, by: .ashka, intensity: 50
      ),
      63
    )
  }

  /// Levels 1 to 5 bring 60% to 140%;
  /// missing disciplines count as 1.
  func testExpertise() {
    let levels = [0, 1, 2, 3, 4, 5, 9]
      .map(Rules.expertise)
    XCTAssertEqual(
      levels,
      [60, 60, 80, 100, 120, 140, 140]
    )
    XCTAssertEqual(
      Unit.gerald.level(.fire), 1
    )
  }

  /// The table, with normal where it says
  /// nothing; a layer's own matchups win.
  func testMatchups() {
    XCTAssertEqual(
      Rules.matchup(.shock, .energy),
      Matchup(200)
    )
    XCTAssertEqual(
      Rules.matchup(.slash, .energy),
      .normal
    )
    let hide = Unit.ashka.layers[0]
    XCTAssertEqual(
      hide.matchup(.burn), .immune
    )
    XCTAssertEqual(
      hide.matchup(.slash), .normal
    )
    XCTAssertEqual(Kind.shock.name, "shock")
    XCTAssertEqual(
      Material.wood.name, "wood"
    )
    XCTAssertEqual(
      Discipline.shields.name, "shields"
    )
  }

  /// Moving stretches the wait: 90% for
  /// none, 1% more per twentieth of the
  /// range, 110% for all; a unit that
  /// can't move waits as usual.
  func testPace() {
    XCTAssertEqual(
      Rules.pace(moved: 0, of: 300), 90
    )
    XCTAssertEqual(
      Rules.pace(moved: 14, of: 300), 90
    )
    XCTAssertEqual(
      Rules.pace(moved: 150, of: 300), 100
    )
    XCTAssertEqual(
      Rules.pace(moved: 300, of: 300), 110
    )
    XCTAssertEqual(
      Rules.pace(moved: 0, of: 0), 100
    )
    XCTAssertEqual(
      Rules.wait(
        speed: 100, weight: .heavy, pace: 90
      ),
      135
    )
  }
}
