/// What each side knows of the other: only
/// what it has seen. A foe that hasn't
/// moved far yet may go further; one that
/// hasn't used an ability may still have
/// it. Of its own side, it knows all.
public extension Battle {
  /// How far from where unit `id` stands
  /// it could hit on its next turn, as far
  /// as `side` knows, to a target's edge.
  /// Of the other side, the furthest it
  /// has moved in a turn, plus the longest
  /// reach of the attacks it has used; of
  /// its own, its movement next turn plus
  /// its longest reach. None if it's down
  /// or none is known.
  func danger(
    from id: Int,
    seenBy side: Side
  ) -> Int? {
    zone(of: id, seenBy: side, heals: false)
  }

  /// The same for its heals: how far it
  /// could heal on its next turn.
  func care(
    from id: Int,
    seenBy side: Side
  ) -> Int? {
    zone(of: id, seenBy: side, heals: true)
  }

  /// `danger` or, with `heals`, `care`.
  private func zone(
    of id: Int,
    seenBy side: Side,
    heals: Bool
  ) -> Int? {
    let unit = units[id]
    guard unit.isUp else {
      return nil
    }
    let all = unit.unit.abilities
    let known = unit.side == side
    let used = known
      ? Set(all.indices) : unit.shown
    let move = known
      ? unit.moveNextTurn : unit.furthest
    let radius = unit.unit.size.radius
    return used
      .filter { all[$0].kind.heals == heals }
      .map {
        all[$0].reach.limit(
          from: radius, to: 0
        )
      }
      .max()
      .map { move + $0 }
  }

  /// The round, from 1: 100 ticks each.
  var round: Int {
    tick / 100 + 1
  }

  /// How hard hits land now, in percent
  /// (`Rules.intensity(at:)`).
  var intensity: Int {
    Rules.intensity(at: tick)
  }
}

extension BattleUnit {
  /// What its movement pool holds once its
  /// next turn starts; 0 with none.
  var moveNextTurn: Int {
    zip(unit.pools, pools)
      .first { $0.0.kind == .movement }
      .map { $0.0.refilled($0.1) } ?? 0
  }
}
