import RuleSteward
import SwiftUI

/// One unit in a battle: its name and kind,
/// health, shield and resource, and whether
/// it's on turn or down. Text from the
/// rules (names, kinds) isn't translated
/// yet, so it carries a `data-` identifier.
struct UnitRow: View {
  let unit: BattleUnit
  let onTurn: Bool

  init(unit: BattleUnit, onTurn: Bool) {
    self.unit = unit
    self.onTurn = onTurn
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      HStack {
        if onTurn {
          Image(systemName: "bolt.fill")
            .foregroundStyle(.tint)
            .accessibilityHidden(true)
        }
        Text(verbatim: unit.unit.name)
          .font(.headline)
          .testID("data-name-\(unit.id)")
        Text(verbatim: unit.unit.kind)
          .foregroundStyle(.secondary)
          .testID("data-kind-\(unit.id)")
      }
      if unit.isUp {
        gauges
      } else {
        Text("Down")
          .foregroundStyle(.secondary)
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
          Shield \(unit.shield) of \
          \(shield.points)
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
