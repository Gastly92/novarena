/// A unit's numbers, all whole numbers so
/// every result is exact and repeatable.
public struct Stats: Sendable {
  /// Health. At 0 the unit is down.
  public var health: Int
  /// Physical damage dealt.
  public var attack: Int
  /// Special damage dealt.
  public var magic: Int
  /// Cuts physical damage taken.
  public var armor: Int
  /// Cuts special damage taken.
  public var resistance: Int
  /// How often the unit acts.
  public var speed: Int

  /// A unit's stats.
  public init(
    health: Int,
    attack: Int,
    magic: Int,
    armor: Int,
    resistance: Int,
    speed: Int
  ) {
    self.health = health
    self.attack = attack
    self.magic = magic
    self.armor = armor
    self.resistance = resistance
    self.speed = speed
  }
}
