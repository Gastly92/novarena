@testable import RuleSteward
import XCTest

/// A turn's start as a step of its own:
/// layers that recharge or regrow are
/// logged, so a screen can show them.
final class PassiveTests: XCTestCase {
  func testTurnStartIsLogged() throws {
    let worn = Fixtures.unit(
      "A",
      layers: [
        Layer(
          "Shield",
          material: .energy,
          points: 100,
          recharge: 40
        ),
        Layer(
          "Hide",
          material: .flesh,
          points: 100,
          regrows: 15
        ),
      ]
    )
    var battle = Battle(
      party: [worn],
      foes: [Fixtures.unit("B", speed: 50)],
      places: Fixtures.together(2)
    )
    battle.units[0].layers = [20, 50]
    try battle.beginTurn()
    try battle.beginTurn()
    XCTAssertEqual(
      Fixtures.lines(battle),
      [
        "[100] A",
        "  A's Shield recharges +40 (60)",
        "  A's Hide regrows +15 (65)",
      ]
    )
    try battle.use(0, on: 1)
    XCTAssertEqual(battle.log.count, 5)
  }
}
