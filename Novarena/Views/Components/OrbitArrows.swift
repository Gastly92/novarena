import RuleSteward
import SwiftUI

/// On the arena: the circle the planned
/// spot rests on (`Fight.rim`), faintly,
/// and an arrow each side of the spot
/// that steps it round while held. The
/// arrows stay put while one is held, so
/// the finger stays on it; a touch that
/// lifts or is cancelled lets go.
struct OrbitArrows: View {
  let fight: Fight
  let rim: Rim
  let map: ArenaMap
  @ScaledMetric private var knob = 30.0
  /// The arrow held, if any.
  @GestureState private var held: Nudge?
  /// Where the arrows sat when one was
  /// pressed.
  @State private var pinned: Rim?

  init(
    fight: Fight,
    rim: Rim,
    map: ArenaMap
  ) {
    self.fight = fight
    self.rim = rim
    self.map = map
  }

  var body: some View {
    let arrows = pinned ?? rim
    ZStack(alignment: .topLeading) {
      path
      ForEach(
        [Nudge.counterclockwise, .clockwise],
        id: \.self
      ) {
        arrow($0, at: arrows.arrow($0))
      }
    }
    .onChange(of: held) {
      pinned = $1 == nil ? nil : fight.rim
      fight.press($1)
    }
  }

  /// The circle, dashed and faint.
  private var path: some View {
    let across = map.points(2 * rim.radius)
    return Circle()
      .stroke(
        .secondary,
        style: StrokeStyle(
          lineWidth: 1, dash: [2, 4]
        )
      )
      .frame(width: across, height: across)
      .position(map.location(of: rim.center))
  }

  /// The arrow going `way`, at `spot`.
  private func arrow(
    _ way: Nudge,
    at spot: Point
  ) -> some View {
    Image(systemName: way.symbol)
      .font(.caption.bold())
      .frame(width: knob, height: knob)
      .background(
        Circle().fill(.regularMaterial)
      )
      .contentShape(Circle())
      .gesture(
        DragGesture(minimumDistance: 0)
          .updating($held) { _, held, _ in
            held = way
          }
      )
      .accessibilityElement()
      .accessibilityLabel(way.label)
      .accessibilityAddTraits(.isButton)
      .testID("orbit-\(way)")
      .position(map.location(of: spot))
  }
}
