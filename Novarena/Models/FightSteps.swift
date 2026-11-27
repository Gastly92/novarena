import Foundation
import RuleSteward

/// A step of a turn, for playing foes'
/// turns one at a time, so the screen can
/// show (and later animate) each: the
/// turn starting (passives take hold), a
/// move, an action, the end.
enum Step: Equatable {
  case begin
  case move(Point)
  case use(Action)
  case end
}

/// Playing the foes' turns a step at a
/// time.
extension Fight {
  /// Whether it's a foe's turn, to be
  /// played a step at a time.
  var isFoesTurn: Bool {
    actor?.side == .foes
  }

  /// Plays the next step of the foes'
  /// turns, planning the next foe's turn
  /// once one ends; what it logged goes in
  /// `shown`. Nothing on the party's turn.
  func advance() {
    if steps.isEmpty {
      steps = plan()
    }
    guard !steps.isEmpty else {
      return
    }
    let mark = battle.log.count
    take(steps.removeFirst())
    shown = battle.log[mark...].map {
      $0.description.trimmingCharacters(
        in: .whitespaces
      )
    }
  }

  /// Plays the foes' turns through, to the
  /// party's turn (or the end).
  func skip() {
    while isFoesTurn {
      advance()
    }
  }

  /// The foe on turn's plain choice, as
  /// steps; none on the party's turn.
  private func plan() -> [Step] {
    guard isFoesTurn,
      let turn = battle.plainChoice
    else { return [] }
    var steps = [Step.begin]
    steps += [turn.before].compactMap(\.self)
      .map(Step.move)
    steps += [turn.action].compactMap(\.self)
      .map(Step.use)
    steps += turn.bonuses.map(Step.use)
    steps += [turn.after].compactMap(\.self)
      .map(Step.move)
    return steps + [.end]
  }
}
