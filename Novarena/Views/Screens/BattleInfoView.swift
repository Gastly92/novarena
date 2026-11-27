import RuleSteward
import SwiftUI

/// About the battle as a whole: the round
/// and how hard hits land. Shown as a
/// sheet from the battle.
struct BattleInfoView: View {
  let battle: Battle
  @Environment(\.dismiss)
  private var dismiss

  init(battle: Battle) {
    self.battle = battle
  }

  var body: some View {
    List {
      Section {
        LabeledContent(
          "Round",
          value: battle.round,
          format: .number
        )
        LabeledContent(
          "Intensity",
          value: battle.intensity,
          format: .percent
        )
      } footer: {
        Text("""
          Every hit does this share of \
          its damage. It starts low and \
          rises a little each round, so \
          fights always end.
          """)
      }
    }
    .navigationTitle("Battle info")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      Button("Done") {
        dismiss()
      }
    }
  }
}
