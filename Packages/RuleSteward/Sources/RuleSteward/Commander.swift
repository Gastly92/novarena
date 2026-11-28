/// The player, off the field: a place in
/// the turn order, and on its turns an
/// order from afar to one of its side.
/// (A boss's master, later, the same for
/// the foes.)
public struct Commander: Sendable,
  Equatable {
  /// Whose commander it is.
  public let side: Side
  /// The tick its next turn comes at.
  public internal(set) var nextTurn: Int
  /// The units it has warded: once each a
  /// battle.
  public internal(set) var warded: Set<Int>

  /// A commander, its first turn after a
  /// usual wait.
  init(side: Side) {
    self.side = side
    nextTurn = Rules.wait(
      speed: 100, weight: .normal
    )
    warded = []
  }
}

/// What a commander does on its turn.
public enum Order: Sendable, Equatable {
  /// Gives back a quarter of the unit's
  /// outermost standing layer (not a
  /// broken one), up to whole.
  case restore(Int)
  /// A ward for the unit: its next three
  /// hits soaked whole. Once a unit a
  /// battle.
  case ward(Int)
  /// Nothing this turn.
  case pass
}

public extension Battle {
  /// Hits a ward soaks.
  static let wardHits = 3

  /// Whether it's the commander's turn:
  /// its turn comes no later than the next
  /// unit's, and no unit's turn is under
  /// way. Units wait until it's done.
  var commanderUp: Bool {
    guard let commander, progress == nil,
      let next
    else { return false }
    return commander.nextTurn
      <= units[next].nextTurn
  }

  /// Where the commander's next turn falls
  /// among `queue` (unit ids): before the
  /// first unit whose turn comes after
  /// it. None without a commander.
  func commanderSlot(
    in queue: [Int]
  ) -> Int? {
    commander.map { commander in
      let soon = queue.filter {
        units[$0].nextTurn
          < commander.nextTurn
      }
      return soon.count
    }
  }

  /// Whether the commander could give
  /// `order` now.
  func canCommand(_ order: Order) -> Bool {
    var after = self
    return (try? after.command(order)) != nil
  }

  /// The commander gives `order` on its
  /// turn: the clock moves to it, the
  /// order takes hold, and its next turn
  /// comes after a usual wait.
  mutating func command(
    _ order: Order
  ) throws(Mistake) {
    guard commanderUp,
      var leader = commander
    else { throw .notCommanding }
    guard allows(order, by: leader) else {
      throw .badTarget
    }
    tick = leader.nextTurn
    log.append(
      .turn("Commander", tick: tick)
    )
    switch order {
    case let .restore(id):
      restore(id)
    case let .ward(id):
      leader.warded.insert(id)
      units[id].wards = Self.wardHits
      log.append(.warded(
        units[id].unit.name,
        hits: Self.wardHits
      ))
    case .pass:
      break
    }
    leader.nextTurn += Rules.wait(
      speed: 100, weight: .normal
    )
    commander = leader
  }
}

extension Battle {
  /// Whether `leader` may give `order`: a
  /// restore to an ally with a standing
  /// layer to restore, a ward to an ally
  /// it hasn't warded yet.
  private func allows(
    _ order: Order,
    by leader: Commander
  ) -> Bool {
    switch order {
    case let .restore(id):
      ally(id, of: leader.side)
        && restorable(id) != nil
    case let .ward(id):
      ally(id, of: leader.side)
        && !leader.warded.contains(id)
    case .pass:
      true
    }
  }

  /// Whether unit `id` is up on `side`.
  private func ally(
    _ id: Int,
    of side: Side
  ) -> Bool {
    units.indices.contains(id)
      && units[id].isUp
      && units[id].side == side
  }

  /// Unit `id`'s outermost standing layer,
  /// if it's short of whole.
  private func restorable(
    _ id: Int
  ) -> Int? {
    let unit = units[id]
    let left = unit.layers
    let standing = left.indices.first {
      left[$0] > 0
    }
    return standing.flatMap {
      let whole = unit.unit.layers[$0].points
      return left[$0] < whole ? $0 : nil
    }
  }

  /// Gives back a quarter of unit `id`'s
  /// outermost standing layer, up to whole.
  private mutating func restore(_ id: Int) {
    if let index = restorable(id) {
      let layer = units[id].unit
        .layers[index]
      let left = units[id].layers[index]
      let gained = min(
        layer.points - left, layer.points / 4
      )
      units[id].layers[index] += gained
      log.append(.mends(
        units[id].unit.name,
        layer.name,
        gained: gained,
        now: left + gained
      ))
    }
  }
}
