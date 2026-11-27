/// What a hit does: slash, pierce, burn…
/// or, for a heal, mend. An open list: a
/// new kind is one more `static let`,
/// plus table entries where it meets a
/// material unusually.
public struct Kind: Hashable, Sendable {
  /// Its name, for the log.
  public let name: String
  /// Whether it mends an ally's layers
  /// rather than wearing a foe's down.
  public let heals: Bool

  /// A kind of damage, or with `heals`,
  /// of healing.
  public init(
    _ name: String,
    heals: Bool = false
  ) {
    self.name = name
    self.heals = heals
  }

  /// Blades.
  public static let slash = Self("slash")
  /// Points: spears, arrows, daggers.
  public static let pierce = Self("pierce")
  /// Blunt force: fists, hammers, shields.
  public static let crush = Self("crush")
  /// Fire.
  public static let burn = Self("burn")
  /// Lightning; breaks energy shields.
  public static let shock = Self("shock")
  /// Holy light; sears demons.
  public static let radiant = Self(
    "radiant"
  )
  /// Healing: mends flesh fully, armor
  /// and hide by half, machines not at
  /// all.
  public static let mend = Self(
    "mend", heals: true
  )
}

/// What a layer is made of: metal,
/// wood, flesh… An open list, like
/// `Kind`.
public struct Material: Hashable, Sendable {
  /// Its name, for display.
  public let name: String

  /// A material.
  public init(_ name: String) {
    self.name = name
  }

  /// Plate, mail, plating.
  public static let metal = Self("metal")
  /// Shields, staves.
  public static let wood = Self("wood")
  /// Living bodies.
  public static let flesh = Self("flesh")
  /// Force fields.
  public static let energy = Self("energy")
  /// A fire demon's hide.
  public static let ember = Self("ember")
  /// Padded armor: soaks blows, but burns.
  public static let cloth = Self("cloth")
}

/// How a kind of damage meets a material.
public struct Matchup: Sendable, Equatable {
  /// The damage it does, in percent: 0 is
  /// immune, 50 resists, 150 is weak.
  public let percent: Int
  /// Whether what's left of a hit that
  /// breaks the layer goes on to the next
  /// one, rather than stopping there.
  public let carries: Bool

  /// A matchup.
  public init(
    _ percent: Int,
    carries: Bool = false
  ) {
    self.percent = percent
    self.carries = carries
  }

  /// Full damage, stopping at the layer.
  public static let normal = Self(100)
  /// No damage at all.
  public static let immune = Self(0)
}

extension Rules {
  /// Matchups by kind, then material.
  typealias Table = [
    Kind: [Material: Matchup]
  ]

  /// How each kind meets each material,
  /// where it isn't `Matchup.normal`.
  static let table: Table = [
    .slash: [
      .metal: Matchup(50),
      .flesh: Matchup(150),
    ],
    .pierce: [
      .metal: Matchup(75, carries: true),
    ],
    .crush: [
      .metal: Matchup(100, carries: true),
      .wood: Matchup(150),
      .cloth: Matchup(50),
    ],
    .burn: [
      .wood: Matchup(150),
      .flesh: Matchup(125),
      .cloth: Matchup(150),
    ],
    .shock: [
      .metal: Matchup(100, carries: true),
      .energy: Matchup(200),
    ],
    .radiant: [
      .ember: Matchup(150),
    ],
    .mend: [
      .metal: Matchup(50),
      .wood: Matchup(50),
      .cloth: Matchup(50),
      .ember: Matchup(50),
      .energy: .immune,
    ],
  ]

  /// How `kind` meets `material`.
  static func matchup(
    _ kind: Kind,
    _ material: Material
  ) -> Matchup {
    table[kind]?[material] ?? .normal
  }
}
