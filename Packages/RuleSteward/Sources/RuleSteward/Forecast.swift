/// What a hit would do.
public struct Strike: Sendable, Equatable {
  /// Who takes it: the target, or the
  /// bodyguard who steps in for it.
  public let hit: Int
  /// What the shield would lose.
  public let shieldLost: Int
  /// The shield left after.
  public let shieldLeft: Int
  /// What health would lose.
  public let healthLost: Int
  /// The health left after.
  public let healthLeft: Int
  /// Whether it does nothing (an
  /// immunity).
  public let immune: Bool
}

/// What a turn would do, worked out on a
/// copy of the battle before it's taken.
/// Nothing is random, so this is exactly
/// what happens if it is.
public struct Forecast: Sendable, Equatable {
  /// What its action would do; none if it
  /// only moves or waits.
  public let strike: Strike?
  /// The turn order after: where the actor
  /// lands. Empty if the battle would end.
  public let queue: [Int]
  /// The side that would win, if this ends
  /// it.
  public let winner: Side?
}

public extension Battle {
  /// What using `ability` on `target`
  /// from where the unit stands would do.
  func forecast(
    _ ability: Int,
    on target: Int
  ) throws(Mistake) -> Forecast {
    try forecast(Turn(
      action: Action(ability, on: target)
    ))
  }

  /// What `act(turn)` would do, without
  /// doing it.
  func forecast(
    _ turn: Turn
  ) throws(Mistake) -> Forecast {
    var after = self
    try after.act(turn)
    return Forecast(
      strike: turn.action.map {
        strike($0.target, after: after)
      },
      queue: after.queue,
      winner: after.winner
    )
  }

  /// What a hit aimed at `target` did, as
  /// `after` shows.
  private func strike(
    _ target: Int,
    after: Self
  ) -> Strike {
    let stepped = after.units.first {
      $0.guarded != units[$0.id].guarded
    }
    let hit = stepped?.id ?? target
    let before = units[hit]
    let now = after.units[hit]
    let immune = after.log
      .dropFirst(log.count)
      .contains(.immune(now.unit.name))
    return Strike(
      hit: hit,
      shieldLost: before.shield - now.shield,
      shieldLeft: now.shield,
      healthLost: before.health - now.health,
      healthLeft: now.health,
      immune: immune
    )
  }
}
