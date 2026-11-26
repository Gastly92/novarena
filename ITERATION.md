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

## Next: movement

Free movement, as in `brainstorm-2.md`
(Movement), in pull requests:

- **A, rules.** Whole-number positions,
  each unit a circle (a size radius) with a
  Move stat, and each ability a reach
  (melee, edge to edge) or a range. A turn
  is moving up to Move and one action,
  either order, movement split around it.
  The stand-in AI walks toward its target.
  An open arena (no obstacles yet). The
  forecast covers moves, and its turn order
  replaces tick talk.
- **B, the screen** (0.0.4): a top-down
  arena of placeholder circles; where the
  unit on turn can reach; picking a spot,
  then a foe in reach with its preview; the
  turn order as a row, showing where the
  unit lands.
- **C.** Obstacles and pathfinding (the
  hidden fine grid), then terrain.

## After that

Roughly, and reordered by how each build
feels: ranges from unknown stats
(knowledge); a better AI; status effects;
commander actions.
