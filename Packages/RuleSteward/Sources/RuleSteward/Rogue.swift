/// A rogue, who dodges (see `Reaction`).
public extension Unit {
  /// A halfling rogue: small and quick,
  /// light leathers over a plain body; a
  /// shortsword, and a dagger thrown on
  /// top each turn. Dodges the first
  /// weapon aimed at her each round, for
  /// stamina.
  static let wren = Unit(
    "Wren",
    kind: "halfling rogue",
    stats: Stats(speed: 110),
    layers: [
      Layer(
        "Leathers",
        material: .leather,
        points: 80
      ),
      Layer(
        "Body",
        material: .flesh,
        points: 50
      ),
    ],
    expertise: [.blades: 4],
    abilities: [
      Ability(
        "Shortsword",
        power: 45,
        kind: .slash,
        discipline: .blades
      ),
      Ability(
        "Dagger Throw",
        power: 20,
        kind: .pierce,
        discipline: .blades,
        bonus: Bonus("throw"),
        reach: .ranged(300),
        measure: .step
      ),
    ],
    size: .small,
    pools: [
      Pool(
        .movement,
        maximum: 400,
        measure: .step
      ),
      Pool(
        .stamina,
        maximum: 60,
        refill: 10
      ),
    ],
    reactions: [.dodge]
  )
}
