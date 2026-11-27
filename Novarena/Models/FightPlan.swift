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
  /// on its next turn, as far as the
  /// party knows (`Battle.danger(from:
  /// seenBy:)`): a circle around it.
  var zones: [Zone] {
    battle.units
      .filter { watched.contains($0.id) }
      .compactMap { unit in
        let radius = battle.danger(
          from: unit.id, seenBy: .party
        )
        return radius.map {
          Zone(
            center: unit.place,
            radius: $0,
            side: unit.side
          )
        }
      }
  }

  /// Turns unit `id`'s zone on or off.
  func watch(_ id: Int) {
    watched.formSymmetricDifference([id])
  }

  /// Whether any zone is on; turning it on
  /// shows everyone's, off hides them all.
  var showsZones: Bool {
    get { !watched.isEmpty }
    set {
      watched = newValue
        ? Set(battle.units.map(\.id)) : []
    }
  }
}

/// Where a unit could hit on its next
/// turn: a circle, and whose it is.
struct Zone {
  let center: Point
  let radius: Int
  let side: Side
}
