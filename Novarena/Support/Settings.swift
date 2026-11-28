import Foundation

/// How the player likes battles to play,
/// kept in `UserDefaults` (changed in
/// `SettingsView`) and read as a fight
/// starts.
struct Settings: Equatable {
  /// Whether to counter a foe's spell a
  /// party unit can counter.
  enum Answer: String {
    /// Ask first, each time.
    case ask
    /// Always counter.
    case always
    /// Never counter.
    case never
  }

  /// Where each is kept.
  static let endsKey = "endsTurns"
  static let stepsKey = "stepsFoes"
  static let countersKey = "counters"

  /// Whether a turn ends by itself once
  /// nothing's left to do.
  var endsTurns = true
  /// Whether foes' turns play a step at a
  /// time (else straight through).
  var stepsFoes = true
  /// Whether to counter foes' spells.
  var counters = Answer.ask

  /// The defaults: turns end by themselves,
  /// foes step, counters are asked.
  init() {
    // Each as declared above.
  }

  /// The settings kept in `defaults`, each
  /// its default if never set.
  init(_ defaults: UserDefaults) {
    let start = Self()
    endsTurns = defaults.object(
      forKey: Self.endsKey
    ) as? Bool ?? start.endsTurns
    stepsFoes = defaults.object(
      forKey: Self.stepsKey
    ) as? Bool ?? start.stepsFoes
    let saved = defaults.string(
      forKey: Self.countersKey
    )
    counters = saved
      .flatMap(Answer.init(rawValue:))
      ?? start.counters
  }

  /// As the screens for tests play: turns
  /// end by hand, foes step, counters are
  /// asked.
  static var manual: Self {
    var settings = Self()
    settings.endsTurns = false
    return settings
  }
}
