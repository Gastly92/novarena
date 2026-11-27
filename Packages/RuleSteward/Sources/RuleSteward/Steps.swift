/// How far the unit on turn is through its
/// turn.
struct Progress: Sendable {
  /// What its moves so far cost, in
  /// centimetres of its Move.
  var moved = 0
  /// Its action's weight, once it has
  /// acted.
  var weight: Weight?
}

/// A turn, a step at a time: the unit on
/// turn moves (in as many straight legs as
/// it likes, up to its Move in all), takes
/// at most one action, and ends its turn.
/// The turn begins with its first step. A
/// step that can't be taken throws and
/// changes nothing.
public extension Battle {
  /// What's left of the unit on turn's
  /// Move, in centimetres.
  var moveLeft: Int {
    guard let actor = next else {
      return 0
    }
    let move = units[actor].unit.stats.move
    return move - (progress?.moved ?? 0)
  }

  /// Whether the unit on turn has acted.
  var hasActed: Bool {
    progress?.weight != nil
  }

  /// What moving the unit on turn straight
  /// to `spot` costs of its Move: the
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

  /// Moves the unit on turn straight to
  /// `spot`, if it fits there and has the
  /// Move left.
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
    progress?.moved += cost
    units[mover.id].place = spot
    log.append(.moves(mover.unit.name, spot))
  }

  /// The unit on turn uses `ability` (its
  /// index in the unit's list) on `target`
  /// (an id), from where it stands.
  mutating func use(
    _ ability: Int,
    on target: Int
  ) throws(Mistake) {
    let mover = try ready()
    guard !hasActed else {
      throw .acted
    }
    let chosen = try check(
      Action(ability, on: target),
      by: mover,
      at: mover.place
    )
    begin(mover)
    progress?.weight = chosen.weight
    units[mover.id].pool -= chosen.cost
    log.append(.uses(
      mover.unit.name,
      chosen.name,
      target: units[target].unit.name
    ))
    hit(
      units[target],
      with: chosen,
      from: mover.id
    )
    if let side = winner {
      progress = nil
      log.append(.wins(side))
    }
  }

  /// Ends the unit on turn's turn: its
  /// next comes after the usual wait,
  /// scaled by its action's weight.
  mutating func endTurn() throws(Mistake) {
    let mover = try ready()
    begin(mover)
    units[mover.id].nextTurn += Rules.wait(
      speed: mover.unit.stats.speed,
      weight: progress?.weight ?? .normal
    )
    progress = nil
  }

  /// Plays the rest of the unit on turn's
  /// turn: a move, an action, another move
  /// and the end, each if given. It all
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
  /// hasn't begun yet.
  func ready()
    throws(Mistake) -> BattleUnit {
    guard let actor = next else {
      throw .over
    }
    var unit = units[actor]
    if progress == nil {
      unit.startTurn()
    }
    return unit
  }

  /// Begins `mover`'s turn, if it hasn't
  /// begun: the clock moves to it, and its
  /// refill takes hold.
  mutating func begin(_ mover: BattleUnit) {
    guard progress == nil else {
      return
    }
    units[mover.id] = mover
    tick = mover.nextTurn
    log.append(.turn(
      mover.unit.name, tick: tick
    ))
    progress = Progress()
  }
}
