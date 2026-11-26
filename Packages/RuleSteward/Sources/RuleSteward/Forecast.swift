/// What an action would do, worked out on a
/// copy of the battle before it's taken.
/// Nothing is random, so this is exactly
/// what happens if it is.
public struct Forecast: Sendable, Equatable {
  /// Who takes the hit: the target, or the
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
  /// Whether the hit does nothing (an
  /// immunity).
  public let immune: Bool
  /// The turn order after: where the actor
  /// lands. Empty if the battle would end.
  public let queue: [Int]
  /// The side that would win, if this ends
  /// it.
  public let winner: Side?
}

public extension Battle {
  /// What `act(ability, on: target)` would
  /// do, without doing it.
  func forecast(
    _ ability: Int,
    on target: Int
  ) throws(Mistake) -> Forecast {
    var after = self
    try after.act(ability, on: target)
    let stepped = after.units.first {
      $0.guarded != units[$0.id].guarded
    }
    let hit = stepped?.id ?? target
    let before = units[hit]
    let now = after.units[hit]
    let immune = after.log
      .dropFirst(log.count)
      .contains(.immune(now.unit.name))
    return Forecast(
      hit: hit,
      shieldLost: before.shield - now.shield,
      shieldLeft: now.shield,
      healthLost: before.health - now.health,
      healthLeft: now.health,
      immune: immune,
      queue: after.queue,
      winner: after.winner
    )
  }
}
