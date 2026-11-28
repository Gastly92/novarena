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

/// Circling round another unit, for
/// planning a move that hugs it.
public extension Battle {
  /// Someone up the unit on turn would
  /// touch (within 2 cm) standing at
  /// `spot`; none if no one, or nobody is
  /// on turn.
  func touching(
    _ spot: Point
  ) -> BattleUnit? {
    guard let mover = try? ready() else {
      return nil
    }
    let radius = mover.unit.size.radius
    return units.first {
      let apart = radius
        + $0.unit.size.radius + 2
      return $0.id != mover.id && $0.isUp
        && $0.place.squared(to: spot)
          <= apart * apart
    }
  }

  /// The spot `step` centimetres round
  /// `other` from `spot`, clockwise on
  /// screen (or not), kept just clear of
  /// it and within the unit on turn's
  /// range; none if it can't go.
  func circle(
    from spot: Point,
    round other: BattleUnit,
    clockwise: Bool,
    by step: Int
  ) -> Point? {
    guard let mover = try? ready(),
      let ahead = Self.ahead(
        of: spot,
        round: other.place,
        clockwise: clockwise,
        by: step
      )
    else { return nil }
    let apart = mover.unit.size.radius
      + other.unit.size.radius
    let clear = ahead.away(
      from: other.place, by: apart
    )
    return clear.flatMap {
      reachable(toward: $0)
    }
  }

  /// Whether `spot` is on the edge of the
  /// unit on turn's range (within 2 cm).
  func atEdge(_ spot: Point) -> Bool {
    moveLeft > 0
      && cost(to: spot) + 2 >= moveLeft
  }

  /// The spot `step` centimetres round the
  /// edge of the unit on turn's range from
  /// `spot`, clockwise on screen (or not),
  /// kept on the edge; none if it can't
  /// go.
  func orbit(
    from spot: Point,
    clockwise: Bool,
    by step: Int
  ) -> Point? {
    guard let mover = try? ready(),
      let ahead = Self.ahead(
        of: spot,
        round: mover.place,
        clockwise: clockwise,
        by: step
      )
    else { return nil }
    return reachable(toward: ahead)
  }
}

extension Battle {
  /// `step` centimetres on from `spot`
  /// along the circle round `center`
  /// (clockwise on screen, or not), rounded
  /// outward so it always moves; none from
  /// `center` itself.
  static func ahead(
    of spot: Point,
    round center: Point,
    clockwise: Bool,
    by step: Int
  ) -> Point? {
    let across = spot.x - center.x
    let down = spot.y - center.y
    let length = Geometry.rootUp(
      center.squared(to: spot)
    )
    guard length > 0 else {
      return nil
    }
    let turn = clockwise
      ? (x: -down, y: across)
      : (x: down, y: -across)
    return Point(
      x: spot.x + Geometry.outward(
        turn.x * step, over: length
      ),
      y: spot.y + Geometry.outward(
        turn.y * step, over: length
      )
    )
  }
}
