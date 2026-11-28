import RuleSteward

/// The rules' units: Foundation has its own
/// `Unit`, for measurements.
typealias Unit = RuleSteward.Unit

/// Who fights, picked before a battle: up
/// to three units a side, from every unit
/// there is (`Unit.all`), the same one
/// more than once if wanted.
struct Lineup: Equatable {
  /// The most units a side.
  static let most = 3

  /// The party's picks, as indices into
  /// `Unit.all`.
  private(set) var party: [Int]
  /// The foes' picks.
  private(set) var foes: [Int]

  /// A lineup; the sample battle's unless
  /// given.
  init(
    party: [Int] = [0, 2],
    foes: [Int] = [1, 3]
  ) {
    self.party = party
    self.foes = foes
  }

  /// One side's picks.
  func picks(_ side: Side) -> [Int] {
    side == .party ? party : foes
  }

  /// Whether `side` has room for another.
  func hasRoom(_ side: Side) -> Bool {
    picks(side).count < Self.most
  }

  /// Adds unit `index` to `side`, if it
  /// has room.
  mutating func add(
    _ index: Int,
    to side: Side
  ) {
    guard hasRoom(side) else {
      return
    }
    if side == .party {
      party.append(index)
    } else {
      foes.append(index)
    }
  }

  /// Takes the pick at `place` off `side`.
  mutating func remove(
    at place: Int,
    from side: Side
  ) {
    if side == .party {
      party.remove(at: place)
    } else {
      foes.remove(at: place)
    }
  }

  /// Whether both sides have someone.
  var isReady: Bool {
    !party.isEmpty && !foes.isEmpty
  }

  /// A fight between the picks, played as
  /// `settings` say.
  @MainActor
  func fight(
    _ settings: Settings = Settings()
  ) -> Fight {
    Fight(
      party: party.map { Unit.all[$0] },
      foes: foes.map { Unit.all[$0] },
      settings: settings
    )
  }
}
