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
  /// A unit's layer takes damage.
  case layer(
    String, String, took: Int, left: Int
  )
  /// A unit has no layers left.
  case exposed(String)
  /// A unit is knocked out.
  case out(String)
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
    case let .layer(name, layer, took, left):
      """
        \(name)'s \(layer) -\(took) \
      (\(left))
      """
    case let .exposed(name):
      "  \(name) is exposed"
    case let .out(name):
      "  \(name) is knocked out"
    case .wins(.party):
      "The party wins"
    case .wins(.foes):
      "The foes win"
    }
  }
}
