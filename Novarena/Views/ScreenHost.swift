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
    switch screen {
    case .home:
      HomeView()
    }
  }
}
