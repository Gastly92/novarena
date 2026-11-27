import SwiftUI

/// Planning a move: how far it goes and
/// what's left, the arrows to nudge it,
/// and buttons to commit or undo it.
struct MovePanel: View {
  let fight: Fight

  init(fight: Fight) {
    self.fight = fight
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      status
        .foregroundStyle(.secondary)
        .testID("move-status")
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
    }
  }

  /// The planned move and what's left
  /// after, or how to plan one.
  @ViewBuilder
  private var status: some View {
    let left = fight.moveLeft
    if let planned = fight.planned {
      Text("""
        Moves \(planned) cm, then \
        \(left - planned) cm left
        """)
    } else {
      Text("""
        \(left) cm of Move left. Drag in \
        the arena, or use the arrows.
        """)
    }
  }
}
