#!/usr/bin/env bash
# Waits for this run's "Build for testing"
# job, so a test shard can start (and boot
# its simulator) alongside the build rather
# than after it: the first boot takes
# minutes of CPU (docs/CI-SPEED.md).
# Exits 0 once the build succeeded, 1 if it
# failed, was skipped or cancelled.
# Needs GH_TOKEN, GITHUB_REPOSITORY and
# GITHUB_RUN_ID (CI sets the last two).
set -euo pipefail

name="Build for testing"
url="repos/$GITHUB_REPOSITORY/actions"
url+="/runs/$GITHUB_RUN_ID/jobs"
start=$SECONDS
while :; do
  # The latest attempt of each job, so a
  # re-run of failed shards finds the
  # earlier attempt's build.
  state=$(gh api -X GET "$url" \
    -f filter=latest -f per_page=100 \
    --jq "first(.jobs[]
      | select(.name == \"$name\")
      | \"\(.status) \(.conclusion)\")" \
    || true)
  case "$state" in
    "completed success")
      echo "Build ready after" \
        "$((SECONDS - start)) s"
      exit 0 ;;
    completed*)
      echo "::error::$name: ${state#* }"
      exit 1 ;;
  esac
  sleep 10
done
