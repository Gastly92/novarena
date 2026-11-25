public extension Battle {
  /// The next unit's plain choice: the
  /// affordable ability and foe that deal
  /// the most damage (shields and
  /// bodyguards aside), the first on a tie.
  /// A stand-in for real tactics, so whole
  /// battles can be played and read.
  var plainChoice: (Int, on: Int)? {
    guard let actor = next else {
      return nil
    }
    let mover = units[actor]
    var best: (Int, on: Int)?
    var most = -1
    let foes = units.filter {
      $0.isUp && $0.side != mover.side
    }
    let abilities = mover.unit.abilities
    for index in abilities.indices
    where canUse(index) {
      let ability = abilities[index]
      for foe in foes {
        let amount = Rules.damage(
          ability,
          from: mover.unit.stats,
          to: foe.unit,
          intensity: 100
        )
        if amount > most {
          most = amount
          best = (index, on: foe.id)
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
      guard let (ability, target)
        = plainChoice
      else { return }
      try? act(ability, on: target)
    }
  }
}
