import SwiftUI

/// Planning a move: the arrows to nudge
/// it and buttons to commit or undo it,
/// then how far it goes and what's left
/// (below, so the arrows stay put as it
/// changes), then, with a foe tapped, how
/// to walk toward it.
struct MovePanel: View {
  let fight: Fight

  init(fight: Fight) {
    self.fight = fight
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack(spacing: 16) {
        NudgePad(fight: fight)
        VStack(
          alignment: .leading, spacing: 16
        ) {
          Button("Commit move") {
            fight.commit()
          }
          Button("Undo") {
            fight.undo()
          }
        }
        .buttonStyle(.borderless)
        .disabled(fight.ghost == nil)
      }
      status
        .foregroundStyle(.secondary)
        .testID("move-status")
      if let id = fight.approached {
        approach(fight.battle.units[id])
      }
    }
  }

  /// The foe picked to walk toward (its
  /// name from the rules, so a `data-`
  /// identifier), and buttons to walk up
  /// close or to the edge of reach.
  private func approach(
    _ foe: BattleUnit
  ) -> some View {
    HStack {
      Text(verbatim: foe.unit.name)
        .font(.headline)
        .testID("data-approached")
      Spacer()
      Button("Up close") {
        fight.upClose()
      }
      .testID("up-close")
      Button("In range") {
        fight.inRange()
      }
      .disabled(fight.rangeSpot == nil)
      .testID("in-range")
    }
    .buttonStyle(.bordered)
  }

  /// The planned move and what's left
  /// after, or how to plan one.
  private var status: some View {
    Text(fight.moveStatus)
  }
}
