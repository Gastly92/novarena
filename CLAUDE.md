# CLAUDE.md

Novarena: a SwiftUI iPhone app, set up for
developing entirely from an iPhone with
Claude Code and the GitHub app, never a
desktop or Mac. Everything that needs a
Mac (building, testing, signing,
uploading) runs in CI.

## This app
- What it is: an endless, turn-based
  tactics game with roguelike runs. An
  interdimensional entity pulls hand-made,
  named heroes from every era of fantasy
  into its pocket world to fight
  gladiator-style against random teams,
  with no dice mid-battle. Design notes:
  `brainstorm-2.md` (current),
  `brainstorm-3.md` (ideas beyond the
  battle, from iterating) and
  `brainstorm.md` (the earlier ship idea).
  The roadmap is at the end of
  `brainstorm-2.md`, which is left as
  written.
- Now: iterating on the battle until it's
  good, then building the game from there
  (`ITERATION.md`: how it works, each
  build and how it felt, decisions, and
  the next pull requests). One pull
  request at a time; after one that
  changes the game merges, send it to
  TestFlight and ask how it felt, and let
  that choose the next. Record decisions
  and feedback in `ITERATION.md`.
- The name: nova (a new star) and arena
  (Latin for sand, the fighting floor).
  Written as one word, never with a
  capital A in the middle (it reads as
  "Nov").
- Bundle ID `com.gastly92.novarena`.
- Repo `gastly92/novarena` (first
  created as `ios-game-01`).

## The rules (Packages/RuleSteward)
- The game's rules, carried out, with no
  UI: units, the timeline, damage,
  shields, resources and a battle played
  turn by turn. The design is in
  `brainstorm-2.md`. The app imports it
  (`project.yml`); `Models/Fight.swift`
  runs a battle for the screen, so view
  code never decides a rule.
- Text from the rules (unit and ability
  names, the log) isn't translated yet:
  views show it with `Text(verbatim:)`
  and a `data-` identifier, which
  `LocalizationTests` lets through. When
  the rules get translations, drop the
  prefix there.
- Words: a **unit** is any character in a
  fight, either side (not all fight); the
  player's group is the **party**. Not
  hero, fighter, clan or roster. Foundation
  has its own `Unit` (measurements), so a
  module importing both says `typealias
  Unit = RuleSteward.Unit` once (see
  `Tests/RuleStewardTests/Fixtures.swift`).
- No dice, ever: whole numbers only,
  rounded down; no random numbers, clock
  or floating point. The same choices
  always give the same battle.
- Tests: `.github/scripts/rules-tests.sh`
  runs them on Linux in Docker (Swift
  pinned in `.github/swift/Dockerfile`),
  and fails unless they run every line
  and region of `Sources/`. CI's `Rule
  tests` job runs the same script, so run
  it before pushing rules changes. For
  quicker loops, a Linux Swift toolchain
  from swift.org runs `swift test` in the
  package directly.
- `SampleBattleTests` pins the whole log
  of the four sample units' battle. A rule
  change that changes that fight changes
  the log: check the new lines read right
  (turn ticks, damage by the formula),
  then update them in the same PR, so the
  diff shows what the change did.

## Building
- This container is Linux: nothing
  Swift/Xcode builds locally. CI is the
  compiler.
- `.github/workflows/ios-build.yml` runs
  on every PR and push to `main` (macOS
  runners: GitHub's `xcode-27` image, as
  App Store Connect refuses builds from
  an older SDK from April 2027, and
  `macos-26` jobs sat queued until GitHub
  cancelled them; for the next Xcode,
  change every `runs-on` in both
  workflows, list the label in
  `.github/actionlint.yaml` if actionlint
  doesn't know it, and re-record the
  snapshots). It generates the project and
  builds the tests once, then runs them in
  two shards on separate runners in
  parallel (`.github/scripts/run-tests.sh`;
  `main`, and `localization` for
  `LocalizationTests` alone), and a
  `Coverage` job merges the shards'
  results. A Release device build runs
  alongside. The CI summary shows how long
  building and each shard took. Docs-only
  PRs (`*.md`, `docs/`, `site/`) skip the
  macOS jobs. `CI Gate` is the single
  pass/fail check for a PR; the repo's
  `main` ruleset requires it (see
  `docs/NEW-APP.md`), so keep its name.
- Tests: `NovarenaTests/` (unit tests for
  logic in `Novarena/Models/`) and
  `NovarenaUITests/` (XCTest UI tests that
  launch the app and check the screen).
  Both run in the scheme's test action.
- Screens: every full screen is a view in
  `Novarena/Views/Screens/` (one per file;
  pieces of screens go in
  `Views/Components/`). Each screen and
  screen state has a case in `ScreenID`
  (`Novarena/Support/`, also compiled into
  the UI tests) and is shown by
  `Novarena/Views/ScreenHost.swift`, which
  UI tests open directly with
  `-showScreen <id>`. CI's `Screen list`
  job fails if a screen in
  `Views/Screens/` isn't in `ScreenHost`.
  The Coverage job's `Screen list gate`
  (`unpictured.sh`) fails on view code no
  ScreenID draws (from the localization
  shard's coverage), so every state gets a
  snapshot. Lines that are never drawn
  (what a tap does, a sheet's contents) go
  in `.github/unpictured.txt` with why.
- Accessibility: use system colors and
  text styles (or `@ScaledMetric` for big
  custom sizes) so text scales and both
  light and dark mode work; the
  `fixed_font_size` lint rule flags fixed
  sizes. Large text snapshots show every
  screen scaled. Check on the phone too
  before a release.
- All user-facing text must be
  translatable:
  - In views, pass literals to `Text`,
    `Label`, `Button`, etc. Helper
    parameters that reach `Text` are
    `LocalizedStringKey`, not `String`.
    Never join text with `+` (one literal,
    or a `"""` literal with `\` line
    breaks).
  - Text built in `Models/` or `Support/`
    uses `String(localized:)`, as whole
    sentences (no gluing words together).
    A SwiftLint rule flags plain sentences
    there.
  - Words that change with a number ("1
    day" / "2 days") get plural forms in
    `Novarena/Localizable.xcstrings`; edit
    its JSON by hand (no Xcode here).
  - CI's `String catalog` job
    (`check-strings.py`) fails on catalog
    keys no Swift string uses any more;
    delete them with the code.
  - `LocalizationTests` runs every
    `ScreenID` in a pseudo-language that
    brackets translatable text, and fails
    on unbracketed text
    (`LocalizationCheck`; tell it which
    system text to let through).
- SwiftLint runs in CI with `--strict`
  (warnings fail). Config:
  `.swiftlint.yml`. Every opt-in rule is
  on; the few turned off each say why
  there. When two rules disagree, keep the
  one that makes code shorter. No
  `swiftlint:disable` comments in code:
  fix the cause (a flagged line usually
  has a cleaner form), or turn the rule
  off in `.swiftlint.yml` with a reason.
  Run `.github/scripts/swiftlint.sh`
  before pushing Swift changes: CI's
  SwiftLint job runs the same script, in
  Docker with the version pinned in
  `.github/swiftlint/Dockerfile` (the
  session start hook prepares it).
- Lines max 45 chars, so a diff line fits
  a phone in portrait without wrapping.
  This covers docs, YAML and scripts too:
  CI's `Line length` job runs
  `check-lines.py` (it skips URLs, single
  unbreakable words, Markdown tables and
  code blocks, and `uses:` lines). It
  reads only files git tracks, so `git
  add` new files before running it.
  Indent with 2 spaces. To fit:
  - Prefer short, clear names; a long line
    often means a name could be shorter.
  - Pull deeply nested view code into a
    small helper view or property, but
    only where nesting is what pushes lines
    over.
  - Use the helpers: `.testID(_:)`,
    `.fullWidth(_:)`, `.wrapsText()`
    (`Views/Components/ViewHelpers.swift`);
    in UI tests `App.start`,
    `app.text(_:)`, `element.appears()`.
  - Long text uses a `"""` literal with
    `\` line breaks (one key, still one
    sentence).
  - Otherwise wrap: one argument per line
    is fine.
- Wrapped Swift lines go in one level (2
  spaces), never aligned by hand:
  SwiftLint's `indentation_width` rule
  checks it.
- Compiler warnings are errors, and every
  target builds in Swift 6 language mode,
  so data races are compile errors. The
  `unchecked_concurrency` lint rule bans
  the ways around that check
  (`@unchecked Sendable`,
  `nonisolated(unsafe)`,
  `@preconcurrency`). A handler for
  notifications Apple posts from
  background threads (Core Data,
  CloudKit) is `@Sendable` and hops to
  the main actor itself (`Task {
  @MainActor in … }`): a main-actor
  handler compiles but crashes when the
  post comes from another thread.
- Coverage gate (`coverage.sh`): every line
  of the app must run in tests (unit,
  snapshot and UI tests all count); the
  log names each untested function. Keep
  decisions out of views: put them in
  `Models/` or `Support/` and unit test
  them. Pass in outside pieces (store,
  clock, notifications) so tests can fake
  them. For an Apple class tests can't
  fake (e.g. `CKContainer`), declare a
  protocol with only the methods used,
  conform the class in an empty extension
  (`extension CKContainer: Cloud {}`), and
  pass fakes in tests. An Apple object
  tests can't make (e.g. a CloudKit
  event): read its fields by key-value
  coding, so a test can post an
  `NSObject` with the same `@objc`
  properties. Every button and branch in
  a view needs a UI test or snapshot that
  reaches it; code nothing can reach gets
  deleted. A view using Swift's automatic
  initializer shows its private property
  defaults as untested; give it an
  explicit `init`.
- UI tests launch the app with
  `App.start`, which passes `-uiTesting`;
  the app then turns off UIKit animations,
  so a test never acts on a screen still
  sliding in. No retries or longer waits
  in UI tests. `run-tests.sh` runs a shard
  once more only when the UI test runner
  failed to start and no UI test ran, or
  the simulator dropped out before any
  test ran; it adds a warning and a
  summary line. (The template's
  long-press helper, `menuItem`, retried
  a long-press read as a tap after a
  runner stall; bring it back from
  `gastly92/ios-template` when a screen
  needs a long-press.)
- In `@MainActor` tests, wait with
  `await fulfillment(of:)`, never
  `wait(for:)`: it blocks the main actor,
  so work that needs it never runs.
- Read many elements in one accessibility
  snapshot (`app.snapshot()`), not
  element by element: hundreds of separate
  queries a screen timed out when a runner
  stalled.
- Snapshot tests take a picture of every
  `ScreenID` with `Looks.check` in light,
  dark and large text (on a screen three
  phones tall, so long screens show in
  full). Once screens show dates, fix the
  day too (the template's `\.now`
  environment value). Images live in
  `NovarenaTests/__Snapshots__/`. CI records
  missing ones and commits them to the PR
  branch (pull before pushing again),
  pushing with the snapshot app's token so
  CI runs on the new commit
  (`docs/SNAPSHOT-APP.md`). Without the
  app's secrets (e.g. Dependabot PRs) it
  pushes with CI's own token and starts
  the run itself; GitHub then also holds a
  duplicate behind "Approve and run"
  (`action_required` in `actions_list`),
  which needs no approval. Look at the
  images, then push the next real change.
  Deleting images re-records them too.
  After an intended visual change, add
  the `record-snapshots` label to the PR
  to record all of them again; a failed
  comparison uploads `snapshot-diffs`.
  `precision: 0.9999` lets only 0.01% of
  pixels differ (~130 on a phone image):
  runners now and then draw up to ~36 a
  shade off, so 1 and 0.99999 were
  flaky. Don't loosen it further: at
  0.99 a changed date format passed.
  Re-record after Xcode, iOS or snapshot
  library updates. Nothing animated on a
  snapshot screen: a `ProgressView`
  spinner draws a different frame each
  run, so use a still image there.
  CI tests on iPhone 17 with the iOS the
  images were drawn on, saved in
  `__Snapshots__/iOS.txt` (`run-tests.sh`
  logs which), so every run matches even
  while GitHub rolls out a new runner
  image. `record-snapshots` draws on the
  newest iOS and saves it; so does the
  first run without the file (a new app).
  A newer iOS on the runner only warns on
  the PR: move to it by adding
  `record-snapshots`. If the saved iOS is
  gone, the snapshot tests fail and say
  to record again (iOS draws system
  controls, e.g. the date picker's
  format). On `main`, a newer iOS opens a
  PR moving to it, assigned to the owner
  (`docs/IOS-UPDATES.md`). Tests run in
  US English and UTC whatever the
  simulator's settings (`project.yml`
  scheme, `App.start`).
- Test-only Swift packages are declared in
  `Packages/TestSupport/Package.swift`
  (pinned with `exact:`), which tests
  `import TestSupport` to get. Dependabot
  opens weekly PRs for them, and for the
  GitHub Actions, SwiftLint and the
  workflow checkers' versions:
  check CI and summarize what changed
  (release notes); the user merges. If
  snapshots change, re-record them before
  merging.
- CI's `Workflows & scripts` job runs
  actionlint on `.github/workflows/` and
  ShellCheck on every `*.sh`. The session
  start hook installs both (versions in
  `.github/checkers/requirements.txt`,
  which Dependabot bumps), so run them
  before pushing workflow or script
  changes. Runner labels actionlint
  doesn't know yet go in
  `.github/actionlint.yaml`;
  `runner-labels.sh` fails once it knows
  one, so the entry gets dropped.
- Periphery (CI step after the build)
  fails on unused code. Delete it rather
  than ignore it; no `periphery:ignore`
  comments. For a real false positive,
  restructure the code or ask the user.
- No saved data, notifications or
  settings yet. When they come, start
  from the template's versions
  (`gastly92/ios-template`): SwiftData
  with a frozen, versioned schema and
  migration tests (saved data must never
  be lost); a `Notifier` passed in at
  launch; `@AppStorage` with test-owned
  `UserDefaults` (and the privacy
  manifest's `CA92.1` reason).
- The Xcode project is generated from
  `project.yml` by XcodeGen. Never add a
  `.xcodeproj`; put new source files under
  `Novarena/` (picked up automatically) and
  build settings in `project.yml`.
  Info.plist is generated from
  `INFOPLIST_KEY_*` settings there. Add
  permission strings the same way.
- After pushing, check CI with the GitHub
  MCP tools (`actions_list`,
  `get_job_logs`) and fix failures before
  calling the work done. Re-read Swift
  changes carefully first, since each CI
  round trip takes a few minutes.

## Shipping to the phone (TestFlight)
- `.github/workflows/testflight.yml`
  (manual, `workflow_dispatch`) archives,
  cloud-signs with an App Store Connect
  API key, uploads to TestFlight, and tags
  the commit (e.g. `v0.4.6-build12`).
- One-time setup (bundle ID, App Store
  Connect app, an API key, and the repo
  secrets `APPLE_TEAM_ID`,
  `ASC_ISSUER_ID`, `ASC_KEY_ID` and
  `ASC_KEY_P8`): the steps are in
  `docs/NEW-APP.md`; walk the user through
  them. Never print, log, or ask for the
  secrets.
- When asked to ship or test on the
  phone, trigger it with
  `actions_run_trigger` (`run_workflow`,
  `workflow_id: testflight.yml`,
  `ref: main`). Verify the log shows
  "Upload succeeded". The build shows in
  TestFlight about 5–15 min later.
- Version scheme (`MARKETING_VERSION` in
  `project.yml`; Apple allows only three
  numbers): early builds are `0.0.x`,
  starting at 0.0.1 (the hello world),
  bumped in the PR that changes what
  reaches the phone. The scheme past that
  is decided once the battle prototype
  feels right (roadmap step 4).
  1.0.0 is the first App Store release;
  after that, patch for bug fixes, minor
  for new features. Build number =
  workflow run number (automatic).
- iOS 17+, iPhone only, portrait.
  `ITSAppUsesNonExemptEncryption` is NO;
  keep it that way unless adding real
  encryption.
- Capabilities that need entitlements
  (HealthKit, push, iCloud, App Groups)
  need extra signing setup: a
  `.entitlements` file via `project.yml`,
  the capability enabled on the App ID,
  and changes to the TestFlight workflow
  (it archives with
  `CODE_SIGNING_ALLOWED=NO`). iCloud sync
  step by step, with what was learned
  building it: `docs/ICLOUD.md`.
- Keep the privacy manifest
  (`Novarena/PrivacyInfo.xcprivacy`) and
  the privacy page (`site/privacy.html`)
  true to what the app does: update both
  when adding tracking, collected data, or
  APIs Apple requires a reason for (e.g.
  `UserDefaults` / `@AppStorage`: reason
  `CA92.1`). `PrivacyInfoTests` checks the
  manifest.
- `site/` holds the App Store support and
  privacy pages; `pages.yml` publishes
  them to GitHub Pages on each push to
  `main` that changes them, at
  `https://<owner>.github.io/<repo>/` and
  `.../privacy.html` (the URLs App Store
  Connect asks for). Keep the support page
  true to the app's features.
- App Store screenshots: `AppStoreTests`
  draws them with `AppStoreShots` from the
  same screens as the snapshots, framed
  and captioned, at the sizes App Store
  Connect takes; the images to upload are
  in
  `NovarenaTests/__Snapshots__/AppStoreTests/`.
  Update the shots and captions when a
  pictured screen or a listed feature
  changes.
- The app icon comes from
  `.github/scripts/app-icon.sh <mark>
  <color> <color>` (a letter or two on a
  gradient, in light, dark and tinted),
  and the product page header from
  `.github/scripts/app-header.sh`. Both
  run in the cloud session (ImageMagick).
  Use the same colors in `AppStoreTests`.
