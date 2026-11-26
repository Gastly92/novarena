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
  "[105] Gerald",
  "  Gerald moves to (500, 200)",
  "[111] Ashka",
  "  Ashka moves to (1023, 200)",
  "  Ashka: Fireball → Gerald",
  "  Oswin guards Gerald",
  "  Oswin -97 (283)",
  "[117] Kestrel-9",
  "  Kestrel-9 moves to (883, 478)",
  "  Kestrel-9: Arc Beam → Gerald",
  "  Gerald -59 (241)",
  "[125] Oswin",
  "  Oswin moves to (377, 496)",
  "[210] Gerald",
  "  Gerald moves to (767, 394)",
  "  Gerald: Lunge → Kestrel-9",
  "  Kestrel-9's shield -52 (98)",
  "[234] Kestrel-9",
  "  Kestrel-9: Arc Beam → Gerald",
  "  Oswin guards Gerald",
  "  Oswin -48 (235)",
  "[250] Oswin",
  "  Oswin moves to (604, 392)",
  "[277] Ashka",
  "  Ashka: Fireball → Gerald",
  "  Gerald -120 (121)",
  "[351] Kestrel-9",
  "  Kestrel-9: Arc Beam → Gerald",
  "  Oswin guards Gerald",
  "  Oswin -49 (186)",
  "[367] Gerald",
  "  Gerald moves to (933, 269)",
  "  Gerald: Lunge → Ashka",
  "  Ashka -76 (244)",
  "[375] Oswin",
  "  Oswin moves to (732, 431)",
  "  Oswin: Shield Bash → Kestrel-9",
  "  Kestrel-9's shield -19 (131)",
  "[443] Ashka",
  "  Ashka: Fireball → Gerald",
  "  Oswin guards Gerald",
  "  Oswin -100 (86)",
  "[468] Kestrel-9",
  "  Kestrel-9 moves to (899, 409)",
  "  Kestrel-9: Piston Fist → Gerald",
  "  Gerald -32 (89)",
  "[468] Oswin",
  "  Oswin moves to (742, 430)",
  "  Oswin: Shield Bash → Kestrel-9",
  "  Kestrel-9's shield -20 (111)",
  "[524] Gerald",
  "  Gerald: Lunge → Ashka",
  "  Ashka -78 (166)",
  "[561] Oswin",
  "  Oswin: Shield Bash → Kestrel-9",
  "  Kestrel-9's shield -20 (91)",
  "[585] Kestrel-9",
  "  Kestrel-9: Arc Beam → Gerald",
  "  Oswin guards Gerald",
  "  Oswin -50 (36)",
  "[609] Ashka",
  "  Ashka: Claw → Gerald",
  "  Oswin guards Gerald",
  "  Oswin -17 (19)",
  "[654] Oswin",
  "  Oswin: Shield Bash → Kestrel-9",
  "  Kestrel-9's shield -20 (71)",
  "[681] Gerald",
  "  Gerald: Lunge → Ashka",
  "  Ashka -79 (87)",
  "[702] Kestrel-9",
  "  Kestrel-9: Piston Fist → Gerald",
  "  Oswin guards Gerald",
  "  Oswin -19 (0)",
  "  Oswin is down",
  "[720] Ashka",
  "  Ashka: Fireball → Gerald",
  "  Gerald -89 (0)",
  "  Gerald is down",
  "The foes win",
]
