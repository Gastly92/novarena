/// The first hand-made units, for trying
/// the rules out.
public extension Unit {
  /// A mouse knight: sturdy, armored and
  /// slow to tire, but a weak caster.
  static let gerald = Unit(
    "Gerald",
    kind: "mouse knight",
    stats: Stats(
      health: 300,
      attack: 130,
      magic: 20,
      armor: 110,
      resistance: 40,
      speed: 95
    ),
    abilities: [
      Ability(
        "Sword Cut",
        power: 60,
        delivery: .physical
      ),
      Ability(
        "Lunge",
        power: 100,
        delivery: .physical,
        cost: 40,
        weight: .heavy
      ),
    ],
    resource: Resource(
      "stamina", maximum: 100, refill: 25
    )
  )

  /// A fire demon: fire can't touch it, but
  /// frost can.
  static let ashka = Unit(
    "Ashka",
    kind: "fire demon",
    stats: Stats(
      health: 320,
      attack: 80,
      magic: 150,
      armor: 60,
      resistance: 90,
      speed: 90
    ),
    abilities: [
      Ability(
        "Claw",
        power: 60,
        delivery: .physical
      ),
      Ability(
        "Fireball",
        power: 120,
        delivery: .special,
        element: .fire,
        cost: 40,
        weight: .heavy
      ),
    ],
    affinities: [
      .fire: .immune, .frost: .weak,
    ],
    resource: Resource(
      "mana", maximum: 100, refill: 15
    )
  )

  /// A shield bearer: takes the first hit
  /// each round meant for an ally.
  static let oswin = Unit(
    "Oswin",
    kind: "shield bearer",
    stats: Stats(
      health: 380,
      attack: 100,
      magic: 20,
      armor: 160,
      resistance: 70,
      speed: 80
    ),
    abilities: [
      Ability(
        "Shield Bash",
        power: 50,
        delivery: .physical,
        weight: .light
      ),
    ],
    resource: Resource(
      "stamina", maximum: 100, refill: 25
    ),
    passives: [.bodyguard]
  )

  /// A war mech behind an energy shield
  /// that recharges, unless shock breaks it.
  static let kestrel = Unit(
    "Kestrel-9",
    kind: "war mech",
    stats: Stats(
      health: 340,
      attack: 120,
      magic: 90,
      armor: 130,
      resistance: 50,
      speed: 85
    ),
    abilities: [
      Ability(
        "Piston Fist",
        power: 60,
        delivery: .physical
      ),
      Ability(
        "Arc Beam",
        power: 100,
        delivery: .special,
        element: .shock,
        cost: 50
      ),
    ],
    affinities: [.shock: .weak],
    resource: Resource(
      "charge", maximum: 100, refill: 25
    ),
    shield: Shield(
      "Energy Shield",
      points: 150,
      blocks: [.physical, .special],
      recharges: true,
      brokenBy: .shock
    )
  )
}
