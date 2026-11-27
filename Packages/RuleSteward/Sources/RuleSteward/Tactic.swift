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
  /// The next unit's turn for using
  /// `ability` on `target`, walking just
  /// into reach first (or as far toward
  /// it as it can); none once it's over.
  func approach(
    _ ability: Int,
    on target: Int
  ) -> Turn? {
    (try? ready()).map {
      approach(ability, on: target, by: $0)
    }
  }

  /// The next unit's plain choice: of the
  /// affordable abilities and their
  /// targets (foes to hit, allies to
  /// heal), the one that knocks out, or
  /// else wears off or mends the most
  /// (bodyguards aside), among
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
    let abilities = mover.unit.abilities
    for index in abilities.indices
    where canUse(index)
      && abilities[index].bonus == nil {
      let ability = abilities[index]
      for target in units where target.isUp
        && isTarget(
          target, of: ability, by: mover
        ) {
        let turn = approach(
          index, on: target.id, by: mover
        )
        let amount = Self.estimate(
          ability, by: mover.unit, on: target
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
  /// wear off `target`'s layers, or for a
  /// heal mend, as things stand; a
  /// knockout beats any amount.
  private static func estimate(
    _ ability: Ability,
    by unit: Unit,
    on target: BattleUnit
  ) -> Int {
    var struck = target
    let amount = Rules.damage(
      ability, by: unit, intensity: 100
    )
    guard !ability.kind.heals else {
      let gains = struck.mend(
        amount, from: ability
      )
      return gains.map(\.gained).reduce(0, +)
    }
    let losses = struck.take(
      amount, from: ability
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

  /// The target in reach of `actor`'s
  /// ability at `index`, where it stands,
  /// that it would hurt (or heal) most, if
  /// it can use it.
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
        $0.isUp
          && isTarget(
            $0, of: ability, by: mover
          )
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
