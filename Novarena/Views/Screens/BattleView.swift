import RuleSteward
import SwiftUI

/// A battle: the turn order, both sides, the
/// unit on turn's abilities (pick one, then
/// tap a foe), and the log. Text from the
/// rules isn't translated yet, so it carries
/// a `data-` identifier.
struct BattleView: View {
  @State private var fight: Fight

  init(fight: Fight) {
    _fight = State(initialValue: fight)
  }

  var body: some View {
    List {
      Section("Turn order") {
        TurnOrder(fight: fight)
      }
      Section("Foes") { foes }
      Section("Party") {
        ForEach(fight.units(.party)) {
          row($0)
        }
      }
      Section {
        Controls(fight: fight)
      }
      Section("Log") { log }
    }
    .navigationTitle("Battle")
    .navigationBarTitleDisplayMode(.inline)
  }

  /// The foes, each a button to tap once an
  /// ability is picked.
  private var foes: some View {
    ForEach(fight.units(.foes)) { foe in
      Button {
        fight.target(foe.id)
      } label: {
        row(foe)
      }
      .disabled(
        fight.chosen == nil || !foe.isUp
      )
      .testID("data-foe-\(foe.id)")
    }
  }

  /// The latest log lines, newest first.
  private var log: some View {
    ForEach(
      Array(fight.latest.enumerated()),
      id: \.offset
    ) {
      Text(verbatim: $0.element)
        .font(.caption.monospaced())
        .testID("data-log")
    }
  }

  /// A unit, marked if it's on turn.
  private func row(
    _ unit: BattleUnit
  ) -> some View {
    UnitRow(
      unit: unit,
      onTurn: unit.id == fight.actor?.id
    )
  }
}

/// Who acts next, in order, and the time.
private struct TurnOrder: View {
  let fight: Fight

  var body: some View {
    VStack(alignment: .leading) {
      Text("Tick \(fight.battle.tick)")
        .font(.caption)
        .foregroundStyle(.secondary)
      Text(verbatim: names)
        .testID("data-queue")
    }
  }

  /// The queue's names, the next first.
  private var names: String {
    fight.queue.map(\.unit.name)
      .joined(separator: " · ")
  }
}

/// The unit on turn's abilities, or the
/// outcome once the battle is over.
private struct Controls: View {
  let fight: Fight

  var body: some View {
    if let outcome = fight.outcome {
      Text(outcome)
        .font(.headline)
      Button("Fight again") {
        fight.restart()
      }
    } else if let actor = fight.actor {
      abilities(of: actor)
      if fight.chosen != nil {
        Text("Now tap a foe.")
          .foregroundStyle(.secondary)
      }
    }
  }

  /// One button per ability, with its cost;
  /// the picked one is checked.
  private func abilities(
    of actor: BattleUnit
  ) -> some View {
    let all = actor.unit.abilities
    return ForEach(
      all.indices, id: \.self
    ) { index in
      Button {
        fight.choose(index)
      } label: {
        HStack {
          Text(verbatim: all[index].name)
            .testID("data-ability-name")
          Spacer()
          if all[index].cost > 0 {
            Text("Costs \(all[index].cost)")
              .foregroundStyle(.secondary)
          }
          if fight.chosen == index {
            Image(systemName: "checkmark")
              .accessibilityHidden(true)
          }
        }
      }
      .disabled(!fight.battle.canUse(index))
      .testID("data-ability-\(index)")
    }
  }
}
