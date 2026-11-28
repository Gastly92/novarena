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

  /// Moves the planned spot `from` `step`
  /// cm round the unit it touches, if any:
  /// clockwise on screen, or not.
  func circle(
    _ way: Nudge,
    from: Point,
    by step: Int
  ) {
    if let other = battle.touching(from),
      let spot = battle.circle(
        from: from,
        round: other,
        clockwise: way == .clockwise,
        by: step
      ) {
      place(spot)
    }
  }

  /// The arrow circling round the unit the
  /// planned spot (or the unit's own)
  /// touches that sits in the pad's
  /// `corner` (each -1 or 1, across and
  /// down): clockwise top right, the other
  /// way top left, fixed so a held arrow
  /// stays under the finger. None if it
  /// touches nobody.
  func circling(
    at corner: (x: Int, y: Int)
  ) -> Nudge? {
    guard !isFoesTurn,
      let from = ghost ?? actor?.place,
      battle.touching(from) != nil
    else { return nil }
    let ways: [Nudge] = [
      .clockwise, .counterclockwise,
    ]
    return ways.first {
      $0.corner == corner
    }
  }

  /// How a 10 cm nudge `way` from the
  /// planned spot (or the unit's own)
  /// would go: straight, bending as it
  /// slides along an edge, or nowhere (also
  /// on a foe's turn, or once it's over).
  func bend(_ way: Nudge) -> Bend {
    guard !way.circles else {
      return .straight
    }
    guard !isFoesTurn,
      let from = ghost ?? actor?.place
    else { return .stuck }
    let goal = Point(
      x: from.x + way.offset.x * 10,
      y: from.y + way.offset.y * 10
    )
    guard let spot = battle.reachable(
      toward: goal
    ), spot != from else { return .stuck }
    let across = way.offset.x == 0
      ? spot.x - from.x : spot.y - from.y
    return Bend(way, across: across)
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
