import Foundation
import RuleSteward

/// What the picked skill would do, and on
/// whom it can be used.
extension Fight {
  /// What the picked skill would do to
  /// unit `id`, from the planned spot, a
  /// line each; none until one is picked,
  /// or if it can't be used on `id` (an
  /// ally for an attack, a foe for a heal,
  /// anyone down).
  func preview(of id: Int) -> [String] {
    guard let turn = plan(on: id) else {
      return []
    }
    do {
      return try battle.forecast(turn)
        .lines(for: id, in: battle)
    } catch .outOfReach {
      return [
        String(localized: "Out of reach"),
      ]
    } catch {
      return []
    }
  }

  /// Whether the picked skill, from the
  /// planned spot, reaches unit `id` and
  /// can be used on it.
  func inReach(_ id: Int) -> Bool {
    let forecast = plan(on: id).flatMap {
      try? battle.forecast($0)
    }
    return forecast?.strike != nil
  }

  /// Whether the picked skill can be used
  /// on unit `id` at all, in reach or not:
  /// an attack on a foe up, a heal on an
  /// ally it can mend.
  func canAim(at id: Int) -> Bool {
    guard let turn = plan(on: id) else {
      return false
    }
    do {
      _ = try battle.forecast(turn)
      return true
    } catch .badTarget {
      return false
    } catch {
      return true
    }
  }

  /// The turn order once this turn ends
  /// (with the planned move, and the
  /// picked skill on the first unit it
  /// reaches, if any), showing where the
  /// unit on turn lands, whatever the
  /// turn: acting, only moving or
  /// waiting; none on a foe's turn, once
  /// it's over, or if it would end the
  /// battle.
  var queueAfter: [BattleUnit] {
    (afterTurn?.queue ?? []).map {
      battle.units[$0]
    }
  }

  /// The turn order shown, a seat each:
  /// the order after this turn (or, with
  /// none to plan, as it stands), with the
  /// commander's seat where its turn falls;
  /// none once it's over.
  var seats: [Seat] {
    let after = afterTurn
    let ids = after?.queue ?? battle.queue
    guard !ids.isEmpty else {
      return []
    }
    let slot = after.map(\.commanderSlot)
      ?? battle.commanderSlot(in: ids)
    var all = ids.enumerated().map {
      Seat.unit(
        battle.units[$0.element],
        place: $0.offset
      )
    }
    if let slot {
      all.insert(.commander, at: slot)
    }
    return all
  }

  /// What this turn would do (with the
  /// picked skill on the first unit it
  /// reaches, if any); none on a foe's or
  /// the commander's turn, once it's over,
  /// or if it would end the battle.
  private var afterTurn: Forecast? {
    guard !isFoesTurn, !isCommanding else {
      return nil
    }
    let mine = aimed.map {
      Turn(before: ghost, action: $0)
    }
    let turns = [mine].compactMap(\.self)
      + battle.units
      .compactMap { plan(on: $0.id) }
      + [Turn(before: ghost)]
    let forecasts = turns.compactMap {
      try? battle.forecast($0)
    }
    let after = forecasts.first {
      $0.strike != nil
    } ?? forecasts.last
    return after?.queue.isEmpty == false
      ? after : nil
  }

  /// The rest of the turn using the picked
  /// skill on unit `id` from the planned
  /// spot; none until a skill is picked.
  private func plan(on id: Int) -> Turn? {
    chosen.map {
      Turn(
        before: ghost,
        action: Action($0, on: id)
      )
    }
  }
}

/// A seat in the turn order: a unit (its
/// place among the units), or the
/// commander.
enum Seat {
  case unit(BattleUnit, place: Int)
  case commander
}
