# CI speed

Where the time goes in a run of
`ios-build.yml`, and what could make it
faster. Each idea is a CI-only pull
request to try, measure, and keep only if
it helps.

## Where the time goes

From PR #20's run 80 (November 2026), about
10½ minutes from push to result:

| Stage | Time | Notes |
|---|---|---|
| Linux checks | under 1 min | In parallel; never the slow part |
| Build for testing | 2 min 45 s | The build 1 min 51 s, Periphery 25 s |
| Each test shard | about 6 min 20 s | About 3 min of it is downloading the build while the simulator boots; tests 2½–2¾ min |
| Coverage, CI Gate | 30 s | |

## Ideas

### 1. Build in each shard (tried: slower)

Tried in PR #33 and dropped. The idea was
that each shard spends 2-5 minutes on the
9 MB `test-build` download (main's run
167: 2 min 14 s and 5 min 8 s, 14 min 15 s
in all) while the build takes 1½.

What happened:

- Booting the simulator at the start of
  the shard, then building (run 174):
  26 min 51 s. The boot slowed every step
  on the 3-core runner: `xcodebuild
  -version` took 1-5 min instead of 0 s,
  XcodeGen 1½-2½ min instead of 7 s, the
  build 7-9½ min instead of 1½.
- Building first, then booting (run 178):
  19 min 10 s. The builds took 38 s and
  1 min 12 s, but the boot moved into the
  tests: finding the simulator took 6
  min, and the main shard's tests 9 min
  instead of 5½.

So the simulator's first boot costs
minutes of CPU wherever it goes. Waiting
on the download hid it, and the boot is
probably why the 9 MB download is so
slow in the first place. Anything that
puts CPU work in that window makes the
run slower.

Merging coverage from the two shards'
separate builds worked, if a later idea
needs it.

### 2. Let PR builds use main's cache

Maybe a minute a run.

- The cache key includes a hash of
  `Packages/`, and the restore key keeps
  that hash, so a PR that changes
  `RuleSteward` (almost every one now)
  never finds main's build: the log says
  "Cache not found" and the build starts
  from nothing.
- A broader fallback restore key (any main
  build on the same Xcode) would reuse the
  compiled dependencies, recompiling only
  what changed.
- Measure it: restoring a large build
  folder takes time too, and it has to be
  quicker than what it saves.

### 3. Snapshot recording (keep as is)

Recording takes two full runs: one records
the images, then the bot's commit runs
everything again (about 20 minutes in
all). The second run checks the images on
the final commit, which is worth the time.

### 4. Small things (not worth changing)

- Cleaning up at the end of each Mac job
  (stopping leftover simulator processes):
  about 20 s.
- Installing XcodeGen with Homebrew: about
  10 s.

## Not speed, but due

Homebrew warns that `periphery` is
deprecated because its upstream repository
is archived. It will be disabled on
2027-08-12, and the unused-code step
fails from then. Before that: install a
pinned release binary instead of the
Homebrew formula, or move to another tool
if nobody maintains it any more.
