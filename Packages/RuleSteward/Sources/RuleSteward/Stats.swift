/// A unit's numbers, all whole numbers so
/// every result is exact and repeatable.
/// What it wears and what it's good at are
/// its layers and expertise.
public struct Stats: Sendable {
  /// How often the unit acts.
  public var speed: Int
  /// How far it can go in a turn, in
  /// centimetres.
  public var move: Int

  /// A unit's stats.
  public init(speed: Int, move: Int) {
    self.speed = speed
    self.move = move
  }
}
