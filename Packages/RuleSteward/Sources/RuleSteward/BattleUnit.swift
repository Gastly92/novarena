/// Which side of a battle a unit is on.
public enum Side: Sendable {
  /// The player's party.
  case party
  /// The units it faces.
  case foes
}

/// A unit during a battle: what's left of
/// its layers, its pools, its place on
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
  /// What's in each of its pools, in the
  /// unit's order.
  public internal(set) var pools: [Int]
  /// The tick its next turn comes at.
  public internal(set) var nextTurn: Int
  /// Where it stands.
  public internal(set) var place: Point
  /// The furthest it has moved in one
  /// turn, as the other side has seen.
  public internal(set) var furthest = 0
  /// What it has moved this turn.
  var moving = 0
  /// The abilities it has used (indices
  /// into its list), as the other side
  /// has seen.
  public internal(set) var shown: Set<Int> =
    []
  /// Hits its ward will still soak whole.
  public internal(set) var wards = 0
  /// Whether it took any damage since its
  /// last turn (a recharging layer waits).
  var wasHit = false
  /// The round it last stood in for an
  /// ally (`Passive.bodyguard`).
  var guarded: Int?
  /// The round it last reacted (a
  /// bodyguard's step in included).
  var reacted: Int?

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
    pools = unit.pools.map(\.maximum)
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

  /// Whether it can pay for `ability`
  /// from its pools.
  func affords(_ ability: Ability) -> Bool {
    ability.costs.allSatisfy {
      amount(in: $0.key) >= $0.value
    }
  }

  /// What's in its pool of `kind`; 0 if it
  /// has none.
  public func amount(
    in kind: PoolKind
  ) -> Int {
    unit.pools.firstIndex { $0.kind == kind }
      .map { pools[$0] } ?? 0
  }

  /// Takes what `ability` costs from its
  /// pools.
  mutating func pay(for ability: Ability) {
    for (index, pool) in unit.pools
      .enumerated() {
      let cost = ability.costs[pool.kind]
      pools[index] -= cost ?? 0
    }
  }

  /// Takes `amount` from its pool of
  /// `kind`.
  mutating func spend(
    _ amount: Int,
    from kind: PoolKind
  ) {
    for (index, pool) in unit.pools
      .enumerated() where pool.kind == kind {
      pools[index] -= amount
    }
  }

  /// The start of its turn: its pools
  /// refill, recharging layers fill if it
  /// wasn't hit since its last turn, and
  /// layers that regrow do, unless broken.
  mutating func startTurn() {
    pools = zip(unit.pools, pools).map {
      $0.refilled($1)
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
    moving = 0
  }

  /// Takes `amount` of `ability`'s damage,
  /// unless its ward soaks the hit whole.
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
    if wards > 0 {
      wards -= 1
      return []
    }
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

  /// The outermost layer `kind` can mend:
  /// worn but not broken (a broken layer,
  /// like one that regrows, stays broken),
  /// and of a material it works on.
  func mendable(_ kind: Kind) -> Int? {
    layers.indices.first {
      (1..<unit.layers[$0].points)
        .contains(layers[$0])
        && unit.layers[$0].matchup(kind)
          .percent > 0
    }
  }

  /// Mends `amount` of `ability`'s healing
  /// into the outermost layer it can mend,
  /// scaled by how its kind meets the
  /// layer, up to whole. Returns what it
  /// gained, like `take`.
  mutating func mend(
    _ amount: Int,
    from ability: Ability
  ) -> [(layer: Int, gained: Int)] {
    guard let index = mendable(ability.kind)
    else { return [] }
    let layer = unit.layers[index]
    let scaled = amount
      * layer.matchup(ability.kind).percent
      / 100
    let gained = min(
      layer.points - layers[index], scaled
    )
    layers[index] += gained
    return [(index, gained)]
  }
}
