// swift-tools-version: 6.0
import PackageDescription

/// The game's rules, carried out: units,
/// the timeline, damage, shields and
/// resources, and a battle played turn by
/// turn. No UI and no randomness, so it
/// builds and tests anywhere Swift runs.
let package = Package(
  name: "RuleSteward",
  platforms: [.iOS(.v17), .macOS(.v14)],
  products: [
    .library(
      name: "RuleSteward",
      targets: ["RuleSteward"]
    ),
  ],
  targets: [
    .target(name: "RuleSteward"),
    .testTarget(
      name: "RuleStewardTests",
      dependencies: ["RuleSteward"]
    ),
  ]
)
