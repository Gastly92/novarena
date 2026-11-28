import RuleSteward

/// What a fight says about the turn being
/// planned: the move, the picked skill's
/// reach, and the zones.
extension Fight {
  /// The planned move and what's left
  /// after, in the unit's own measure, or
  /// how to plan one.
  var moveStatus: String {
    Self.moveStatus(
      actor?.unit.pools.first {
        $0.kind == .movement
      },
      left: moveLeft,
      planned: planned
    )
  }

  /// What `moveStatus` says, for a unit
  /// with a movement `pool` (if any),
  /// `left` of it, and `planned` of it to
  /// spend.
  static func moveStatus(
    _ pool: Pool?,
    left: Int,
    planned: Int?
  ) -> String {
    guard let pool else {
      return String(localized: "Can't move")
    }
    let measure = pool.measure ?? .step
    let now = measure.says(left)
    guard let planned else {
      return String(localized: """
        \(now) of movement left. Drag in \
        the arena, or use the arrows.
        """)
    }
    let after = measure.says(left - planned)
    return String(localized: """
      Moves \(measure.says(planned)), then \
      \(after) left
      """)
  }

  /// Where the picked skill reaches from
  /// (the planned spot, or where the unit
  /// stands), and how far, to a target's
  /// edge; none until one is picked.
  var reach: (center: Point, radius: Int)? {
    guard let chosen, let actor else {
      return nil
    }
    let skill = actor.unit.abilities[chosen]
    let radius = skill.reach.limit(
      from: actor.unit.size.radius, to: 0
    )
    return (ghost ?? actor.place, radius)
  }

  /// Where each watched unit up could hit
  /// on its next turn, and heal, as far as
  /// the party knows (`Battle.danger` and
  /// `Battle.care`): circles around it.
  var zones: [Zone] {
    battle.units
      .filter { watched.contains($0.id) }
      .flatMap { unit in
        [false, true].compactMap { heals in
          zone(of: unit, heals: heals)
        }
      }
  }

  /// Unit's harm zone, or with `heals` its
  /// heal zone, if the party knows one.
  private func zone(
    of unit: BattleUnit,
    heals: Bool
  ) -> Zone? {
    let radius = heals
      ? battle.care(
        from: unit.id, seenBy: .party
      )
      : battle.danger(
        from: unit.id, seenBy: .party
      )
    return radius.map {
      Zone(
        center: unit.place,
        radius: $0,
        side: unit.side,
        heals: heals
      )
    }
  }

  /// The circle the planned spot (or the
  /// unit's own) rests on, that the orbit
  /// arrows follow: round the unit it
  /// touches (just clear of it), else the
  /// edge of the range. None if neither,
  /// or when it isn't the party's unit's
  /// turn.
  var rim: Rim? {
    guard !isFoesTurn, !isCommanding,
      let actor
    else { return nil }
    let from = ghost ?? actor.place
    let gap = actor.unit.size.radius + 45
    if let other = battle.touching(from) {
      let apart = actor.unit.size.radius
        + other.unit.size.radius
      return Rim(
        center: other.place,
        radius: apart,
        spot: from,
        gap: gap
      )
    }
    return battle.atEdge(from)
      ? Rim(
        center: actor.place,
        radius: moveLeft,
        spot: from,
        gap: gap
      ) : nil
  }

  /// Moves the planned spot `from` at
  /// least 5 cm (or `step`) round what it
  /// rests on (`rim`): clockwise on screen,
  /// or not.
  func circle(
    _ way: Nudge,
    from: Point,
    by step: Int
  ) {
    let clockwise = way == .clockwise
    let length = max(step, 5)
    let spot = battle.touching(from).map {
      battle.circle(
        from: from,
        round: $0,
        clockwise: clockwise,
        by: length
      )
    } ?? battle.orbit(
      from: from,
      clockwise: clockwise,
      by: length
    )
    if let spot {
      place(spot)
    }
  }

  /// Turns unit `id`'s zone on or off.
  func watch(_ id: Int) {
    watched.formSymmetricDifference([id])
  }

  /// Whether zones are on; turning them on
  /// shows everyone's (taps then turn each
  /// off or on), off hides them all.
  var showsZones: Bool {
    get { zoning }
    set {
      zoning = newValue
      watched = newValue
        ? Set(battle.units.map(\.id)) : []
    }
  }
}

/// Where a unit could hit (or heal) on its
/// next turn: a circle, whose it is, and
/// which.
struct Zone {
  let center: Point
  let radius: Int
  let side: Side
  let heals: Bool
}

/// The circle the planned spot rests on
/// (`Fight.rim`), and where the orbit
/// arrows sit.
struct Rim {
  let center: Point
  let radius: Int
  /// The planned spot, on it.
  let spot: Point
  /// How far from the spot the arrows
  /// sit, in centimetres.
  let gap: Int

  /// Where the orbit arrow `way` sits:
  /// `gap` round from the spot, the way
  /// it goes.
  func arrow(_ way: Nudge) -> Point {
    let across = Double(spot.x - center.x)
    let down = Double(spot.y - center.y)
    let length = (
      across * across + down * down
    ).squareRoot()
    let turn = way == .clockwise
      ? (x: -down, y: across)
      : (x: down, y: -across)
    let scale = Double(gap) / max(length, 1)
    return Point(
      x: spot.x + Int(turn.x * scale),
      y: spot.y + Int(turn.y * scale)
    )
  }
}
