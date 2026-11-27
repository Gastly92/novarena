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
  "  Oswin's Tower Shield -140 (0)",
  "[121] Kestrel-9",
  "  Kestrel-9 moves to (912, 556)",
  "  Kestrel-9: Arc Beam → Gerald",
  "  Oswin guards Gerald",
  "  Oswin's Mail -61 (49)",
  "[125] Oswin",
  "  Oswin moves to (510, 452)",
  "[190] Gerald",
  "  Gerald moves to (642, 248)",
  "  Gerald: Lunge → Ashka",
  "  Ashka's Ember Hide -111 (129)",
  "[242] Kestrel-9",
  "  Kestrel-9: Arc Beam → Gerald",
  "  Oswin guards Gerald",
  "  Oswin's Mail -49 (0)",
  "  Oswin's Body -13 (47)",
  "[250] Oswin",
  "  Oswin moves to (606, 397)",
  "  Oswin: Shield Bash → Ashka",
  "  Ashka's Ember Hide -65 (64)",
  "[277] Ashka",
  "  Ashka: Fireball → Gerald",
  "  Gerald's Plate -118 (122)",
  "[332] Gerald",
  "  Gerald moves to (817, 448)",
  "  Gerald: Lunge → Kestrel-9",
  "  Kestrel-9's Energy Shield -100 (0)",
  "[343] Oswin",
  "  Oswin: Shield Bash → Ashka",
  "  Ashka's Ember Hide -66 (13)",
  "[363] Kestrel-9",
  "  Kestrel-9: Arc Beam → Gerald",
  "  Oswin guards Gerald",
  "  Oswin's Body -47 (0)",
  "  Oswin is exposed",
  "[436] Oswin",
  "  Oswin: Shield Bash → Ashka",
  "  Ashka's Ember Hide -13 (0)",
  "  Ashka is exposed",
  "[443] Ashka",
  "  Ashka: Claw → Oswin",
  "  Oswin is knocked out",
  "[474] Gerald",
  "  Gerald moves to (791, 418)",
  "  Gerald: Sword Cut → Ashka",
  "  Ashka is knocked out",
  "[484] Kestrel-9",
  "  Kestrel-9 moves to (886, 526)",
  "  Kestrel-9: Piston Fist → Gerald",
  "  Gerald's Plate -57 (65)",
  "[569] Gerald",
  "  Gerald: Sword Cut → Kestrel-9",
  "  Kestrel-9's Energy Shield -40 (0)",
  "[605] Kestrel-9",
  "  Kestrel-9: Arc Beam → Gerald",
  "  Gerald's Plate -64 (1)",
  "[664] Gerald",
  "  Gerald: Lunge → Kestrel-9",
  "  Kestrel-9's Plating -87 (33)",
  "[726] Kestrel-9",
  "  Kestrel-9: Piston Fist → Gerald",
  "  Gerald's Plate -1 (0)",
  "  Gerald's Body -58 (2)",
  "[806] Gerald",
  "  Gerald: Lunge → Kestrel-9",
  "  Kestrel-9's Plating -33 (0)",
  "  Kestrel-9's Frame -40 (0)",
  "  Kestrel-9 is exposed",
  "[847] Kestrel-9",
  "  Kestrel-9: Piston Fist → Gerald",
  "  Gerald's Body -2 (0)",
  "  Gerald is exposed",
  "[948] Gerald",
  "  Gerald: Sword Cut → Kestrel-9",
  "  Kestrel-9 is knocked out",
  "The party wins",
]
