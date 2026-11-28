@testable import Novarena
import RuleSteward
import XCTest

/// The party's commander on screen: its
/// turn, its orders and its seat in the
/// turn order.
@MainActor
final class FightCommandTests: XCTestCase {
  /// Two rounds on, the commander is up:
  /// first in the turn order, nothing to
  /// plan or move, Oswin worn enough to
  /// restore. Restoring him ends its turn.
  func testCommands() {
    let fight = Fight(stage: .commanding)
    XCTAssertTrue(fight.isCommanding)
    XCTAssertFalse(fight.isFoesTurn)
    guard case .commander = fight.seats.first
    else {
      XCTFail("Commander not first")
      return
    }
    XCTAssertEqual(fight.seats.count, 5)
    XCTAssertTrue(fight.queueAfter.isEmpty)
    XCTAssertNil(fight.rim)
    fight.place(Point(x: 500, y: 500))
    XCTAssertNil(fight.ghost)
    let battle = fight.battle
    XCTAssertTrue(
      battle.canCommand(.restore(1))
    )
    XCTAssertTrue(
      battle.canCommand(.ward(0))
    )
    fight.command(.restore(1))
    XCTAssertFalse(fight.isCommanding)
    let worn = battle.units[1].layers
      .reduce(0, +)
    let now = fight.battle.units[1].layers
      .reduce(0, +)
    XCTAssertGreaterThan(now, worn)
  }

  /// Warding Gerald hands over to Ashka,
  /// whose turn begins; he can't be warded
  /// again. The commander's seat comes
  /// after the units already ahead of it.
  func testWards() {
    let fight = Fight(stage: .warded)
    XCTAssertEqual(
      fight.battle.units[0].wards, 3
    )
    XCTAssertTrue(fight.isFoesTurn)
    XCTAssertFalse(
      fight.battle.canCommand(.ward(0))
    )
    let slot = fight.seats.firstIndex {
      if case .commander = $0 {
        true
      } else {
        false
      }
    }
    XCTAssertNotNil(slot)
    XCTAssertNotEqual(slot, 0)
  }

  /// Only its own screens and real fights
  /// have a commander; it stays for a
  /// fight again. With no commander, no
  /// seat; once over, no seats.
  func testWho() {
    XCTAssertNil(Fight().battle.commander)
    let real = Fight(
      party: [.gerald],
      foes: [.ashka]
    )
    real.restart()
    XCTAssertNotNil(real.battle.commander)
    let plain = Fight()
    XCTAssertEqual(
      plain.seats.count, plain.queue.count
    )
    XCTAssertTrue(
      Fight(stage: .end).seats.isEmpty
    )
  }
}
