import RuleSteward

extension Forecast {
  /// What it says, a line each, for the row
  /// of `target` (an id) in `battle`.
  func lines(
    for target: Int,
    in battle: Battle
  ) -> [String] {
    guard let strike else {
      let walks = String(localized: """
        Out of reach: walks toward it
        """)
      return [walks]
    }
    guard !strike.immune else {
      return [String(localized: "Immune")]
    }
    var lines: [String] = []
    if strike.hit != target {
      let name = battle.units[strike.hit]
        .unit.name
      lines.append(String(
        localized: "\(name) takes it instead"
      ))
    }
    if strike.shieldLost > 0 {
      lines.append(String(localized: """
        Shield −\(strike.shieldLost), \
        \(strike.shieldLeft) left
        """))
    }
    if strike.healthLost > 0 {
      lines.append(String(localized: """
        Health −\(strike.healthLost), \
        \(strike.healthLeft) left
        """))
    }
    if strike.healthLeft == 0 {
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

extension Reach {
  /// How far it reaches, for the ability's
  /// row.
  var label: String {
    switch self {
    case let .melee(reach):
      String(localized: "Melee, \(reach) cm")
    case let .ranged(reach):
      String(localized: "Range \(reach) cm")
    }
  }
}
