@testable import Novarena
import RuleSteward
import XCTest

/// Reactions on screen: a dodge in the
/// preview, a counterspell asked for on a
/// foe's turn.
@MainActor
final class FightReactionTests: XCTestCase {
  /// Isolde's Chill Touch on Wren would be
  /// dodged.
  func testDodgePreview() {
    let fight = Fight(stage: .dodging)
    XCTAssertEqual(fight.actor?.id, 1)
    XCTAssertEqual(
      fight.preview(of: 3),
      ["Wren dodges it"]
    )
  }

  /// Ashka's Fireball, cast near Isolde:
  /// the party is asked. Countering it
  /// spends Isolde's mana and nothing
  /// lands; letting it through, it lands.
  func testCounters() throws {
    let fight = Fight(stage: .countering)
    let ask = try XCTUnwrap(fight.question)
    XCTAssertEqual(ask.reactor.id, 1)
    XCTAssertEqual(ask.spell, "Fireball")
    fight.advance()
    XCTAssertTrue(
      fight.shown.contains(
        "Isolde counters it"
      )
    )
    XCTAssertNil(fight.question)
    let through = Fight(stage: .countering)
    through.advance(reacting: false)
    XCTAssertFalse(
      through.shown.contains {
        $0.contains("counters")
      }
    )
    XCTAssertNil(Fight().question)
  }

  /// A spell at a foe who can counter it
  /// previews as countered.
  func testCounteredPreview() throws {
    let battle = Battle(
      party: [.isolde],
      foes: [.isolde],
      places: [
        Point(x: 500, y: 400),
        Point(x: 700, y: 400),
      ]
    )
    let lines = try battle.forecast(0, on: 1)
      .lines(for: 1, in: battle)
    XCTAssertEqual(lines, ["Countered"])
  }
}
