# Brainstorm

Working notes from the first design
conversation. Nothing here is final: it records
where the ideas stand, what was ruled out and
why, and what is still open. When something is
decided, it moves into a real design doc.

Working title: **Seven Hours**, aboard the ship
***Lullaby***. Tagline idea: *"One night. Three
hundred years."*

---

## Where this came from

The game grew out of a Pokémon romhack fork
(`pokeemerald-expansion`) whose Battle Factory
turned out to be the fun part. What made it fun:

- **Deterministic battles.** Speed decides who
  moves first, damage is fixed, abilities always
  do the same thing. A battle becomes a
  perfect-information puzzle, a "zen clean-up",
  almost like solitaire.
- **Drafting and swapping.** Draft a team, fight,
  swap one in from the team you beat.
- **Damage previews as ranges.** The fork shows
  damage as a range ("34–56%", "KO", "0%
  immune", "100% Sturdy") because the player
  doesn't know the foe's hidden stats. The
  outcome is fixed; only the player's knowledge
  is uncertain.

The goal is to keep that feeling in an original
game: no Pokémon, no combat, own IP that can ship
on the App Store.

## Design pillars

1. **Determinism.** No dice. Every outcome
   follows from the rules and the state.
   Uncertainty only ever comes from what the
   player doesn't know yet.
2. **Perfect information where it counts.**
   Hazards show what they will do next (like Into
   the Breach and Slay the Spire).
3. **Planning over reflexes.** Time is paused
   while you plan. Nothing happens until you
   commit.
4. **No grind.** No levels, no XP, no clearing a
   field by hand, no "come back in 4 hours"
   timers, no waiting.
5. **Never solve the same problem twice.** Once a
   kind of problem is solved, the robots handle
   it. Every visit brings something new.
6. **Cozy, not stressful.** Player against the
   elements, never against rivals. No horror.
   Nobody ever dies.
7. **No dialogue.** No talking characters, no
   cutscenes. Story comes through the
   environment and documents.

## Premise

A **sleeper ship**, a small spherical ship (a
scaled-down Death Star, but not built for evil),
is carrying its passengers to a destination
light-years away. The passengers are asleep the
whole voyage and never wake during the game.

The player is the ship's **maintenance system**.
It sleeps too, and wakes only when a problem
needs attention. Cute modular robots do the
physical work.

### Why sleep, even if aging were solved

Not something the game explains out loud. One
cheerful "passenger handbook" document in the
Files program would cover it.

- **Supplies.** Awake people need food, water and
  life support for centuries. Sleepers need a
  fraction, so the ship is lighter and needs
  less fuel.
- **Boredom and isolation.** Centuries in a metal
  sphere wear people down. Sleep makes the
  voyage feel like one night.
- **Social drift.** An awake society changes in
  transit. Sleepers arrive with the purpose they
  left with.
- **Space.** Pods pack densely; living quarters
  don't.
- **Risk.** Not aging isn't not dying. Sleepers
  ride in the safest part of the ship.
- **Not losing the time.** Arrive with your life
  ahead of you, alongside the people you left
  with.

The tone to keep: the ship carries what the
passengers need for *arrival*, and they *chose*
to sleep through the trip. The robots and the
maintenance system sleep between problems for the
same reason: saving their strength for arrival.

### Stakes without stress

Failure can never mean a passenger dies. The ship
has redundancy. A failed attempt means the
problem persists, a system degrades, or resources
are lost, and you can retry. Pods might drop into
a safe mode that costs something, but nobody is
harmed.

## What the player is

Deliberately **not** "an AI". There is real
stigma against AI, especially among gamers, and
"AI in training" was ruled out. "Agent" is also
out.

- **Leave the player unnamed.** You are whoever
  is at the keyboard. The game never says whether
  that is a program, a person on a distant
  console, or the ship itself.
- The *system* gets a mechanical name in the UI,
  e.g. **WATCHDOG** (a real computer part that
  idles and wakes when something goes wrong) or
  **MAINT**. Don't use "Watchdog" as the game
  title: too close to Ubisoft's *Watch Dogs*.
- **Recovery, not learning.** The ship's computer
  was damaged or partly shut down for the voyage.
  Restoring a ship section brings back part of
  its archives, so new commands and programs are
  *recovered* or *installed*, never *learned*.
- **The robots carry the warmth.** Cute,
  non-verbal (beeps, expressions, body language),
  like WALL-E, R2-D2, BB-8. Charming machines,
  not minds.

### Vocabulary

| Avoid | Use instead |
|---|---|
| AI, agent, intelligence | system, terminal, console |
| learn, train | recover, install, restore |
| think, decide | run, compute, process |
| simulation | dry run, projection, forecast |

## Structure

### Seven hours, seven wakes

The title doubles as the structure. For the
passengers, the voyage is one night's sleep.

- **Seven chapters, one per "hour" of the
  night.** Each chapter is a wake-up: 11 p.m.,
  midnight, 1 a.m., …
- **Each wake opens with a boot sequence.**
  BIOS-style screen, memory count, startup chime.
  The ship's clock shows the hour of the night;
  the voyage counter shows how many years have
  actually passed.
- **Between wakes, years pass.** Shown as a
  starfield screensaver. No clock, nothing to
  wait for.
- **The ship changes while you sleep.**
  Hydroponics has grown, something has worn out,
  a repair has held or settled.
- **Dawn is arrival.** The last hour ends at
  morning, when the passengers wake. That is the
  ending.

### The ship is the map

A sphere of decks, opened up section by section,
metroidvania-style. Candidate sections:

- **Cryo bay.** The passengers. The heart of the
  stakes.
- **Hydroponics.** Healing terrain, growing
  between wakes.
- **Reactor and engines.** Heat, energy, vents.
- **Fabrication.** Building robots and modules
  (the "workshop").
- **Observatory.** Charting the voyage;
  starlight.
- **Cargo and drone bay.** Launch point for
  asteroid stops.

Restoring a section changes it into a resource:
a repaired greenhouse becomes healing ground, a
rebuilt solar array becomes a starlight field.

### Content economy: rooms in states, not missions

The problem with lots of missions: similar ones
get tedious, procedural ones get repetitive, and
unique ones are expensive and often unseen
(everyone plays Mario 1-1; few see 5-3, and warp
pipes skip it).

The answer: **10–15 hand-made sections that every
player visits**, each visited **several times in
different states**:

1. **Broken.** First visit: get it running.
2. **Restored, then disrupted.** A later event
   brings a new problem to the same room.
3. **Repurposed.** A harder challenge that uses
   what you built there.

The layout costs once; the visits differ because
the room has changed and so has your toolkit.
Rough sizing: ~12 sections × 3 states ≈ 36
encounters, a 15–25 hour game.

### Deep space as seasons

What is outside the ship changes how the same
rooms play:

- **Passing a red dwarf.** Heat, strong
  starlight, overheating.
- **A nebula.** Dust in the vents, conductive
  surfaces, poor visibility.
- **Deep void.** Cold, no starlight, energy
  scarcity.
- **A rogue planet's gravity well.** Shifting
  gravity: elevation and low-g zones matter.

### Asteroid stops

The "mines": away missions for elements and
compounds. Keep to a handful of distinct
**asteroid types**, each its own terrain set and
each new the first time:

- **Iron-rich.** Heavy, magnetic.
- **Icy comet.** Coolant, slippery surfaces,
  water.
- **Carbon-rich.** Dust, organics, compounds.

Rarer elements come from specific types, giving a
reason to visit each.

## The encounter

The core of the game, and the part to prototype
first once the design settles.

### What you play against

**The ship's own decay and the environment**, not
opponents. Leaking coolant, power surges, debris,
vacuum breaches, failing heat regulation, gas,
cave-ins on asteroids. Hazards follow rules and
**show their next action in advance**.

Rivals (another AI's crew, competing contests)
were considered and ruled out as too stressful.

### Objectives, not kills

- Extract ore from marked spots before a cave-in
  reaches them.
- Seal vents while a gas cloud spreads.
- Shield a structure through a debris shower.
- Get a heavy drill across a field.

### Movement: free-form, like Divinity: Original Sin 2

- No grid or hexes on screen. Robots move freely,
  limited by distance per round.
- **Underneath, whole-number coordinates**, so
  dry runs and replays are exact and testable.
- Touch controls: drag a ghost of the robot,
  show the reachable area as a shaded region,
  snap to useful spots (cover, a vent's edge).

### Elevation without 3D

Height is a property of the ground, not a real
third axis. FFTA did height with 2D sprites on an
isometric map. Areas have a height value, shown
with shading and shadows:

- **High ground:** longer range, better views.
- **Falling:** cliff edges are dangerous.
- **Low-gravity zones:** robots jump further but
  drift; heavy chassis stay planted.

### The round: 100 ticks

Like a D&D round representing ~6 seconds, a round
here is **100 ticks**.

1. **Plan (paused).** Queue each robot's actions
   within its 100 ticks: movement costs ticks per
   distance, abilities cost ticks.
2. Hazards' actions sit on the same timeline,
   visible ("cave-in at tick 60, here").
3. **Dry run.** Preview the whole round. It's
   deterministic, so the dry run *is* the
   result, as far as your knowledge goes (see
   ranges below).
4. **Commit**, and watch the ~6 seconds play out
   in real time.

Speed = how much a robot fits into its 100 ticks.
Timing becomes the puzzle: can the shield go up
at tick 55, before the cave-in at 60?

A **timeline scrubber** lets you drag back and
forth through the ticks, both while planning and
while watching. That is the "fourth dimension":
time as something you can look along, and
mistakes in a dry run cost nothing.

### Robot meters: energy and integrity

Two meters instead of HP:

- **Energy** (like mana) powers abilities.
  Running out = **shutdown**: the robot skips
  turns until recharged. Not a loss.
- **Integrity** (health). At zero the robot is
  disabled and towed home for repair. Nothing is
  ever permanently lost.

Abilities that work across the meters or between
robots:

- **Overclock:** spend integrity to gain energy.
- **Shields:** spend energy to absorb damage to
  integrity. ("Plasma shield", like Protect /
  Reflect.)
- **Power transfer:** pass energy to an adjacent
  robot. The game's "ramp"; rewards positioning.
- **Nano swarm:** restores integrity each turn
  (like Leftovers).

### Specialties (the "types")

Drill, Cryo, Solar, Magnet, Builder, Scanner,
Thermal, … Each strong against certain hazards
and materials (Cryo cools a thermal vent; Magnet
sorts a metal-rich debris field). Status
conditions: overheated, dust-clogged, low power,
frozen joints.

### Terrain and surfaces

Terrain is the energy map:

- **Starlight** recharges Solar robots.
- **Thermal vents** recharge Thermal robots and
  may damage others.
- **Ice** cools overheated robots.
- **Hydroponics / plant growth** heals (like
  Grassy Terrain).

**Surfaces** (from DOS2): abilities and hazards
leave areas on the ground that interact,
deterministically and combo-ably:

- Spilled coolant freezes into ice; ice plus a
  thermal vent becomes steam, which blocks sight.
- Conductive dust plus a discharge spreads
  energy, good or bad depending on who's in it.
- A plasma field burns integrity but charges
  plasma-type robots.

Terrain becomes something you *create*
mid-encounter, not just a map property.

### Hardware and software: the EDH layer

The feel of Magic's Commander (EDH): build around
an identity, assemble an engine that does
something absurd. But with **no draw and no
shuffle**: your whole library is always
available, and you pick what to do each turn.

- **Modules are hardware**, mounted on robots:
  nano swarm, heat resistance, drill arm, solar
  panels, power coupler. They decide what a robot
  *can* do; many are passive.
- **Programs are software**, loaded into the
  system's memory: Overclock, Reroute Power,
  Coordinated Lift, Emergency Shield. They're
  what you can *tell* robots to do. **The library
  is your collection of programs.**
- A program needs the right hardware to run
  (Reroute Power needs a power coupler), so
  programs and modules must be built to work
  together. Synergy across two layers.
- **A commander:** a lead robot or core module
  that defines the build's identity, like color
  identity (a Solar commander allows Solar
  modules).
- **Triggered effects make engines:** "whenever
  a robot gains energy, the nano swarm repairs
  1". Deterministic, so combos can be counted
  exactly.

### Keeping choices interesting without a draw

Without Magic's draw, one best play could repeat
every turn. Constraints that prevent it:

- **Energy cost.** The best abilities are
  expensive.
- **Cooldowns.** A used ability rests for a
  visible number of turns.
- **Position.** Abilities only work from certain
  spots, ranges or adjacencies.
- **Processing power** (below).

### Memory and processing power

Two resources of the system itself:

- **Memory = what you bring.** How many programs
  you can load into an encounter from your
  library. The deckbuilding constraint.
- **Processing power = what you can do per
  round.** How many commands you can issue. The
  "pick X" constraint.

Both grow over the voyage as sections are
restored (memory more often than processing).
Key tension: **your robots can do more than you
can command.** Robots you don't command fall back
on passive modules, so a robot built to run
itself is valuable.

### Chassis and module slots

The chassis decides the cap:

- **Small: 2 slots.** Fast, light.
- **Medium: 3 slots.** All-rounder.
- **Large: 4 slots.** Slow, heavy (matters with
  gravity).

### Team size

**3–4 robots deployed, more at home.** Keeps a
round readable on a phone. With the processing
limit, a fourth robot only earns its place if it
can look after itself.

### Resource warning

That's five resources: energy, integrity, ticks,
processing, memory. Each has a distinct job, but
it's a lot to teach. Introduce them over the
first missions; keep only energy and integrity
always on screen.

## Knowledge and ranges

Straight from the fork's damage preview: outcomes
are fixed, knowledge is incomplete, so **the dry
run shows ranges where you don't know enough.**

- "Drilling this plate: 34–56% through." (Exact
  hardness unknown.)
- "Coolant spread: reaches 2–4 m." Shown as a
  soft area that tightens as you learn.
- "Bulkhead holds." (The Sturdy case.)
- "No effect." (Immunity.)
- "Sealed." (Certain success: the KO case.)

### Narrowing ranges is progression

- **Scanning** narrows a range before you act.
  Costs ticks and processing: information has a
  price.
- **Observing** one interaction narrows it. The
  first drill strike reveals real hardness; the
  rest of the plan becomes exact. (What
  competitive Pokémon players do when working out
  a foe's spread from damage taken.)
- **Knowledge is kept forever** in the Records
  database. Once titanium plating's response to
  drilling is measured, every future dry run with
  it is exact.
- The **periodic table** fits here: studying an
  element reveals its properties (conductivity,
  melting point, hardness), removing uncertainty
  from every plan using it.

**Knowledge is the level-up.** The system doesn't
get stronger; it gets more *certain*. Early dry
runs are full of ranges; late ones are mostly
exact, with ranges only from new things.

### Ranges bring back the tension

"Free, exact simulation" risks trial and error.
Ranges fix that:

- **Full knowledge:** a commit is guaranteed. The
  calm end of a puzzle.
- **A range:** a commit is a judgment call. Spend
  ticks scanning, add insurance, or trust it?
  Playing around a possible Focus Sash, with no
  dice.
- **A gamble that falls short is gentle:** the
  problem persists, a little is lost, and you now
  know the exact value.

### One change from the fork

The fork treats unrevealed abilities and items as
absent, so its range can be confidently wrong.
Fine in Pokémon, where the opponent hides
information. Here, **unknowns must be visible**:
a "?" on an unscanned hazard, or an honestly
wider range. The dry run never claims certainty
it doesn't have. A surprise is always the
player's choice not to scan.

### Elegance, optionally

Solving is guaranteed eventually, so satisfaction
can also come from solving *well* (fewer
resources, less integrity lost, fewer ticks).
Zachtronics-style histograms comparing your
solution to others': quiet, optional, not a
leaderboard.

## Progression without grind

- **No levels.** Robots improve through modules
  you build and swap: more options, not bigger
  numbers.
- **Unlocks drive progress:** recovered programs,
  new modules, new elements, new ship sections.
  Advance by knowing more and having more tools
  (Outer Wilds, Baba Is You), not by repetition.
- **Elements pay for building.** Common ones
  build bodies (iron, silicon for chassis; copper
  for wiring); rarer ones build modules (helium-3
  for power cores, rare earths for magnets);
  specific ones drive specialties (a Cryo module
  needs something only the ice shelf / icy comet
  gives).
- **The periodic table is the collection.**
  Filling it in element by element is the same
  pull as completing a Pokédex.
- **Solved problems stay solved.** The robots
  handle them from then on. (A light form of
  automation, rather than scripts you write.)

## The interface: a retro desktop OS

2026 has a lot of Windows 98 / XP nostalgia. The
UI is an **original** late-90s-style OS (beveled
grey windows, taskbar, Start button) with its own
name, logo and sounds, e.g. **"LullabyOS 98"**.
Do **not** copy Microsoft's look, logo or startup
sound (trademark risk).

### Programs are the game's systems

| Program | Role |
|---|---|
| Terminal | Deeper commands for power users |
| Ship Map | Decks: what's restored, where problems are |
| Dry Run | The tactics view: plan, scrub, commit |
| Fabricator | Build robots and modules |
| Element Table | The periodic table collection |
| Records | Knowledge database: hazards, materials |
| Replay Player | Watch saved runs, export clips |
| Files | The story: crew documents, photos, notes |

### OS moments as story beats

- **Install wizards** for recovered programs
  (progress bar, "Next >", "Finish"); new icons
  appear on the desktop and in the Start menu.
- **Problems arrive as error pop-ups:** "Warning:
  Coolant pressure low on Deck 3." That starts an
  encounter.
- **Boot sequence** opens each wake.
- **Screensaver** (starfield) shows the years
  passing between wakes.
- **Corrupted files** become readable as archives
  are restored: the gentle mystery, told through
  documents with no dialogue.

### Easter eggs

- A **solitaire** program: a nod to the fork's
  "Pokémon solitaire" feeling.
- A **Minesweeper-like** program: the same skill
  as scanning, inferring the hidden from the
  visible.

### The terminal

Still there, but one program among many. Typing
on a phone is miserable, so it should *look*
typed while you tap command chips that
autocomplete.

## Replays and sharing

- **A replay is tiny:** starting state + list of
  commands; the viewer's device re-runs it. A
  short code or link, not a video file.
- **Video export** for social: a mission's
  ~6-second rounds strung together is a 30–60
  second clip. Slow-mo on key moments, a camera
  that follows the action, surface effects
  (steam, ice, plasma) to make it pretty.
- **The voyage log:** every committed run is
  saved; at arrival, a closing montage of the
  whole journey.

## Naming

- **Title (favourite): *Seven Hours*.** A full
  night's sleep; gives the seven-wake structure;
  dawn = arrival. Spell it out (not "7 Hours").
  It's a plain phrase, so check the App Store and
  Steam for clashes before settling.
- **Ship: *Lullaby*.** "Welcome aboard the
  *Lullaby*."
- **Tagline:** "One night. Three hundred years."
- **Also liked:** *Quiet Hours* (when everyone is
  asked to keep it down so others can sleep),
  *Wee Hours*, *Off Hours* (when only maintenance
  is around), *Small Hours*, *Pilot Light*,
  *1024 Sleepers* (1024 passengers; a classic
  computer number).
- **Avoid:** *Watchdog* (Watch Dogs), *3 A.M.*
  (horror associations online), *Dark Hours*,
  *Lonely Hours*, *Long Hours*.
- **Use a codename** for the repo, the app's name
  in code and the bundle ID (e.g. `lullaby`). The
  bundle ID can never change once the app exists
  in App Store Connect; the App Store display
  name can change any time.

## Ideas considered and set aside

- **Contests / a dance battle on a tug-of-war
  meter** (one shared meter starting at 50, each
  move pushes it). Liked, but the theme moved on;
  the tug-of-war may still be useful somewhere.
- **Rival AIs / competing crews.** Too stressful.
- **Mining an asteroid as the main setting.** The
  abandoned ship is better; asteroids became the
  stops.
- **Terraforming a planet.** Too big in scale.
- **Writing automation routines** (gambit lists
  or code). Replaced by "solved problems stay
  solved".
- **"AI in training" framing.** Stigma; replaced
  by an unnamed player and recovery.
- **Waking crew / dialogue.** Passengers stay
  asleep; no writing for characters.
- **Grid or hex movement.** Replaced by
  free-form.

## Open questions

- What does a typical encounter look like round
  by round? (One room, one problem, two robots, a
  couple of unknowns: the next thing to work
  through.)
- Commands per round: a shared pool for the whole
  team, or does every robot act once?
- What is the voyage *for*? The destination
  decides the ending and what "fully restored"
  means.
- How much does the ship change between wakes,
  and what changes it?
- Portrait or landscape? The desktop look suits
  landscape; one-handed phone play suits
  portrait.
- Art style for the chibi robots and the Dry Run
  view (pixel art vs. vector).
- How do Records and scanning surface uncertainty
  visually in a free-form space?
- Do some encounters refuse "stays solved" (hand
  crafted puzzles, like the fork's Arena idea of
  "win in N turns")?

## Technical notes

- **Built on `gastly92/ios-template`:** SwiftUI,
  developed entirely from an iPhone, CI on
  GitHub's macOS runners, TestFlight to the
  phone, App Store pipeline included.
- **Engine as a pure Swift package** with no UI:
  robots, abilities, hazards, ticks, resolution.
  Rewrite the rules; don't port the fork's C
  code. A pure package might even build and test
  on Linux (`swift test`), unlike the app.
- **SwiftUI for the OS** (windows, wizards,
  dialogs) snapshot-tests easily. **The Dry Run
  view likely needs SpriteKit** (free movement,
  surfaces, effects), which fights the template's
  100% coverage gate. Contain it to one program.
- **Determinism in practice:** whole-number maths
  (no floating point) so results match on every
  device; every replay records the rules version
  it was played under, since rule changes break
  old replays.
- **A solver** can check every scenario is
  solvable and estimate difficulty, the same way
  a matchup simulation could balance the fork.
- **Art is the real bottleneck.** The retro OS
  is mostly text and simple shapes; the robots
  are the main art cost. Placeholders are fine
  for a prototype.

## Games to look at

- **Into the Breach:** deterministic tactics,
  enemy intents shown in advance.
- **Final Fantasy Tactics Advance:** isometric
  tactics, height with 2D sprites.
- **Divinity: Original Sin 2:** free-form
  movement, surfaces that interact.
- **Slay the Spire:** visible intents; map
  route-planning.
- **Magic: the Gathering (Commander / EDH):**
  identity-based building, engines and combos.
- **Zachtronics games:** optional solution
  histograms.
- **Outer Wilds, Baba Is You:** progress by
  knowledge, not stats.
- **Stardew Valley:** the cozy home-base rhythm.
- **Hypnospace Outlaw, Emily Is Away, Her
  Story:** games played inside an old OS.
