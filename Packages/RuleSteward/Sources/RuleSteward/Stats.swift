/// A unit's numbers, all whole numbers so
/// every result is exact and repeatable.
/// How far it moves is its movement pool;
/// what it wears and is good at, its
/// layers and expertise.
public struct Stats: Sendable {
  /// How often the unit acts.
  public var speed: Int

  /// A unit's stats.
  public init(speed: Int) {
    self.speed = speed
  }
}
