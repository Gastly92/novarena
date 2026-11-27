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
  /// What it wears, outermost first, down
  /// to its body, the last.
  public let layers: [Layer]
  /// Its level, 1 to 5, in each
  /// discipline; 1 where missing.
  public let expertise: [Discipline: Int]
  /// What it can do on its turn. The first
  /// should cost nothing, so a unit with an
  /// empty pool still has a move.
  public let abilities: [Ability]
  /// How big it is.
  public let size: Size
  /// What its abilities spend, if anything.
  public let resource: Resource?
  /// Its always-on effects.
  public let passives: [Passive]

  /// A unit.
  public init(
    _ name: String,
    kind: String,
    stats: Stats,
    layers: [Layer],
    expertise: [Discipline: Int],
    abilities: [Ability],
    size: Size = .medium,
    resource: Resource? = nil,
    passives: [Passive] = []
  ) {
    self.name = name
    self.kind = kind
    self.stats = stats
    self.layers = layers
    self.expertise = expertise
    self.abilities = abilities
    self.size = size
    self.resource = resource
    self.passives = passives
  }

  /// Its level in `discipline`.
  func level(
    _ discipline: Discipline
  ) -> Int {
    expertise[discipline] ?? 1
  }
}
