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

  /// One centimetre this way.
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
    }
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
}
