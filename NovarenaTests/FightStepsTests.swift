@testable import Novarena
import RuleSteward
import XCTest

/// Foes' turns a step at a time, and the
/// orbit arrows at an edge.
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
  /// the orbit arrows follow it: the rim
  /// is his range round him, clockwise
  /// sits below the planned spot and goes
  /// down, the other way above. Away from
  /// an edge or a unit, on a foe's turn,
  /// or once it's over, there's no rim.
  func testOrbits() throws {
    let edge = Fight(stage: .edge)
    let gerald = edge.battle.units[0]
    let rim = try XCTUnwrap(edge.rim)
    XCTAssertEqual(rim.center, gerald.place)
    XCTAssertEqual(rim.radius, edge.moveLeft)
    let below = edge.orbitSpot(.clockwise)
    let above = edge.orbitSpot(
      .counterclockwise
    )
    XCTAssertGreaterThan(below?.y ?? 0, 200)
    XCTAssertLessThan(above?.y ?? 200, 200)
    edge.nudge(.clockwise, by: 1)
    let moved = try XCTUnwrap(edge.ghost)
    XCTAssertGreaterThan(moved.y, 200)
    let start = Fight()
    XCTAssertNil(start.rim)
    XCTAssertNil(start.orbitSpot(.clockwise))
    XCTAssertNil(Fight(stage: .foes).rim)
    XCTAssertNil(Fight(stage: .end).rim)
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
}
