/// What a pool holds: movement, stamina,
/// mana… An open list, like `Kind`.
public struct PoolKind: Hashable, Sendable {
  /// Its name, for display.
  public let name: String

  /// A kind of pool.
  public init(_ name: String) {
    self.name = name
  }

  /// What moving spends. A unit without
  /// one can't move.
  public static let movement = Self(
    "movement"
  )
  /// A body's effort.
  public static let stamina = Self("stamina")
  /// Magic.
  public static let mana = Self("mana")
  /// A machine's stored power.
  public static let charge = Self("charge")
}

/// A length with a name, for showing
/// distances: a unit's steps, a skill's
/// reach. The rules count whole
/// centimetres; measures are how a screen
/// says them.
public struct Measure: Sendable, Equatable {
  /// Its name for one, e.g. "step".
  public let one: String
  /// Its name for more, e.g. "steps".
  public let many: String
  /// How long one is.
  public let centimetres: Int

  /// A measure.
  public init(
    _ one: String,
    _ many: String,
    centimetres: Int
  ) {
    self.one = one
    self.many = many
    self.centimetres = centimetres
  }

  /// A walker's step, half a metre.
  public static let step = Self(
    "step", "steps", centimetres: 50
  )
  /// A long stride, 60 cm.
  public static let stride = Self(
    "stride", "strides", centimetres: 60
  )
  /// A mech's fuel, 25 cm of travel.
  public static let fuel = Self(
    "fuel", "fuel", centimetres: 25
  )
  /// An arm and weapon's reach, half a
  /// metre.
  public static let reach = Self(
    "reach", "reaches", centimetres: 50
  )
  /// A spell's casting distance.
  public static let cast = Self(
    "cast", "casts", centimetres: 50
  )
  /// A lightning arc's length.
  public static let arc = Self(
    "arc", "arcs", centimetres: 50
  )
}

/// Something a unit spends: its movement,
/// stamina, mana. It starts full. A pool
/// with no `refill` fills again at the
/// start of each of the unit's turns, so
/// what isn't spent is lost (movement);
/// one with a `refill` gains that much,
/// keeping what wasn't spent, up to its
/// maximum (saving up for a bigger turn).
public struct Pool: Sendable {
  /// What it holds.
  public let kind: PoolKind
  /// The most it holds.
  public let maximum: Int
  /// What it gains each turn, keeping the
  /// rest; none fills it each turn.
  public let refill: Int?
  /// How a screen says its amounts, if not
  /// as plain points (movement, in
  /// centimetres, as steps).
  public let measure: Measure?

  /// A pool.
  public init(
    _ kind: PoolKind,
    maximum: Int,
    refill: Int? = nil,
    measure: Measure? = nil
  ) {
    self.kind = kind
    self.maximum = maximum
    self.refill = refill
    self.measure = measure
  }

  /// What it holds at the start of a turn,
  /// holding `amount` before.
  func refilled(_ amount: Int) -> Int {
    refill.map {
      min(maximum, amount + $0)
    } ?? maximum
  }
}

/// How often a bonus skill can be used: one
/// group's skills share its uses each turn
/// (a wizard's cantrips, one a turn); a
/// skill alone in its group has its own.
public struct Bonus: Sendable, Equatable {
  /// The group's name.
  public let group: String
  /// Its uses each turn.
  public let perTurn: Int

  /// A bonus group.
  public init(
    _ group: String,
    perTurn: Int = 1
  ) {
    self.group = group
    self.perTurn = perTurn
  }
}
