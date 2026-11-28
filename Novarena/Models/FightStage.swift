import RuleSteward

extension Fight {
  /// How far into the sample battle a
  /// screen starts, for UI tests and
  /// snapshots.
  enum Stage {
    /// Gerald's first turn.
    case start
    /// The same, with a move planned to
    /// (300, 200).
    case moving
    /// The same, skills open, Sword Cut
    /// picked: no foe in reach.
    case aiming
    /// Gerald's second turn, with a move
    /// planned that puts Kestrel-9 in Sword
    /// Cut's reach, but not Ashka.
    case planned
    /// The same, after Sword Cut and
    /// Pommel Strike on Kestrel-9: the
    /// turn still to end.
    case acted
    /// Six turns in.
    case middle
    /// The same, with every zone on.
    case zones
    /// Eleven turns in: Ashka and Oswin
    /// exposed, Oswin's turn, the actions
    /// open (short, so his row shows).
    case exposed
    /// Played to the end.
    case end
    /// Gerald's first turn ended without
    /// moving: Ashka's turn begun, then her
    /// move shown, a step at a time.
    case foes
    /// Gerald's first turn, a move planned
    /// to the east edge of his range: up
    /// and down slide along it.
    case edge
    /// With the party's commander: its
    /// second turn, Oswin worn.
    case commanding
    /// With the commander: Gerald's first
    /// turn ended, then Gerald warded, and
    /// Ashka's turn begun.
    case warded
    /// Gerald's first turn, Oswin tapped
    /// with the move open: a walk planned
    /// to touch him, arrows circling round
    /// him.
    case circling
    /// Gerald and Maren against the same
    /// foes, six turns in: Maren's turn,
    /// Mend Wounds picked, Gerald's plate
    /// worn and in her reach, every zone
    /// on.
    case healing
    /// Gerald and Isolde against Ashka and
    /// Wren, Isolde near the foes: her
    /// first turn, Chill Touch picked and a
    /// move planned beside Wren, who would
    /// dodge it.
    case dodging
    /// The same lineup: Ashka's first turn,
    /// her Fireball about to be cast near
    /// Isolde, who can counter it.
    case countering
  }
}

/// How each stage of the sample battle is
/// set up for its screen.
extension Fight.Stage {
  /// The stage battle screen `screen`
  /// shows; none for other screens.
  init?(screen: ScreenID) {
    let stages: [ScreenID: Self] = [
      .battle: .start,
      .battleMoving: .moving,
      .battleAiming: .aiming,
      .battlePlanned: .planned,
      .battleActed: .acted,
      .battleMiddle: .middle,
      .battleZones: .zones,
      .battleEnd: .end,
      .battleHealing: .healing,
      .battleExposed: .exposed,
      .battleFoes: .foes,
      .battleEdge: .edge,
      .battleCircling: .circling,
      .battleCommanding: .commanding,
      .battleWarded: .warded,
      .battleDodging: .dodging,
      .battleCountering: .countering,
    ]
    guard let stage = stages[screen] else {
      return nil
    }
    self = stage
  }

  /// Whether the party has a commander:
  /// only on its own screens, so the
  /// others keep the sample's timeline.
  private var commands: Bool {
    self == .commanding || self == .warded
  }

  /// The battle it starts from: who
  /// fights, where, and whether the party
  /// has a commander.
  var battle: Battle {
    Battle(
      party: party,
      foes: reacts ? [.ashka, .wren]
        : [.ashka, .kestrel],
      places: reacts ? Self.near : nil,
      commander: commands ? .party : nil
    )
  }

  /// Whether it shows reactions.
  private var reacts: Bool {
    self == .dodging || self == .countering
  }

  /// Where the reactions' stages deploy:
  /// Isolde near the foes.
  private static let near = [
    Point(x: 250, y: 200),
    Point(x: 650, y: 300),
    Point(x: 950, y: 200),
    Point(x: 950, y: 600),
  ]

  /// Who fights for the party.
  private var party: [Unit] {
    switch self {
    case .healing:
      [.gerald, .maren]
    case .dodging, .countering:
      [.gerald, .isolde]
    default:
      [.gerald, .oswin]
    }
  }

  /// How many turns are played plainly
  /// first.
  var turns: Int {
    switch self {
    case .start, .moving, .aiming, .foes,
      .edge, .circling, .commanding, .warded,
      .dodging, .countering:
      0
    case .planned, .acted:
      4
    case .middle, .zones, .healing:
      6
    case .exposed:
      11
    case .end:
      200
    }
  }

  /// The plans and picks this stage starts
  /// with, once the foes have acted.
  @MainActor
  func setUp(_ fight: Fight) {
    switch self {
    case .start, .middle, .end:
      break
    case .exposed:
      fight.panel = .actions
    case .foes:
      fight.endTurn()
      fight.advance()
    case .edge:
      fight.place(Point(x: 600, y: 200))
    case .circling:
      fight.tap(fight.battle.units[1].place)
    case .dodging, .countering:
      reactions(fight)
    case .commanding:
      // Two rounds on: Oswin worn.
      fight.endTurn()
      fight.command(.pass)
      for _ in 0..<2 {
        fight.skip()
        fight.endTurn()
      }
    case .warded:
      fight.endTurn()
      fight.command(.ward(0))
    case .zones:
      fight.showsZones = true
    case .moving:
      fight.place(Point(x: 300, y: 200))
    case .aiming:
      fight.panel = .skills
      fight.choose(0)
    case .planned:
      fight.panel = .skills
      fight.place(Point(x: 817, y: 448))
      fight.choose(0)
    case .acted:
      fight.place(Point(x: 817, y: 448))
      fight.choose(0)
      fight.target(3)
      fight.choose(2)
      fight.target(3)
    case .healing:
      fight.panel = .skills
      fight.choose(2)
      fight.showsZones = true
    }
  }

  /// The reactions' stages: after
  /// Gerald's turn, Isolde's.
  @MainActor
  private func reactions(_ fight: Fight) {
    fight.endTurn()
    guard self == .dodging else {
      fight.endTurn()
      fight.advance()
      return
    }
    fight.panel = .skills
    fight.place(Point(x: 690, y: 340))
    fight.choose(3)
  }
}
