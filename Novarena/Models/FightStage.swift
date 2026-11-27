import RuleSteward

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
    ]
    guard let stage = stages[screen] else {
      return nil
    }
    self = stage
  }

  /// Who fights for the party.
  var party: [Unit] {
    self == .healing
      ? [.gerald, .maren] : [.gerald, .oswin]
  }

  /// Who they face.
  var foes: [Unit] {
    [.ashka, .kestrel]
  }

  /// How many turns are played plainly
  /// first.
  var turns: Int {
    switch self {
    case .start, .moving, .aiming, .foes,
      .edge:
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
      fight.advance()
    case .edge:
      fight.place(Point(x: 600, y: 200))
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
}
