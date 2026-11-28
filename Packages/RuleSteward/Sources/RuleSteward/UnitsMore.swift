/// More hand-made units: a cleric, an
/// archer, a golem and an ice mage, tuned
/// with the first four (see
/// `BalanceTests`).
public extension Unit {
  /// A war cleric: a padded gambeson
  /// (soaks blows, but burns) over a
  /// plain body; an expert's mace, a smite
  /// from afar that sears demons, and a
  /// prayer each turn that mends an ally
  /// (or herself): flesh fully, armor by
  /// half, machines not at all. Smite and
  /// prayer share her mana.
  static let maren = Unit(
    "Maren",
    kind: "war cleric",
    stats: Stats(speed: 95),
    layers: [
      Layer(
        "Gambeson",
        material: .cloth,
        points: 120
      ),
      Layer(
        "Body",
        material: .flesh,
        points: 60
      ),
    ],
    expertise: [.maces: 4, .faith: 4],
    abilities: [
      Ability(
        "Mace Blow",
        power: 85,
        kind: .crush,
        discipline: .maces
      ),
      Ability(
        "Smite",
        power: 60,
        kind: .radiant,
        discipline: .faith,
        costs: [.mana: 50],
        reach: .ranged(400),
        measure: .cast
      ),
      Ability(
        "Mend Wounds",
        power: 30,
        kind: .mend,
        discipline: .faith,
        costs: [.mana: 30],
        bonus: Bonus("prayer"),
        reach: .ranged(400),
        measure: .cast
      ),
    ],
    pools: [
      Pool(
        .movement,
        maximum: 300,
        measure: .step
      ),
      Pool(
        .mana,
        maximum: 100,
        refill: 15
      ),
    ],
  )

  /// A longbow archer: leather over a
  /// plain body, quick on her feet, a
  /// master of the bow who shoots from far
  /// off, with a knife up close.
  static let tamsin = Unit(
    "Tamsin",
    kind: "longbow archer",
    stats: Stats(speed: 100),
    layers: [
      Layer(
        "Leather",
        material: .leather,
        points: 110
      ),
      Layer(
        "Body",
        material: .flesh,
        points: 60
      ),
    ],
    expertise: [.bows: 5, .blades: 2],
    abilities: [
      Ability(
        "Longbow",
        power: 62,
        kind: .pierce,
        discipline: .bows,
        reach: .ranged(700),
        measure: .step
      ),
      Ability(
        "Knife",
        power: 40,
        kind: .slash,
        discipline: .blades
      ),
    ],
    pools: [
      Pool(
        .movement,
        maximum: 350,
        measure: .step
      ),
    ],
  )

  /// A stone golem: slow and big, a thick
  /// shell of rock over a stone core that
  /// shrugs off arrows, blades, fire and
  /// lightning but cracks under blows; it
  /// slams, or hurls a rock.
  static let gorrum = Unit(
    "Gorrum",
    kind: "stone golem",
    stats: Stats(speed: 70),
    layers: [
      Layer(
        "Stone Shell",
        material: .stone,
        points: 340
      ),
      Layer(
        "Core",
        material: .stone,
        points: 80
      ),
    ],
    expertise: [.unarmed: 4],
    abilities: [
      Ability(
        "Slam",
        power: 90,
        kind: .crush,
        discipline: .unarmed,
        weight: .heavy
      ),
      Ability(
        "Hurl Rock",
        power: 50,
        kind: .crush,
        discipline: .unarmed,
        costs: [.stamina: 50],
        reach: .ranged(300),
        measure: .step
      ),
    ],
    size: .large,
    pools: [
      Pool(
        .movement,
        maximum: 200,
        measure: .step
      ),
      Pool(
        .stamina,
        maximum: 100,
        refill: 25
      ),
    ],
  )

  /// An ice mage: robes over a plain body,
  /// a master of frost. A frost bolt each
  /// turn, a heavy ice lance when her mana
  /// allows, and one cantrip a turn on top
  /// (an ice shard from afar, or a chill
  /// touch up close), sharing one bonus.
  static let isolde = Unit(
    "Isolde",
    kind: "ice mage",
    stats: Stats(speed: 95),
    layers: [
      Layer(
        "Robes",
        material: .cloth,
        points: 80
      ),
      Layer(
        "Body",
        material: .flesh,
        points: 60
      ),
    ],
    expertise: [.frost: 5],
    abilities: [
      Ability(
        "Frost Bolt",
        power: 40,
        kind: .freeze,
        discipline: .frost,
        reach: .ranged(450),
        measure: .cast
      ),
      Ability(
        "Ice Lance",
        power: 75,
        kind: .freeze,
        discipline: .frost,
        costs: [.mana: 50],
        weight: .heavy,
        reach: .ranged(500),
        measure: .cast
      ),
      Ability(
        "Ice Shard",
        power: 20,
        kind: .freeze,
        discipline: .frost,
        bonus: Bonus("cantrip"),
        reach: .ranged(350),
        measure: .cast
      ),
      Ability(
        "Chill Touch",
        power: 30,
        kind: .freeze,
        discipline: .frost,
        bonus: Bonus("cantrip")
      ),
    ],
    pools: [
      Pool(
        .movement,
        maximum: 300,
        measure: .step
      ),
      Pool(
        .mana,
        maximum: 100,
        refill: 15
      ),
    ],
  )
}
