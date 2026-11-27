@testable import RuleSteward
import XCTest

/// Foundation (which XCTest brings in) has
/// its own `Unit`, for measurements; this
/// module means the game's.
typealias Unit = RuleSteward.Unit

/// Made-up units for testing one rule at a
/// time.
enum Fixtures {
  /// A unit with these stats and abilities,
  /// trained (100%) unarmed, wearing one
  /// flesh hide of `hide` points, or
  /// `layers`; with no hide, it's exposed
  /// from the start.
  static func unit(
    _ name: String,
    speed: Int = 100,
    move: Int = 300,
    size: Size = .medium,
    hide: Int = 1000,
    layers: [Layer]? = nil,
    abilities: [Ability] = [poke],
    passives: [Passive] = []
  ) -> Unit {
    let skin = Layer(
      "Hide", material: .flesh, points: hide
    )
    return Unit(
      name,
      kind: "test",
      stats: Stats(speed: speed),
      layers: layers
        ?? (hide > 0 ? [skin] : []),
      expertise: [.unarmed: 3],
      abilities: abilities,
      size: size,
      pools: [
        Pool(.movement, maximum: move),
      ],
      passives: passives
    )
  }

  /// An unarmed hit of `kind`.
  static func hit(
    _ name: String,
    power: Int,
    kind: Kind = .crush,
    weight: Weight = .normal,
    reach: Reach = far
  ) -> Ability {
    Ability(
      name,
      power: power,
      kind: kind,
      discipline: .unarmed,
      weight: weight,
      reach: reach
    )
  }

  /// A small blunt hit that reaches across
  /// any arena.
  static let poke = hit("Poke", power: 10)

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
}
