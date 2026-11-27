/// The first hand-made units, for trying
/// the rules out. Their numbers are tuned
/// so each fights each other about evenly
/// (see `BalanceTests`).
public extension Unit {
  /// A mouse knight: small and quick, in
  /// plate over a thin body; an expert
  /// with his sword, and quick enough to
  /// add a pommel strike to any turn.
  static let gerald = Unit(
    "Gerald",
    kind: "mouse knight",
    stats: Stats(speed: 105),
    layers: [
      Layer(
        "Plate",
        material: .metal,
        points: 190
      ),
      Layer(
        "Body",
        material: .flesh,
        points: 60
      ),
    ],
    expertise: [.blades: 4],
    abilities: [
      Ability(
        "Sword Cut",
        power: 80,
        kind: .slash,
        discipline: .blades
      ),
      Ability(
        "Lunge",
        power: 100,
        kind: .pierce,
        discipline: .blades,
        costs: [.stamina: 40],
        weight: .heavy
      ),
      Ability(
        "Pommel Strike",
        power: 12,
        kind: .crush,
        discipline: .blades,
        bonus: Bonus("pommel")
      ),
    ],
    size: .small,
    pools: [
      Pool(
        .movement,
        maximum: 350,
        measure: .step
      ),
      Pool(
        .stamina,
        maximum: 100,
        refill: 25
      ),
    ],
  )

  /// A fire demon: no armor, but a thick
  /// ember hide that grows back and that
  /// fire can't touch; a master of fire.
  static let ashka = Unit(
    "Ashka",
    kind: "fire demon",
    stats: Stats(speed: 90),
    layers: [
      Layer(
        "Ember Hide",
        material: .ember,
        points: 250,
        regrows: 15,
        matchups: [.burn: .immune]
      ),
    ],
    expertise: [.unarmed: 3, .fire: 5],
    abilities: [
      Ability(
        "Claw",
        power: 60,
        kind: .slash,
        discipline: .unarmed
      ),
      Ability(
        "Fireball",
        power: 90,
        kind: .burn,
        discipline: .fire,
        costs: [.mana: 40],
        weight: .heavy,
        reach: .ranged(500),
        measure: .cast
      ),
    ],
    pools: [
      Pool(
        .movement,
        maximum: 300,
        measure: .stride
      ),
      Pool(
        .mana,
        maximum: 100,
        refill: 10
      ),
    ],
  )

  /// A shield bearer: a tower shield over
  /// mail; takes the first hit each round
  /// meant for an ally.
  static let oswin = Unit(
    "Oswin",
    kind: "shield bearer",
    stats: Stats(speed: 80),
    layers: [
      Layer(
        "Tower Shield",
        material: .wood,
        points: 140
      ),
      Layer(
        "Mail",
        material: .metal,
        points: 110
      ),
      Layer(
        "Body",
        material: .flesh,
        points: 60
      ),
    ],
    expertise: [.shields: 5, .blades: 2],
    abilities: [
      Ability(
        "Shield Bash",
        power: 50,
        kind: .crush,
        discipline: .shields,
        weight: .light
      ),
    ],
    pools: [
      Pool(
        .movement,
        maximum: 300,
        measure: .step
      ),
      Pool(
        .stamina,
        maximum: 100,
        refill: 25
      ),
    ],
    passives: [.bodyguard]
  )

  /// A war mech: an energy shield that
  /// recharges (unless shock breaks it)
  /// over metal plating.
  static let kestrel = Unit(
    "Kestrel-9",
    kind: "war mech",
    stats: Stats(speed: 82),
    layers: [
      Layer(
        "Energy Shield",
        material: .energy,
        points: 100,
        recharge: 40
      ),
      Layer(
        "Plating",
        material: .metal,
        points: 120
      ),
      Layer(
        "Frame",
        material: .metal,
        points: 40
      ),
    ],
    expertise: [.unarmed: 3, .lightning: 4],
    abilities: [
      Ability(
        "Piston Fist",
        power: 60,
        kind: .crush,
        discipline: .unarmed
      ),
      Ability(
        "Arc Beam",
        power: 60,
        kind: .shock,
        discipline: .lightning,
        costs: [.charge: 50],
        reach: .ranged(450),
        measure: .arc
      ),
    ],
    size: .large,
    pools: [
      Pool(
        .movement,
        maximum: 300,
        measure: .fuel
      ),
      Pool(
        .charge,
        maximum: 100,
        refill: 25
      ),
    ],
  )
}
