/// What a hit would do to one of a unit's
/// layers.
public struct Loss: Sendable, Equatable {
  /// Which layer, outermost 0.
  public let layer: Int
  /// The points it would lose.
  public let lost: Int
  /// The points it would have left.
  public let left: Int
}

/// What a heal would do to one of a
/// unit's layers.
public struct Gain: Sendable, Equatable {
  /// Which layer, outermost 0.
  public let layer: Int
  /// The points it would gain.
  public let gained: Int
  /// The points it would have after.
  public let now: Int
}

/// What a hit, or a heal, would do.
public struct Strike: Sendable, Equatable {
  /// Who takes it: the target, or the
  /// bodyguard who steps in for it.
  public let hit: Int
  /// What its layers would lose,
  /// outermost first.
  public let losses: [Loss]
  /// What a heal would mend.
  public let gains: [Gain]
  /// Whether it would be left with no
  /// layers.
  public let exposes: Bool
  /// Whether it would be knocked out.
  public let knocksOut: Bool
  /// Whether it would do nothing (an
  /// immunity).
  public let immune: Bool
  /// Whether it would be dodged.
  public let dodged: Bool
  /// Whether a foe would counter it.
  public let countered: Bool
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
  /// Where the commander's turn falls in
  /// `queue`, with one.
  public let commanderSlot: Int?
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
      winner: after.winner,
      commanderSlot: after.commanderSlot(
        in: after.queue
      )
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
    let (losses, gains) = Self.changes(
      from: before, to: now
    )
    let added = after.log
      .dropFirst(log.count)
    let immune = added.contains(
      .immune(now.unit.name)
    )
    return Strike(
      hit: hit,
      losses: losses,
      gains: gains,
      exposes: now.isExposed
        && !before.isExposed,
      knocksOut: !now.isUp,
      immune: immune,
      dodged: added.contains(
        .dodges(now.unit.name)
      ),
      countered: added.contains(
        where: \.counters
      )
    )
  }

  /// What changed in a unit's layers from
  /// `before` to `now`: losses, then
  /// gains.
  private static func changes(
    from before: BattleUnit,
    to now: BattleUnit
  ) -> ([Loss], [Gain]) {
    let changed = before.layers.indices
      .filter {
        before.layers[$0] != now.layers[$0]
      }
    let losses = changed
      .filter {
        before.layers[$0] > now.layers[$0]
      }
      .map {
        Loss(
          layer: $0,
          lost: before.layers[$0]
            - now.layers[$0],
          left: now.layers[$0]
        )
      }
    let gains = changed
      .filter {
        before.layers[$0] < now.layers[$0]
      }
      .map {
        Gain(
          layer: $0,
          gained: now.layers[$0]
            - before.layers[$0],
          now: now.layers[$0]
        )
      }
    return (losses, gains)
  }
}

private extension Event {
  /// Whether it's a counterspell.
  var counters: Bool {
    if case .counters = self {
      return true
    }
    return false
  }
}
