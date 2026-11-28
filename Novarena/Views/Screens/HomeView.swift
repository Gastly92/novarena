import SwiftUI

/// The first screen: the game's name, while
/// the arena is being built; a fight, the
/// picker and the settings.
struct HomeView: View {
  /// Where settings are kept.
  let defaults: UserDefaults

  init(defaults: UserDefaults) {
    self.defaults = defaults
  }

  var body: some View {
    VStack(spacing: 16) {
      Image(systemName: "bolt.fill")
        .font(.largeTitle)
        .foregroundStyle(.tint)
        .accessibilityHidden(true)
      Text("Novarena")
        .font(.largeTitle.bold())
      Text("""
        Heroes from every era are on \
        their way.
        """)
        .font(.title3)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
        .wrapsText()
      NavigationLink("Fight") {
        BattleView(fight: Fight(
          party: [.gerald, .oswin],
          foes: [.ashka, .kestrel],
          settings: Settings(defaults)
        ))
      }
      .buttonStyle(.borderedProminent)
      .padding(.top)
      NavigationLink("Choose who fights") {
        PickerView(defaults: defaults)
      }
      NavigationLink("Settings") {
        SettingsView(defaults: defaults)
      }
    }
    .padding()
    .fullWidth()
    .testID("home")
  }
}
