/// How far the unit on turn is through its
/// turn.
struct Progress: Sendable {
  /// Its main action's weight, once it has
  /// taken it.
  var weight: Weight?
  /// Bonus uses so far, by group.
  var bonuses: [String: Int] = [:]
}

/// A turn, a step at a time: the unit on
/// turn moves (in as many straight legs as
/// its movement pool pays for), takes at
/// most one main action and the bonus
/// actions its groups allow, and ends its
/// turn. The turn begins with its first
/// step. A step that can't be taken throws
/// and changes nothing.
public extension Battle {
  /// What's left of the unit on turn's
  /// movement, in centimetres; 0 if it
  /// can't move.
  var moveLeft: Int {
    (try? ready())?.amount(in: .movement)
      ?? 0
  }

  /// Whether the unit on turn has taken its
  /// main action.
  var hasActed: Bool {
    progress?.weight != nil
  }

  /// What moving the unit on turn straight
  /// to `spot` costs of its movement: the
  /// distance, rounded up to whole
  /// centimetres, so legs never add up to
  /// more than they walk.
  func cost(to spot: Point) -> Int {
    guard let actor = next else {
      return 0
    }
    return Geometry.rootUp(
      units[actor].place.squared(to: spot)
    )
  }

  /// The nearest spot to `spot` the unit
  /// on turn can stop at: `spot` itself if
  /// it's in range, in the arena and
  /// clear; else pulled into the arena and
  /// its range (on the way there), and
  /// pushed clear of whoever is in the
  /// way, so a plan slides along those
  /// edges. If that finds nothing (`spot`
  /// on someone's middle, or wedged
  /// between a unit and the edge of the
  /// range), the furthest clear spot on
  /// the straight way toward it. None if
  /// not even that, or nobody is on turn.
  func reachable(
    toward spot: Point
  ) -> Point? {
    guard let mover = try? ready() else {
      return nil
    }
    let radius = mover.unit.size.radius
    var stop = spot
    for _ in 0..<4 {
      if fits(mover, at: stop),
        cost(to: stop) <= moveLeft {
        return stop
      }
      stop = arena.clamp(
        stop, radius: radius
      )
      if cost(to: stop) > moveLeft {
        stop = mover.place.toward(
          stop, by: moveLeft
        )
      }
      if let other = blocker(
        of: mover, at: stop
      ) {
        let apart = radius
          + other.unit.size.radius
        guard let out = stop.away(
          from: other.place, by: apart
        ) else { break }
        stop = out
      }
    }
    let aim = arena.clamp(
      spot, radius: radius
    )
    return furthest(toward: aim, by: mover)
  }

  /// The furthest spot on the straight way
  /// from where `mover` stands toward
  /// `spot`, within its range, where it
  /// fits, trying every 5 cm back.
  private func furthest(
    toward spot: Point,
    by mover: BattleUnit
  ) -> Point? {
    let most = min(cost(to: spot), moveLeft)
    return stride(from: most, to: 0, by: -5)
      .lazy
      .map {
        mover.place.toward(spot, by: $0)
      }
      .first { fits(mover, at: $0) }
  }

  /// Moves the unit on turn straight to
  /// `spot`, if it fits there and has the
  /// movement left.
  mutating func move(
    to spot: Point
  ) throws(Mistake) {
    let mover = try ready()
    guard fits(mover, at: spot) else {
      throw .blocked
    }
    let cost = cost(to: spot)
    guard cost <= moveLeft else {
      throw .tooFar
    }
    begin(mover)
    units[mover.id].spend(
      cost, from: .movement
    )
    units[mover.id].place = spot
    units[mover.id].moving += cost
    units[mover.id].furthest = max(
      units[mover.id].furthest,
      units[mover.id].moving
    )
    log.append(.moves(mover.unit.name, spot))
  }

  /// The unit on turn uses `ability` (its
  /// index in the unit's list) on `target`
  /// (an id), from where it stands: its
  /// main action, or a bonus one if its
  /// group has uses left this turn. A foe
  /// who can counter it does, unless
  /// `reacting` is off (its side said no).
  mutating func use(
    _ ability: Int,
    on target: Int,
    reacting: Bool = true
  ) throws(Mistake) {
    let mover = try ready()
    let chosen = try check(
      Action(ability, on: target),
      by: mover,
      at: mover.place
    )
    guard isFree(chosen) else {
      throw .acted
    }
    let counter = reacting
      ? counter(ability, on: target) : nil
    begin(mover)
    if let bonus = chosen.bonus {
      let group = bonus.group
      let used = progress?.bonuses[group]
        ?? 0
      progress?.bonuses[group] = used + 1
    } else {
      progress?.weight = chosen.weight
    }
    units[mover.id].pay(for: chosen)
    units[mover.id].shown.insert(ability)
    log.append(.uses(
      mover.unit.name,
      chosen.name,
      target: units[target].unit.name
    ))
    if let counter {
      countered(by: counter)
    } else if chosen.kind.heals {
      heal(
        target, with: chosen, from: mover.id
      )
    } else {
      hit(
        units[target],
        with: chosen,
        from: mover.id
      )
    }
    if let side = winner {
      progress = nil
      log.append(.wins(side))
    }
  }

  /// What `unit`'s layer at `index` growing
  /// back from `was` at its turn's start
  /// logs: a recharge or regrowth.
  static func restoring(
    _ unit: BattleUnit,
    layer index: Int,
    from was: Int
  ) -> Event {
    let layer = unit.unit.layers[index]
    let now = unit.layers[index]
    if layer.recharge > 0 {
      return .recharges(
        unit.unit.name,
        layer.name,
        gained: now - was,
        now: now
      )
    }
    return .regrows(
      unit.unit.name,
      layer.name,
      gained: now - was,
      now: now
    )
  }

  /// Begins the next unit's turn without
  /// moving or acting yet: its refill and
  /// passives take hold (`begin`), as a
  /// step of its own. Nothing more
  /// happens if it has begun.
  mutating func beginTurn() throws(Mistake) {
    begin(try ready())
  }

  /// Ends the unit on turn's turn: its
  /// next comes after the usual wait,
  /// scaled by its main action's weight
  /// and by how much of its movement it
  /// used (`Rules.pace`).
  mutating func endTurn() throws(Mistake) {
    let mover = try ready()
    begin(mover)
    let range = mover.unit.pools.first {
      $0.kind == .movement
    }?.maximum ?? 0
    let pace = Rules.pace(
      moved: units[mover.id].moving,
      of: range
    )
    units[mover.id].nextTurn += Rules.wait(
      speed: mover.unit.stats.speed,
      weight: progress?.weight ?? .normal,
      pace: pace
    )
    progress = nil
  }

  /// Plays the rest of the unit on turn's
  /// turn: a move, an action, bonus
  /// actions, another move and the end,
  /// each if given. It all
  /// happens or, if a step can't be taken,
  /// none of it.
  mutating func act(
    _ turn: Turn
  ) throws(Mistake) {
    var after = self
    if let spot = turn.before {
      try after.move(to: spot)
    }
    if let action = turn.action {
      try after.use(
        action.ability, on: action.target
      )
    }
    for bonus in turn.bonuses
    where after.winner == nil {
      try after.use(
        bonus.ability, on: bonus.target
      )
    }
    if after.winner == nil {
      if let spot = turn.after {
        try after.move(to: spot)
      }
      try after.endTurn()
    }
    self = after
  }
}

extension Battle {
  /// The unit on turn as its turn has it:
  /// refilled at the start, if the turn
  /// hasn't begun yet. Units wait while
  /// the commander is up.
  func ready()
    throws(Mistake) -> BattleUnit {
    guard let actor = next else {
      throw .over
    }
    guard !commanderUp else {
      throw .commanding
    }
    var unit = units[actor]
    if progress == nil {
      unit.startTurn()
    }
    return unit
  }

  /// Whether the unit on turn may still use
  /// `ability` this turn: the main action
  /// if it hasn't taken it, a bonus while
  /// its group has uses left.
  func isFree(_ ability: Ability) -> Bool {
    guard let bonus = ability.bonus else {
      return !hasActed
    }
    let used = progress?.bonuses[bonus.group]
      ?? 0
    return used < bonus.perTurn
  }

  /// Begins `mover`'s turn, if it hasn't
  /// begun: the clock moves to it, and its
  /// refill and passives take hold, each
  /// layer that regrows or recharges
  /// logged.
  mutating func begin(_ mover: BattleUnit) {
    guard progress == nil else {
      return
    }
    let before = units[mover.id].layers
    units[mover.id] = mover
    tick = mover.nextTurn
    log.append(.turn(
      mover.unit.name, tick: tick
    ))
    for (index, was) in before.enumerated()
    where mover.layers[index] > was {
      log.append(Self.restoring(
        mover, layer: index, from: was
      ))
    }
    progress = Progress()
  }
}
