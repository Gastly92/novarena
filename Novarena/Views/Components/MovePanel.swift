import SwiftUI

/// Planning a move: the arrows to nudge
/// it and buttons to commit or undo it,
/// then how far it goes and what's left
/// (below, so the arrows stay put as it
/// changes).
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
    }
  }

  /// The planned move and what's left
  /// after, or how to plan one.
  private var status: some View {
    Text(fight.moveStatus)
  }
}
