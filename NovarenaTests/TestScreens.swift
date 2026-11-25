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
    ScreenHost(screen: screen)
      .transaction { $0.animation = nil }
  }
}
