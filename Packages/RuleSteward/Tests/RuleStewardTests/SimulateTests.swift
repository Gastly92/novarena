import Foundation
import RuleSteward
import XCTest

/// Prints win rates from `Simulator`, for
/// balancing by hand; skipped unless
/// `SIMULATE` is set. Run it with
/// `.github/scripts/simulate.sh`, which
/// passes these on:
/// - `SIMULATE_SIZES`: team sizes, e.g.
///   "1,2,3" (default "1,2").
/// - `SIMULATE_UNITS`: unit names, e.g.
///   "Gerald,Wren" (default every unit).
/// - `SIMULATE_COMMANDER`: "party" or
///   "foes", the side with a commander
///   (default none).
/// - `SIMULATE_MATRIX`: "1" adds who beats
///   whom one on one.
final class SimulateTests: XCTestCase {
  private let env = ProcessInfo.processInfo
    .environment

  func testReport() throws {
    guard env["SIMULATE"] != nil else {
      throw XCTSkip("SIMULATE is not set")
    }
    let simulator = Simulator(
      units: try chosen(),
      commander: side()
    )
    let names = simulator.units.map(\.name)
    say("Commander: \(commanderName)")
    for size in sizes {
      let result = simulator.run(size: size)
      say("""
        Teams of \(size): \(result.battles) \
        battles, party wins \
        \(result.partyRate)%, \
        undecided \(result.undecided)
        """)
      for (name, rate) in zip(
        names, result.rates
      ) {
        say("  \(name): \(rate)%")
      }
    }
    guard env["SIMULATE_MATRIX"] == "1"
    else { return }
    say("One on one, row beats column, %:")
    let head = names.joined(separator: " | ")
    say("  " + head)
    for (name, row) in zip(
      names, simulator.matrix()
    ) {
      let cells = row.map(String.init)
      say("  \(name): " + cells.joined(
        separator: " | "
      ))
    }
  }

  /// The units named in `SIMULATE_UNITS`,
  /// or all of them.
  private func chosen() throws -> [Unit] {
    guard let list = env["SIMULATE_UNITS"]
    else { return Unit.all }
    return try list.split(separator: ",")
      .map { name in
        try XCTUnwrap(
          Unit.all.first {
            $0.name == name
          },
          "No unit called \(name)"
        )
      }
  }

  /// The side `SIMULATE_COMMANDER` names.
  private func side() -> Side? {
    switch env["SIMULATE_COMMANDER"] {
    case "party":
      .party
    case "foes":
      .foes
    default:
      nil
    }
  }

  private var commanderName: String {
    env["SIMULATE_COMMANDER"] ?? "none"
  }

  /// The team sizes to play.
  private var sizes: [Int] {
    (env["SIMULATE_SIZES"] ?? "1,2")
      .split(separator: ",")
      .compactMap { Int($0) }
  }

  /// Prints a line of the report, marked
  /// so the script can pick it out.
  private func say(_ line: String) {
    print("SIM " + line)
  }
}
