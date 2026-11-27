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

/// Something a unit wears, or is, that
/// hits wear down: plate, a shield, its
/// own hide. A unit's last layer is its
/// body.
public struct Layer: Sendable {
  /// What it's called, for display.
  public let name: String
  /// What it's made of.
  public let material: Material
  /// Its points when whole.
  public let points: Int
  /// What it refills at the start of the
  /// unit's turn if the unit wasn't hit
  /// since its last turn, even when
  /// broken, like the shields in Halo.
  public let recharge: Int
  /// What it grows back at the start of
  /// each of the unit's turns, unless it's
  /// broken.
  public let regrows: Int
  /// How kinds of damage meet it, where it
  /// differs from its material.
  public let matchups: [Kind: Matchup]

  /// A layer.
  public init(
    _ name: String,
    material: Material,
    points: Int,
    recharge: Int = 0,
    regrows: Int = 0,
    matchups: [Kind: Matchup] = [:]
  ) {
    self.name = name
    self.material = material
    self.points = points
    self.recharge = recharge
    self.regrows = regrows
    self.matchups = matchups
  }

  /// How `kind` meets it.
  func matchup(_ kind: Kind) -> Matchup {
    matchups[kind]
      ?? Rules.matchup(kind, material)
  }
}

/// An always-on effect a unit carries.
public enum Passive: Sendable {
  /// The first attack each round on an ally
  /// is taken by this unit instead.
  case bodyguard
}
