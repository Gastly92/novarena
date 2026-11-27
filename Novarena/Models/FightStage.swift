import RuleSteward

/// How each stage of the sample battle is
/// set up for its screen.
extension Fight.Stage {
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
    case .start, .moving, .aiming:
      0
    case .planned, .acted:
      4
    case .middle, .zones, .healing:
      6
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
