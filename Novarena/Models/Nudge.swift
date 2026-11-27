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
  /// Round the unit the planned spot
  /// touches, clockwise on screen.
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
}

/// How a nudge would go: straight on,
/// bending toward one side (sliding along
/// the edge of the range or round a unit),
/// or nowhere.
enum Bend: Equatable {
  case straight
  case toward(Nudge)
  case stuck

  /// Bends a nudge `way` that moved
  /// `across` centimetres sideways (right
  /// or down positive) would go.
  init(_ way: Nudge, across: Int) {
    guard across != 0 else {
      self = .straight
      return
    }
    let upright = way.offset.x == 0
    switch (upright, across < 0) {
    case (true, true):
      self = .toward(.west)
    case (true, false):
      self = .toward(.east)
    case (false, true):
      self = .toward(.north)
    case (false, false):
      self = .toward(.south)
    }
  }

  /// The icon for an arrow nudging `way`:
  /// a chevron, or a turning arrow when it
  /// bends.
  func symbol(_ way: Nudge) -> String {
    let name = way.word
    guard !way.circles else {
      return "arrow.\(name)"
    }
    guard case let .toward(side) = self
    else { return "chevron.\(name)" }
    return "arrow.turn.\(name).\(side.word)"
  }
}

extension Nudge {
  /// Its direction's name, as SF Symbols
  /// spell it.
  var word: String {
    switch self {
    case .north:
      "up"
    case .west:
      "left"
    case .east:
      "right"
    case .south:
      "down"
    case .clockwise:
      "clockwise"
    case .counterclockwise:
      "counterclockwise"
    }
  }
}
