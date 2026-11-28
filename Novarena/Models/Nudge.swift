/// A direction the move pad nudges the
/// planned spot, and how a held arrow
/// speeds up.
enum Nudge: CaseIterable {
  /// Up the screen.
  case north
  /// Left.
  case west
  /// Right.
  case east
  /// Down the screen.
  case south
  /// Round what the planned spot rests on
  /// (a unit, or the edge of the range),
  /// clockwise on screen.
  case clockwise
  /// The other way round.
  case counterclockwise

  /// One centimetre this way; none for
  /// circling.
  var offset: (x: Int, y: Int) {
    switch self {
    case .north:
      (0, -1)
    case .west:
      (-1, 0)
    case .east:
      (1, 0)
    case .south:
      (0, 1)
    case .clockwise, .counterclockwise:
      (0, 0)
    }
  }

  /// Whether it circles round a unit.
  var circles: Bool {
    self == .clockwise
      || self == .counterclockwise
  }

  /// How far the `tick`th nudge of a held
  /// arrow goes: 1 cm at first, growing
  /// smoothly to 20 cm a tick.
  static func step(_ tick: Int) -> Int {
    min(1 + tick * tick / 40, 20)
  }

  /// The wait after the `tick`th nudge: a
  /// moment after the first, so a tap
  /// moves 1 cm, then quick repeats.
  static func delay(
    after tick: Int
  ) -> Duration {
    .milliseconds(tick == 0 ? 400 : 30)
  }

  /// Its arrow's icon.
  var symbol: String {
    switch self {
    case .north:
      "chevron.up"
    case .west:
      "chevron.left"
    case .east:
      "chevron.right"
    case .south:
      "chevron.down"
    case .clockwise:
      "arrow.clockwise"
    case .counterclockwise:
      "arrow.counterclockwise"
    }
  }
}
