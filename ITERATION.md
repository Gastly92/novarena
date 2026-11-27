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

This doc is the battle's only. Ideas beyond
it (facilities, currency, saving) go in
`brainstorm-3.md`; each part of the game
gets its own iteration doc when its work
starts.

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

- **0.0.5, turns in steps**: move,
  skills and actions apart; drag and
  nudge a ghost, commit the walk.
  - Wanted: waiting should be worth
    something (now: saving pools for a
    later turn, see Pools).
  - Hard to move the full distance in
    one direction: the ghost should snap
    to the edge of the range.
  - Show a skill's reach, not just the
    move's.
  - Centimetres don't read well as a
    unit.
- **0.0.6, layers**: layers, damage
  kinds, materials and expertise.
  - Wanted: a skill picked against a foe
    out of reach should plan the walk
    into reach, to commit then use.
  - Wanted: the turn ending by itself
    once nothing's left, as a setting.
  - Wanted: danger zones per foe, and
    the party's own zones too, by kind
    (heal ranges, a foe's revealed
    heals).
  - Wanted: foe layers and damage
    previews as percentages.
  - Wanted: a battle info sheet
    (intensity, weather and the like).
  - Wanted: more units, and a way to
    try them out.
- **0.0.7, pools**: pools, bonus
  actions, measures, the skill's reach
  ring.
  - After the main action, the skills
    should stay open while a bonus is
    left, not jump to ending the turn
    (fixed in 0.0.8).

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
  was played. No unit is good or bad,
  and there are no fixed sides: every
  team of one to three (repeats
  allowed) fights every other of its
  size, both ways round, with plain
  choices on both sides, and each unit
  should win about half the battles
  it's in, at every size (40-60%;
  `BalanceTests`). Battles can have
  more than two units a side.
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

- **Pools** (from 0.0.5):
  - A unit has any number of pools
    (movement, stamina, mana, charge,
    fuel…), each with a maximum and a
    refill each turn. Some reset each
    turn (movement: standing still
    doesn't let you sprint later);
    others carry over up to the maximum,
    so a unit can save up for a bigger
    turn (charge over three turns for a
    big attack).
  - Moving spends the movement pool; a
    unit without one can't move. A skill
    can cost from several pools.
  - One main action a turn, plus bonus
    actions: each bonus skill is in a
    group with a number of uses a turn
    (a wizard's cantrips share one; a
    rogue's dagger throw and jump each
    have their own).
  - The timeline stays: Speed, and the
    main action's weight.
  - The stand-in AI uses its bonus
    actions after its main one, on the
    foe each hurts most (it should: a
    free action left unused is a waste).
- **Measures, not centimetres**: the
  rules keep whole centimetres, but the
  screen shows named measures, each a
  name and a length: a unit's movement
  in its own (steps for walkers, fuel
  for a mech), a skill's reach in its
  own. Names are placeholders until
  better ones come.
- **Height** (z): every spot has a
  height as well as x and y, and reach
  is measured in three dimensions, so a
  flier above is out of a sword's reach
  but not a spear's. Everyone is on the
  ground for now. With terrain (C):
  hills and walls give height; moving
  up costs by how a unit gets around
  (walkers pay to climb, climbers scale
  walls, heavy units can't, fliers
  change altitude freely and pass over
  ground obstacles); high ground
  lengthens ranged reach, and paths
  curve around what's in the way (the
  ghost's snap to the edge then follows
  the path).

- **AI levels** (owner's call): foes
  get harder by playing better, never
  by stronger numbers, so the units stay
  balanced and balance runs use the same
  AI on both sides. One interface, a
  level per way of choosing a turn:
  - Basic: today's stand-in.
  - Tactical: focuses fire, stays out of
    known danger, keeps range, saves
    pools for a big turn.
  - Planner: looks a few turns ahead,
    simulating likely replies (no dice,
    so lines play out exactly).
  - Omniscient: the planner, deeper,
    seeing everything.
  The first three only know what they've
  seen of the other side, as the player
  does (the danger zone's knowledge).
- **Usability** (from 0.0.6):
  - A skill picked against a foe out of
    reach places the ghost at the
    nearest spot in reach, to adjust,
    commit, then use.
  - The turn ends by itself once nothing
    is left to do (main action used, no
    usable bonus, no movement), as a
    setting, on by default.
  - So a settings screen comes, reached
    from home, saved with `@AppStorage`
    (test-owned `UserDefaults`, the
    privacy manifest's `CA92.1`, the
    privacy page).
- **Pan and zoom** the arena: pinch and
  two-finger drag, the one-finger drag
  still moving the ghost; with bigger
  arenas and terrain.
- **Zones and percentages** (from
  0.0.6):
  - Each foe's danger zone toggles on
    its own (tap the foe); the party's
    units show their zones too, coloured
    by kind: harm in red, heals in
    green (a foe's heals once revealed).
  - Foe layers, and damage previews on
    them, show as percentages of the
    layer; the party's own stay exact.
  - A battle info sheet: intensity, the
    round, and weather once it exists.
- **New units** (from 0.0.6), with
  healing in the rules: a cleric who
  heals; a rogue with a free dagger
  throw and jump each turn and a dodge;
  an archer (pierce, leather); a stone
  golem that resists pierce; an ice
  mage whose cantrips share one bonus,
  bringing a freeze kind. A simple
  picker for who fights, to try them
  (the real draft is a facility, in
  `brainstorm-3.md`).
- **The commander** (owner's call; the
  name is a placeholder): the player,
  off the field, gets a portrait in the
  turn order and acts from afar on its
  turns:
  - Restore 25% of what's left of a
    unit's outer layer.
  - Once per battle per unit, a ward:
    a new outer layer that soaks the
    next 3 hits.
  - Foes have one in boss battles
    (`brainstorm-3.md`).
- **Reactions** (owner's call): things
  units do out of turn, when something
  happens: being attacked, a foe moving
  by, a spell cast, an ally hit.
  - Passives react by themselves (a
    bodyguard stepping in, a rogue's
    dodge); others ask (a wizard's
    counterspell: "React? Yes / No").
  - One reaction a round; some cost
    pools.
  - Previews say "may be dodged" when
    a reaction could change the result.
  - A setting per reaction: ask, always
    or never.
- **Novarenas, the fields** (owner's
  call):
  - Biomes from Earth's ecosystems:
    forest, volcano, beach and more,
    each with its own ground (sand,
    water, burning vents) and weather.
  - Obstacles: walls of brick or steel,
    breakable, with a material and
    points like a layer, so the matchup
    table covers them (crush breaks
    brick; slash barely marks steel).
    They block movement and sight.
  - Towers with ladders: height, which
    walkers climb, heavy units can't
    and fliers skip.
  - The shape of a track-and-field
    oval: long straight top and bottom,
    curved ends, walled all round by
    impenetrable barriers. The sides
    deploy clear of the curves.
  - The camera can switch perspective
    (top-down and tilted). Open:
    `brainstorm-2.md` planned sprites at
    one fixed 3/4 angle with no 3D, so
    this needs real 3D or drawn angles;
    decide before the art.
  - Generated before each match from a
    seed: the biome, then its ground,
    then obstacles from its set. A
    whole-number generator in the rules,
    so the same seed is the same field
    and battles stay free of chance.
    Fields are fair (mirrored or
    balanced), always passable, nobody
    deploys in an obstacle, and
    `BalanceTests` runs over many seeds.
    Hand-made fields come first.

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
- **B2b, layers** (done, #18, 0.0.6):
  layers,
  damage kinds, materials and expertise
  in the rules, the sample units remade
  and balanced, layer bars and previews
  on screen.
- **B2c, pools** (done, #19, 0.0.7):
  pools,
  bonus actions, named measures and
  height in the rules; on screen, pool
  bars, measures, the picked skill's
  reach as a ring, and the ghost
  snapping to the edge of the range.
- **B3, the danger zone** (done, #20,
  0.0.8): the
  rules record what each side has seen
  of the other (furthest move, abilities
  used); the screen shades the danger
  zone from that, behind a toggle.
- **B3b, zones and percentages**
  (0.0.9): per-foe and party zones by
  kind, percentages for foes, the
  battle info sheet.
- **Units**: healing, the five new
  units, the picker.
- **The commander**: its turn and
  actions.
- **Reactions**: triggers, automatic and
  asked, the one-a-round limit.
- **B4, usability**: plan the approach
  to a far foe, end turns by
  themselves, the settings screen.
- **AI, basic and tactical**: the AI
  levels' interface, and the tactical
  level.
- **C.** The oval novarena; obstacles
  (breakable walls) and pathfinding
  (the hidden fine grid); terrain,
  biomes and height (towers), with pan
  and zoom and the camera; then fields
  generated from a seed. Traps join
  here: an event on the way stops and
  commits a walk. Then the planner and
  omniscient AI.

## After that

Battle ideas from the brainstorms not
planned yet, roughly in order and
reordered by how each build feels:

- **Status effects** (`brainstorm-2.md`):
  kinds (boons, curses, stances,
  conditions), fixed durations, blocked
  by a matching layer (a ward stops a
  freeze), taxes not skips (a stun
  delays). The ice mage's freeze first.
- **Time magic and charged abilities**:
  haste, slow, delay, quicken; a
  charged spell sits in the turn order
  with its area drawn on the arena.
- **Ranges from unknown stats**
  (knowledge): previews as ranges for a
  foe not fully seen, narrowing as it
  shows more; `brainstorm.md` adds
  scanning, at a cost.
- **Traits**: always-visible passives
  (Small, Brave, immune to fire); an
  unrevealed one shows as "?".
- **Bodyguard range**: guarding only
  allies nearby (open since A).
- **Shove, knockback, knockdown,
  grapple**: decided by size and
  strength, with where someone lands
  previewed.
- **Protections**: last stand, a
  phoenix's rebirth egg, a hit cap
  aura, repair over time.
- **Scout and deploy**: see the field
  and foes, then place the party in its
  starting zone.
- **Weather, arena traits and
  surfaces**: fire burns grass and melts
  ice, frost freezes water to floor,
  shock spreads through water; hazards
  on a schedule shown in advance.
- **Pickups**: items on the field with a
  number of uses; one-time charms.
- **A picker for long ability lists**:
  grouped by kind, what's affordable
  first.
- **More commander powers** from the
  fork's gimmicks: Titan, Finisher, a
  transformation, a change of kind.
