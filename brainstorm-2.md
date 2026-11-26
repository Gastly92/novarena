# Brainstorm 2: The Arena

Working notes from the second design
conversation. The game has pivoted from the
sleeper ship ([brainstorm.md](brainstorm.md))
to an **endless, turn-based tactics game with
roguelike runs**: a party of named units
fights gladiator-style against random teams
of foes. Nothing here is final.

---

## Where this came from

The same root as the first brainstorm: the
Battle Factory in the `pokeemerald-expansion`
fork. The ship idea turned the fun parts
(determinism, range previews, drafting)
against the environment. This version puts
them back where they started: **against
opponents**.

## Pillars

Carried over from brainstorm 1:

1. **No dice mid-battle.** No hit/miss rolls,
   no random crits. Outcomes follow from
   rules and state.
2. **Randomness lives between fights.** Which
   foes you draw, which recruits and rewards
   are offered. The Battle Factory split.
3. **Planning over reflexes.** Turn-based;
   nothing happens until you commit.
4. **Damage previews as ranges** while a
   foe's stats are unknown, exact once they
   are known.
5. **Single player, against the computer.**
   Balance is asymmetric and aims at the
   player's fun, not a competitive meta (the
   fork's "flavour and fun come before
   competitive balance"). There is no human
   opponent to keep things fair for.

Changed:

- **Rivals are back.** You fight opponents.
  The "cozy, nobody dies, no rivals" pillar
  is dropped.
- **Leveling is in.** Brainstorm 1 ruled out
  levels and XP; here, collecting units,
  leveling them and unlocking their upgrades
  is part of the fun.

## Theme

All of fantasy, past, present and future,
mixed freely: mouse knights, robot mech
droids, ice wizards, a rebirth phoenix, all
in one arena.

No extra structure (factions, eras, an
in-world reason) is needed to make the mix
work. Magic: the Gathering mixes everything
and is fine.

### Premise

Inspired by Ayreon's *Into the Electric
Castle*: an **interdimensional entity pulls
characters from across time, space and
dimensions of reality into its own pocket of
existence, for its own amusement**.

The mix needs no structure, but this gives it
a reason, and it explains a lot of the game's
rules at once:

- **Why a mouse knight fights a mech**: the
  entity took both.
- **Why the fights never end**: the entity
  wants another show. An endless streak is an
  encore.
- **Why arenas, weather and hazards change**:
  the entity reshapes its pocket world on a
  whim.
- **Why a fallen unit can come back**: the
  entity puts its toys back together, unless
  it decides a fight is to the death.
- **Why there's a home base**: it's the
  units' corner of the pocket world.
- **Why cosmetics and shinies**: the entity
  likes its collection to look good.
- **The commander actions** could be the
  entity (or whoever it favours) reaching in.

Open: who the player is. The entity itself, a
favourite it lets play, or a captive champion
who runs the party. Similar premises exist
(Marvel's *Contest of Champions*, *Dissidia*,
Star Trek's Q), so the entity and its world
need their own character, and the game should
borrow no names from the album or from those.

## Units and the party

- **Words.** A **unit** is any character in a
  fight, on either side (not all of them
  fight). The player's group is the
  **party**. Not "hero", "fighter", "clan" or
  "roster".
- **Like FFTA's clans.** You build up a party
  over time, not a deck.
- **No cards.** No card frames, no deck, no
  draw. Units are party members.
- **Every unit is named.** Not "Mouse Knight"
  but *Gerald*, a mouse knight. There can be
  other mouse knights, each their own person
  with their own name (and presumably their
  own kit).
- **Collecting them all** is a goal in
  itself.
- **Traits stack.** Like the fork's innate
  abilities, a unit can have any number of
  always-on traits on top of their kit:
  Gerald might be *Small*, *Brave* and
  *Fire-wary* at once. Traits are pure
  upsides (or plain facts, like an immunity),
  always visible, and some come from
  upgrades. "Trait" is the working name,
  replacing "innate" (which autocorrects to
  "inmate"); others to consider: *boon*,
  *gift*, *mark*.
- **Hand-made, one of a kind.** Every unit is
  designed by hand: name, look, kit. No
  generated units or name variants. A fixed
  set to collect, which makes each one worth
  having (and makes art and writing the main
  cost).
- **Two ways to gain units:**
  - **Recruit from teams you beat**, the
    Battle Factory swap.
  - **Buy with currency.**

## The fight

- **Everyone fights.** Every unit you bring
  enters the arena. No bench, no sitting out:
  games that don't let you use everyone are
  less fun.
- **Fight size isn't capped by the screen.**
  The battlefield can be panned, so large
  fights are fine on a phone.
- **You command everyone.** Every unit's turn
  is yours to play; no unit runs on
  autopilot.
- **The player is not on the field.** You
  command from outside, but can still reach
  in with commander actions (see [Commander
  actions](#commander-actions)).

## Battle system (proposal)

A first full pass, combining the options from
the design conversation. They turned out not
to be mutually exclusive; each answers a
different question. Everything here is a
starting point to prototype, not a decision.

### What it has to work with

A **2D or 2.5D game of sprites** built from a
phone (SwiftUI app, SpriteKit for the battle
view, CI does the building). So:

- **A flat arena seen from a 3/4 top-down
  angle**, sprites sorted by their y position
  so nearer ones draw in front. No 3D.
- **Sprites face left or right only**,
  mirrored. One idle, one move, one attack
  and one hit animation per unit is a
  workable floor. Four or eight facings would
  multiply the art for little gain.
- **Height is a property of the ground** (a
  raised platform, a pit), drawn with shading
  and a drop shadow, as in brainstorm 1.

### Shape of a fight

1. **Scout.** Before the fight you see the
   arena and the foe team: names, looks and
   any trait that is always visible (see
   [What you can see](#what-you-can-see)).
2. **Deploy.** Place your units anywhere in
   your starting zone.
3. **Fight.** Units act one at a time in
   timeline order (below). On a unit's turn
   it can **move up to its Move distance and
   take one action**, in either order, and
   may split its movement around the action.
4. **End.** The fight ends when one side has
   nobody standing.

### Speed and the timeline

Speed is a stat, and it decides both turn
order and **how often** a unit acts: faster
units get slightly more turns. This is the
"charge time" family (FFT, FFX), and it makes
time magic one of the most important kinds of
ability.

- **Every unit has a next-turn time** on a
  shared clock measured in ticks.
- **After acting, a unit's next turn is
  `10000 ÷ Speed` ticks later** (whole
  numbers, rounded down). Speed 100 waits 100
  ticks, Speed 125 waits 80, and Speed 80
  waits 125. Over 1,000 ticks the Speed 125
  unit acts 12 times and the Speed 80 unit 8.
- **Actions have a weight.** A heavy action
  (a big swing, a long spell) adds to the
  wait; a light one (a quick jab, a buff)
  takes from it. So "defend" is never a
  wasted turn: it's light, so you're back
  sooner.
- **The timeline is always on screen**: a
  strip of portraits showing the next ~10
  turns. While planning, it shows where the
  unit *would* land after the chosen action,
  and where a haste or a delay would move
  everyone.
- **Ties are settled by a fixed ladder**,
  never a coin flip (the fork's speed-tie
  rule): higher base Speed first, then
  smaller size, then higher HP %, then your
  side.
- **A round is 100 ticks**, the same unit as
  brainstorm 1. Rounds only matter for things
  that tick per round (intensity, auras,
  terrain).

**Time magic** works on the timeline
directly:

- **Haste / Slow** change a unit's Speed for
  a while.
- **Delay** pushes a foe's next turn back a
  fixed number of ticks. **Quicken** pulls an
  ally's forward, even to "now".
- **Stop** (rare, bosses and legends) removes
  a unit from the timeline for a fixed time.

**Charged abilities** take time to go off. A
charged spell is placed on the timeline with
its target area drawn on the arena ("Meteor,
tick 340, here"). Foes can step out of it, or
delay the caster so it lands later. This is
FFT's charge-time magic, and it gives the
"visible intent" of Into the Breach without
making every foe announce every move.

### Stats

| Stat | What it does |
|---|---|
| **HP** | Health. At 0 the unit is down. |
| **Attack** | Physical damage. |
| **Magic** | Special damage (spells, beams, psychic, tech). |
| **Armor** | Reduces physical damage. |
| **Resistance** | Reduces special damage. |
| **Speed** | Turn frequency (above). |
| **Move** | Distance per turn, in metres. |

Plus **size**, a trait rather than a stat
(see [Movement](#movement)).

This is option A from before (Pokémon-like)
with Move added, and a different damage
formula. Numbers sit in the tens to hundreds.
An example:

> **Gerald**, mouse knight. HP 300, Attack
> 130,
> Magic 20, Armor 110, Resistance 40, Speed
> 95,
> Move 5 m, small.

### Damage

Every attack has two properties:

- **Delivery**: **physical** (blocked by
  Armor) or **special** (blocked by
  Resistance).
- **Element**, or none: fire, frost, shock,
  poison, light, shadow, … (the list is
  open). The element is what immunities and
  weaknesses key off, not the delivery.

A starting formula, in whole numbers:

```
damage = Power × Offense ÷ (100 + Defense)
         × element modifier × intensity
```

- **Offense** is Attack or Magic, **Defense**
  is Armor or Resistance, by delivery.
- **Defense never fully blocks**: each 100
  points roughly halves what's left, with
  diminishing returns (the League of Legends
  armor curve).
- **Example:** an orc's Axe Chop (Power 100,
  Attack 130) on Gerald: 100 × 130 ÷ 210 =
  61, about 20% of his HP. A pyromancer's
  Fireball (Power 120, Magic 150) on Gerald:
  120 × 150 ÷ 140 = 128, about 43%.

**Element modifiers are per unit, not a type
chart.** Each unit lists its own weaknesses,
resistances and immunities as traits:

- **Immune:** 0 damage, whatever the
  attacker's Offense. A flamethrower on a
  fire demon does nothing.
- **Resist:** half. **Weak:** one and a half.
- **Absorb** (rare): the hit heals instead.

Hand-made units make a per-unit list work
better than an 18×18 chart: the fire demon is
immune to fire because it is a fire demon,
not because of a table.

### Shields and passive protection

Shields come from **abilities, traits and
items** (Honkai: Star Rail style). Nobody has
a shield just from their stats, so many units
have none. But shields are **typed** (DOS2
style), and that is where the variety comes
from:

- **A shield is a layer on top of HP** that
  absorbs damage of its kind until broken.
- **Status effects can't land through a
  matching shield.** A Ward stops a freeze;
  Plate stops a knockdown. So control is
  earned by breaking the shield first, and
  it's predictable.
- **Layers stack**: a unit can carry several,
  and each one needs its own answer.

**Protection is passive, not a turn spent.**
Pokémon's Protect is fun but wastes turns.
Here, defensive units are always ready:

- **Shield bearer**, *Bodyguard*: the first
  attack each round on an ally within 2 m is
  taken by the bearer instead.
- **Mech warrior**, *Energy Shield*: a
  150-point shield that fully recharges at
  the start of its turn if it took no damage
  since its last turn. Like the recharging
  energy shields in the *Halo* games.
- **Wizard**, *Ward*: blocks special damage
  up to a cap, and every status effect while
  up.
- **Nano swarm**: repairs a fixed amount of
  HP at the start of each turn.
- **Damage-cap aura** (the fork's Halo
  ability, a different idea from *Halo*'s
  shields): no single hit can take more than
  40% of the max HP of anyone within range,
  friend or foe, so nobody nearby goes down
  in fewer than three hits.
- **Last stand** (the fork's
  Sturdy/Psybubble): survives the first
  lethal hit of the fight at 1 HP.
- **Rebirth** (phoenix): when downed, becomes
  an egg on the timeline and hatches at half
  HP a fixed number of ticks later, unless
  the egg is broken first.

### Defences across eras

The mix of eras pays off most here: each kind
of defence has its own counter, and they come
from different worlds.

| Defence | Era | Broken by |
|---|---|---|
| Ward | Arcane | Dispel, anti-magic, silence |
| Plate / heavy armor | Medieval | Armor-piercing, crushing, acid |
| Energy shield | Sci-fi | Shock, EMP |
| Nano swarm repair | Sci-fi | EMP, fire |
| Regeneration | Beast / mythic | Poison, curses, fire |
| Holy blessing | Mythic | Shadow |

A team then needs answers for several kinds
of defence, and the random foe draw decides
which.

### A full toolbox

**Units have as many abilities as suits
them**, not a fixed four like Pokémon. A
wizard with a dozen spells keeps all twelve.
Nothing is swapped out before a fight; what
limits a turn is the resource each ability
costs (below), so every unit always has their
whole toolbox.

On a phone, a long ability list needs a good
picker: grouped by kind, with what's
affordable this turn first.

### Resources: uses, not accuracy

The fork's lesson: accuracy became a price
(fewer uses), not a coin flip. Here every
attack hits, and the strong ones cost more of
the unit's resource. Units don't all share
one resource; each kind fits its unit and
behaves differently:

| Resource | Example | Behaves like |
|---|---|---|
| Mana | Wizard | A pool that refills slowly each turn |
| Charge | Mech | Spent in bursts, refilled by recharging or arena power |
| Stamina | Knight | Refills fast if the turn was light |
| Ammo | Gunner, pickups | A fixed count, no refill mid-fight |

- **Some units mix them**: a spellblade might
  spend stamina on sword work and mana on
  spells.
- **Resources give counters too**: an EMP
  drains charge, a silence locks mana,
  exhaustion hits stamina. Another layer of
  the era-against-era matchups.
- **Cheap, reliable attacks always exist**,
  so a unit with an empty pool still has a
  turn (the fork's strong-but-short vs.
  reliable choice).

### Kinds of status

Borrowed from *Guild Wars 1*: effects on a
unit come in kinds, each with its own rules,
and abilities can interact with a kind as a
whole:

| Kind | What it is | Example |
|---|---|---|
| Enchantment | A magic boon, can be dispelled | Ward, Haste |
| Hex | A magic curse, can be cleansed | Weakness, Doom |
| Stance | A unit's own posture, one at a time | Brace, Berserk |
| Condition | A physical state | Poison, Burn, Paralysis |

- **Abilities key off kinds**: "deals more to
  hexed foes", "strips one enchantment",
  "while in a stance, …", "spreads every
  condition on the target".
- **Not limited to these.** More kinds can
  join (a mech's *malfunction*, a spirit's
  *possession*).
- **The same status can mean different things
  per unit.** A condition has a default
  effect, and a unit's traits can change it:
  a paralysed knight's muscles lock (actions
  get heavier), while a paralysed mech
  short-circuits (its charge drains instead).

### Status effects without dice

Following the fork's determinism rules:

- **Statuses land when nothing stops them**:
  no matching shield, no immunity. No
  percentage chance.
- **Durations are fixed** and counted in the
  affected unit's own turns ("Frozen: 2
  turns").
- **No locks.** Control never takes away
  turns forever: a stun **delays** a unit on
  the timeline by a fixed amount rather than
  skipping it, and a unit can't be stunned
  again until it has acted (the fork's flinch
  cap).
- **Some statuses are taxes, not skips**,
  like the fork's paralysis: "Shocked" makes
  the unit's actions heavier instead of
  cancelling them.

### Escalation

The fork's **intensity**: all damage rises a
little every round (92% in round 1, +1% each
round, no cap). Fights always end, and
healing and shield walls can't stall forever.

### Movement

**Free movement is feasible with sprites.**
The art doesn't change; the work is in the
maths and the touch controls:

- **Positions are whole-number coordinates**
  (say, in centimetres) so every result is
  exact and repeatable. Distances compare
  squared values, so no square roots or
  floating point.
- **Every unit is a circle.** Size sets the
  radius: small (a mouse knight), medium (a
  wizard), large (a mech), huge (a dragon).
  Circles can't overlap, so big units block
  paths and are easier to surround, and area
  attacks catch them more easily.
- **Pathfinding uses a hidden fine grid**
  (say 10 cm cells) with A*, smoothed into
  straight lines. The player never sees a
  grid. The reachable area is drawn as a
  shaded region, shrunk by the unit's radius
  so big units can't squeeze through small
  gaps.
- **Melee reach** is measured edge to edge
  (the attacker's radius plus the weapon's
  reach), so a dragon's bite reaches further
  than Gerald's sword.
- **Touch controls:** drag a ghost of the
  unit, with snap points at useful spots
  (cover, the edge of an area, in reach of a
  foe).
- **Threat overlay:** while placing, show
  which foes could reach that spot before
  your next turn.

A grid or hexes would be simpler, but not by
much once the hidden grid exists, and free
movement is what makes size matter.

### Arenas

The randomness lives in the arena as well as
in the foes. Arenas are hand-made, drawn at
random, and can change a fight drastically:

- **Terrain**: high ground (longer range),
  pits, pillars that block sight and shots,
  water, lava, ice, tall grass.
- **Arena traits**: a ley line that boosts
  magic, a scrapyard that recharges machines,
  holy ground, a storm that charges shock
  attacks, darkness that shortens ranges.
- **Weather**: rain (douses fire, conducts
  shock), sandstorm, snow, fog (shortens
  sight), wind (carries clouds and arrows),
  heat. It can change mid-fight on a schedule
  shown in advance.
- **Elements meet the environment**: fire
  burns grass and melts ice, frost freezes
  water into a walkable floor, shock spreads
  through water and metal.
- **Hazards on the clock**: a gate that opens
  at tick 300, a collapsing floor, a rising
  tide. All shown in advance on the timeline.
- **You see the arena before deploying**, so
  it's a puzzle to read, not a surprise.

### Interactions beyond abilities

Units can act on each other and the arena in
ways any unit can try, not only through their
own abilities:

- **Shove**: push someone a short way. Off a
  cliff, into lava or a pit, or into another
  unit.
- **Knockback** (pushed further, by a hit)
  and **knockdown** (put on the ground,
  delayed on the timeline).
- **Grapple**: hold someone so neither of you
  moves until one breaks free or the other
  lets go.
- **Steal**: take a held item or pickup from
  someone in reach.
- **Size and weight decide, not dice**: how
  far a shove goes is a fixed rule of the two
  units' sizes and strength. Gerald can't
  shove a dragon; a dragon can shove Gerald
  across the arena. The preview shows where
  someone will land.

### Items and equipment

- **Equipment** is worn into the fight, with
  a limit per unit, and comes with the unit's
  upgrades.
- **Pickups** lie on the arena or drop from
  downed foes. Any unit can grab one. A
  wizard can pick up an AK-47 and use it: the
  weapon brings its own attack (power, range,
  delivery, element) and uses the holder's
  Attack, so a wizard with a rifle shoots
  worse than a soldier.
- **Pickups have uses, not durability
  rolls**: a rifle with 6 shots is empty
  after 6.
- **One-shot items fire at a fixed moment**,
  like the fork's entry items: a focus charm
  that survives the first lethal hit, a quick
  charm that puts you first on the timeline
  once.

### Support units

Support units have three kinds of tools:

- **Buffs and healing**: raise stats, add
  shields, heal, cleanse statuses.
- **Battlefield control**: raise walls,
  create terrain (ice, fire, holy ground),
  push and pull, swap places, teleport.
- **Time**: haste, slow, delay, quicken (see
  the timeline).

### Lethal and non-lethal

Not every fight has to be to the death:

- **Fights have stakes**: an exhibition bout
  (the loser is knocked out and recovers) vs.
  a fight to the death (a unit who falls may
  be lost). What a fall costs could depend on
  the fight.
- **Abilities can be lethal or not**: a
  subduing blow knocks out instead of
  killing, which matters when you want to
  recruit the foe afterwards.

### Winning without fighting

Pacifist ways through a fight, or part of
one:

- **Bargaining**: pay a foe to yield or leave
  the arena.
- **Control**: charm or mind control, so a
  foe fights for you for a fixed time.
- **Seduction**: a foe that won't attack the
  unit who charmed it, like the fork's
  infatuation (which never cancels a turn).
- **A reason to use them**: foes won over
  this way might be easier to recruit, or pay
  out differently.

All of it deterministic: whether a bargain
works follows from rules the player can read
(what the foe values, how hurt it is), never
a roll.

### Commander actions

The player isn't on the field but can reach
in:

- **A small set of commander actions**,
  chosen before the run (a healing spell, a
  war chant that hastes everyone for a round,
  a ward on one unit, a rally that cleanses
  statuses).
- **Each is usable once per fight**, like the
  fork's free gimmicks (one Mega, one Z-Move
  per team), so the question is *when* to use
  it.
- **They act between turns**, at any moment
  you choose, and don't take a unit's turn.

The fork's **free gimmicks** are the model
for what the commander can do. Translated:

- **Dynamax → Titan**: a unit's HP doubles
  for 3 turns. Once per unit per fight.
- **Z-Move → Finisher**: one attack does 1.5×
  damage and ignores defences.
- Possibly **Mega Evolution → a
  transformation** for the rest of the fight,
  and **Terastallize → a change of element**
  (new weaknesses and immunities).

### What you can see

Everything the fork learned about previews
carries over:

- **Damage preview as a range** while a foe's
  stats are unknown ("Fireball → 38–46%"),
  exact once they are known.
- **KO verdicts spelled out**: "KO", "may
  KO", or a range that can't KO. Previews
  round **down** and HP shows rounded **up**,
  so "damage ≥ HP" on screen is always a real
  KO.
- **Immunities, weaknesses and visible traits
  are always shown**, like the fork's
  innates. "Fire → 0% (immune)" needs no
  guesswork; a flame on a fire demon is
  obvious anyway.
- **Hidden things say they're hidden.**
  Brainstorm 1's change to the fork: an
  unrevealed passive is a "?", not treated as
  absent, so the preview never claims
  certainty it doesn't have.
- **Status preview**: "Freeze → blocked by
  Ward", "Stun → immune".
- **Timeline preview** after each planned
  action.
- **Battle log** of every action and its
  damage.
- **Knowledge is kept**: once a foe unit's
  stats are seen, every later fight against
  them is exact (brainstorm 1's "knowledge is
  the level-up", and the bestiary idea).
- **Fighting reveals some, recruiting
  reveals all.** Every battle can bring
  foes you haven't met. Fighting one shows
  part of it (what it used on you, what you
  saw hit it); recruiting it shows
  everything. So the ranges narrow over a
  run, and an unrecruited foe can still
  hold a surprise.

## Lessons from the fork

Takeaways from the `pokeemerald-expansion`
fork's notes (`fork-docs/` in that
repository) that shaped the battle system
above:

- **Replace a random upside with a rule the
  player can read off the board**, then buff
  what lost its value. Every removed roll got
  a deterministic replacement and, where
  needed, a compensating buff.
- **Accuracy became a price, not a coin
  flip.** Moves always hit; less accurate
  moves got fewer uses. Strong-but-costly vs.
  reliable is still a real choice. Here: big
  attacks are heavy on the timeline or have
  few uses.
- **One "strong hit" rule replaced many
  rolls.** Secondary effects, flinches and
  high-crit moves all land on a
  super-effective hit. Here: status lands
  when no shield stops it.
- **No locks.** No flinching the same foe two
  turns running, Protect can't be used twice
  in a row, confusion never cancels a turn,
  sleep has a fixed length.
- **Escalating intensity** ends long fights.
- **Entry-turn items**: chance-based items
  became guaranteed one-time effects at a
  fixed moment.
- **Halo, Psybubble, Sturdy**: passive
  protections with a clear rule are fun and
  easy to plan around. Halo's 40% cap means
  "never fewer than three hits".
- **Innates (here: traits) vs. chosen
  abilities.** An innate is a pure upside and
  always visible; a chosen ability can carry
  a real downside. Units could have both:
  always-visible traits, plus a kit that has
  trade-offs.
- **The preview and the AI share one damage
  calculation**, so they never disagree, and
  the AI is taught every rule it would
  otherwise misjudge.
- **What the player may know is the hard
  part.** The INFO viewer's reveal rules
  broke more than anything else. Decide early
  what is visible, what is a range and what
  is a "?".
- **Pacing of an endless run:** a boss every
  10 wins, a champion at 50 and 100, a
  warning before a big fight, stronger AI for
  bosses than regular foes, and big powers
  held back for bosses.
- **Limited team-wide powers create
  choices**: one gimmick per team per type
  made every member compete for it.
- **Variety rules in the draft**: one of each
  species and one of each item per team kept
  teams varied.
- **When a rule keeps being broken, make it a
  test**, not a louder sentence in a doc.

## Progression

- **Units level up** and **unlock upgrades**
  (new abilities, passives, evolutions).
- **Stat upgrades are bought outside
  battle**, like *Fire Emblem: The Sacred
  Stones*' stat boosters, so maximising one
  unit is something you work on between
  fights.
- **Levels may not raise base stats.** Battle
  experience could do something else instead
  (unlock abilities or traits, a mastery, a
  title); what exactly is open.
- **Currency** is earned by winning. It buys
  recruits (units on offer), possibly
  upgrades or training, and **cosmetic
  upgrades** (looks for units, the home
  base).
- **Flair and shinies**: rare cosmetic
  variants of units and their equipment (a
  gilded sword, a shiny palette), like
  Pokémon's shinies.
- **Losing ends the streak**, but something
  persists. With a leveling party, the
  obvious answer is **the party itself**:
  units, levels and upgrades stay; only the
  streak (and maybe in-run gold) resets.

### Idea: open level vs. fixed level

Battle Facilities in Pokémon offer "Lv. 50"
and "Open Level" brackets. The same could
work here:

- **Open bracket:** your units' levels count.
  A stronger party goes further.
- **Fixed bracket:** everyone is set to the
  same level. Pure tactics and team-building,
  nothing that grinding can fix.

If levels don't raise base stats, the two
brackets differ less, and this may not be
needed.

## Game modes ("facilities")

The fork's Battle Frontier has several
facilities with different rules; the fork has
converted the Battle Factory and is working
on the Battle Tower. This game can have more
than one too. Ideas:

- **Draft**: fight with units offered at
  random, swap in from beaten teams (the
  Factory).
- **Party gauntlet**: your own party, endless
  (the Tower).
- **Boss rush**: champions only.
- **Trials**: hand-made puzzles, such as "win
  in 3 turns".
- **Survival**: no healing between fights.

## Collection

A **bestiary** is a must, like the Pokédex:

- **Every unit and foe you've met**, with
  what you've learned about them. Once a
  foe's stats are known, every later preview
  against them is exact ("knowledge is kept",
  from [What you can
  see](#what-you-can-see)).
- **Units you own vs. units you've seen**, so
  collecting them all has a checklist.
- **Shinies and flair** collected too.

## Outside of combat

Combat is the primary system. Between fights
is party management, FFTA-style: recruiting,
leveling, choosing upgrades, picking who to
bring.

**Farming and exploring aren't ruled out**,
just not the main system. No idea for them
has felt fun yet.

### Home base

A home base, like in some gacha games:

- **Navigated by menus**, not by walking
  around. Walking from place to place (as in
  the fork's Battle Frontier) is tedious, and
  menus are easier to build.
- **Places in the base are the game's
  systems**: the arena gate, the barracks
  (party), the shop, the training ground, and
  so on.
- **Cosmetics** can decorate it.

## Set aside

- **Cards, decks and draws** (Lost
  Kingdoms-style summoning). Units are party
  members instead.
- **A summoner on the field.** The player
  commands from outside.
- **A bench or mid-fight summoning.**
  Everyone fights.
- **Factions or eras to organise the theme.**
  Not needed.
- **Walking around a hub** (as in the fork's
  Frontier). Menus instead.

## Open questions

- **Battle system:** the proposal above needs
  a prototype. Biggest unknowns: whether the
  timeline maths feels right, how heavy and
  light actions are priced, and the damage
  formula's numbers.
- **What battle experience does** if levels
  don't raise base stats.
- **Which resources exist**, and how each
  refills.
- **Which status kinds exist** beyond
  enchantments, hexes, stances and
  conditions.
- **The trait name.**
- **Which facilities** come first after the
  main one.
- **Element list:** which elements exist, and
  how many.
- **How big fights get**, given every unit
  takes its own turn and you play them all.
- **Fallen units:** knocked out for the fight
  only, injured for the run, or lost?
  Possibly decided by the fight's stakes
  (lethal or not).
- **How bargaining and charm are decided**
  without dice.
- **Commander actions:** how many per run,
  and how they are unlocked.
- **Run shape:** sets of fights with a
  champion at the end of each (Battle
  Factory's sets of seven), or one continuous
  climb?
- **What else currency buys** beyond
  recruits, and whether there's one currency
  or two (in-run vs. persistent).
- **How recruiting from beaten teams works:**
  one pick per win, or only some foes can
  join? (Later.)
- **Difficulty over a streak.** The fork
  draws foes uniformly with no scaling; with
  a leveling party, foes probably need to
  scale.

## Roadmap

The order of work, one or more pull requests
per step. The near-term goal is step 4: a
**0.0.1** build with a battle that starts to
feel right, then iterate from there. No
throwaway browser prototypes: the battle is
built in the real game and improved as we go.

1. **Brainstorm 2.** These notes.
2. **Take what's needed from
   `gastly92/ios-template`**: project layout,
   CI, TestFlight and App Store pipeline,
   coverage gate.
3. **Repository set-up and TestFlight with a
   "hello world"** build on the phone.
4. **Basic battle engine with a few units.**
   Several pull requests: the rules as a pure
   Swift package (timeline, damage, shields,
   immunities, movement), a first handful of
   units, then a battle screen, until it
   starts to feel right. (0.0.1 went to the
   hello world, so this is a later 0.0.x.)
   See [Step 4 so far](#step-4-so-far).
5. **The rest of the game**: battle flow,
   menus, party management, drafting, earning
   and spending currency, and so on.

## Step 4 so far

How the battle is being iterated: one pull
request at a time, each sent to TestFlight
and played on the phone, the next chosen by
what the last one felt like.

**The screen is a placeholder** until the
sprites. How it looks, or how readable the
text is, doesn't matter yet; what the
player can know and decide does.

Done:

- **Rules package** (`RuleSteward`): the
  timeline, damage, shields, resources, a
  bodyguard, four sample units, a stand-in
  AI.
- **0.0.2, a battle screen**: the sample
  battle, played by picking an ability then
  a foe.
- **0.0.3, previews**: each ability's power,
  cost and weight; once one is picked, each
  foe's exact result
  (`Battle.forecast`), and the turn order
  after the move.

What 0.0.3 felt like:

- Without movement and positions it's
  watching numbers go down: the tactics are
  missing.
- Lunge vs. Sword Cut only matters if the
  choice shows **where in the line you end
  up**: the timeline is a row of portraits,
  and picking a move shows your next turn's
  place in it. Not ticks, and not written
  out as "you go 3rd".
- The fork's previews were fun as ranges.
  Here a range comes from what you don't
  know yet (see [What you can
  see](#what-you-can-see)), not from dice.

Next, movement ([Movement](#movement)), in
pull requests:

- **A, rules.** Whole-number positions,
  each unit a circle (a size radius) with a
  Move stat, and each ability a reach
  (melee, edge to edge) or a range. A turn
  is moving up to Move and one action,
  either order, movement split around it.
  The stand-in AI walks toward its target.
  An open arena (no obstacles yet). The
  forecast includes moves. The turn order
  in the forecast replaces tick talk.
- **B, the screen** (0.0.4): a top-down
  arena of placeholder circles, where the
  unit on turn can reach, picking a spot,
  then a foe in reach with its preview; the
  turn order as a row, showing where the
  unit lands.
- **C.** Obstacles and pathfinding (the
  hidden fine grid), then terrain.

After movement, roughly: ranges from
unknown stats and the bestiary (knowledge);
a better AI; status effects; commander
actions. Feedback from each build can
reorder these.

