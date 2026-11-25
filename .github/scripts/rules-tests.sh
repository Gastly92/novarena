#!/bin/bash
# Tests the rules package
# (Packages/RuleSteward) on Linux, in
# Docker with the Swift version pinned in
# .github/swift/Dockerfile, and fails
# unless the tests run every line and
# region of its sources. CI's Rule tests
# job runs this too. Starts the Docker
# daemon if it isn't running (as in Claude
# Code cloud sessions).
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

echo "Testing with $image"
# Builds in /tmp inside the container, so
# nothing is written into the checkout.
docker run --rm -v "$root:/work" \
  -w /work/Packages/RuleSteward \
  "$image" bash -euo pipefail -c '
build=/tmp/build
swift test --enable-code-coverage \
  --scratch-path "$build"
bin="$build/debug/RuleStewardPackageTests.xctest"
prof="$build/debug/codecov/default.profdata"
skip="(Tests|/tmp)/"
llvm-cov report "$bin" \
  -instr-profile="$prof" \
  -ignore-filename-regex="$skip" \
  | tee /tmp/report.txt
# TOTAL: missed regions and missed lines.
missed=$(awk "/^TOTAL/ { print \$3 + \$9 }" \
  /tmp/report.txt)
if [ "$missed" != 0 ]; then
  echo "::error::Untested rules code:"
  llvm-cov show "$bin" \
    -instr-profile="$prof" \
    -ignore-filename-regex="$skip" \
    | grep -E "^ +[0-9]+\| +0\|" || true
  exit 1
fi
echo "Every line and region is tested."
'
