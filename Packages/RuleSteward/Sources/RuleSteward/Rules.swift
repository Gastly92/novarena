/// The formulas, in whole numbers, rounded
/// down.
enum Rules {
  /// The wait after acting, in ticks:
  /// 10,000 ÷ Speed, scaled by the action's
  /// weight. Speed 100 waits 100 ticks.
  static func wait(
    speed: Int,
    weight: Weight
  ) -> Int {
    10_000 * weight.percent / (speed * 100)
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

  /// What `ability` from `attacker` does to
  /// `target`, before shields:
  /// Power × Offense ÷ (100 + Defense),
  /// then the target's affinity for the
  /// element, then intensity.
  static func damage(
    _ ability: Ability,
    from attacker: Stats,
    to target: Unit,
    intensity: Int
  ) -> Int {
    let physical = ability.delivery
      == .physical
    let offense = physical
      ? attacker.attack : attacker.magic
    let defense = physical
      ? target.stats.armor
      : target.stats.resistance
    var hit = ability.power * offense
      / (100 + defense)
    if let element = ability.element,
      let affinity =
        target.affinities[element] {
      let (top, bottom) = affinity.factor
      hit = hit * top / bottom
    }
    return hit * intensity / 100
  }
}
