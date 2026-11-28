import Foundation
import RuleSteward

/// What a fight shows of the battle, and
/// what follows a step by itself: the turn
/// ending once nothing's left, the foes'
/// turns beginning.
extension Fight {
  /// The unit whose turn it is.
  var actor: BattleUnit? {
    battle.next.map { battle.units[$0] }
  }

  /// Everyone up, in turn order.
  var queue: [BattleUnit] {
    battle.queue.map { battle.units[$0] }
  }

  /// One side's units, in list order.
  func units(_ side: Side) -> [BattleUnit] {
    battle.units.filter { $0.side == side }
  }

  /// One side's units still up.
  func standing(
    _ side: Side
  ) -> [BattleUnit] {
    units(side).filter(\.isUp)
  }

  /// Everyone knocked out, party first.
  var fallen: [BattleUnit] {
    battle.units.filter { !$0.isUp }
  }

  /// The latest log lines, newest first.
  var latest: [String] {
    battle.log.suffix(12).reversed().map {
      $0.description.trimmingCharacters(
        in: .whitespaces
      )
    }
  }

  /// Who won, once someone has.
  var outcome: String? {
    battle.winner.map {
      $0 == .party
        ? String(localized: "The party wins")
        : String(localized: "The foes win")
    }
  }

  /// What the planned move would cost, in
  /// centimetres, if one is planned.
  var planned: Int? {
    ghost.map { battle.cost(to: $0) }
  }

  /// What's left of the unit on turn's
  /// movement, before the planned move.
  var moveLeft: Int {
    battle.moveLeft
  }

  /// Whether the planned skill reaches its
  /// target from the planned spot.
  var canUse: Bool {
    aimed.map { inReach($0.target) }
      ?? false
  }

  /// Ends the turn, if the settings say so
  /// and the unit on turn has no skill it
  /// can use on anyone from where it
  /// stands (none it can pay for, or none
  /// that reaches) and no movement left.
  func endIfDone() {
    guard settings.endsTurns, !isFoesTurn,
      !isCommanding, let actor
    else { return }
    let left = actor.unit.abilities.indices
      .contains(where: reachesAnyone)
    if !left, battle.moveLeft == 0 {
      endTurn()
    }
  }

  /// Whether the unit on turn can use
  /// `ability` on someone from where it
  /// stands.
  private func reachesAnyone(
    _ ability: Int
  ) -> Bool {
    battle.canUse(ability)
      && battle.units.contains {
        let turn = Turn(
          action: Action(ability, on: $0.id)
        )
        return (try? battle.forecast(turn))
          != nil
      }
  }

  /// The foes' turn, if one is up, begins:
  /// a step at a time, or played through,
  /// as the settings say.
  func foesGo() {
    guard isFoesTurn else {
      return
    }
    if settings.stepsFoes {
      advance()
    } else {
      skip()
    }
  }
}
