@testable import Novarena
import RuleSteward
import XCTest

/// The sample battle's stages, for the
/// screens, and who's up or down in them.
@MainActor
final class FightStageTests: XCTestCase {
  /// Each battle screen has its stage; the
  /// others none.
  func testStagesByScreen() {
    XCTAssertEqual(
      Fight.Stage(screen: .battleEnd), .end
    )
    XCTAssertNil(Fight.Stage(screen: .home))
  }

  /// Eleven turns in, Ashka and Oswin are
  /// exposed, and it's Oswin's turn.
  func testExposed() {
    let fight = Fight(stage: .exposed)
    let bare = fight.battle.units.filter {
      $0.isUp && $0.isExposed
    }
    let names = bare.map(\.unit.name)
    XCTAssertEqual(names, ["Oswin", "Ashka"])
    XCTAssertEqual(fight.actor?.id, 1)
  }

  /// At the end, only Gerald stands; the
  /// rest have fallen, party first.
  func testFallen() {
    let end = Fight(stage: .end)
    XCTAssertEqual(
      end.fallen.map(\.unit.name),
      ["Oswin", "Ashka", "Kestrel-9"]
    )
    let party = end.standing(.party)
    XCTAssertEqual(
      party.map(\.unit.name), ["Gerald"]
    )
  }
}
