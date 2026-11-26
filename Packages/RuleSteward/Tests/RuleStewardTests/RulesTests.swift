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

  /// The examples in brainstorm-2.md.
  func testDamageFormula() {
    let orc = Stats(
      health: 1,
      attack: 130,
      magic: 0,
      armor: 0,
      resistance: 0,
      speed: 1,
      move: 1
    )
    let chop = Ability(
      "Axe Chop",
      power: 100,
      delivery: .physical
    )
    XCTAssertEqual(
      Rules.damage(
        chop,
        from: orc,
        to: .gerald,
        intensity: 100
      ),
      61
    )
    let fireball = Unit.ashka.abilities[1]
    XCTAssertEqual(
      Rules.damage(
        fireball,
        from: Unit.ashka.stats,
        to: .gerald,
        intensity: 100
      ),
      128
    )
  }

  func testAffinities() {
    let fire = Ability(
      "Flame",
      power: 100,
      delivery: .special,
      element: .fire
    )
    let caster = Fixtures.unit("Caster")
    let damage = { (target: Unit) in
      Rules.damage(
        fire,
        from: caster.stats,
        to: target,
        intensity: 100
      )
    }
    let plain = Fixtures.unit("A")
    XCTAssertEqual(damage(plain), 100)
    XCTAssertEqual(damage(.ashka), 0)
    let weak = Fixtures.unit(
      "Weak", affinities: [.fire: .weak]
    )
    XCTAssertEqual(damage(weak), 150)
    let resists = Fixtures.unit(
      "Resists", affinities: [.fire: .resist]
    )
    XCTAssertEqual(damage(resists), 50)
  }
}
