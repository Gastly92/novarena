import SwiftUI

/// Four arrows that nudge the planned
/// move: a tap moves it 1 cm, holding
/// repeats, faster and faster
/// (`Fight.press(_:)`). The pad never
/// changes; at an edge, a nudge slides
/// along it, and orbit arrows on the arena
/// go round it.
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
        gap
        arrow(.north)
        gap
      }
      GridRow {
        arrow(.west)
        gap
        arrow(.east)
      }
      GridRow {
        gap
        arrow(.south)
        gap
      }
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
    Image(systemName: way.symbol)
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

extension Nudge {
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
