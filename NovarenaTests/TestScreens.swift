@testable import Novarena
import SwiftUI

/// Screens for snapshot and App Store tests:
/// each as `ScreenHost` shows it.
@MainActor
enum TestScreens {
  /// `screen`, with nothing animating.
  static func page(
    _ screen: ScreenID
  ) -> some View {
    let suite = "snapshot.\(screen.rawValue)"
    return ScreenHost(
      screen: screen,
      defaults: AppLaunch.clean(suite)
    )
    .transaction { $0.animation = nil }
  }
}
