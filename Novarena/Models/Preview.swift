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

extension Measure {
  /// `centimetres` in this measure, to a
  /// tenth: "7 steps", "1.5 casts".
  func says(_ centimetres: Int) -> String {
    let tenths = centimetres * 10
      / self.centimetres
    let amount = (Double(tenths) / 10)
      .formatted()
    let name = tenths == 10 ? one : many
    return String(
      localized: "\(amount) \(name)"
    )
  }
}

extension Ability {
  /// What it costs, a line per pool, by
  /// the pools' names.
  var costLines: [String] {
    costs
      .sorted { $0.key.name < $1.key.name }
      .map {
        String(localized: """
          Costs \($0.value) \($0.key.name)
          """)
      }
  }

  /// How far it reaches, in its own
  /// measure, for its row.
  var reachLabel: String {
    switch reach {
    case let .melee(reach):
      String(localized: """
        Melee, \(measure.says(reach))
        """)
    case let .ranged(reach):
      String(localized: """
        Range \(measure.says(reach))
        """)
    }
  }
}
