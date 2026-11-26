/// Where units can go, and what they
/// reach from there.
extension Battle {
  /// Whether `mover` can move to `first`,
  /// then on to `second`.
  func check(
    _ first: Point?,
    then second: Point?,
    by mover: BattleUnit
  ) throws(Mistake) {
    let stop = first ?? mover.place
    let end = second ?? stop
    for spot in [first, second]
    where !fits(mover, at: spot) {
      throw .blocked
    }
    guard Geometry.legs(
      mover.place.squared(to: stop),
      stop.squared(to: end),
      within: mover.unit.stats.move
    ) else { throw .tooFar }
  }

  /// Whether `mover` fits at `spot` (if
  /// it's going anywhere): inside the
  /// arena, clear of everyone else up.
  func fits(
    _ mover: BattleUnit,
    at spot: Point?
  ) -> Bool {
    guard let spot else {
      return true
    }
    let radius = mover.unit.size.radius
    return arena.holds(spot, radius: radius)
      && units.allSatisfy {
        let apart = radius
          + $0.unit.size.radius
        return $0.id == mover.id || !$0.isUp
          || $0.place.squared(to: spot)
            >= apart * apart
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
