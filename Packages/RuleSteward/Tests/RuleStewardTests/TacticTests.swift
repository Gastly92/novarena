@testable import RuleSteward
import XCTest

/// The stand-in AI's plain choices.
final class TacticTests: XCTestCase {
  /// Melee, half a metre edge to edge.
  private let jab = Ability(
    "Jab",
    power: 10,
    kind: .crush,
    discipline: .unarmed
  )

  /// The plain choice picks a foe it can
  /// reach this turn over a bigger hit it
  /// can't.
  func testPlainChoicePrefersReach() {
    let big = Ability(
      "Big",
      power: 90,
      kind: .crush,
      discipline: .unarmed
    )
    let battle = Battle(
      party: [
        Fixtures.unit(
          "A", abilities: [jab, big]
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

  /// A knockout beats any amount of wear:
  /// an exposed foe is finished first.
  func testFinishesTheExposed() {
    let battle = Battle(
      party: [Fixtures.unit("A")],
      foes: [
        Fixtures.unit("Whole", speed: 50),
        Fixtures.unit(
          "Bare", speed: 50, hide: 0
        ),
      ],
      places: Fixtures.together(3)
    )
    XCTAssertEqual(
      battle.plainChoice?.action,
      Action(0, on: 2)
    )
  }
}
