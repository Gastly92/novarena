import RuleSteward
import SwiftUI

/// Shows one screen (`ScreenID`): where the
/// app starts, and each screen state UI and
/// snapshot tests open directly.
struct ScreenHost: View {
  let screen: ScreenID
  /// Where settings are kept.
  let defaults: UserDefaults

  init(
    screen: ScreenID,
    defaults: UserDefaults
  ) {
    self.screen = screen
    self.defaults = defaults
  }

  var body: some View {
    NavigationStack {
      switch screen {
      case .home:
        HomeView(defaults: defaults)
      case .settings:
        SettingsView(defaults: defaults)
      case .battleInfo:
        BattleInfoView(battle: middle)
      case .battleFallen:
        BattleView(
          fight: Fight(stage: .end),
          showsFallen: true
        )
      case .picker:
        PickerView(defaults: defaults)
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
