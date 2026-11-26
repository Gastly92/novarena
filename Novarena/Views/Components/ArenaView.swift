import RuleSteward
import SwiftUI

/// The arena from above, to scale: each
/// unit a circle its size, the unit on
/// turn ringed with how far it can move
/// shaded, the picked spot as a dashed
/// ghost, and foes the picked ability
/// reaches ringed. A tap picks a spot, or
/// with an ability picked, a foe. For
/// now it's one button to VoiceOver.
struct ArenaView: View {
  let fight: Fight

  init(fight: Fight) {
    self.fight = fight
  }

  var body: some View {
    let arena = fight.battle.arena
    GeometryReader { space in
      let map = ArenaMap(
        arena, width: space.size.width
      )
      ZStack(alignment: .topLeading) {
        Rectangle()
          .fill(.background)
        if let actor = fight.actor {
          range(of: actor, on: map)
        }
        ForEach(fight.battle.units) {
          token($0, on: map)
        }
        if let actor = fight.actor,
          let spot = fight.spot {
          ghost(of: actor, at: spot, on: map)
        }
      }
      .contentShape(Rectangle())
      .accessibilityElement()
      .accessibilityLabel("Arena")
      .accessibilityAddTraits(.isButton)
      .testID("arena")
      .onTapGesture {
        fight.tap(map.spot(at: $0))
      }
    }
    .aspectRatio(
      ArenaMap.ratio(arena),
      contentMode: .fit
    )
    .clipShape(
      RoundedRectangle(cornerRadius: 12)
    )
  }

  /// How far `actor` can move, shaded.
  private func range(
    of actor: BattleUnit,
    on map: ArenaMap
  ) -> some View {
    let across = map.points(
      2 * actor.unit.stats.move
    )
    return Circle()
      .fill(.tint.opacity(0.12))
      .frame(width: across, height: across)
      .position(
        map.location(of: actor.place)
      )
  }

  /// A unit's circle, with its initial.
  private func token(
    _ unit: BattleUnit,
    on map: ArenaMap
  ) -> some View {
    let across = map.points(
      2 * unit.unit.size.radius
    )
    return Circle()
      .fill(
        unit.isUp ? unit.side.color : .gray
      )
      .opacity(unit.isUp ? 1 : 0.4)
      .overlay { ring(unit) }
      .frame(width: across, height: across)
      .overlay {
        Text(verbatim: unit.initial)
          .font(.caption2.bold())
          .foregroundStyle(.white)
          .fixedSize()
      }
      .position(map.location(of: unit.place))
  }

  /// A ring on the unit on turn, and on
  /// foes the picked ability reaches.
  @ViewBuilder
  private func ring(
    _ unit: BattleUnit
  ) -> some View {
    if unit.id == fight.actor?.id {
      Circle().stroke(.primary, lineWidth: 2)
    } else if fight.inReach(unit.id) {
      Circle().stroke(.orange, lineWidth: 3)
    }
  }

  /// Where `actor` would move: a dashed
  /// line there, and a dashed circle its
  /// size.
  private func ghost(
    of actor: BattleUnit,
    at spot: Point,
    on map: ArenaMap
  ) -> some View {
    let dash = StrokeStyle(
      lineWidth: 2, dash: [4, 3]
    )
    let across = map.points(
      2 * actor.unit.size.radius
    )
    return ZStack(alignment: .topLeading) {
      Path {
        $0.move(
          to: map.location(of: actor.place)
        )
        $0.addLine(
          to: map.location(of: spot)
        )
      }
      .stroke(.secondary, style: dash)
      Circle()
        .stroke(
          actor.side.color, style: dash
        )
        .frame(width: across, height: across)
        .position(map.location(of: spot))
    }
  }
}
