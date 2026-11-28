import RuleSteward

/// Plays many battles with plain choices on
/// both sides and counts who wins, for
/// balancing: `BalanceTests` checks its
/// numbers, and
/// `.github/scripts/simulate.sh` prints
/// them (`SimulateTests`).
struct Simulator {
  /// Who can be in a team.
  let units: [Unit]
  /// The side with a commander in every
  /// battle, if any.
  var commander: Side?

  /// What a run of battles came to.
  struct Result {
    /// Battles won by teams with each unit
    /// (once per copy of it).
    var wins: [Int]
    /// Battles fought by teams with each.
    var fought: [Int]
    /// Battles the party won.
    var partyWins = 0
    /// Battles played.
    var battles = 0
    /// Battles with no winner by the end
    /// (2000 turns).
    var undecided = 0

    /// Each unit's share of wins, in
    /// percent.
    var rates: [Int] {
      zip(wins, fought).map {
        $1 == 0 ? 0 : $0 * 100 / $1
      }
    }

    /// The party's share of wins, in
    /// percent.
    var partyRate: Int {
      battles == 0
        ? 0 : partyWins * 100 / battles
    }
  }

  /// Every team of `size`, as indices into
  /// `units`, each in order so no team
  /// appears twice (a unit can appear more
  /// than once).
  func teams(
    _ size: Int,
    from first: Int = 0
  ) -> [[Int]] {
    guard size > 0 else {
      return [[]]
    }
    let rest = first..<units.count
    return rest.flatMap { index in
      teams(size - 1, from: index).map {
        [index] + $0
      }
    }
  }

  /// Who wins `party` against `foes`
  /// (indices into `units`).
  func winner(
    _ party: [Int],
    _ foes: [Int]
  ) -> Side? {
    var battle = Battle(
      party: party.map { units[$0] },
      foes: foes.map { units[$0] },
      commander: commander
    )
    battle.playPlainly(turns: 2000)
    return battle.winner
  }

  /// Every team of `size` against every
  /// other, both ways round.
  func run(size: Int) -> Result {
    var result = Result(
      wins: units.map { _ in 0 },
      fought: units.map { _ in 0 }
    )
    let all = teams(size)
    for party in all {
      for foes in all where foes != party {
        let won = winner(party, foes)
        result.battles += 1
        result.undecided += won == nil
          ? 1 : 0
        result.partyWins += won == .party
          ? 1 : 0
        for (side, team) in [
          (Side.party, party), (.foes, foes),
        ] {
          for index in team {
            result.fought[index] += 1
            result.wins[index] += won == side
              ? 1 : 0
          }
        }
      }
    }
    return result
  }

  /// One on one: how often the row's unit
  /// beats the column's, in percent of
  /// their two battles (one each way
  /// round).
  func matrix() -> [[Int]] {
    units.indices.map { row in
      units.indices.map { column in
        let first = winner([row], [column])
        let second = winner([column], [row])
        let won = (first == .party ? 1 : 0)
          + (second == .foes ? 1 : 0)
        return won * 50
      }
    }
  }
}
