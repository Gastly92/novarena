@testable import Novarena
import RuleSteward
import XCTest

/// Foes' turns a step at a time, and
/// nudges at an edge.
@MainActor
final class FightStepsTests: XCTestCase {
  /// After Gerald waits, Ashka's turn plays
  /// a step at a time: it begins, she
  /// moves, throws a Fireball, and ends;
  /// skipping plays the rest to Oswin's
  /// turn. On the party's turn there's no
  /// step to take.
  func testFoesStepByStep() {
    let fight = Fight(stage: .foes)
    XCTAssertTrue(fight.isFoesTurn)
    XCTAssertEqual(
      fight.shown,
      ["Ashka moves to (717, 333)"]
    )
    XCTAssertTrue(fight.queueAfter.isEmpty)
    fight.advance()
    XCTAssertEqual(
      fight.shown.first,
      "Ashka: Fireball → Oswin"
    )
    // Her turn's end goes with Kestrel-9's
    // start.
    fight.advance()
    XCTAssertEqual(
      fight.shown,
      ["Kestrel-9's turn begins"]
    )
    fight.place(Point(x: 900, y: 300))
    XCTAssertNil(fight.ghost)
    fight.skip()
    XCTAssertEqual(fight.actor?.id, 1)
    let count = fight.battle.log.count
    fight.advance()
    XCTAssertEqual(
      fight.battle.log.count, count
    )
  }

  /// Ending the party's turn shows the
  /// foe's turn beginning at once, in
  /// words.
  func testBeginsAsAStep() {
    let fight = Fight()
    fight.endTurn()
    let shown = fight.shown
    XCTAssertEqual(
      shown, ["Ashka's turn begins"]
    )
  }

  /// At the east edge of Gerald's range,
  /// down slides along it; no circling
  /// arrows there, nor away from a unit,
  /// on a foe's turn or once it's over.
  func testEdge() throws {
    let edge = Fight(stage: .edge)
    XCTAssertFalse(edge.circling)
    edge.nudge(.south, by: 10)
    let moved = try XCTUnwrap(edge.ghost)
    XCTAssertGreaterThan(moved.y, 200)
    XCTAssertFalse(Fight().circling)
    let foes = Fight(stage: .foes)
    XCTAssertFalse(foes.circling)
    let over = Fight(stage: .end)
    XCTAssertFalse(over.circling)
  }

  /// Arrows' icons: chevrons, and turning
  /// arrows for circling.
  func testSymbols() {
    XCTAssertEqual(
      Nudge.allCases.map(\.symbol),
      [
        "chevron.up", "chevron.left",
        "chevron.right", "chevron.down",
        "arrow.clockwise",
        "arrow.counterclockwise",
      ]
    )
  }

  /// At the last step of the foes' turns
  /// (Kestrel-9's ending), Next and Skip
  /// would both reach Oswin's turn, so it's
  /// the last step; Next gets there. Ashka's
  /// move isn't the last, nor the party's
  /// turn.
  func testLastStep() {
    let last = Fight(stage: .lastStep)
    XCTAssertTrue(last.isLastStep)
    last.advance()
    XCTAssertFalse(last.isFoesTurn)
    XCTAssertFalse(last.isLastStep)
    XCTAssertFalse(
      Fight(stage: .foes).isLastStep
    )
  }
}
