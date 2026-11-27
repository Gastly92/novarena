import RuleSteward
import SwiftUI

/// One unit in a battle: its name and kind,
/// its layers and pools (movement aside),
/// and what
/// the picked ability would do to it. Text
/// from the rules (names, kinds) isn't
/// translated yet, so it carries a `data-`
/// identifier.
struct UnitRow: View {
  let unit: BattleUnit
  /// What the picked ability would do, a
  /// line each.
  let preview: [String]

  init(
    unit: BattleUnit,
    preview: [String] = []
  ) {
    self.unit = unit
    self.preview = preview
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      HStack {
        Text(verbatim: unit.unit.name)
          .font(.headline)
          .testID("data-name-\(unit.id)")
        Text(verbatim: unit.unit.kind)
          .foregroundStyle(.secondary)
          .testID("data-kind-\(unit.id)")
      }
      gauges
      ForEach(preview, id: \.self) {
        Text($0)
          .font(.caption.bold())
          .foregroundStyle(.tint)
      }
    }
    .padding(.vertical, 2)
  }

  /// Each layer, outermost first, with
  /// what's left of it; whether it's
  /// exposed or knocked out; its resource,
  /// if it has one.
  private var gauges: some View {
    VStack(alignment: .leading, spacing: 2) {
      ForEach(
        Array(unit.unit.layers.enumerated()),
        id: \.offset
      ) {
        gauge(
          $0.element,
          left: unit.layers[$0.offset]
        )
      }
      if !unit.isUp {
        Text("Knocked out")
          .font(.caption.bold())
      } else if unit.isExposed {
        Text("Exposed")
          .font(.caption.bold())
      }
      ForEach(
        Array(unit.unit.pools.enumerated())
          .filter {
            $0.element.kind != .movement
          },
        id: \.offset
      ) {
        Text("""
          \($0.element.kind.name) \
          \(unit.pools[$0.offset]) of \
          \($0.element.maximum)
          """)
          .font(.caption)
      }
    }
  }

  /// A layer's name, points and material
  /// (from the rules, so a `data-`
  /// identifier), over a bar.
  private func gauge(
    _ layer: Layer,
    left: Int
  ) -> some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack(spacing: 4) {
        Text("""
          \(layer.name) \(left) of \
          \(layer.points)
          """)
        Text(verbatim: layer.material.name)
          .foregroundStyle(.secondary)
          .testID("data-material")
      }
      .font(.caption)
      ProgressView(
        value: Double(left),
        total: Double(layer.points)
      )
    }
  }
}
