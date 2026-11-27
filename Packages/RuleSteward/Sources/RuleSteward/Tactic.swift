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
      by: min(
        gap, mover.amount(in: .movement)
      )
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
  /// that knocks out, or else wears off
  /// the most (bodyguards aside), among
  /// those it can reach this turn, walking
  /// up to it; if none, it walks toward the
  /// one that would. The first on a tie. A
  /// stand-in for real tactics, so whole
  /// battles can be played and read.
  var plainChoice: Turn? {
    guard let mover = try? ready() else {
      return nil
    }
    var best: Turn?
    var most = (0, -1)
    let foes = units.filter {
      $0.isUp && $0.side != mover.side
    }
    let abilities = mover.unit.abilities
    for index in abilities.indices
    where canUse(index)
      && abilities[index].bonus == nil {
      for foe in foes {
        let turn = approach(
          index, on: foe.id, by: mover
        )
        let amount = Self.estimate(
          abilities[index],
          by: mover.unit,
          on: foe
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
    return best.map {
      var turn = $0
      turn.bonuses = plainBonuses(
        after: turn
      )
      return turn
    }
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

  /// How much `ability` by `unit` would
  /// wear off `foe`'s layers, as things
  /// stand; a knockout beats any amount.
  private static func estimate(
    _ ability: Ability,
    by unit: Unit,
    on foe: BattleUnit
  ) -> Int {
    var struck = foe
    let losses = struck.take(
      Rules.damage(
        ability, by: unit, intensity: 100
      ),
      from: ability
    )
    return struck.isOut ? 100_000
      : losses.map(\.lost).reduce(0, +)
  }

  /// The bonus actions the unit on turn
  /// would add after `turn`'s move and main
  /// action: each bonus skill, while its
  /// group has uses and its pools can pay,
  /// on the foe in reach it hurts most.
  private func plainBonuses(
    after turn: Turn
  ) -> [Action] {
    var after = self
    if let spot = turn.before {
      try? after.move(to: spot)
    }
    if let action = turn.action {
      try? after.use(
        action.ability, on: action.target
      )
    }
    var picks: [Action] = []
    guard let actor = after.next else {
      return picks
    }
    let all = after.units[actor].unit
      .abilities
    for index in all.indices
    where all[index].bonus != nil {
      while let foe = after.plainTarget(
        index, by: actor
      ), (try? after.use(
        index, on: foe
      )) != nil {
        picks.append(Action(index, on: foe))
      }
    }
    return picks
  }

  /// The foe in reach of `actor`'s ability
  /// at `index`, where it stands, that it
  /// would hurt most, if it can use it.
  private func plainTarget(
    _ index: Int,
    by actor: Int
  ) -> Int? {
    guard canUse(index) else {
      return nil
    }
    let mover = units[actor]
    let ability = mover.unit.abilities[index]
    return units
      .filter {
        $0.isUp && $0.side != mover.side
          && reaches(
            ability,
            from: mover.place,
            by: mover,
            to: $0
          )
      }
      .max {
        Self.estimate(
          ability, by: mover.unit, on: $0
        ) < Self.estimate(
          ability, by: mover.unit, on: $1
        )
      }?
      .id
  }
}
