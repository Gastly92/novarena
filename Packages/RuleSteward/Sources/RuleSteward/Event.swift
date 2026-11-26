/// Something that happened in a battle, in
/// order. Its description is a line of the
/// battle log (English, for tests and
/// development; the game's screens will
/// show their own text).
public enum Event: Sendable, Equatable {
  /// A unit's turn begins at a tick.
  case turn(String, tick: Int)
  /// A unit moves to a spot.
  case moves(String, Point)
  /// A unit uses an ability on a target.
  case uses(String, String, target: String)
  /// A bodyguard takes a hit for an ally.
  case guards(String, ally: String)
  /// A unit is immune to the hit.
  case immune(String)
  /// A shield takes damage.
  case shield(String, took: Int, left: Int)
  /// Health takes damage.
  case damage(String, took: Int, left: Int)
  /// A unit goes down.
  case down(String)
  /// The battle is over.
  case wins(Side)
}

extension Event: CustomStringConvertible {
  /// The log line.
  public var description: String {
    switch self {
    case let .turn(name, tick):
      "[\(tick)] \(name)"
    case let .moves(name, spot):
      "  \(name) moves to \(spot)"
    case let .uses(name, ability, target):
      "  \(name): \(ability) → \(target)"
    case let .guards(name, ally):
      "  \(name) guards \(ally)"
    case let .immune(name):
      "  \(name) is immune"
    case let .shield(name, took, left):
      "  \(name)'s shield -\(took) (\(left))"
    case let .damage(name, took, left):
      "  \(name) -\(took) (\(left))"
    case let .down(name):
      "  \(name) is down"
    case .wins(.party):
      "The party wins"
    case .wins(.foes):
      "The foes win"
    }
  }
}
