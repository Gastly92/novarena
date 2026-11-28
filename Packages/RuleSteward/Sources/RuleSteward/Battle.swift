/// Why a turn can't be taken.
public enum Mistake: Error, Equatable {
  /// One side has nobody up.
  case over
  /// The unit has no such ability.
  case noAbility
  /// Its pools can't pay for it.
  case cantAfford
  /// The target is missing or down; for
  /// an attack, an ally; for a heal, a
  /// foe, or an ally with nothing it can
  /// mend.
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
  /// It has already taken its main action
  /// this turn, or the bonus group's uses.
  case acted
  /// The commander's turn comes first.
  case commanding
  /// It isn't the commander's turn, or
  /// there's no commander.
  case notCommanding
}

/// A battle between the party and its foes,
/// played one turn at a time on a shared
/// timeline. Nothing is random: the same
/// choices always give the same battle.
public struct Battle: Sendable {
  /// Everyone in it, party first.
  public internal(set) var units:
    [BattleUnit]
  /// Where it's fought.
  public let arena: Arena
  /// What has happened so far.
  public internal(set) var log: [Event] = []
  /// The time, in ticks (100 a round).
  public internal(set) var tick = 0
  /// How far the unit on turn is through
  /// it, once it has begun.
  var progress: Progress?
  /// One side's commander, off the field,
  /// if it has one.
  public internal(set) var commander:
    Commander?

  /// A battle between `party` and `foes`
  /// in `arena`, each unit starting at its
  /// spot in `places` (party first), or
  /// where the arena deploys it.
  /// Everyone's first turn comes after one
  /// usual wait. A `commander` side gets
  /// one, its first turn after a usual
  /// wait too.
  public init(
    party: [Unit],
    foes: [Unit],
    arena: Arena = .open,
    places: [Point]? = nil,
    commander side: Side? = nil
  ) {
    self.arena = arena
    commander = side.map {
      Commander(side: $0)
    }
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
  /// more of its layers left, then the
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

  /// Whether the next unit can use its
  /// ability at this index: its main
  /// action not yet taken (or, for a bonus,
  /// its group's uses not spent), and its
  /// pools can pay, counting what they
  /// refill as its turn starts.
  public func canUse(
    _ ability: Int
  ) -> Bool {
    guard let ready = try? ready() else {
      return false
    }
    let all = ready.unit.abilities
    return all.indices.contains(ability)
      && isFree(all[ability])
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

  /// The ability `action` uses, if `mover`
  /// can use it from `spot`.
  func check(
    _ action: Action,
    by mover: BattleUnit,
    at spot: Point
  ) throws(Mistake) -> Ability {
    let all = mover.unit.abilities
    guard all.indices
      .contains(action.ability)
    else { throw .noAbility }
    let chosen = all[action.ability]
    let target = action.target
    guard units.indices.contains(target),
      units[target].isUp,
      isTarget(
        units[target], of: chosen, by: mover
      )
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

  /// Whether `chosen` by `mover` can be
  /// used on `target` (up): an attack on
  /// a foe, a heal on an ally (or itself)
  /// with something it can mend.
  func isTarget(
    _ target: BattleUnit,
    of chosen: Ability,
    by mover: BattleUnit
  ) -> Bool {
    guard chosen.kind.heals else {
      return target.side != mover.side
    }
    return target.side == mover.side
      && target.mendable(chosen.kind) != nil
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

  /// Mends `target` with `ability` from
  /// `actor`. Heals don't grow with
  /// intensity.
  mutating func heal(
    _ target: Int,
    with ability: Ability,
    from actor: Int
  ) {
    let amount = Rules.damage(
      ability,
      by: units[actor].unit,
      intensity: 100
    )
    let gains = units[target].mend(
      amount, from: ability
    )
    let healed = units[target]
    for (layer, gained) in gains {
      log.append(.mends(
        healed.unit.name,
        healed.unit.layers[layer].name,
        gained: gained,
        now: healed.layers[layer]
      ))
    }
  }

  /// Resolves `ability` from `actor` on
  /// `aimed`, or on its bodyguard.
  mutating func hit(
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
      by: units[actor].unit,
      intensity: Rules.intensity(at: tick)
    )
    let warded = units[target].wards > 0
    let losses = units[target].take(
      amount, from: ability
    )
    let struck = units[target]
    guard !warded else {
      log.append(.ward(
        name, left: struck.wards
      ))
      return
    }
    for (layer, lost) in losses {
      log.append(.layer(
        name,
        struck.unit.layers[layer].name,
        took: lost,
        left: struck.layers[layer]
      ))
    }
    if struck.isOut {
      log.append(.out(name))
    } else if losses.isEmpty {
      log.append(.immune(name))
    } else if struck.isExposed {
      log.append(.exposed(name))
    }
  }
}
