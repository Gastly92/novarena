/// What each side knows of the other: only
/// what it has seen. A foe that hasn't
/// moved far yet may go further; one that
/// hasn't used an ability may still have
/// it.
public extension Battle {
  /// How far from where unit `id` stands
  /// it could hit on its next turn, as far
  /// as the other side knows: the furthest
  /// it has moved in a turn, plus the
  /// longest reach of the abilities it has
  /// used, to a target's edge. None if it's
  /// down or hasn't used one yet.
  func danger(from id: Int) -> Int? {
    let foe = units[id]
    guard foe.isUp else {
      return nil
    }
    let radius = foe.unit.size.radius
    return foe.shown
      .map {
        foe.unit.abilities[$0].reach.limit(
          from: radius, to: 0
        )
      }
      .max()
      .map { foe.furthest + $0 }
  }
}
