import RuleSteward

/// How each stage of the sample battle is
/// set up for its screen.
extension Fight.Stage {
  /// The plans and picks this stage starts
  /// with, once the foes have acted.
  @MainActor
  func setUp(_ fight: Fight) {
    switch self {
    case .start, .middle, .end:
      break
    case .danger:
      fight.showsDanger = true
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
    }
  }
}
