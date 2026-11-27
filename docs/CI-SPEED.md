# CI speed

Where the time goes in a run of
`ios-build.yml`, and what could make it
faster. None of this is done yet: each idea
is a CI-only pull request to try, measure,
and keep only if it helps.

## Where the time goes

From PR #20's run 80 (November 2026), about
10½ minutes from push to result:

| Stage | Time | Notes |
|---|---|---|
| Linux checks | under 1 min | In parallel; never the slow part |
| Build for testing | 2 min 45 s | The build 1 min 51 s, Periphery 25 s |
| Each test shard | about 6 min 20 s | About 3 min of it is downloading the build; tests 2½–2¾ min |
| Coverage, CI Gate | 30 s | |

## Ideas

### 1. Build in each shard

The likely biggest win, about 2 minutes a
run.

- Each shard spends about 3 minutes
  fetching the 9 MB `test-build` artifact:
  around 2 minutes before the download even
  starts, then 37 s to transfer it. Run 80's
  two shards and the run before it were the
  same.
- Building takes 2 minutes, so each shard
  building for itself, in parallel, beats
  waiting for the download.
- Periphery stays in one shard (it reuses
  that build's index).
- The cost: more Mac runner minutes.
- An alternative to try: pass the build
  through `actions/cache` with a
  per-run key instead of an artifact. It may
  download faster, but that's less certain.

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
