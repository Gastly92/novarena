import RuleSteward
import SwiftUI

/// Shows one screen (`ScreenID`): where the
/// app starts, and each screen state UI and
/// snapshot tests open directly.
struct ScreenHost: View {
  let screen: ScreenID

  init(screen: ScreenID) {
    self.screen = screen
  }

  var body: some View {
    NavigationStack {
      switch screen {
      case .home:
        HomeView()
      case .battleInfo:
        BattleInfoView(battle: middle)
      case .battleFallen:
        BattleView(
          fight: Fight(stage: .end),
          showsFallen: true
        )
      case .picker:
        PickerView()
      default:
        if let stage = Fight.Stage(
          screen: screen
        ) {
          BattleView(
            fight: Fight(stage: stage)
          )
        }
      }
    }
  }

  /// The sample battle six turns in.
  private var middle: Battle {
    Fight(stage: .middle).battle
  }
}
