/// How an attack lands, which decides the
/// defence it meets: physical meets Armor,
/// special meets Resistance.
public enum Delivery: Sendable {
  /// Swords, claws, bullets.
  case physical
  /// Spells, beams, psychic force.
  case special
}

/// What an attack is made of. Weaknesses,
/// resistances and immunities key off it,
/// not the delivery. More (poison, light,
/// shadow, …) join with the first unit that
/// uses them.
public enum Element: Sendable {
  /// Burns.
  case fire
  /// Freezes.
  case frost
  /// Electric; breaks energy shields.
  case shock
}

/// How a unit takes one element.
public enum Affinity: Sendable {
  /// One and a half times the damage.
  case weak
  /// Half the damage.
  case resist
  /// No damage at all.
  case immune

  /// The damage multiplier, as a fraction.
  var factor: (Int, Int) {
    switch self {
    case .weak:
      (3, 2)
    case .resist:
      (1, 2)
    case .immune:
      (0, 1)
    }
  }
}
