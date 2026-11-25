/// A pool spent on abilities: a wizard's
/// mana, a mech's charge, a knight's
/// stamina. It refills a little at the
/// start of each of the unit's turns.
public struct Resource: Sendable {
  /// What kind it is, for display.
  public let name: String
  /// The most it holds; units start full.
  public let maximum: Int
  /// What it refills each turn.
  public let refill: Int

  /// A resource.
  public init(
    _ name: String,
    maximum: Int,
    refill: Int
  ) {
    self.name = name
    self.maximum = maximum
    self.refill = refill
  }
}

/// A layer over a unit's health that takes
/// damage of the kinds it blocks first.
public struct Shield: Sendable {
  /// What it's called, for display.
  public let name: String
  /// Its points when full.
  public let points: Int
  /// The deliveries it blocks.
  public let blocks: Set<Delivery>
  /// Refills at the start of the unit's
  /// turn if the unit took no damage since
  /// its last turn, like the shields in
  /// Halo.
  public let recharges: Bool
  /// Hits of this element do double damage
  /// to it (shock against energy).
  public let brokenBy: Element?

  /// A shield.
  public init(
    _ name: String,
    points: Int,
    blocks: Set<Delivery>,
    recharges: Bool = false,
    brokenBy: Element? = nil
  ) {
    self.name = name
    self.points = points
    self.blocks = blocks
    self.recharges = recharges
    self.brokenBy = brokenBy
  }
}

/// An always-on effect a unit carries.
public enum Passive: Sendable {
  /// The first attack each round on an ally
  /// is taken by this unit instead.
  case bodyguard
}
