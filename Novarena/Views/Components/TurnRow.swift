import RuleSteward
import SwiftUI

/// The turn order as a row of portraits:
/// the order after the turn being
/// planned, named for the unit on turn,
/// with where it lands circled (or, on the
/// commander's or a foe's turn, as it
/// stands), the commander's turn among
/// them. Names
/// come from the rules, so they carry a
/// `data-` identifier.
struct TurnRow: View {
  let fight: Fight
  @ScaledMetric private var size = 36.0

  init(fight: Fight) {
    self.fight = fight
  }

  var body: some View {
    let after = fight.queueAfter
    VStack(alignment: .leading, spacing: 4) {
      Group {
        if let actor = fight.actor,
          !after.isEmpty {
          Text("""
            Turn order after \
            \(actor.unit.name)'s turn
            """)
        } else {
          Text("Turn order")
        }
      }
      .testID("turn-title")
      .font(.caption)
      .foregroundStyle(.secondary)
      HStack(alignment: .top, spacing: 8) {
        ForEach(
          Array(fight.seats.enumerated()),
          id: \.offset
        ) {
          seat(
            $0.element,
            lands: !after.isEmpty
          )
        }
      }
    }
    .fullWidth(.leading)
  }

  /// A seat's portrait: a unit's (circled
  /// where the unit on turn lands, once
  /// there's a plan), or the commander's.
  @ViewBuilder
  private func seat(
    _ seat: Seat,
    lands: Bool
  ) -> some View {
    switch seat {
    case let .unit(unit, place):
      portrait(
        unit,
        at: place,
        lands: lands
          && unit.id == fight.actor?.id
      )
    case .commander:
      commander
    }
  }

  /// The commander's portrait: a crown in
  /// the party's color.
  private var commander: some View {
    VStack(spacing: 2) {
      Image(systemName: "crown.fill")
        .font(.headline)
        .foregroundStyle(.white)
        .accessibilityHidden(true)
        .frame(width: size, height: size)
        .background(
          Circle().fill(Side.party.color)
        )
      Text("Commander")
        .font(.caption2)
        .lineLimit(1)
        .testID("order-commander")
    }
  }

  /// A unit's initial in its side's color,
  /// with its name under it.
  private func portrait(
    _ unit: BattleUnit,
    at place: Int,
    lands: Bool
  ) -> some View {
    VStack(spacing: 2) {
      Text(verbatim: unit.initial)
        .font(.headline)
        .foregroundStyle(.white)
        .testID("data-initial")
        .frame(width: size, height: size)
        .background(
          Circle().fill(unit.side.color)
        )
        .overlay {
          if lands {
            Circle()
              .stroke(.primary, lineWidth: 3)
          }
        }
      Text(verbatim: unit.unit.name)
        .font(.caption2)
        .lineLimit(1)
        .testID("data-order-\(place)")
    }
  }
}

extension Side {
  /// The side's color on the battle
  /// screen.
  var color: Color {
    self == .party ? .blue : .red
  }
}

extension BattleUnit {
  /// The first letter of its name, for its
  /// portrait and token.
  var initial: String {
    String(unit.name.prefix(1))
  }
}
