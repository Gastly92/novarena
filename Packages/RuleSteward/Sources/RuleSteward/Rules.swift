/// The formulas, in whole numbers, rounded
/// down.
enum Rules {
  /// The wait after acting, in ticks:
  /// 10,000 ÷ Speed, scaled by the action's
  /// weight and the turn's pace. Speed 100
  /// waits 100 ticks.
  static func wait(
    speed: Int,
    weight: Weight,
    pace: Int = 100
  ) -> Int {
    10_000 * weight.percent * pace
      / (speed * 10_000)
  }

  /// How moving stretches the wait, in
  /// percent: 90 for not moving at all, 1
  /// more for each twentieth of its
  /// `range` it `moved`, to 110 for all
  /// of it, so a small step barely counts
  /// and resting brings the next turn
  /// sooner. A unit that can't move
  /// waits as usual.
  static func pace(
    moved: Int,
    of range: Int
  ) -> Int {
    range > 0 ? 90 + 20 * moved / range : 100
  }

  /// Damage scales with the battle's
  /// intensity, in percent: 92 in the first
  /// round (100 ticks), 1 more each round
  /// after, uncapped, so fights end.
  static func intensity(
    at tick: Int
  ) -> Int {
    92 + tick / 100
  }

  /// What `ability` used by `unit` does
  /// before it meets a layer: its power,
  /// scaled by the unit's expertise in its
  /// discipline, then by intensity.
  static func damage(
    _ ability: Ability,
    by unit: Unit,
    intensity: Int
  ) -> Int {
    let skill = expertise(
      unit.level(ability.discipline)
    )
    return ability.power * skill / 100
      * intensity / 100
  }
}
