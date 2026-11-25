import SwiftUI
import UIKit

@main
struct NovarenaApp: App {
  private let launch: AppLaunch

  init() {
    let info = ProcessInfo.processInfo
    launch = AppLaunch(
      arguments: info.arguments
    )
    if launch.isUITesting {
      // No UIKit animations (screen pushes,
      // sheets, menus), so UI tests never
      // act on a screen still sliding in.
      UIView.setAnimationsEnabled(false)
    }
  }

  var body: some Scene {
    WindowGroup {
      ScreenHost(screen: launch.screen)
    }
  }
}
