import RuleSteward
import SwiftUI

/// Choosing who fights: up to three units
/// a side, from every unit there is, then
/// the fight. Tapping a pick takes it off.
/// Names come from the rules, so they
/// carry a `data-` identifier.
struct PickerView: View {
  @State private var lineup: Lineup
  /// Where settings are kept.
  let defaults: UserDefaults

  init(
    defaults: UserDefaults,
    lineup: Lineup = Lineup()
  ) {
    _lineup = State(initialValue: lineup)
    self.defaults = defaults
  }

  var body: some View {
    List {
      Section {
        NavigationLink("Fight") {
          BattleView(
            fight: lineup.fight(
              Settings(defaults)
            )
          )
        }
        .disabled(!lineup.isReady)
        .testID("start-fight")
      }
      team(.party, title: "Party")
      team(.foes, title: "Foes")
      Section("Units") {
        ForEach(
          Unit.all.indices, id: \.self
        ) {
          candidate($0)
        }
      }
    }
    .navigationTitle("Who fights")
    .navigationBarTitleDisplayMode(.inline)
  }

  /// One side's picks, each a button that
  /// takes it off.
  private func team(
    _ side: Side,
    title: LocalizedStringKey
  ) -> some View {
    let picks = lineup.picks(side)
    return Section(title) {
      ForEach(
        Array(picks.enumerated()),
        id: \.offset
      ) {
        pick(
          $0.element, at: $0.offset, of: side
        )
      }
    }
  }

  /// Unit `index`, picked at `place` on
  /// `side`: a button that takes it off.
  private func pick(
    _ index: Int,
    at place: Int,
    of side: Side
  ) -> some View {
    Button {
      lineup.remove(at: place, from: side)
    } label: {
      Label {
        Text(verbatim: Unit.all[index].name)
          .testID("data-name")
      } icon: {
        Image(systemName: "minus.circle")
      }
    }
    .testID("data-\(side)-\(place)")
  }

  /// A unit there is: its name and kind,
  /// then buttons adding it to a side.
  private func candidate(
    _ index: Int
  ) -> some View {
    let unit = Unit.all[index]
    return VStack(alignment: .leading) {
      Text(verbatim: unit.name)
        .testID("data-name")
      Text(verbatim: unit.kind)
        .font(.caption)
        .foregroundStyle(.secondary)
        .testID("data-kind")
      adders(index)
    }
  }

  /// Buttons adding unit `index` to either
  /// side, while it has room.
  private func adders(
    _ index: Int
  ) -> some View {
    HStack {
      Button("Party", systemImage: "plus") {
        lineup.add(index, to: .party)
      }
      .disabled(!lineup.hasRoom(.party))
      .testID("add-party-\(index)")
      Button("Foes", systemImage: "plus") {
        lineup.add(index, to: .foes)
      }
      .disabled(!lineup.hasRoom(.foes))
      .testID("add-foes-\(index)")
    }
    .buttonStyle(.bordered)
  }
}
