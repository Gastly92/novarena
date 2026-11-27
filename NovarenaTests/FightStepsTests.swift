@testable import Novarena
import RuleSteward
import XCTest

/// Foes' turns a step at a time, and how
/// the arrows bend at an edge.
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

  /// A foe's turn begins as a step of its
  /// own, in words.
  func testBeginsAsAStep() {
    let fight = Fight()
    fight.endTurn()
    fight.advance()
    let shown = fight.shown
    XCTAssertEqual(
      shown, ["Ashka's turn begins"]
    )
  }

  /// At the east edge of Gerald's range,
  /// up and down slide along the curve
  /// (bending west), east can't go, west
  /// goes straight; elsewhere on the edge
  /// arrows bend east, north or south.
  func testBends() {
    let edge = Fight(stage: .edge)
    XCTAssertEqual(
      edge.ghost, Point(x: 600, y: 200)
    )
    XCTAssertEqual(
      edge.bend(.north), .toward(.west)
    )
    XCTAssertEqual(
      edge.bend(.south), .toward(.west)
    )
    XCTAssertEqual(edge.bend(.east), .stuck)
    XCTAssertEqual(
      edge.bend(.west), .straight
    )
    let low = Fight()
    low.place(Point(x: 0, y: 700))
    XCTAssertEqual(
      low.bend(.south), .toward(.east)
    )
    XCTAssertEqual(
      low.bend(.west), .toward(.north)
    )
    let high = Fight()
    high.place(Point(x: 1000, y: 0))
    XCTAssertEqual(
      high.bend(.east), .toward(.south)
    )
    let over = Fight(stage: .end)
    XCTAssertEqual(over.bend(.north), .stuck)
    let foes = Fight(stage: .foes)
    XCTAssertEqual(foes.bend(.north), .stuck)
  }

  /// Arrows' icons: chevrons, or turning
  /// arrows that bend.
  func testSymbols() {
    XCTAssertEqual(
      Bend.straight.symbol(.north),
      "chevron.up"
    )
    XCTAssertEqual(
      Bend.stuck.symbol(.west),
      "chevron.left"
    )
    XCTAssertEqual(
      Bend.toward(.west).symbol(.south),
      "arrow.turn.down.left"
    )
    XCTAssertEqual(
      Bend.toward(.south).symbol(.east),
      "arrow.turn.right.down"
    )
  }
}
