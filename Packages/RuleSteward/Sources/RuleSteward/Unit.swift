/// A hand-made, named character: what it is
/// before a battle starts. `BattleUnit`
/// holds how it's doing during one.
public struct Unit: Sendable {
  /// Its name, e.g. "Gerald".
  public let name: String
  /// What it is, e.g. "mouse knight".
  public let kind: String
  /// Its numbers.
  public let stats: Stats
  /// How it takes each element; elements
  /// missing here hit normally.
  public let affinities: [Element: Affinity]
  /// What its abilities spend, if anything.
  public let resource: Resource?
  /// A layer over its health, if any.
  public let shield: Shield?
  /// What it can do on its turn. The first
  /// should cost nothing, so a unit with an
  /// empty pool still has a move.
  public let abilities: [Ability]
  /// Its always-on effects.
  public let passives: [Passive]

  /// A unit.
  public init(
    _ name: String,
    kind: String,
    stats: Stats,
    abilities: [Ability],
    affinities: [Element: Affinity] = [:],
    resource: Resource? = nil,
    shield: Shield? = nil,
    passives: [Passive] = []
  ) {
    self.name = name
    self.kind = kind
    self.stats = stats
    self.affinities = affinities
    self.resource = resource
    self.shield = shield
    self.abilities = abilities
    self.passives = passives
  }
}
