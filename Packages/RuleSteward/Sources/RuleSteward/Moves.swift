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
  /// Everyone up the unit on turn would
  /// touch (within 2 cm) standing at
  /// `spot`; none if nobody is on turn.
  func touched(
    _ spot: Point
  ) -> [BattleUnit] {
    guard let mover = try? ready() else {
      return []
    }
    let radius = mover.unit.size.radius
    return units.filter {
      let apart = radius
        + $0.unit.size.radius + 2
      return $0.id != mover.id && $0.isUp
        && $0.place.squared(to: spot)
          <= apart * apart
    }
  }

  /// Whether a straight move from `spot`
  /// toward `next` heads into a unit
  /// `spot` touches (nearer its middle):
  /// a nudge that shouldn't go, as
  /// circling goes round it instead.
  func heads(
    from spot: Point,
    into next: Point
  ) -> Bool {
    touched(spot).contains {
      next.squared(to: $0.place)
        < spot.squared(to: $0.place)
    }
  }

  /// The first unit `touched(spot)` lists.
  func touching(
    _ spot: Point
  ) -> BattleUnit? {
    touched(spot).first
  }

  /// The spot `step` centimetres (or as
  /// near that as it can go) round a unit
  /// the planned `spot` touches, clockwise
  /// on screen or not, kept just clear of
  /// it. Where two units meet, it goes
  /// round whichever lets it go on, so a
  /// group is circled round its outside.
  /// None if it can't go: nothing touched,
  /// or every step would overlap someone,
  /// leave the arena or go out of range.
  func circle(
    from spot: Point,
    clockwise: Bool,
    by step: Int
  ) -> Point? {
    var length = step
    while length > 0 {
      if let next = around(
        spot,
        clockwise: clockwise,
        by: length
      ) {
        return next
      }
      length /= 2
    }
    return nil
  }
}

extension Battle {
  /// The first spot `step` centimetres
  /// round a unit `spot` touches that the
  /// unit on turn can reach and fits in.
  private func around(
    _ spot: Point,
    clockwise: Bool,
    by step: Int
  ) -> Point? {
    guard let mover = try? ready() else {
      return nil
    }
    let radius = mover.unit.size.radius
    return touched(spot).lazy
      .compactMap { other in
        let apart = radius
          + other.unit.size.radius
        let ahead = Self.ahead(
          of: spot,
          round: other.place,
          clockwise: clockwise,
          by: step
        )
        return ahead?.away(
          from: other.place, by: apart
        )
      }
      .first {
        fits(mover, at: $0)
          && cost(to: $0) <= moveLeft
      }
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
