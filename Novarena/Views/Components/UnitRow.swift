import RuleSteward
import SwiftUI

/// One unit in a battle: its name and kind,
/// health, shield and resource, and what
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

  /// Health, then shield and resource if
  /// it has them.
  private var gauges: some View {
    let full = unit.unit.stats.health
    return VStack(alignment: .leading) {
      ProgressView(
        value: Double(unit.health),
        total: Double(full)
      )
      Text("""
        Health \(unit.health) of \
        \(full)
        """)
        .font(.caption)
      if let shield = unit.unit.shield {
        Text("""
          \(shield.name) \(unit.shield) \
          of \(shield.points)
          """)
          .font(.caption)
      }
      if let pool = unit.unit.resource {
        Text("\(pool.name) \(unit.pool)")
          .font(.caption)
      }
    }
  }
}
