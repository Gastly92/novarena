import RuleSteward

extension Forecast {
  /// What it says, a line each, for the row
  /// of `target` (an id) in `battle`.
  func lines(
    for target: Int,
    in battle: Battle
  ) -> [String] {
    guard let strike else {
      return []
    }
    guard !strike.immune else {
      return [String(localized: "Immune")]
    }
    var lines: [String] = []
    let struck = battle.units[strike.hit]
    if strike.hit != target {
      let name = struck.unit.name
      lines.append(String(
        localized: "\(name) takes it instead"
      ))
    }
    for loss in strike.losses {
      let layer = struck.unit
        .layers[loss.layer].name
      lines.append(String(localized: """
        \(layer) −\(loss.lost), \
        \(loss.left) left
        """))
    }
    if strike.knocksOut {
      lines.append(
        String(localized: "Knocked out")
      )
    } else if strike.exposes {
      lines.append(String(localized: """
        Exposed: the next hit knocks out
        """))
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
  /// What it does to the unit's next turn,
  /// shown when it isn't the usual wait.
  var label: String? {
    switch self {
    case .light:
      String(localized: "Light")
    case .normal:
      nil
    case .heavy:
      String(localized: "Heavy")
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
