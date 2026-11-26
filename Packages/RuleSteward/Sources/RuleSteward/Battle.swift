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
  /// The target is out of the ability's
  /// reach.
  case outOfReach
  /// The moves add up to more than the
  /// unit's Move.
  case tooFar
  /// A spot it moves to is taken, or
  /// outside the arena.
  case blocked
}

/// A battle between the party and its foes,
/// played one turn at a time on a shared
/// timeline. Nothing is random: the same
/// choices always give the same battle.
public struct Battle: Sendable {
  /// Everyone in it, party first.
  public private(set) var units: [BattleUnit]
  /// Where it's fought.
  public let arena: Arena
  /// What has happened so far.
  public private(set) var log: [Event] = []
  /// The time, in ticks (100 a round).
  public private(set) var tick = 0

  /// A battle between `party` and `foes`
  /// in `arena`, each unit starting at its
  /// spot in `places` (party first), or
  /// where the arena deploys it.
  /// Everyone's first turn comes after one
  /// usual wait.
  public init(
    party: [Unit],
    foes: [Unit],
    arena: Arena = .open,
    places: [Point]? = nil
  ) {
    self.arena = arena
    let spots = places ?? arena.deploy(
      party: party.count, foes: foes.count
    )
    let sides =
      party.map { (Side.party, $0) }
      + foes.map { (Side.foes, $0) }
    units = sides.enumerated().map {
      BattleUnit(
        id: $0.offset,
        side: $0.element.0,
        unit: $0.element.1,
        place: spots[$0.offset]
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

  /// Everyone up, in the order their next
  /// turns come: the earliest tick first,
  /// ties broken by a fixed ladder (higher
  /// base Speed, then smaller size, then
  /// higher health percent, then the
  /// party, then list order), never by
  /// chance. Empty once
  /// the battle is over.
  public var queue: [Int] {
    guard winner == nil else {
      return []
    }
    return units
      .filter(\.isUp)
      .sorted {
        order($0).lexicographicallyPrecedes(
          order($1)
        )
      }
      .map(\.id)
  }

  /// Whose turn is next (the queue's
  /// first).
  public var next: Int? {
    queue.first
  }

  /// Whether the next unit can pay for its
  /// ability at this index, counting what
  /// its resource refills as its turn
  /// starts.
  public func canUse(
    _ ability: Int
  ) -> Bool {
    guard let actor = next else {
      return false
    }
    var ready = units[actor]
    ready.startTurn()
    let all = ready.unit.abilities
    return all.indices.contains(ability)
      && ready.affords(all[ability])
  }

  /// A unit's place in the turn order.
  private func order(
    _ unit: BattleUnit
  ) -> [Int] {
    [
      unit.nextTurn,
      -unit.unit.stats.speed,
      unit.unit.size.radius,
      -unit.percent,
      unit.side == .party ? 0 : 1,
      unit.id,
    ]
  }

  /// Plays the next unit's turn: `ability`
  /// (its index in the unit's list) on
  /// `target` (an id), from where it
  /// stands.
  public mutating func act(
    _ ability: Int,
    on target: Int
  ) throws(Mistake) {
    try act(Turn(
      action: Action(ability, on: target)
    ))
  }

  /// Plays the next unit's `turn`, or
  /// throws, changing nothing, if it can't
  /// be taken.
  public mutating func act(
    _ turn: Turn
  ) throws(Mistake) {
    guard let actor = next else {
      throw .over
    }
    var mover = units[actor]
    mover.startTurn()
    let stop = turn.before ?? mover.place
    let chosen = try check(
      turn.action, by: mover, at: stop
    )
    try check(
      turn.before,
      then: turn.after,
      by: mover
    )
    units[actor] = mover
    tick = mover.nextTurn
    log.append(.turn(
      mover.unit.name, tick: tick
    ))
    move(actor, to: turn.before)
    if let chosen, let action = turn.action {
      units[actor].pool -= chosen.cost
      log.append(.uses(
        mover.unit.name,
        chosen.name,
        target: units[action.target]
          .unit.name
      ))
      hit(
        units[action.target],
        with: chosen,
        from: actor
      )
    }
    move(actor, to: turn.after)
    units[actor].nextTurn += Rules.wait(
      speed: mover.unit.stats.speed,
      weight: chosen?.weight ?? .normal
    )
    if let side = winner {
      log.append(.wins(side))
    }
  }

  /// The ability `action` uses, if `mover`
  /// can use it from `spot`.
  private func check(
    _ action: Action?,
    by mover: BattleUnit,
    at spot: Point
  ) throws(Mistake) -> Ability? {
    guard let action else {
      return nil
    }
    let all = mover.unit.abilities
    guard all.indices
      .contains(action.ability)
    else { throw .noAbility }
    let chosen = all[action.ability]
    let target = action.target
    guard units.indices.contains(target),
      units[target].isUp,
      units[target].side != mover.side
    else { throw .badTarget }
    guard mover.affords(chosen) else {
      throw .cantAfford
    }
    guard reaches(
      chosen,
      from: spot,
      by: mover,
      to: units[target]
    ) else { throw .outOfReach }
    return chosen
  }

  /// Moves unit `id` to `spot`, if it's
  /// going anywhere.
  private mutating func move(
    _ id: Int,
    to spot: Point?
  ) {
    guard let spot else {
      return
    }
    units[id].place = spot
    log.append(.moves(
      units[id].unit.name, spot
    ))
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
