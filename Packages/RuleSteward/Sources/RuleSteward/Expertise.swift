/// A field of skill an ability belongs to:
/// blades, shields, fire magic… An open
/// list, like `Kind`.
public struct Discipline: Hashable,
  Sendable {
  /// Its name, for display.
  public let name: String

  /// A discipline.
  public init(_ name: String) {
    self.name = name
  }

  /// Swords and knives.
  public static let blades = Self("blades")
  /// Fighting with a shield.
  public static let shields = Self("shields")
  /// Fists, claws and bodies.
  public static let unarmed = Self("unarmed")
  /// Fire magic.
  public static let fire = Self("fire")
  /// Maces, hammers and clubs.
  public static let maces = Self("maces")
  /// Bows and crossbows.
  public static let bows = Self("bows")
  /// Ice and cold magic.
  public static let frost = Self("frost")
  /// Holy magic: blessings and healing.
  public static let faith = Self("faith")
  /// Lightning, magic or machine.
  public static let lightning = Self(
    "lightning"
  )
}

extension Rules {
  /// How much of an ability's power a unit
  /// brings, in percent, at `level` in its
  /// discipline: 1 untrained, 60; 2
  /// novice, 80; 3 trained, 100; 4 expert,
  /// 120; 5 master, 140.
  static func expertise(
    _ level: Int
  ) -> Int {
    40 + 20 * min(max(level, 1), 5)
  }
}
