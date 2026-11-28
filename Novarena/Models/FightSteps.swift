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
    !battle.commanderUp
      && actor?.side == .foes
  }

  /// The party's unit who could counter
  /// the foe's next step, a spell, and
  /// what it is: the party is asked
  /// before it's cast. None otherwise.
  var question: (
    reactor: BattleUnit, spell: String
  )? {
    guard isFoesTurn, let actor,
      case let .use(action) = steps.first,
      let id = battle.counter(
        action.ability, on: action.target
      ),
      battle.units[id].side == .party
    else { return nil }
    let spell = actor.unit
      .abilities[action.ability].name
    return (battle.units[id], spell)
  }

  /// Whether it's the party's commander's
  /// turn.
  var isCommanding: Bool {
    battle.commanderUp
  }

  /// Plays the next step of the foes'
  /// turns, planning the next foe's turn
  /// once one ends; what it logged goes in
  /// `shown`. A turn's end, which shows
  /// nothing, goes with the step after
  /// (the next turn's start), so each step
  /// shows something. Nothing on the
  /// party's turn. With `reacting` off,
  /// the party lets a spell it could
  /// counter through.
  func advance(reacting: Bool = true) {
    if steps.first == .end {
      take(steps.removeFirst())
    }
    if steps.isEmpty {
      steps = plan()
    }
    guard !steps.isEmpty else {
      return
    }
    let mark = battle.log.count
    take(
      steps.removeFirst(), reacting: reacting
    )
    shown = battle.log[mark...]
      .map(Self.says)
  }

  /// What `event` says on screen: a turn's
  /// start in words, the rest as logged.
  static func says(
    _ event: Event
  ) -> String {
    if case let .turn(name, _) = event {
      return String(
        localized: "\(name)'s turn begins"
      )
    }
    return event.description
      .trimmingCharacters(in: .whitespaces)
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
