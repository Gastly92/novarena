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
    if let line = notice(strike, battle) {
      return [line]
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
      lines.append(struck.says(
        loss.layer,
        losing: loss.lost,
        left: loss.left
      ))
    }
    for gain in strike.gains {
      lines.append(struck.says(
        gain.layer,
        gaining: gain.gained,
        now: gain.now
      ))
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

  /// What a strike that does nothing
  /// says: immune, countered or dodged;
  /// none if it does something.
  private func notice(
    _ strike: Strike,
    _ battle: Battle
  ) -> String? {
    if strike.immune {
      return String(localized: "Immune")
    }
    if strike.countered {
      return String(localized: "Countered")
    }
    guard strike.dodged else {
      return nil
    }
    let name = battle.units[strike.hit]
      .unit.name
    return String(
      localized: "\(name) dodges it"
    )
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

extension BattleUnit {
  /// Its layer at `index`, with `left` of
  /// its points: exact for the party, a
  /// percentage for foes ("Plate 45 of
  /// 60", "Plate 75%").
  func says(
    _ index: Int,
    left: Int
  ) -> String {
    let layer = unit.layers[index]
    let name = layer.name
    guard side == .foes else {
      return String(localized: """
        \(name) \(left) of \(layer.points)
        """)
    }
    let part = Self.percent(
      left, of: layer.points
    )
    return String(localized: """
      \(name) \(part.formatted(.percent))
      """)
  }

  /// What a hit takes from its layer at
  /// `index`, `lost` of it with `left`
  /// after: exact for the party, a
  /// percentage of the layer for foes
  /// ("Plate −15, 45 left", "Plate −25%,
  /// 75% left").
  func says(
    _ index: Int,
    losing lost: Int,
    left: Int
  ) -> String {
    let layer = unit.layers[index]
    let name = layer.name
    guard side == .foes else {
      return String(localized: """
        \(name) −\(lost), \(left) left
        """)
    }
    let after = Self.percent(
      left, of: layer.points
    )
    let before = Self.percent(
      left + lost, of: layer.points
    )
    let gone = (before - after)
      .formatted(.percent)
    return String(localized: """
      \(name) −\(gone), \
      \(after.formatted(.percent)) left
      """)
  }

  /// What a heal mends in its layer at
  /// `index`: `gained`, to `now`. Always
  /// exact: the party heals its own.
  func says(
    _ index: Int,
    gaining gained: Int,
    now: Int
  ) -> String {
    let name = unit.layers[index].name
    return String(localized: """
      \(name) +\(gained), now \(now)
      """)
  }

  /// `part` of `whole` in percent, rounded
  /// down, but never 0 while some is left.
  static func percent(
    _ part: Int,
    of whole: Int
  ) -> Int {
    part == 0
      ? 0 : max(1, part * 100 / whole)
  }
}
