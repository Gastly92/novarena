/// An ability used on a target.
public struct Action: Sendable, Equatable {
  /// Its index in the unit's list.
  public let ability: Int
  /// The target's id.
  public let target: Int

  /// `ability` on `target`.
  public init(
    _ ability: Int,
    on target: Int
  ) {
    self.ability = ability
    self.target = target
  }
}

/// What a unit does on its turn: moves
/// and takes its main action, in either
/// order, the move split around it if it
/// likes, with bonus actions after the
/// main one. Each part is optional; a turn
/// with none of them waits.
public struct Turn: Sendable, Equatable {
  /// Where it moves first, in a straight
  /// line.
  public var before: Point?
  /// What it does there.
  public var action: Action?
  /// Bonus actions it takes next, in order.
  public var bonuses: [Action]
  /// Where it moves after, in a straight
  /// line, with what's left of its Move.
  public var after: Point?

  /// A turn.
  public init(
    before: Point? = nil,
    action: Action? = nil,
    bonuses: [Action] = [],
    after: Point? = nil
  ) {
    self.before = before
    self.action = action
    self.bonuses = bonuses
    self.after = after
  }
}
