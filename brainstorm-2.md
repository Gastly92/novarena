# Brainstorm 2: The Arena

Working notes from the second design
conversation. The game has pivoted from the
sleeper ship ([brainstorm.md](brainstorm.md)) to
an **endless, turn-based tactics game with
roguelike runs**: a clan of named heroes fights
gladiator-style against random teams of foes.
Nothing here is final.

---

## Where this came from

The same root as the first brainstorm: the Battle
Factory in the `pokeemerald-expansion` fork. The
ship idea turned the fun parts (determinism,
range previews, drafting) against the
environment. This version puts them back where
they started: **against opponents**.

## Pillars

Carried over from brainstorm 1:

1. **No dice mid-battle.** No hit/miss rolls, no
   random crits. Outcomes follow from rules and
   state.
2. **Randomness lives between fights.** Which
   foes you draw, which recruits and rewards are
   offered. The Battle Factory split.
3. **Planning over reflexes.** Turn-based; nothing
   happens until you commit.
4. **Damage previews as ranges** while a foe's
   stats are unknown, exact once they are known.

Changed:

- **Rivals are back.** You fight opponents. The
  "cozy, nobody dies, no rivals" pillar is
  dropped.
- **Leveling is in.** Brainstorm 1 ruled out
  levels and XP; here, collecting heroes,
  leveling them and unlocking their upgrades is
  part of the fun.

## Theme

All of fantasy, past, present and future, mixed
freely: mouse knights, robot mech droids, ice
wizards, a rebirth phoenix, all in one arena.

No extra structure (factions, eras, an in-world
reason) is needed to make the mix work. Magic: the
Gathering mixes everything and is fine.

## Heroes and the clan

- **Like FFTA's clan.** You build up a roster of
  fighters over time, not a deck.
- **No cards.** No card frames, no deck, no draw.
  Heroes are clan members.
- **Every hero is named.** Not "Mouse Knight" but
  *Gerald*, a mouse knight. There can be other
  mouse knights, each their own person with their
  own name (and presumably their own kit).
- **Collecting them all** is a goal in itself.
- **Hand-made, one of a kind.** Every hero is
  designed by hand: name, look, kit. No generated
  heroes or name variants. A fixed roster to
  collect, which makes each one worth having
  (and makes art and writing the main cost).
- **Two ways to gain heroes:**
  - **Recruit from teams you beat**, the Battle
    Factory swap.
  - **Buy with currency.**

## The fight

- **Everyone fights.** Every fighter you bring
  enters the arena. No bench, no sitting out:
  games that don't let you use everyone are less
  fun.
- **Fight size isn't capped by the screen.** The
  battlefield can be panned, so large fights are
  fine on a phone.
- **You command everyone.** Every hero's turn is
  yours to play; no hero runs on autopilot.
- **The player is not on the field.** You command
  from outside, but can still reach in with
  commander actions (see
  [Commander actions](#commander-actions)).

## Battle system (proposal)

A first full pass, combining the options from the
design conversation. They turned out not to be
mutually exclusive; each answers a different
question. Everything here is a starting point to
prototype, not a decision.

### What it has to work with

A **2D or 2.5D game of sprites** built from a
phone (SwiftUI app, SpriteKit for the battle
view, CI does the building). So:

- **A flat arena seen from a 3/4 top-down
  angle**, sprites sorted by their y position so
  nearer ones draw in front. No 3D.
- **Sprites face left or right only**, mirrored.
  One idle, one move, one attack and one hit
  animation per hero is a workable floor. Four
  or eight facings would multiply the art for
  little gain.
- **Height is a property of the ground** (a
  raised platform, a pit), drawn with shading
  and a drop shadow, as in brainstorm 1.

### Shape of a fight

1. **Scout.** Before the fight you see the arena
   and the foe team: names, looks and any trait
   that is always visible (see
   [What you can see](#what-you-can-see)).
2. **Deploy.** Place your heroes anywhere in your
   starting zone.
3. **Fight.** Heroes act one at a time in
   timeline order (below). On a hero's turn it
   can **move up to its Move distance and take
   one action**, in either order, and may split
   its movement around the action.
4. **End.** The fight ends when one side has
   nobody standing.

### Speed and the timeline

Speed is a stat, and it decides both turn order
and **how often** a hero acts: faster heroes get
slightly more turns. This is the "charge time"
family (FFT, FFX), and it makes time magic one of
the most important kinds of ability.

- **Every hero has a next-turn time** on a shared
  clock measured in ticks.
- **After acting, a hero's next turn is
  `10000 ÷ Speed` ticks later** (whole numbers,
  rounded down). Speed 100 waits 100 ticks, Speed
  125 waits 80, Speed 80 waits 125. Over 1,000
  ticks the Speed 125 hero acts 12 times and the
  Speed 80 hero 8.
- **Actions have a weight.** A heavy action
  (a big swing, a long spell) adds to the wait; a
  light one (a quick jab, a buff) takes from it.
  So "defend" is never a wasted turn: it's light,
  so you're back sooner.
- **The timeline is always on screen**: a strip
  of portraits showing the next ~10 turns. While
  planning, it shows where the hero *would* land
  after the chosen action, and where a haste or a
  delay would move everyone.
- **Ties are settled by a fixed ladder**, never a
  coin flip (the fork's speed-tie rule): higher
  base Speed first, then smaller size, then higher
  HP %, then your side.
- **A round is 100 ticks**, the same unit as
  brainstorm 1. Rounds only matter for things
  that tick per round (intensity, auras, terrain).

**Time magic** works on the timeline directly:

- **Haste / Slow** change a hero's Speed for a
  while.
- **Delay** pushes a foe's next turn back a fixed
  number of ticks. **Quicken** pulls an ally's
  forward, even to "now".
- **Stop** (rare, bosses and legends) removes a
  hero from the timeline for a fixed time.

**Charged abilities** take time to go off. A
charged spell is placed on the timeline with its
target area drawn on the arena ("Meteor, tick
340, here"). Foes can step out of it, or delay the
caster so it lands later. This is FFT's
charge-time magic, and it gives the "visible
intent" of Into the Breach without making every
foe announce every move.

### Stats

| Stat | What it does |
|---|---|
| **HP** | Health. At 0 the hero is down. |
| **Attack** | Physical damage. |
| **Magic** | Special damage (spells, beams, psychic, tech). |
| **Armor** | Reduces physical damage. |
| **Resistance** | Reduces special damage. |
| **Speed** | Turn frequency (above). |
| **Move** | Distance per turn, in metres. |

Plus **size**, a trait rather than a stat (see
[Movement](#movement)).

This is option A from before (Pokémon-like) with
Move added, and a different damage formula.
Numbers sit in the tens to hundreds. An example:

> **Gerald**, mouse knight. HP 300, Attack 130,
> Magic 20, Armor 110, Resistance 40, Speed 95,
> Move 5 m, small.

### Damage

Every attack has two properties:

- **Delivery**: **physical** (blocked by Armor)
  or **special** (blocked by Resistance).
- **Element**, or none: fire, frost, shock,
  poison, light, shadow, … (the list is open).
  The element is what immunities and
  weaknesses key off, not the delivery.

A starting formula, in whole numbers:

```
damage = Power × Offense ÷ (100 + Defense)
         × element modifier × intensity
```

- **Offense** is Attack or Magic, **Defense** is
  Armor or Resistance, by delivery.
- **Defense never fully blocks**: each 100 points
  roughly halves what's left, with diminishing
  returns (the League of Legends armor curve).
- **Example:** an orc's Axe Chop (Power 100,
  Attack 130) on Gerald: 100 × 130 ÷ 210 = 61,
  about 20% of his HP. A pyromancer's Fireball
  (Power 120, Magic 150) on Gerald:
  120 × 150 ÷ 140 = 128, about 43%.

**Element modifiers are per hero, not a type
chart.** Each hero lists its own weaknesses,
resistances and immunities as traits:

- **Immune:** 0 damage, whatever the attacker's
  Offense. A flamethrower on a fire demon does
  nothing.
- **Resist:** half. **Weak:** one and a half.
- **Absorb** (rare): the hit heals instead.

Hand-made heroes make a per-hero list work
better than an 18×18 chart: the fire demon is
immune to fire because it is a fire demon, not
because of a table.

### Shields and passive protection

Shields come from **abilities, traits and items**
(Honkai: Star Rail style). Nobody has a shield
just from their stats, so many heroes have none.
But shields are **typed** (DOS2 style), and that
is where the variety comes from:

- **A shield is a layer on top of HP** that
  absorbs damage of its kind until broken.
- **Status effects can't land through a
  matching shield.** A Ward stops a freeze; Plate
  stops a knockdown. So control is earned by
  breaking the shield first, and it's
  predictable.
- **Layers stack**: a hero can carry several, and
  each one needs its own answer.

**Protection is passive, not a turn spent.**
Pokémon's Protect is fun but wastes turns. Here,
defensive heroes are always ready:

- **Shield bearer**, *Bodyguard*: the first
  attack each round on an ally within 2 m is
  taken by the bearer instead.
- **Mech warrior**, *Energy Shield*: a 150-point
  shield that fully recharges at the start of its
  turn if it took no damage since its last turn.
  Halo-style.
- **Wizard**, *Ward*: blocks special damage up to
  a cap, and every status effect while up.
- **Nano swarm**: repairs a fixed amount of HP at
  the start of each turn.
- **Halo aura** (from the fork's Halo): no single
  hit can take more than 40% of the max HP of
  anyone within range, friend or foe, so nobody
  nearby goes down in fewer than three hits.
- **Last stand** (the fork's Sturdy/Psybubble):
  survives the first lethal hit of the fight at 1
  HP.
- **Rebirth** (phoenix): when downed, becomes an
  egg on the timeline and hatches at half HP a
  fixed number of ticks later, unless the egg is
  broken first.

### Defences from every era, and what breaks them

The mix of eras pays off most here: each kind of
defence has its own counter, and they come from
different worlds.

| Defence | Era | Broken by |
|---|---|---|
| Ward | Arcane | Dispel, anti-magic, silence |
| Plate / heavy armor | Medieval | Armor-piercing, crushing, acid |
| Energy shield | Sci-fi | Shock, EMP |
| Nano swarm repair | Sci-fi | EMP, fire |
| Regeneration | Beast / mythic | Poison, curses, fire |
| Holy blessing | Mythic | Shadow |

A team then needs answers for several kinds of
defence, and the random foe draw decides which.

### Status effects without dice

Following the fork's determinism rules:

- **Statuses land when nothing stops them**: no
  matching shield, no immunity. No percentage
  chance.
- **Durations are fixed** and counted in the
  affected hero's own turns ("Frozen: 2 turns").
- **No locks.** Control never takes away turns
  forever: a stun **delays** a hero on the
  timeline by a fixed amount rather than skipping
  it, and a hero can't be stunned again until it
  has acted (the fork's flinch cap).
- **Some statuses are taxes, not skips**, like
  the fork's paralysis: "Shocked" makes the
  hero's actions heavier instead of cancelling
  them.

### Escalation

The fork's **intensity**: all damage rises a
little every round (92% in round 1, +1% each
round, no cap). Fights always end, and healing
and shield walls can't stall forever.

### Movement

**Free movement is feasible with sprites.** The
art doesn't change; the work is in the maths and
the touch controls:

- **Positions are whole-number coordinates**
  (say, in centimetres) so every result is exact
  and repeatable. Distances compare squared
  values, so no square roots or floating point.
- **Every hero is a circle.** Size sets the
  radius: small (a mouse knight), medium (a
  wizard), large (a mech), huge (a dragon).
  Circles can't overlap, so big heroes block
  paths and are easier to surround, and area
  attacks catch them more easily.
- **Pathfinding uses a hidden fine grid** (say
  10 cm cells) with A*, smoothed into straight
  lines. The player never sees a grid. The
  reachable area is drawn as a shaded region,
  shrunk by the hero's radius so big heroes can't
  squeeze through small gaps.
- **Melee reach** is measured edge to edge (the
  attacker's radius plus the weapon's reach), so
  a dragon's bite reaches further than Gerald's
  sword.
- **Touch controls:** drag a ghost of the hero,
  with snap points at useful spots (cover, the
  edge of an area, in reach of a foe).
- **Threat overlay:** while placing, show which
  foes could reach that spot before your next
  turn.

A grid or hexes would be simpler, but not by much
once the hidden grid exists, and free movement is
what makes size matter.

### Arenas

The randomness lives in the arena as well as in
the foes. Arenas are hand-made, drawn at random,
and can change a fight drastically:

- **Terrain**: high ground (longer range), pits,
  pillars that block sight and shots, water,
  lava, ice, tall grass.
- **Arena traits**: a ley line that boosts
  magic, a scrapyard that recharges machines,
  holy ground, a storm that charges shock
  attacks, darkness that shortens ranges.
- **Hazards on the clock**: a gate that opens at
  tick 300, a collapsing floor, a rising tide.
  All shown in advance on the timeline.
- **You see the arena before deploying**, so it's
  a puzzle to read, not a surprise.

### Items and equipment

- **Equipment** is worn into the fight, with a
  limit per hero, and comes with the hero's
  upgrades.
- **Pickups** lie on the arena or drop from
  downed foes. Any hero can grab one. A wizard can
  pick up an AK-47 and use it: the weapon brings
  its own attack (power, range, delivery,
  element) and uses the holder's Attack, so a
  wizard with a rifle shoots worse than a
  soldier.
- **Pickups have uses, not durability rolls**:
  a rifle with 6 shots is empty after 6.
- **One-shot items fire at a fixed moment**, like
  the fork's entry items: a focus charm that
  survives the first lethal hit, a quick charm
  that puts you first on the timeline once.

### Support heroes

Support heroes have three kinds of tools:

- **Buffs and healing**: raise stats, add
  shields, heal, cleanse statuses.
- **Battlefield control**: raise walls, create
  terrain (ice, fire, holy ground), push and
  pull, swap places, teleport.
- **Time**: haste, slow, delay, quicken (see
  the timeline).

### Commander actions

The player isn't on the field but can reach in:

- **A small set of commander actions**, chosen
  before the run (a healing spell, a war chant
  that hastes everyone for a round, a ward on one
  hero, a rally that cleanses statuses).
- **Each is usable once per fight**, like the
  fork's free gimmicks (one Mega, one Z-Move per
  team), so the question is *when* to use it.
- **They act between turns**, at any moment you
  choose, and don't take a hero's turn.

### What you can see

Everything the fork learned about previews
carries over:

- **Damage preview as a range** while a foe's
  stats are unknown ("Fireball → 38–46%"), exact
  once they are known.
- **KO verdicts spelled out**: "KO", "may KO",
  or a range that can't KO. Previews round
  **down** and HP shows rounded **up**, so
  "damage ≥ HP" on screen is always a real KO.
- **Immunities, weaknesses and visible traits are
  always shown**, like the fork's innates. "Fire
  → 0% (immune)" needs no guesswork; a flame on
  a fire demon is obvious anyway.
- **Hidden things say they're hidden.** Brainstorm
  1's change to the fork: an unrevealed passive
  is a "?", not treated as absent, so the
  preview never claims certainty it doesn't
  have.
- **Status preview**: "Freeze → blocked by Ward",
  "Stun → immune".
- **Timeline preview** after each planned action.
- **Battle log** of every action and its damage.
- **Knowledge is kept**: once a foe hero's stats
  are seen, every later fight against them is
  exact (brainstorm 1's "knowledge is the
  level-up", and the bestiary idea).

## Lessons from the fork

Takeaways from the `pokeemerald-expansion` fork's
notes (`fork-docs/` in that repository) that
shaped the battle system above:

- **Replace a random upside with a rule the
  player can read off the board**, then buff what
  lost its value. Every removed roll got a
  deterministic replacement and, where needed, a
  compensating buff.
- **Accuracy became a price, not a coin flip.**
  Moves always hit; less accurate moves got fewer
  uses. Strong-but-costly vs. reliable is still a
  real choice. Here: big attacks are heavy on the
  timeline or have few uses.
- **One "strong hit" rule replaced many rolls.**
  Secondary effects, flinches and high-crit moves
  all land on a super-effective hit. Here: status
  lands when no shield stops it.
- **No locks.** No flinching the same foe two
  turns running, Protect can't be used twice in a
  row, confusion never cancels a turn, sleep has a
  fixed length.
- **Escalating intensity** ends long fights.
- **Entry-turn items**: chance-based items became
  guaranteed one-time effects at a fixed moment.
- **Halo, Psybubble, Sturdy**: passive
  protections with a clear rule are fun and easy
  to plan around. Halo's 40% cap means "never
  fewer than three hits".
- **Innates vs. chosen abilities.** An innate is
  a pure upside and always visible; a chosen
  ability can carry a real downside. Heroes could
  have both: always-visible traits, plus a kit
  that has trade-offs.
- **The preview and the AI share one damage
  calculation**, so they never disagree, and the
  AI is taught every rule it would otherwise
  misjudge.
- **What the player may know is the hard part.**
  The INFO viewer's reveal rules broke more than
  anything else. Decide early what is visible,
  what is a range and what is a "?".
- **Pacing of an endless run:** a boss every 10
  wins, a champion at 50 and 100, a warning
  before a big fight, stronger AI for bosses than
  regular foes, and big powers held back for
  bosses.
- **Limited team-wide powers create choices**:
  one gimmick per team per type made every member
  compete for it.
- **Variety rules in the draft**: one of each
  species and one of each item per team kept
  teams varied.
- **When a rule keeps being broken, make it a
  test**, not a louder sentence in a doc.

## Progression

- **Heroes level up** and **unlock upgrades**
  (new abilities, passives, evolutions).
- **Currency** is earned by winning. It buys
  recruits (heroes on offer) and possibly
  upgrades or training.
- **Losing ends the streak**, but something
  persists. With a leveling clan, the obvious
  answer is **the clan itself**: heroes, levels
  and upgrades stay; only the streak (and maybe
  in-run gold) resets.

### Idea: open level vs. fixed level

Battle Facilities in Pokémon offer "Lv. 50" and
"Open Level" brackets. The same could work here:

- **Open bracket:** your heroes' levels count. A
  stronger clan goes further.
- **Fixed bracket:** everyone is set to the same
  level. Pure tactics and team-building, nothing
  that grinding can fix.

## Outside of combat

No non-combat gameplay idea has felt fun, so
there isn't any. What happens between fights is
clan management, FFTA-style: recruiting, leveling,
choosing upgrades, picking who to bring. That's
enough.

## Set aside

- **Cards, decks and draws** (Lost Kingdoms-style
  summoning). Heroes are clan members instead.
- **A summoner on the field.** The player commands
  from outside.
- **A bench or mid-fight summoning.** Everyone
  fights.
- **Factions or eras to organise the theme.** Not
  needed.
- **Non-combat activities** (crafting, farming,
  exploring). None felt fun.

## Open questions

- **Battle system:** the proposal above needs a
  prototype. Biggest unknowns: whether the
  timeline maths feels right, how heavy and light
  actions are priced, and the damage formula's
  numbers.
- **Element list:** which elements exist, and how
  many.
- **How big fights get**, given every hero takes
  its own turn and you play them all.
- **Fallen fighters:** knocked out for the fight
  only, injured for the run, or lost?
- **Commander actions:** how many per run, and
  how they are unlocked.
- **Run shape:** sets of fights with a champion at
  the end of each (Battle Factory's sets of
  seven), or one continuous climb?
- **What else currency buys** beyond recruits,
  and whether there's one currency or two (in-run
  vs. persistent).
- **How recruiting from beaten teams works:** one
  pick per win, or only some foes can join?
  (Later.)
- **Difficulty over a streak.** The fork draws
  foes uniformly with no scaling; with a leveling
  clan, foes probably need to scale.

## Roadmap

The order of work, one or more pull requests per
step. The near-term goal is step 4: a **0.0.1**
build with a battle that starts to feel right,
then iterate from there. No throwaway browser
prototypes: the battle is built in the real game
and improved as we go.

1. **Brainstorm 2.** These notes.
2. **Take what's needed from
   `gastly92/ios-template`**: project layout, CI,
   TestFlight and App Store pipeline, coverage
   gate.
3. **Repository set-up and TestFlight with a
   "hello world"** build on the phone.
4. **Basic battle engine with a few heroes.**
   Several pull requests: the rules as a pure
   Swift package (timeline, damage, shields,
   immunities, movement), a first handful of
   heroes, then a battle screen, until it starts
   to feel right. Tag **0.0.1**. ("Hero" is a
   working name; the final word is not chosen.)
5. **The rest of the game**: battle flow, menus,
   clan management, drafting, earning and
   spending currency, and so on.
