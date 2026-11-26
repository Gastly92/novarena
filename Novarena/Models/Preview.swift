import RuleSteward

extension Forecast {
  /// What it says, a line each, for the row
  /// of `target` (an id) in `battle`.
  func lines(
    for target: Int,
    in battle: Battle
  ) -> [String] {
    guard !immune else {
      return [String(localized: "Immune")]
    }
    var lines: [String] = []
    if hit != target {
      let name = battle.units[hit].unit.name
      lines.append(String(
        localized: "\(name) takes it instead"
      ))
    }
    if shieldLost > 0 {
      lines.append(String(localized: """
        Shield −\(shieldLost), \
        \(shieldLeft) left
        """))
    }
    if healthLost > 0 {
      lines.append(String(localized: """
        Health −\(healthLost), \
        \(healthLeft) left
        """))
    }
    if healthLeft == 0 {
      lines.append(
        String(localized: "Goes down")
      )
    }
    if winner == .party {
      lines.append(
        String(localized: "Wins the battle")
      )
    }
    return lines
  }
}

extension Weight {
  /// What it does to the unit's next turn.
  var label: String {
    switch self {
    case .light:
      String(localized: """
        Light: next turn after ¾ of the \
        usual wait
        """)
    case .normal:
      String(localized: """
        Next turn after the usual wait
        """)
    case .heavy:
      String(localized: """
        Heavy: next turn after 1½ times \
        the usual wait
        """)
    }
  }
}
