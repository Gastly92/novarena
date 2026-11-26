/// Which side of a battle a unit is on.
public enum Side: Sendable {
  /// The player's party.
  case party
  /// The units it faces.
  case foes
}

/// A unit during a battle: its health,
/// shield, resource, place on the
/// timeline and spot in the arena.
public struct BattleUnit: Sendable,
  Identifiable {
  /// Its place in the battle's list.
  public let id: Int
  /// Its side.
  public let side: Side
  /// Who it is.
  public let unit: Unit
  /// Health left; 0 is down.
  public internal(set) var health: Int
  /// Shield points left.
  public internal(set) var shield: Int
  /// Resource left.
  public internal(set) var pool: Int
  /// The tick its next turn comes at.
  public internal(set) var nextTurn: Int
  /// Where it stands.
  public internal(set) var place: Point
  /// Whether it took any damage since its
  /// last turn (a recharging shield waits).
  var wasHit = false
  /// The round it last stood in for an
  /// ally (`Passive.bodyguard`).
  var guarded: Int?

  /// Still in the fight.
  public var isUp: Bool { health > 0 }

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
    health = unit.stats.health
    shield = unit.shield?.points ?? 0
    pool = unit.resource?.maximum ?? 0
    nextTurn = Rules.wait(
      speed: unit.stats.speed,
      weight: .normal
    )
  }

  /// Its health in percent, for breaking
  /// ties on the timeline.
  var percent: Int {
    health * 100 / unit.stats.health
  }

  /// Whether it can pay for `ability`.
  func affords(_ ability: Ability) -> Bool {
    ability.cost <= pool
  }

  /// The start of its turn: its resource
  /// refills, and a recharging shield that
  /// wasn't hit since its last turn fills.
  mutating func startTurn() {
    if let resource = unit.resource {
      pool = min(
        resource.maximum,
        pool + resource.refill
      )
    }
    if let full = unit.shield,
      full.recharges, !wasHit {
      shield = full.points
    }
    wasHit = false
  }

  /// Takes `hit` damage of `ability`'s kind:
  /// a shield that blocks it goes first
  /// (twice as fast against what breaks
  /// it). Returns what the shield took and
  /// what reached health.
  mutating func take(
    _ hit: Int,
    from ability: Ability
  ) -> (shield: Int, health: Int) {
    var left = hit
    var used = 0
    if let full = unit.shield, shield > 0,
      full.blocks.contains(
        ability.delivery
      ) {
      let factor = ability.element != nil
        && ability.element == full.brokenBy
        ? 2 : 1
      used = min(shield, hit * factor)
      shield -= used
      let covered = (used + factor - 1)
        / factor
      left = hit - covered
    }
    wasHit = true
    let dealt = min(health, left)
    health -= dealt
    return (used, dealt)
  }
}
