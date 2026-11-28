/// Reactions: what units do out of turn.
public extension Battle {
  /// The stamina a dodge costs.
  static let dodgeCost = 40
  /// The mana a counterspell costs.
  static let counterCost = 50
  /// How near a caster a counterspell
  /// reaches, edge to edge, in cm.
  static let counterRange = 300

  /// Who would counter the unit on turn
  /// using `ability` on `target` (an id):
  /// the first foe of it that can, if it's
  /// a spell; none if nobody can, or it
  /// can't be used.
  func counter(
    _ ability: Int,
    on target: Int
  ) -> Int? {
    guard let mover = try? ready(),
      let chosen = try? check(
        Action(ability, on: target),
        by: mover,
        at: mover.place
      ),
      chosen.measure == .cast
    else { return nil }
    return units.first {
      $0.side != mover.side
        && canReact($0, .counterspell)
        && near($0, mover)
    }?.id
  }
}

extension Battle {
  /// Whether `unit` could react with
  /// `reaction` now: it's up, has it,
  /// hasn't reacted this round, and can
  /// pay.
  func canReact(
    _ unit: BattleUnit,
    _ reaction: Reaction
  ) -> Bool {
    let (kind, cost) = reaction == .dodge
      ? (PoolKind.stamina, Self.dodgeCost)
      : (PoolKind.mana, Self.counterCost)
    return unit.isUp
      && unit.unit.reactions.contains(
        reaction
      )
      && unit.reacted != tick / 100
      && unit.amount(in: kind) >= cost
  }

  /// Whether `unit` is within counterspell
  /// range of `caster`, edge to edge.
  private func near(
    _ unit: BattleUnit,
    _ caster: BattleUnit
  ) -> Bool {
    let reach = Self.counterRange
      + unit.unit.size.radius
      + caster.unit.size.radius
    return unit.place.squared(
      to: caster.place
    ) <= reach * reach
  }

  /// Unit `id` counters the spell being
  /// used: it pays and has reacted.
  mutating func countered(by id: Int) {
    units[id].spend(
      Self.counterCost, from: .mana
    )
    units[id].reacted = tick / 100
    let name = units[id].unit.name
    log.append(.counters(name))
  }

  /// Unit `id` dodges `ability`, if it's
  /// an attack it can dodge: it pays and
  /// has reacted. Whether it did.
  mutating func dodge(
    _ id: Int,
    _ ability: Ability
  ) -> Bool {
    guard ability.measure != .cast,
      canReact(units[id], .dodge)
    else { return false }
    units[id].spend(
      Self.dodgeCost, from: .stamina
    )
    units[id].reacted = tick / 100
    let name = units[id].unit.name
    log.append(.dodges(name))
    return true
  }
}
