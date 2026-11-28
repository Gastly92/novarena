#!/bin/bash
# Prints win rates for the rules' units,
# for balancing: every team of each size
# against every other, both ways round,
# with plain choices (SimulateTests and
# Simulator in the rules' tests). Runs in
# Docker like rules-tests.sh. Settings,
# all optional, as environment variables:
#   SIMULATE_SIZES=1,2,3  team sizes
#   SIMULATE_UNITS=Gerald,Wren  who
#   SIMULATE_COMMANDER=party  or foes
#   SIMULATE_MATRIX=1  one on one table
# e.g. SIMULATE_COMMANDER=party \
#   .github/scripts/simulate.sh
set -euo pipefail

root="$(git rev-parse --show-toplevel)"
pin="$root/.github/swift/Dockerfile"
image="$(sed -n 's/^FROM //p' "$pin")"

if ! docker info >/dev/null 2>&1; then
  (dockerd >/tmp/dockerd.log 2>&1 &)
  for _ in $(seq 1 30); do
    docker info >/dev/null 2>&1 && break
    sleep 1
  done
fi

docker run --rm -v "$root:/work" \
  -w /work/Packages/RuleSteward \
  -e SIMULATE=1 \
  -e SIMULATE_SIZES \
  -e SIMULATE_UNITS \
  -e SIMULATE_COMMANDER \
  -e SIMULATE_MATRIX \
  "$image" \
  swift test -c release \
  --scratch-path /tmp/build \
  --filter SimulateTests 2>&1 \
  | sed -n 's/^SIM //p'
