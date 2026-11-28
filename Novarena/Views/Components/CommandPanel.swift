import RuleSteward
import SwiftUI

/// The party's commander's turn: an order
/// for one ally (restore a quarter of its
/// outer layer, or ward it), or a pass.
/// Names come from the rules, so they
/// carry a `data-` identifier.
struct CommandPanel: View {
  let fight: Fight

  init(fight: Fight) {
    self.fight = fight
  }

  var body: some View {
    Group {
      HStack {
        Text("Your commander's turn")
          .font(.headline)
        Spacer()
        Button("Pass") {
          fight.command(.pass)
        }
        .buttonStyle(.bordered)
      }
      ForEach(fight.standing(.party)) {
        orders(for: $0)
      }
      Text("""
        Restore gives back a quarter of an \
        ally's outer layer. A ward soaks \
        its next 3 hits, once a battle \
        each.
        """)
        .font(.caption)
        .foregroundStyle(.secondary)
    }
  }

  /// An ally's name, then its orders,
  /// each off when it can't be given.
  private func orders(
    for unit: BattleUnit
  ) -> some View {
    HStack {
      Text(verbatim: unit.unit.name)
        .testID("data-commanded-\(unit.id)")
      Spacer()
      order("Restore", .restore(unit.id))
        .testID("restore-\(unit.id)")
      order("Ward", .ward(unit.id))
        .testID("ward-\(unit.id)")
    }
    .buttonStyle(.bordered)
  }

  /// A button giving `order`.
  private func order(
    _ title: LocalizedStringKey,
    _ order: Order
  ) -> some View {
    Button(title) {
      fight.command(order)
    }
    .disabled(
      !fight.battle.canCommand(order)
    )
  }
}
