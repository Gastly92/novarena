import CoreGraphics
import RuleSteward

/// An arena drawn on screen: where its
/// spots (whole centimetres) fall in
/// points, and back. Only drawing uses
/// fractions; the rules never see them.
struct ArenaMap {
  /// Points per centimetre.
  let scale: Double

  /// `arena` drawn `width` points wide.
  init(_ arena: Arena, width: Double) {
    scale = width / Double(arena.width)
  }

  /// How wide the arena is for its height,
  /// to draw it in proportion.
  static func ratio(
    _ arena: Arena
  ) -> Double {
    Double(arena.width)
      / Double(arena.height)
  }

  /// Where `point` is drawn.
  func location(of point: Point) -> CGPoint {
    CGPoint(
      x: Double(point.x) * scale,
      y: Double(point.y) * scale
    )
  }

  /// The spot under a tap at `location`,
  /// to the nearest centimetre.
  func spot(at location: CGPoint) -> Point {
    Point(
      x: Int((location.x / scale).rounded()),
      y: Int((location.y / scale).rounded())
    )
  }

  /// `centimetres` in points.
  func points(_ centimetres: Int) -> Double {
    Double(centimetres) * scale
  }
}
