extension Battle {
  /// `mover`'s turn for using `ability` on
  /// `target`: straight there, just far
  /// enough to reach, then the ability if
  /// it reaches by then. If the spot is
  /// taken, it stays put.
  func approach(
    _ ability: Int,
    on target: Int,
    by mover: BattleUnit
  ) -> Turn {
    let foe = units[target]
    let chosen = mover.unit
      .abilities[ability]
    let action = Action(ability, on: target)
    let start = mover.place
    if reaches(
      chosen, from: start, by: mover, to: foe
    ) {
      return Turn(action: action)
    }
    let limit = chosen.reach.limit(
      from: mover.unit.size.radius,
      to: foe.unit.size.radius
    )
    // 2 more than the gap, so the rounding
    // in `toward` still ends in reach.
    let gap = Geometry.rootUp(
      start.squared(to: foe.place)
    ) - limit + 2
    let spot = start.toward(
      foe.place,
      by: min(gap, mover.unit.stats.move)
    )
    guard fits(mover, at: spot) else {
      return Turn()
    }
    let near = reaches(
      chosen, from: spot, by: mover, to: foe
    )
    return Turn(
      before: spot,
      action: near ? action : nil
    )
  }
}

public extension Battle {
  /// The next unit's plain choice: of the
  /// affordable abilities and foes, the one
  /// that deals the most damage (shields
  /// and bodyguards aside) among those it
  /// can reach this turn, walking up to it;
  /// if none, it walks toward the one that
  /// would. The first on a tie. A stand-in
  /// for real tactics, so whole battles can
  /// be played and read.
  var plainChoice: Turn? {
    guard let actor = next else {
      return nil
    }
    let mover = units[actor]
    var best: Turn?
    var most = (0, -1)
    let foes = units.filter {
      $0.isUp && $0.side != mover.side
    }
    let abilities = mover.unit.abilities
    for index in abilities.indices
    where canUse(index) {
      for foe in foes {
        let turn = approach(
          index, on: foe.id, by: mover
        )
        let amount = Rules.damage(
          abilities[index],
          from: mover.unit.stats,
          to: foe.unit,
          intensity: 100
        )
        let score = (
          turn.action == nil ? 0 : 1, amount
        )
        if score > most {
          most = score
          best = turn
        }
      }
    }
    return best
  }

  /// Plays every turn with `plainChoice`
  /// until one side wins, or `turns` run
  /// out.
  mutating func playPlainly(
    turns: Int = 200
  ) {
    for _ in 0..<turns {
      guard let turn = plainChoice else {
        return
      }
      try? act(turn)
    }
  }
}
