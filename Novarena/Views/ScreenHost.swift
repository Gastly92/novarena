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
      case .battle:
        battle(.start)
      case .battleAiming:
        battle(.aiming)
      case .battlePlanned:
        battle(.planned)
      case .battleMiddle:
        battle(.middle)
      case .battleEnd:
        battle(.end)
      }
    }
  }

  /// The sample battle at `stage`.
  private func battle(
    _ stage: Fight.Stage
  ) -> some View {
    BattleView(fight: Fight(stage: stage))
  }
}
