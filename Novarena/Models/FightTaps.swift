import RuleSteward

/// Taps on the arena, by what's selected:
/// a skill, the zones, the move.
extension Fight {
  /// A tap on the arena at `point`. On a
  /// unit (or within 30 cm of another: the
  /// unit on turn's own circle is exact,
  /// so a tap just beside it plans a short
  /// move): with a skill
  /// picked that can be used on it, aims
  /// it (`aim(at:)`); on the unit on turn,
  /// clears the plan; with zones on, turns
  /// its zone on or off; with the move
  /// open, plans a walk to it; else
  /// nothing yet (later: its details).
  /// Anywhere else it can reach is
  /// planned.
  func tap(_ point: Point) {
    guard let actor else {
      return
    }
    let other = battle.units.first {
      $0.isUp && $0.id != actor.id
        && Self.covers($0, point, by: 30)
    }
    let mine = Self.covers(
      actor, point, by: 0
    )
    let unit = other ?? (mine ? actor : nil)
    if let unit, canAim(at: unit.id) {
      aim(at: unit.id)
    } else if unit?.id == actor.id {
      undo()
    } else if let unit, zoning {
      watch(unit.id)
    } else if let unit, panel == .move {
      walk(to: unit, from: actor)
    } else if unit == nil {
      place(point)
    }
  }

  /// Uses the picked skill on unit `id` if
  /// it reaches from the planned spot; else
  /// plans the move just into reach (or as
  /// far toward it as the unit can go this
  /// turn), or no move if it reaches from
  /// where the unit stands.
  func aim(at id: Int) {
    guard !inReach(id) else {
      target(id)
      return
    }
    if let chosen,
      let turn = battle.approach(
        chosen, on: id
      ) {
      if let spot = turn.before {
        place(spot)
      } else {
        undo()
      }
    }
  }

  /// Plans a straight walk from `actor`
  /// toward `unit`, stopping just touching
  /// it (or at the edge of the range).
  func walk(
    to unit: BattleUnit,
    from actor: BattleUnit
  ) {
    let apart = actor.unit.size.radius
      + unit.unit.size.radius
    place(unit.place.toward(
      actor.place, by: apart
    ))
  }

  /// Whether `point` is on `unit`'s circle,
  /// or within `slack` cm of it.
  private static func covers(
    _ unit: BattleUnit,
    _ point: Point,
    by slack: Int
  ) -> Bool {
    let radius = unit.unit.size.radius
      + slack
    let across = point.x - unit.place.x
    let down = point.y - unit.place.y
    return across * across + down * down
      <= radius * radius
  }
}
