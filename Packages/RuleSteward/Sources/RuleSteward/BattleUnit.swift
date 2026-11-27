/// Which side of a battle a unit is on.
public enum Side: Sendable {
  /// The player's party.
  case party
  /// The units it faces.
  case foes
}

/// A unit during a battle: what's left of
/// its layers, its resource, its place on
/// the timeline and its spot in the arena.
public struct BattleUnit: Sendable,
  Identifiable {
  /// Its place in the battle's list.
  public let id: Int
  /// Its side.
  public let side: Side
  /// Who it is.
  public let unit: Unit
  /// Points left in each of its layers,
  /// outermost first.
  public internal(set) var layers: [Int]
  /// Knocked out: out of the fight.
  public internal(set) var isOut = false
  /// Resource left.
  public internal(set) var pool: Int
  /// The tick its next turn comes at.
  public internal(set) var nextTurn: Int
  /// Where it stands.
  public internal(set) var place: Point
  /// Whether it took any damage since its
  /// last turn (a recharging layer waits).
  var wasHit = false
  /// The round it last stood in for an
  /// ally (`Passive.bodyguard`).
  var guarded: Int?

  /// Still in the fight.
  public var isUp: Bool { !isOut }

  /// Every layer gone, its body too: the
  /// next hit that does any damage knocks
  /// it out.
  public var isExposed: Bool {
    layers.allSatisfy { $0 == 0 }
  }

  init(
    id: Int,
    side: Side,
    unit: Unit,
    place: Point
  ) {
    self.id = id
    self.side = side
    self.unit = unit
    self.place = place
    layers = unit.layers.map(\.points)
    pool = unit.resource?.maximum ?? 0
    nextTurn = Rules.wait(
      speed: unit.stats.speed,
      weight: .normal
    )
  }

  /// What's left of its layers in percent,
  /// for breaking ties on the timeline.
  var percent: Int {
    let whole = unit.layers.map(\.points)
      .reduce(0, +)
    return whole == 0 ? 0
      : layers.reduce(0, +) * 100 / whole
  }

  /// Whether it can pay for `ability`.
  func affords(_ ability: Ability) -> Bool {
    ability.cost <= pool
  }

  /// The start of its turn: its resource
  /// refills, recharging layers fill if it
  /// wasn't hit since its last turn, and
  /// layers that regrow do, unless broken.
  mutating func startTurn() {
    if let resource = unit.resource {
      pool = min(
        resource.maximum,
        pool + resource.refill
      )
    }
    for (index, layer) in unit.layers
      .enumerated() {
      let grows = wasHit ? 0 : layer.recharge
      let heals = layers[index] > 0
        ? layer.regrows : 0
      layers[index] = min(
        layer.points,
        layers[index] + grows + heals
      )
    }
    wasHit = false
  }

  /// Takes `amount` of `ability`'s damage.
  /// It wears down the outermost layer
  /// left (skipping materials the ability
  /// ignores), scaled by how its kind meets
  /// the layer. What's left of a hit that
  /// breaks a layer goes on only if the
  /// matchup carries or the ability
  /// pierces. Once exposed, any damage
  /// knocks it out. Returns what each
  /// layer lost.
  mutating func take(
    _ amount: Int,
    from ability: Ability
  ) -> [(layer: Int, lost: Int)] {
    if isExposed {
      let body = unit.layers.last?
        .matchup(ability.kind) ?? .normal
      isOut = amount * body.percent / 100 > 0
      return []
    }
    var left = amount
    var losses: [(layer: Int, lost: Int)]
    losses = []
    for index in layers.indices
    where layers[index] > 0 {
      let layer = unit.layers[index]
      if ability.ignores.contains(
        layer.material
      ) {
        continue
      }
      let matchup = layer.matchup(
        ability.kind
      )
      let dealt = left * matchup.percent
        / 100
      let lost = min(layers[index], dealt)
      guard lost > 0 else {
        break
      }
      layers[index] -= lost
      losses.append((index, lost))
      guard lost < dealt,
        matchup.carries || ability.pierces
      else { break }
      left = left * (dealt - lost) / dealt
    }
    wasHit = wasHit || !losses.isEmpty
    return losses
  }
}
