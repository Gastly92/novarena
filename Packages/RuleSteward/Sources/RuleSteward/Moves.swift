/// Where units can go, and what they
/// reach from there.
extension Battle {
  /// Whether `mover` fits at `spot`:
  /// inside the arena, clear of everyone
  /// else up.
  func fits(
    _ mover: BattleUnit,
    at spot: Point
  ) -> Bool {
    let radius = mover.unit.size.radius
    return arena.holds(spot, radius: radius)
      && blocker(of: mover, at: spot) == nil
  }

  /// Someone up, other than `mover`, that
  /// a circle of `mover`'s size at `spot`
  /// would overlap.
  func blocker(
    of mover: BattleUnit,
    at spot: Point
  ) -> BattleUnit? {
    let radius = mover.unit.size.radius
    return units.first {
      let apart = radius
        + $0.unit.size.radius
      return $0.id != mover.id && $0.isUp
        && $0.place.squared(to: spot)
          < apart * apart
    }
  }

  /// Whether `ability`, used by `mover`
  /// from `spot`, reaches `target`.
  func reaches(
    _ ability: Ability,
    from spot: Point,
    by mover: BattleUnit,
    to target: BattleUnit
  ) -> Bool {
    let limit = ability.reach.limit(
      from: mover.unit.size.radius,
      to: target.unit.size.radius
    )
    return spot.squared(to: target.place)
      <= limit * limit
  }
}
