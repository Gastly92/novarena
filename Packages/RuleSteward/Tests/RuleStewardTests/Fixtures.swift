@testable import RuleSteward
import XCTest

/// Foundation (which XCTest brings in) has
/// its own `Unit`, for measurements; this
/// module means the game's.
typealias Unit = RuleSteward.Unit

/// Made-up units for testing one rule at a
/// time.
enum Fixtures {
  /// A unit with these stats and abilities.
  static func unit(
    _ name: String,
    speed: Int = 100,
    health: Int = 1000,
    affinities: [Element: Affinity] = [:],
    shield: Shield? = nil,
    abilities: [Ability] = [poke],
    passives: [Passive] = []
  ) -> Unit {
    Unit(
      name,
      kind: "test",
      stats: Stats(
        health: health,
        attack: 100,
        magic: 100,
        armor: 0,
        resistance: 0,
        speed: speed
      ),
      abilities: abilities,
      affinities: affinities,
      shield: shield,
      passives: passives
    )
  }

  /// A small physical hit.
  static let poke = Ability(
    "Poke", power: 10, delivery: .physical
  )

  /// Checks `work` fails with `mistake`.
  static func expect(
    _ mistake: Mistake,
    file: StaticString = #filePath,
    line: UInt = #line,
    _ work: () throws -> Void
  ) {
    XCTAssertThrowsError(
      try work(),
      file: file,
      line: line
    ) {
      XCTAssertEqual(
        $0 as? Mistake,
        mistake,
        file: file,
        line: line
      )
    }
  }

  /// The lines of `battle`'s log.
  static func lines(
    _ battle: Battle
  ) -> [String] {
    battle.log.map(\.description)
  }
}
