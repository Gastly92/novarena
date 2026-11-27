/// What a hit does: slash, pierce, burn…
/// An open list: a new kind is one more
/// `static let`, plus table entries where
/// it meets a material unusually.
public struct Kind: Hashable, Sendable {
  /// Its name, for the log.
  public let name: String

  /// A kind of damage.
  public init(_ name: String) {
    self.name = name
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
    ],
    .burn: [
      .wood: Matchup(150),
      .flesh: Matchup(125),
    ],
    .shock: [
      .metal: Matchup(100, carries: true),
      .energy: Matchup(200),
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
