import SwiftUI

/// How battles play: whether turns end by
/// themselves, foes' turns step, and
/// counterspells are asked. Kept in
/// `UserDefaults` (`Settings`), for the
/// next fight.
struct SettingsView: View {
  @AppStorage private var endsTurns: Bool
  @AppStorage private var stepsFoes: Bool
  @AppStorage private var counters: Answer

  private typealias Answer = Settings.Answer

  init(defaults: UserDefaults) {
    let start = Settings()
    _endsTurns = AppStorage(
      wrappedValue: start.endsTurns,
      Settings.endsKey,
      store: defaults
    )
    _stepsFoes = AppStorage(
      wrappedValue: start.stepsFoes,
      Settings.stepsKey,
      store: defaults
    )
    _counters = AppStorage(
      wrappedValue: start.counters,
      Settings.countersKey,
      store: defaults
    )
  }

  var body: some View {
    Form {
      turns
      foes
      counterspells
    }
    .navigationTitle("Settings")
  }

  /// Whether turns end by themselves.
  private var turns: some View {
    Section {
      Toggle(
        "End turns by themselves",
        isOn: $endsTurns
      )
    } footer: {
      Text("""
        Once a unit has no skill it can use \
        and no movement left.
        """)
    }
  }

  /// Whether foes' turns step.
  private var foes: some View {
    Section {
      Toggle(
        "Foes' turns a step at a time",
        isOn: $stepsFoes
      )
    } footer: {
      Text("""
        Off, they play straight through to \
        your turn.
        """)
    }
  }

  /// Whether to counter foes' spells.
  private var counterspells: some View {
    Section {
      Picker(
        "Counterspells",
        selection: $counters
      ) {
        Text("Ask").tag(Answer.ask)
        Text("Always").tag(Answer.always)
        Text("Never").tag(Answer.never)
      }
    } footer: {
      Text("""
        When a unit can counter a foe's \
        spell: ask each time, or always or \
        never counter.
        """)
    }
  }
}
