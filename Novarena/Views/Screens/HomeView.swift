import SwiftUI

/// The first screen: the game's name, while
/// the arena is being built.
struct HomeView: View {
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
        BattleView(fight: Fight())
      }
      .buttonStyle(.borderedProminent)
      .padding(.top)
    }
    .padding()
    .fullWidth()
    .testID("home")
  }
}
