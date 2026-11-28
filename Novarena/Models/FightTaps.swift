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
  /// open, a foe is picked to walk toward
  /// (`approach`), an ally walked to; else
  /// nothing yet (later: its details).
  /// Anywhere else it can reach is
  /// planned.
  func tap(_ point: Point) {
    guard let actor else {
      return
    }
    approached = nil
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
      approach(unit, from: actor)
    } else if unit == nil {
      place(point)
    }
  }

  /// Plans the picked skill on unit `id`
  /// (`target(_:)`), first planning the
  /// move just into reach if it doesn't
  /// reach from the planned spot (or as
  /// far toward it as the unit can go this
  /// turn), or no move if it reaches from
  /// where the unit stands.
  func aim(at id: Int) {
    if !inReach(id), let chosen,
      let turn = battle.approach(
        chosen, on: id
      ) {
      if let spot = turn.before {
        place(spot)
      } else {
        undo()
      }
    }
    target(id)
  }

  /// With the move open, a tapped foe is
  /// picked to walk toward (`approached`):
  /// up close or in range, as the player
  /// chooses. An ally is walked to, just
  /// touching.
  func approach(
    _ unit: BattleUnit,
    from actor: BattleUnit
  ) {
    if unit.side == actor.side {
      walk(to: unit, from: actor)
    } else {
      approached = unit.id
    }
  }

  /// Walks straight toward the approached
  /// foe, stopping just touching it (or at
  /// the edge of the range).
  func upClose() {
    guard let id = approached, let actor
    else { return }
    walk(to: battle.units[id], from: actor)
  }

  /// Walks to the edge of the picked
  /// skill's reach on the approached foe,
  /// or with none, the longest reach;
  /// backing away if nearer
  /// (`Battle.standoff`).
  func inRange() {
    guard let spot = rangeSpot else {
      return
    }
    place(spot)
  }

  /// Where `inRange()` goes; none without a
  /// foe approached, or a skill that
  /// reaches it.
  var rangeSpot: Point? {
    approached.flatMap {
      battle.standoff(on: $0, with: chosen)
    }
  }

  /// Plans a straight walk from `actor`
  /// toward `unit`, stopping just touching
  /// it (or at the edge of the range).
  private func walk(
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

  /// Whether backing away would move the
  /// planned spot: a skill is planned, and
  /// the spot isn't at the edge of its
  /// reach already.
  var canBackAway: Bool {
    guard let aimed else {
      return false
    }
    let edge = battle.standoff(
      on: aimed.target,
      with: aimed.ability
    )
    return edge != (ghost ?? actor?.place)
  }

  /// Moves the planned spot back (or in)
  /// to the edge of the planned skill's
  /// reach on its target
  /// (`Battle.standoff`), as far as the
  /// unit can go; the skill stays planned.
  /// Nothing without a plan.
  func backAway() {
    guard let aimed,
      let spot = battle.standoff(
        on: aimed.target,
        with: aimed.ability
      )
    else { return }
    place(spot)
  }
}
