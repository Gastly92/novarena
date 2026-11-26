/// How long an action holds a unit up: its
/// next turn comes later after a heavy one,
/// sooner after a light one.
public enum Weight: Sendable {
  /// 75% of the usual wait.
  case light
  /// The usual wait.
  case normal
  /// 150% of the usual wait.
  case heavy

  /// The wait, in percent of the usual.
  public var percent: Int {
    switch self {
    case .light:
      75
    case .normal:
      100
    case .heavy:
      150
    }
  }
}

/// How far an ability reaches.
public enum Reach: Sendable {
  /// Up close: this far from the unit's
  /// edge to the target's, so a big unit
  /// reaches further.
  case melee(Int)
  /// From afar: this far from the unit's
  /// middle to the target's edge, so a big
  /// target is easier to hit.
  case ranged(Int)

  /// The furthest apart the middles of a
  /// unit and its target can be, given
  /// their radii.
  func limit(
    from radius: Int,
    to target: Int
  ) -> Int {
    switch self {
    case let .melee(reach):
      radius + reach + target
    case let .ranged(reach):
      reach + target
    }
  }
}

/// Something a unit can do on its turn. For
/// now, attacks on one foe.
public struct Ability: Sendable {
  /// The name shown to players.
  public let name: String
  /// Base damage, before stats.
  public let power: Int
  /// Which defence it meets.
  public let delivery: Delivery
  /// What it's made of, if anything.
  public let element: Element?
  /// What it takes from the unit's
  /// resource.
  public let cost: Int
  /// How long it holds the unit up.
  public let weight: Weight
  /// How far it reaches.
  public let reach: Reach

  /// An attack; melee, half a metre from
  /// edge to edge, unless `reach` says.
  public init(
    _ name: String,
    power: Int,
    delivery: Delivery,
    element: Element? = nil,
    cost: Int = 0,
    weight: Weight = .normal,
    reach: Reach = .melee(50)
  ) {
    self.name = name
    self.power = power
    self.delivery = delivery
    self.element = element
    self.cost = cost
    self.weight = weight
    self.reach = reach
  }
}
