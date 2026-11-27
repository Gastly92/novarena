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
  /// Whether the battle info sheet is up.
  @State private var showsInfo = false

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
        Section("Foes") { side(.foes) }
        Section("Party") { side(.party) }
        Section("Log") { log }
      }
    }
    .background(
      Color(.systemGroupedBackground)
    )
    .navigationTitle("Battle")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      Button(
        "Battle info",
        systemImage: "info.circle"
      ) {
        showsInfo = true
      }
    }
    .sheet(isPresented: $showsInfo) {
      NavigationStack {
        BattleInfoView(battle: fight.battle)
      }
    }
  }

  /// The turn order and the arena, always
  /// in view.
  private var header: some View {
    VStack(spacing: 8) {
      TurnRow(fight: fight)
      ArenaView(fight: fight)
        .frame(maxHeight: 200)
        .overlay(alignment: .topTrailing) {
          Toggle(
            "Zones",
            systemImage: "scope",
            isOn: $fight.showsZones
          )
          .toggleStyle(.button)
          .font(.caption)
          .padding(4)
        }
    }
    .padding(.horizontal)
    .padding(.top, 8)
  }

  /// One side's units, each a button to
  /// tap once a skill that can be used on
  /// it is picked (an attack on a foe, a
  /// heal on an ally).
  private func side(
    _ side: Side
  ) -> some View {
    ForEach(fight.units(side)) { unit in
      Button {
        fight.target(unit.id)
      } label: {
        UnitRow(
          unit: unit,
          preview: fight.preview(of: unit.id)
        )
      }
      .disabled(!fight.canAim(at: unit.id))
      .testID("data-unit-\(unit.id)")
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

  /// A skill's name, then its power, reach
  /// and weight, then its kind of damage
  /// and discipline (from the rules, so a
  /// `data-` identifier) and what it costs
  /// from which pools.
  private func details(
    _ ability: Ability
  ) -> some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(verbatim: ability.name)
        .testID("data-ability-name")
      Group {
        numbers(ability)
        sources(ability)
      }
      .font(.caption)
      .foregroundStyle(.secondary)
    }
  }

  /// Its power, reach and weight, and
  /// whether it's a bonus.
  private func numbers(
    _ ability: Ability
  ) -> some View {
    HStack {
      Text("Power \(ability.power)")
      Text(ability.reachLabel)
      if let note = ability.weight.label {
        Text(note)
      }
      if ability.bonus != nil {
        Text("Bonus")
      }
    }
  }

  /// Its kind of damage and discipline,
  /// then what it costs from which pools.
  private func sources(
    _ ability: Ability
  ) -> some View {
    HStack {
      Text(verbatim: """
        \(ability.kind.name) · \
        \(ability.discipline.name)
        """)
        .testID("data-ability-kind")
      ForEach(
        ability.costLines, id: \.self
      ) {
        Text($0)
      }
    }
  }
}
