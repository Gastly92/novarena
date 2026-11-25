/// Why a turn can't be taken.
public enum Mistake: Error, Equatable {
  /// One side has nobody up.
  case over
  /// The unit has no such ability.
  case noAbility
  /// Its resource can't pay for it.
  case cantAfford
  /// The target is an ally, down, or
  /// missing.
  case badTarget
}

/// A battle between the party and its foes,
/// played one turn at a time on a shared
/// timeline. Nothing is random: the same
/// choices always give the same battle.
public struct Battle: Sendable {
  /// Everyone in it, party first.
  public private(set) var units: [BattleUnit]
  /// What has happened so far.
  public private(set) var log: [Event] = []
  /// The time, in ticks (100 a round).
  public private(set) var tick = 0

  /// A battle between `party` and `foes`.
  /// Everyone's first turn comes after one
  /// usual wait.
  public init(party: [Unit], foes: [Unit]) {
    let sides =
      party.map { (Side.party, $0) }
      + foes.map { (Side.foes, $0) }
    units = sides.enumerated().map {
      BattleUnit(
        id: $0.offset,
        side: $0.element.0,
        unit: $0.element.1
      )
    }
  }

  /// The side still up, once the other has
  /// nobody left.
  public var winner: Side? {
    let standing = Set(
      units.filter(\.isUp).map(\.side)
    )
    return standing.count == 1
      ? standing.first : nil
  }

  /// Whose turn is next: the earliest tick,
  /// ties broken by a fixed ladder (higher
  /// base Speed, then higher health
  /// percent, then the party, then list
  /// order), never by chance.
  public var next: Int? {
    guard winner == nil else {
      return nil
    }
    return units.filter(\.isUp).min {
      order($0)
        .lexicographicallyPrecedes(order($1))
    }?.id
  }

  /// A unit's place in the turn order.
  private func order(
    _ unit: BattleUnit
  ) -> [Int] {
    [
      unit.nextTurn,
      -unit.unit.stats.speed,
      -unit.percent,
      unit.side == .party ? 0 : 1,
      unit.id,
    ]
  }

  /// Plays the next unit's turn: `ability`
  /// (its index in the unit's list) on
  /// `target` (an id).
  public mutating func act(
    _ ability: Int,
    on target: Int
  ) throws(Mistake) {
    guard let actor = next else {
      throw .over
    }
    let abilities = units[actor].unit
      .abilities
    guard abilities.indices
      .contains(ability)
    else { throw .noAbility }
    let chosen = abilities[ability]
    guard units.indices.contains(target),
      units[target].isUp,
      units[target].side
        != units[actor].side
    else { throw .badTarget }
    var mover = units[actor]
    mover.startTurn()
    guard mover.affords(chosen) else {
      throw .cantAfford
    }
    units[actor] = mover
    tick = mover.nextTurn
    log.append(.turn(
      units[actor].unit.name, tick: tick
    ))
    units[actor].pool -= chosen.cost
    log.append(.uses(
      units[actor].unit.name,
      chosen.name,
      target: units[target].unit.name
    ))
    hit(
      units[target],
      with: chosen,
      from: actor
    )
    units[actor].nextTurn += Rules.wait(
      speed: units[actor].unit.stats.speed,
      weight: chosen.weight
    )
    if let side = winner {
      log.append(.wins(side))
    }
  }

  /// The ally who takes this hit for
  /// `target`, if one can this round.
  private func guardian(
    for target: BattleUnit
  ) -> Int? {
    let round = tick / 100
    return units.first {
      $0.isUp && $0.side == target.side
        && $0.id != target.id
        && $0.unit.passives
          .contains(.bodyguard)
        && $0.guarded != round
    }?.id
  }

  /// Resolves `ability` from `actor` on
  /// `aimed`, or on its bodyguard.
  private mutating func hit(
    _ aimed: BattleUnit,
    with ability: Ability,
    from actor: Int
  ) {
    var target = aimed.id
    if let guardian = guardian(for: aimed) {
      units[guardian].guarded = tick / 100
      log.append(.guards(
        units[guardian].unit.name,
        ally: aimed.unit.name
      ))
      target = guardian
    }
    let name = units[target].unit.name
    let amount = Rules.damage(
      ability,
      from: units[actor].unit.stats,
      to: units[target].unit,
      intensity: Rules.intensity(at: tick)
    )
    guard amount > 0 else {
      log.append(.immune(name))
      return
    }
    let taken = units[target].take(
      amount, from: ability
    )
    if taken.shield > 0 {
      log.append(.shield(
        name,
        took: taken.shield,
        left: units[target].shield
      ))
    }
    if taken.health > 0 {
      log.append(.damage(
        name,
        took: taken.health,
        left: units[target].health
      ))
    }
    if !units[target].isUp {
      log.append(.down(name))
    }
  }
}
