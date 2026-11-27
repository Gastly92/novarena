# Iteration

The goal: iterate on the battle until it's
good, then build the rest of the game up
from there.

The battles are the game. In the fork, what
made the Battle Factory fun was the battles
themselves; the system for spending battle
points never got built, and it didn't need
to be. So menus, the party, drafting,
currency and the rest (roadmap step 5 in
`brainstorm-2.md`) wait until fighting is
fun on its own.

`brainstorm-2.md` is the design as first
written and is left as it is. This doc is
where it changes: what's been tried, what it
felt like, and what's next.

## How it works

- **One pull request at a time.** Each one
  that changes the game goes to TestFlight
  once merged and gets played on the phone.
- **How it felt chooses the next.** The
  owner's notes go under
  [Builds](#builds), and the plan below
  changes to match.
- **The screen is a placeholder** until the
  sprites. How it looks, or how readable
  its text is, doesn't matter yet; what the
  player can know and decide does.
- **Decisions made while iterating go
  here**, under [Decisions](#decisions).

## Builds

- **0.0.1**: hello world.
- **0.0.2, a battle screen**: the sample
  battle (Gerald and Oswin against Ashka
  and Kestrel-9), played by picking an
  ability then a foe. The rules are in
  `RuleSteward`: the timeline, damage,
  shields, resources, a bodyguard, a
  stand-in AI.
  - Felt like: numbers going down. No
    previews; Lunge vs. Sword Cut not clear
    at all.
- **0.0.3, previews**: each ability's power,
  cost and weight; once one is picked, each
  foe's exact result (`Battle.forecast`),
  and the turn order after the move.
  - Felt like: still numbers going down.
    Without movement and positions, the
    tactics are missing.
  - The choice between moves only matters
    if it shows where in the line you end
    up (see [Decisions](#decisions)).
  - The fork's previews were fun as
    ranges; these are exact numbers.
- **0.0.4, the arena**: units as circles
  on a top-down arena, to scale; tap a
  spot, pick an ability, then a foe in
  reach; the turn order as a row of
  portraits.
  - Felt like: moving looked like part of
    a skill. Tapping the arena to move
    wasn't discoverable; picking a skill
    against a far foe walked toward it.
  - Wanted: hold and drag a ghost to pick
    a spot, then a directional control to
    place it exactly.
  - Wanted: a toggle showing the danger
    zone, how far foes can reach with
    their moves and attacks, ranged ones
    too, from only what they've shown so
    far.
  - Moving, general actions and skills as
    separate things.

## Decisions

- **The turn order is a row of
  portraits.** Picking a move shows where
  the unit's next turn lands in that row.
  Not ticks, and not written out as "you go
  3rd".
- **Ranges come from what you don't know**,
  not from dice. Every battle can bring
  foes you haven't met. Fighting one shows
  part of it (what it used on you, what you
  saw hit it); recruiting it shows
  everything. So ranges narrow over a run,
  and an unrecruited foe can still hold a
  surprise.
- **Movement, first cut** (PR A):
  - Centimetres, in an open 12 × 8 m
    arena; the sides start in two columns
    9 m apart.
  - Sizes are radii: small 25, medium 40,
    large 70, huge 120.
  - Melee reaches edge to edge (half a
    metre unless an ability says).
    Ranged reaches from the unit's middle
    to the target's edge, so a big target
    is easier to hit but a big caster
    doesn't shoot further.
  - Moves are straight lines. Two legs
    (before and after the action) add up
    exactly, with no rounding. Only where
    a unit stops has to be clear; walking
    through others waits for pathfinding
    (C).
  - A turn of only moving, or waiting,
    takes the usual wait.
  - Move: Gerald 350, Ashka 300, Oswin
    and Kestrel-9 250.
  - Smaller size joins the tie ladder,
    after Speed, as `brainstorm-2.md` has
    it.
  - The stand-in AI takes the biggest hit
    it can reach this turn, walking just
    into reach; if none, it walks toward
    the biggest hit.
  - Until B, the screen walks the unit
    toward a foe that's out of reach, and
    its preview says so.
  - Open: Oswin still guards from across
    the arena. A bodyguard should probably
    have to be near.
- **The arena screen, first cut** (PR B):
  - The turn order row and the arena stay
    on top; abilities, both sides and the
    log scroll under them.
  - Tap the arena to pick a spot (a dashed
    ghost); tap the unit to clear it. Then
    an ability: foes it reaches from there
    are ringed and show their preview.
    Tap one, in the arena or the list.
  - With no spot picked, tapping a foe out
    of reach still walks toward it.
  - "Wait" or "Move and end turn" ends the
    turn without acting.
  - The shaded range is a plain circle of
    Move; it doesn't yet leave out spots
    the unit can't stop on.
  - Moving after acting is in the rules
    but not on the screen yet.
  - No ticks on screen: the row shows the
    order after the planned move, with the
    unit on turn circled where it lands.
  - Ability rows say only "Light" or
    "Heavy" for weight; the row shows what
    it does. A downed unit's row keeps its
    empty gauges.

- **Turns in steps** (from 0.0.4):
  - Moving, general actions (wait, and
    later others) and skills are separate
    on screen.
  - Every turn the unit can walk its full
    Move, in as many steps as it likes,
    before and after acting. Later,
    skills or foes may cut what's left.
  - A planned move can be dragged,
    nudged and undone freely until it's
    committed. Committing walks it, and
    can't be undone: nothing happening on
    the way (no trap) is information.
    Acting, or an event on the way, also
    commits.
  - A skill can only be used on a foe it
    reaches; it no longer walks toward a
    foe out of reach.
- **The danger zone** (from 0.0.4): a
  toggle shades where foes could reach
  on their next turns, moving and
  attacking, ranged attacks too. It
  comes only from what each foe has
  shown: the furthest it has moved, and
  the abilities it has used. A foe that
  hasn't moved far yet may go further.
  This is the first piece of knowledge
  (see "Ranges come from what you don't
  know").
- **Balance** (from playing 0.0.4 and
  0.0.5): the foes were far too strong;
  the sample fight was lost however it
  was played. Units should be about even
  with each other: each pair tuned in
  simulation (plain choices on both
  sides, both ways round) to near even,
  so that tactics decide a fight.
- **Layers, not health** (owner's call):
  - No health. A unit wears layers,
    outermost first (plate; a tower
    shield over mail; an energy shield
    over plating), down to its body, a
    natural last layer (thin flesh; a
    fire demon's ember hide; a rock
    unit's stone).
  - With every layer, body too, gone,
    the unit is exposed: the next hit
    that does any damage knocks it out.
    Breaking the last layer never knocks
    out in the same hit.
  - No physical/special split. A hit
    has a damage kind (slash, pierce,
    crush, burn, shock, …); a layer has
    a material (metal, wood, flesh,
    energy, ember, …). A table says how
    each kind meets each material (0
    immune, 50 resists, 150 weak), and
    a layer can override it (ember is
    immune to burn). Kinds and materials
    are open lists: poison and others
    join as units need them.
  - Carry-over is conditional: what's
    left of a hit that breaks a layer
    stops there, unless the table says
    that kind carries through that
    material, or the ability pierces.
    Some abilities skip a material.
  - Expertise instead of Attack and
    Magic: each unit has levels (1-5,
    untrained to master) in disciplines
    (blades, shields, fire, …), and an
    ability's discipline scales its
    power (60% to 140%). Disciplines are
    an open list too; expertise may do
    more than damage later.
  - Stats left: Speed and Move.

## Next: movement

Free movement, as in `brainstorm-2.md`
(Movement), in pull requests:

- **A, rules** (done, #15).
  Whole-number positions,
  each unit a circle (a size radius) with a
  Move stat, and each ability a reach
  (melee, edge to edge) or a range. A turn
  is moving up to Move and one action,
  either order, movement split around it.
  The stand-in AI walks toward its target.
  An open arena (no obstacles yet). The
  forecast covers moves, and its turn order
  replaces tick talk.
  - With it, the sample battle is half as
    long (720 ticks, not 1404): Ashka and
    Kestrel-9 shoot from range while
    Gerald and Oswin spend turns walking.
- **B, the screen** (done, #16, 0.0.4):
  a top-down arena of placeholder circles;
  where the unit on turn can reach;
  picking a spot, then a foe in reach with
  its preview; the turn order as a row,
  showing where the unit lands.
- **B2, turns in steps** (done, #17,
  0.0.5): the
  rules take a turn a step at a time:
  move (any number of legs, up to Move
  in all), one action, end. The screen
  splits moving, actions and skills;
  hold and drag a ghost, nudge it with a
  directional pad, commit the walk. A
  skill only targets foes in reach.
- **B2b, layers** (0.0.6, in progress):
  layers,
  damage kinds, materials and expertise
  in the rules, the sample units remade
  and balanced, layer bars and previews
  on screen.
- **B3, the danger zone** (0.0.7): the
  rules record what each side has seen
  of the other (furthest move, abilities
  used); the screen shades the danger
  zone from that, behind a toggle.
- **C.** Obstacles and pathfinding (the
  hidden fine grid), then terrain.
  Traps join here: an event on the way
  stops and commits a walk.

## After that

Roughly, and reordered by how each build
feels: ranges from unknown stats
(knowledge); a better AI; status effects;
commander actions.
