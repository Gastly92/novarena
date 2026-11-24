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

## The fight

- **Everyone fights.** Every fighter you bring
  enters the arena. No bench, no sitting out:
  games that don't let you use everyone are less
  fun.
- **The player is not on the field.** You command
  everyone from outside.
- **But the player can still reach in**: a
  limited set of commander actions, such as a
  healing spell or a bard-style influence (a song
  that speeds allies or steadies them). Needs a
  resource or limit so it is a choice each turn,
  not a free heal.

### No RNG, but not necessarily DOS2

The goal is no randomness mid-battle; DOS2's
physical/magic armour is one way, not a
requirement. Ways to keep fights interesting
without dice:

- **Fixed damage**, previewed before you commit.
- **Shield gating:** a status effect (freeze,
  knockdown) only lands once the matching
  defence is broken, so control is earned and
  predictable.
- **Visible foe intents** (Into the Breach, Slay
  the Spire): foes show what they'll do next.
- **Turn order shown in advance**, set by speed.
- **Ranges from hidden stats**, not from dice
  (pillar 4).

## Stats (open)

Not decided. Two things are clear:

- **Not MTG-small.** Attack 2 / toughness 3 is too
  coarse.
- **Not necessarily Pokémon's set** of Attack /
  Defense / Sp. Atk / Sp. Def / Speed either.

Options to explore:

- **A. Pokémon-like.** HP, Attack, Defense,
  Magic, Resistance, Speed. Familiar, lots of
  number-crunching.
- **B. Two shields over HP.** HP plus a physical
  shield and a magic shield that must be broken
  first; Power, Magic, Speed drive output.
  Damage type then matters on every hit.
- **C. Small stat set, rich abilities.** HP,
  Speed and a defence or two; most of the
  identity lives in abilities with fixed,
  level-scaled numbers.

Numbers in the tens to hundreds read well in a
damage preview ("140–180 of 600") and leave room
for small level-ups to matter.

## Progression

- **Heroes level up** and **unlock upgrades**
  (new abilities, passives, evolutions).
- **Currency** is earned by winning. What it buys
  is open: recruits, upgrades, training.
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

- **Clan size vs. fight size.** If everyone you
  bring fights, how many is that? Is the whole
  clan always in the fight (so clan size is
  capped), or do you pick a squad from a bigger
  clan before each run?
- **Stats:** option A, B, C, or something else?
- **Hero uniqueness:** is each named hero
  hand-made and one of a kind (collect all 80),
  or can names and variants be generated?
- **How do you gain heroes?** Recruit from teams
  you beat (Battle Factory swap), buy with
  currency, or both?
- **Fallen fighters:** knocked out for the fight
  only, injured for the run, or lost?
- **Commander actions:** how many, what resource,
  and are they chosen per run?
- **Run shape:** sets of fights with a champion at
  the end of each (Battle Factory's sets of
  seven), or one continuous climb?
- **What currency buys**, and whether there's one
  currency or two (in-run vs. persistent).
