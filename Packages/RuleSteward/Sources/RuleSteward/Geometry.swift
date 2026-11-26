/// A spot in the arena, in whole
/// centimetres from its top left corner.
public struct Point: Sendable, Equatable {
  /// Across, left to right.
  public var x: Int
  /// Down, top to bottom.
  public var y: Int

  /// A spot.
  public init(x: Int, y: Int) {
    self.x = x
    self.y = y
  }

  /// The distance to `other`, squared, so
  /// it stays a whole number.
  func squared(to other: Self) -> Int {
    let across = other.x - x
    let down = other.y - y
    return across * across + down * down
  }

  /// `steps` centimetres of the way to
  /// `goal` (or all of it, if that's
  /// nearer), rounded so it never goes
  /// further than `steps`.
  func toward(
    _ goal: Self,
    by steps: Int
  ) -> Self {
    let length = Geometry.rootUp(
      squared(to: goal)
    )
    guard steps < length else {
      return goal
    }
    return Self(
      x: x + (goal.x - x) * steps / length,
      y: y + (goal.y - y) * steps / length
    )
  }
}

extension Point: CustomStringConvertible {
  /// "(x, y)", for the log.
  public var description: String {
    "(\(x), \(y))"
  }
}

/// How big a unit is. Every unit is a
/// circle, and circles can't overlap.
public enum Size: Sendable {
  /// A mouse knight.
  case small
  /// A wizard.
  case medium
  /// A mech.
  case large
  /// A dragon.
  case huge

  /// The circle's radius, in centimetres.
  public var radius: Int {
    switch self {
    case .small:
      25
    case .medium:
      40
    case .large:
      70
    case .huge:
      120
    }
  }
}

/// Where a battle is fought: an open
/// rectangle, for now.
public struct Arena: Sendable {
  /// Left to right, in centimetres.
  public let width: Int
  /// Top to bottom, in centimetres.
  public let height: Int

  /// An arena.
  public init(width: Int, height: Int) {
    self.width = width
    self.height = height
  }

  /// 12 by 8 metres.
  public static let open = Self(
    width: 1200, height: 800
  )

  /// Whether a circle of `radius` at
  /// `point` is wholly inside.
  func holds(
    _ point: Point,
    radius: Int
  ) -> Bool {
    point.x >= radius
      && point.y >= radius
      && point.x <= width - radius
      && point.y <= height - radius
  }

  /// Where the sides start: the party in a
  /// column near the left edge, the foes
  /// near the right, each spread evenly
  /// from top to bottom.
  func deploy(
    party: Int,
    foes: Int
  ) -> [Point] {
    column(party, at: 150)
      + column(foes, at: width - 150)
  }

  /// `count` spots spread down a column.
  private func column(
    _ count: Int,
    at x: Int
  ) -> [Point] {
    (0..<count).map {
      Point(
        x: x,
        y: height * (2 * $0 + 1)
          / (2 * count)
      )
    }
  }
}

/// Distances in whole numbers: no square
/// roots of non-squares, no floating point.
enum Geometry {
  /// The square root of `value`, rounded
  /// down.
  static func root(_ value: Int) -> Int {
    var low = 0
    var high = value + 1
    // The largest whole number whose
    // square is at most `value`.
    while high - low > 1 {
      let middle = (low + high) / 2
      if middle * middle <= value {
        low = middle
      } else {
        high = middle
      }
    }
    return low
  }

  /// The square root of `value`, rounded
  /// up.
  static func rootUp(_ value: Int) -> Int {
    let low = root(value)
    return low * low < value ? low + 1 : low
  }

  /// Whether two legs, `first` and
  /// `second` long squared, add up to at
  /// most `limit`: √a + √b ≤ m exactly,
  /// squared twice to stay whole.
  static func legs(
    _ first: Int,
    _ second: Int,
    within limit: Int
  ) -> Bool {
    let left = limit * limit - first
      - second
    return left >= 0
      && 4 * first * second <= left * left
  }
}
