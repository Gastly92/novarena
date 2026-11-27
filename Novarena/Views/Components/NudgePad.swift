import SwiftUI

/// Four arrows that nudge the planned
/// move: a tap moves it 1 cm, holding
/// repeats, faster and faster
/// (`Fight.press(_:)`). An arrow that
/// would slide along an edge turns, and
/// one that can't move dims. Touching a
/// unit, arrows in the corners circle
/// round it.
struct NudgePad: View {
  let fight: Fight
  @ScaledMetric private var size = 40.0

  init(fight: Fight) {
    self.fight = fight
  }

  var body: some View {
    Grid(
      horizontalSpacing: 4,
      verticalSpacing: 4
    ) {
      GridRow {
        corner(-1, -1)
        arrow(.north)
        corner(1, -1)
      }
      GridRow {
        arrow(.west)
        gap
        arrow(.east)
      }
      GridRow {
        corner(-1, 1)
        arrow(.south)
        corner(1, 1)
      }
    }
  }

  /// A corner: an arrow circling round
  /// the unit the planned spot touches,
  /// if one heads that way, else empty.
  @ViewBuilder
  private func corner(
    _ across: Int,
    _ down: Int
  ) -> some View {
    if let way = fight.circling(
      at: (across, down)
    ) {
      arrow(way)
    } else {
      gap
    }
  }

  /// An empty cell.
  private var gap: some View {
    Color.clear
      .frame(width: size, height: size)
  }

  /// An arrow that nudges `way` while
  /// pressed.
  private func arrow(
    _ way: Nudge
  ) -> some View {
    let bend = fight.bend(way)
    let icon = bend.symbol(way)
    return Image(systemName: icon)
      .opacity(bend == .stuck ? 0.3 : 1)
      .frame(width: size, height: size)
      .background(
        RoundedRectangle(cornerRadius: 8)
          .fill(Color(.tertiarySystemFill))
      )
      .contentShape(Rectangle())
      .gesture(
        DragGesture(minimumDistance: 0)
          .onChanged { _ in
            fight.press(way)
          }
          .onEnded { _ in
            fight.press(nil)
          }
      )
      .accessibilityElement()
      .accessibilityLabel(way.label)
      .accessibilityAddTraits(.isButton)
      .testID("nudge-\(way)")
  }
}

private extension Nudge {
  /// What VoiceOver calls it.
  var label: LocalizedStringKey {
    switch self {
    case .north:
      "Nudge up"
    case .west:
      "Nudge left"
    case .east:
      "Nudge right"
    case .south:
      "Nudge down"
    case .clockwise:
      "Circle clockwise"
    case .counterclockwise:
      "Circle counterclockwise"
    }
  }
}
