# Brainstorm 3: Beyond the battle

Ideas that came up while iterating on the
battle (`ITERATION.md`) but reach past it:
game modes, money, saving and sharing.
They build on `brainstorm-2.md`, which is
left as written. Ideas about the battle
itself go in `ITERATION.md` instead.
Nothing here is final, and every name is a
placeholder.

---

## How the docs grow

- **Each part of the game gets its own
  iteration doc** when work on it starts
  (the battle's is `ITERATION.md`; a
  facility or the party might be next).
- **Once the moving parts are playable**, a
  roadmap doc takes the game from there to
  1.0.0, the first App Store release.
- Until then, the brainstorms hold the
  ideas, and iteration docs hold what was
  tried and decided.

## Facilities

Like the Battle Frontier in the
`pokeemerald-expansion` fork: several places
to play, each with its own rules, all
paying out currency for victories. Names
are to be decided.

1. **Draft.** Units offered at random,
   swapped in from beaten teams (the
   Battle Factory).
   The first facility to build, once the
   battle is at a good point.
2. **Constructed.** You choose which units to
   bring. Foes always have a commander
   ("commander" is a placeholder name too).
3. **Auto.** You pick your units, with no
   commander, and they battle by themselves.
   You watch. It needs the AI levels to
   play your side.
4. **Dungeon.** A never-ending dive against
   overall weaker units, such as skeletons
   and goblins, with boss battles and loot of
   some kind.
5. **Games.** Not a death match, but a match
   with a goal:
   - **Capture the flag**: carry the foes'
     flag back to your side. Carrying it
     might cost movement or bonuses, and a
     carrier knocked out drops it.
   - **A soccer-like game**: a ball units
     move with hits (a crush hit knocks it
     further than a slash); score in the
     foes' goal; most goals after a set
     number of rounds wins.
   - **Escort**: walk your commander, now
     a fragile unit on the field, to the
     other side of the novarena unharmed.
     Bodyguards, wards and reactions matter
     most here.

   The rules need a battle's win condition
   to be part of its setup (not always
   "last side standing"), objects on the
   field (a flag, a ball, goal zones), and
   maybe a round limit with a score. All of
   it stays deterministic.

`brainstorm-2.md` has more (a party
gauntlet, a boss rush, trials, survival).

## Runs and bosses

- **Every 10th battle is a boss battle**: the
  foes bring a commander of their own, with
  its own place in the turn order and its
  own commander actions (the commander
  itself is in `ITERATION.md`).
- Each facility keeps its own streak and
  record.

## Unit tiers

From the `pokeemerald-expansion` fork, a
tier for every unit (names are
placeholders):

- **Regular**: most units.
- **Pseudo**: a step above, rarer.
- **Legendary**: bosses' units.
- **Mythical**: the rarest of all.

Where they show up:

- **Draft**: a starting team is regular
  units, perhaps with one pseudo pick.
- **Boss battles** may bring a legendary
  unit.
- **The hardest fights** (the Frontier
  Brain's equivalent, a facility's head
  at set points in a streak) may add a
  mythical one.

Balance: units are balanced against
their own tier, so each should win about
half its battles against units of that
tier (`BalanceTests` per tier). A higher
tier is stronger than the one below.
Open:

- How much stronger each tier is.
- How a fight against a legendary or
  mythical stays winnable: the player's
  commander, a numbers edge, or
  something else.
- What a tier is made of: more layers,
  more abilities, rare mechanics.

## Currency

- **Earned by winning**, in every facility.
- **What it buys is open**: recruits,
  upgrades or items, cosmetics.
  `brainstorm-2.md` has the options.

## Saving

The first time the game needs saved data:
runs, streaks, currency and the party must
survive closing the app. Per `CLAUDE.md`,
it starts from the template's SwiftData
with a frozen, versioned schema and
migration tests, so saved data is never
lost.

## Novarenas, shared

The fields themselves (biomes, obstacles,
the oval, the seed that generates them) are
part of the battle, in `ITERATION.md`.
Beyond it:

- **"Novarenas"** as the name for the
  fields.
- **A field is a seed**, a number, so it can
  be shared: a field of the day for
  everyone, or replaying a field you liked.
- **A replay is a seed plus the commands**
  (`brainstorm.md`'s replays): tiny, and
  exact, since nothing in a battle is left
  to chance.
