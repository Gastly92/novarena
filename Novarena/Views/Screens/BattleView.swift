import RuleSteward
import SwiftUI

/// A battle: the turn order and the arena
/// on top, then the unit on turn's turn
/// (move, skills, actions), both sides,
/// and the log.
/// Text from the rules isn't translated
/// yet, so it carries a `data-`
/// identifier.
struct BattleView: View {
  @State private var fight: Fight

  init(fight: Fight) {
    _fight = State(initialValue: fight)
  }

  var body: some View {
    VStack(spacing: 0) {
      header
      List {
        Section {
          Controls(fight: fight)
        }
        Section("Foes") { foes }
        Section("Party") {
          ForEach(fight.units(.party)) {
            UnitRow(unit: $0)
          }
        }
        Section("Log") { log }
      }
    }
    .background(
      Color(.systemGroupedBackground)
    )
    .navigationTitle("Battle")
    .navigationBarTitleDisplayMode(.inline)
  }

  /// The turn order and the arena, always
  /// in view.
  private var header: some View {
    VStack(spacing: 8) {
      TurnRow(fight: fight)
      ArenaView(fight: fight)
        .frame(maxHeight: 200)
    }
    .padding(.horizontal)
    .padding(.top, 8)
  }

  /// The foes, each a button to tap once a
  /// skill is picked.
  private var foes: some View {
    ForEach(fight.units(.foes)) { foe in
      Button {
        fight.target(foe.id)
      } label: {
        UnitRow(
          unit: foe,
          preview: fight.preview(of: foe.id)
        )
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
}

/// The parts of the unit on turn's turn,
/// one at a time (moving, its skills,
/// other actions), or the outcome once
/// the battle is over.
private struct Controls: View {
  @Bindable var fight: Fight

  init(fight: Fight) {
    self.fight = fight
  }

  var body: some View {
    if let outcome = fight.outcome {
      Text(outcome)
        .font(.headline)
      Button("Fight again") {
        fight.restart()
      }
    } else if let actor = fight.actor {
      Picker(
        "Turn", selection: $fight.panel
      ) {
        Text("Move").tag(Fight.Panel.move)
        Text("Skills")
          .tag(Fight.Panel.skills)
        Text("Actions")
          .tag(Fight.Panel.actions)
      }
      .pickerStyle(.segmented)
      switch fight.panel {
      case .move:
        MovePanel(fight: fight)
      case .skills:
        skills(of: actor)
      case .actions:
        Button("End turn") {
          fight.endTurn()
        }
      }
    }
  }

  /// One button per skill, with its power,
  /// cost, reach and weight; the picked
  /// one is checked.
  private func skills(
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
          details(all[index])
          Spacer()
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

  /// A skill's name, then its power, cost,
  /// reach and weight, then its kind of
  /// damage and discipline (from the
  /// rules, so a `data-` identifier).
  private func details(
    _ ability: Ability
  ) -> some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(verbatim: ability.name)
        .testID("data-ability-name")
      HStack {
        Text("Power \(ability.power)")
        if ability.cost > 0 {
          Text("Costs \(ability.cost)")
        }
        Text(ability.reach.label)
        if let note = ability.weight.label {
          Text(note)
        }
      }
      .font(.caption)
      .foregroundStyle(.secondary)
      Text(verbatim: """
        \(ability.kind.name) · \
        \(ability.discipline.name)
        """)
        .font(.caption)
        .foregroundStyle(.secondary)
        .testID("data-ability-kind")
    }
  }
}
