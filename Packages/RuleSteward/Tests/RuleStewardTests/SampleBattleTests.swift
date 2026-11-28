import RuleSteward
import XCTest

/// The four sample units, played with the
/// plain stand-in choices to the end. The
/// whole log is pinned, so any rule change
/// shows up here, line by line, as a change
/// in how this fight plays out.
final class SampleBattleTests: XCTestCase {
  func testFourSampleUnits() {
    var battle = Battle(
      party: [.gerald, .oswin],
      foes: [.ashka, .kestrel]
    )
    battle.playPlainly()
    XCTAssertEqual(
      Fixtures.lines(battle), sampleLog
    )
  }
}

/// What the sample battle's log reads.
private let sampleLog = [
  "[95] Gerald",
  "  Gerald moves to (600, 200)",
  "[111] Ashka",
  "  Ashka moves to (717, 333)",
  "  Ashka: Fireball → Oswin",
  "  Oswin's Tower Shield -150 (0)",
  "[121] Kestrel-9",
  "  Kestrel-9 moves to (912, 556)",
  "  Kestrel-9: Arc Beam → Gerald",
  "  Oswin guards Gerald",
  "  Oswin's Mail -66 (44)",
  "[125] Oswin",
  "  Oswin moves to (510, 452)",
  "[199] Gerald",
  "  Gerald moves to (642, 248)",
  "  Gerald: Lunge → Ashka",
  "  Ashka's Ember Hide -111 (119)",
  "  Gerald: Pommel Strike → Ashka",
  "  Ashka's Ember Hide -13 (106)",
  "[234] Kestrel-9",
  "  Kestrel-9: Arc Beam → Gerald",
  "  Oswin guards Gerald",
  "  Oswin's Mail -44 (0)",
  "  Oswin's Body -23 (37)",
  "[262] Oswin",
  "  Oswin moves to (606, 397)",
  "  Oswin: Shield Bash → Ashka",
  "  Ashka's Ember Hide -65 (41)",
  "[289] Ashka",
  "  Ashka's Ember Hide regrows +15 (56)",
  "  Ashka: Fireball → Gerald",
  "  Gerald's Plate -118 (72)",
  "[331] Gerald",
  "  Gerald moves to (817, 448)",
  "  Gerald: Lunge → Kestrel-9",
  "  Kestrel-9's Energy Shield -100 (0)",
  "  Gerald: Pommel Strike → Kestrel-9",
  "  Kestrel-9's Plating -13 (117)",
  "[343] Kestrel-9",
  "  Kestrel-9: Arc Beam → Gerald",
  "  Oswin guards Gerald",
  "  Oswin's Body -37 (0)",
  "  Oswin is exposed",
  "[352] Oswin",
  "  Oswin: Shield Bash → Ashka",
  "  Ashka's Ember Hide -56 (0)",
  "  Ashka is exposed",
  "[436] Oswin",
  "  Oswin: Shield Bash → Ashka",
  "  Ashka is knocked out",
  "[452] Kestrel-9",
  """
    Kestrel-9's Energy Shield \
  recharges +40 (40)
  """,
  "  Kestrel-9: Piston Fist → Gerald",
  "  Oswin guards Gerald",
  "  Oswin is knocked out",
  "[481] Gerald",
  "  Gerald: Sword Cut → Kestrel-9",
  "  Kestrel-9's Energy Shield -40 (0)",
  "  Gerald: Pommel Strike → Kestrel-9",
  "  Kestrel-9's Plating -13 (104)",
  "[561] Kestrel-9",
  "  Kestrel-9: Arc Beam → Gerald",
  "  Gerald's Plate -69 (3)",
  "[566] Gerald",
  "  Gerald: Lunge → Kestrel-9",
  "  Kestrel-9's Plating -87 (17)",
  "  Gerald: Pommel Strike → Kestrel-9",
  "  Kestrel-9's Plating -13 (4)",
  "[670] Kestrel-9",
  "  Kestrel-9: Piston Fist → Gerald",
  "  Gerald's Plate -3 (0)",
  "  Gerald's Body -55 (5)",
  "[694] Gerald",
  "  Gerald: Lunge → Kestrel-9",
  "  Kestrel-9's Plating -4 (0)",
  "  Kestrel-9's Frame -40 (0)",
  "  Kestrel-9 is exposed",
  "  Gerald: Pommel Strike → Kestrel-9",
  "  Kestrel-9 is knocked out",
  "The party wins",
]
