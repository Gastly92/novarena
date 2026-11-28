@testable import Novarena
import RuleSteward
import XCTest

/// Settings, and fights played as they
/// say: turns that end by themselves, foes
/// played through, counterspells.
@MainActor
final class FightSettingsTests: XCTestCase {
  /// A unit with one poke and no movement:
  /// once it pokes, nothing's left.
  private func unit(
    _ name: String,
    speed: Int
  ) -> RuleSteward.Unit {
    RuleSteward.Unit(
      name,
      kind: "test",
      stats: Stats(speed: speed),
      layers: [
        Layer(
          "Hide",
          material: .flesh,
          points: 1000
        ),
      ],
      expertise: [:],
      abilities: [
        Ability(
          "Poke",
          power: 10,
          kind: .crush,
          discipline: .unarmed,
          reach: .ranged(10_000)
        ),
      ]
    )
  }

  /// A (quick) against B (slow), with no
  /// commander, as `settings` say.
  private func fight(
    _ settings: Settings
  ) -> Fight {
    let battle = Battle(
      party: [unit("A", speed: 150)],
      foes: [unit("B", speed: 50)]
    )
    return Fight(
      battle,
      settings: settings,
      pause: Fight.sleep
    )
  }

  /// Unset, each is its default; saved,
  /// each is read back.
  func testReadsDefaults() {
    let defaults = AppLaunch.clean(
      "settings.test"
    )
    XCTAssertEqual(
      Settings(defaults), Settings()
    )
    defaults.set(
      false, forKey: Settings.endsKey
    )
    defaults.set(
      false, forKey: Settings.stepsKey
    )
    defaults.set(
      "never", forKey: Settings.countersKey
    )
    let saved = Settings(defaults)
    XCTAssertFalse(saved.endsTurns)
    XCTAssertFalse(saved.stepsFoes)
    XCTAssertEqual(saved.counters, .never)
    XCTAssertFalse(Settings.manual.endsTurns)
  }

  /// With nothing left after the poke (no
  /// movement, no bonus), the turn ends by
  /// itself (A, quick, is up again, its
  /// action not yet taken); by hand, it
  /// waits, A's action taken.
  func testEndsTurns() {
    let ends = fight(Settings())
    XCTAssertEqual(ends.actor?.id, 0)
    ends.choose(0)
    ends.target(1)
    ends.use()
    XCTAssertFalse(ends.battle.hasActed)
    let waits = fight(.manual)
    waits.choose(0)
    waits.target(1)
    waits.use()
    XCTAssertTrue(waits.battle.hasActed)
  }

  /// Not stepping, foes' turns play
  /// through to the party's.
  func testPlaysFoesThrough() {
    var settings = Settings.manual
    settings.stepsFoes = false
    let through = fight(settings)
    through.endTurn()
    XCTAssertFalse(through.isFoesTurn)
    XCTAssertEqual(through.actor?.id, 0)
  }

  /// Ashka's Fireball near Isolde, with
  /// counterspells set to `answer`, Ashka's
  /// move just taken.
  private func countering(
    _ answer: Settings.Answer
  ) -> Fight {
    var settings = Settings.manual
    settings.counters = answer
    let fight = Fight(
      Fight.Stage.countering.battle,
      settings: settings,
      pause: Fight.sleep
    )
    fight.play(0)
    fight.endTurn()
    fight.endTurn()
    fight.advance()
    return fight
  }

  /// Set to always or never, nobody is
  /// asked, and the spell is countered or
  /// not; set to ask, skipping stops at the
  /// question.
  func testCounters() {
    let always = countering(.always)
    XCTAssertNil(always.question)
    always.advance()
    XCTAssertTrue(
      always.shown.contains(
        "Isolde counters it"
      )
    )
    let never = countering(.never)
    XCTAssertNil(never.question)
    never.advance()
    XCTAssertFalse(
      never.shown.contains {
        $0.contains("counters")
      }
    )
    let ask = countering(.ask)
    ask.skip()
    XCTAssertNotNil(ask.question)
    XCTAssertTrue(ask.isFoesTurn)
  }

  /// Answering while foes play through goes
  /// on to the party's turn.
  func testAnswersThenPlaysThrough() {
    var settings = Settings.manual
    settings.stepsFoes = false
    let fight = Fight(
      Fight.Stage.countering.battle,
      settings: settings,
      pause: Fight.sleep
    )
    fight.play(0)
    fight.endTurn()
    fight.endTurn()
    XCTAssertNotNil(fight.question)
    fight.answer(true)
    XCTAssertFalse(fight.isFoesTurn)
    let asked = countering(.ask)
    asked.answer(false)
    XCTAssertNil(asked.question)
  }
}
