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
    move: Int = 300,
    size: Size = .medium,
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
        speed: speed,
        move: move
      ),
      abilities: abilities,
      size: size,
      affinities: affinities,
      shield: shield,
      passives: passives
    )
  }

  /// A small physical hit that reaches
  /// across any arena.
  static let poke = Ability(
    "Poke",
    power: 10,
    delivery: .physical,
    reach: far
  )

  /// Further than any arena is wide.
  static let far = Reach.ranged(10_000)

  /// One spot for each of `count` units,
  /// all the same, so everyone reaches
  /// everyone and rules other than
  /// movement can be tested alone.
  static func together(
    _ count: Int
  ) -> [Point] {
    Array(
      repeating: Point(x: 600, y: 400),
      count: count
    )
  }

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

extension Battle {
  /// Plays the next unit's turn: `ability`
  /// (its index in the unit's list) on
  /// `target` (an id), from where it
  /// stands.
  mutating func act(
    _ ability: Int,
    on target: Int
  ) throws(Mistake) {
    try act(Turn(
      action: Action(ability, on: target)
    ))
  }

  /// The next unit's turn for using
  /// `ability` on `target`, walking up to
  /// it first.
  func approach(
    _ ability: Int,
    on target: Int
  ) -> Turn? {
    next.map {
      approach(
        ability, on: target, by: units[$0]
      )
    }
  }
}
