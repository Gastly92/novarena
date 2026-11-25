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
  var percent: Int {
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

  /// An attack.
  public init(
    _ name: String,
    power: Int,
    delivery: Delivery,
    element: Element? = nil,
    cost: Int = 0,
    weight: Weight = .normal
  ) {
    self.name = name
    self.power = power
    self.delivery = delivery
    self.element = element
    self.cost = cost
    self.weight = weight
  }
}
