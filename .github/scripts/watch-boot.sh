#!/usr/bin/env bash
# For a CI speed test (docs/CI-SPEED.md):
# what keeps the runner busy while the
# simulator boots.
#   watch-boot.sh start
#     in the background: the busiest
#     processes every 15 s, and how long
#     the booted simulator takes to finish
#     booting;
#   watch-boot.sh show
#     prints both, and the simulator caches'
#     sizes.
set -euo pipefail

logs=build/watch
mode="${1:?start or show}"

cpu() {
  local start=$SECONDS
  while :; do
    echo "--- $((SECONDS - start)) s"
    ps -Ao pcpu=,comm= -r | head -n 6
    sleep 15
  done
}

boot() {
  local start=$SECONDS
  xcrun simctl bootstatus "$1"
  echo "Booted after $((SECONDS - start)) s"
}

if [ "$mode" = start ]; then
  mkdir -p "$logs"
  udid=$(xcrun simctl list devices \
    booted -j \
    | jq -r 'first(.devices[][]
      | .udid) // empty')
  cpu > "$logs/cpu.log" 2>&1 &
  boot "$udid" > "$logs/boot.log" 2>&1 &
  exit 0
fi

echo "::group::Boot"
cat "$logs/boot.log" || true
echo "::endgroup::"
echo "::group::Busiest processes"
cat "$logs/cpu.log" || true
echo "::endgroup::"
echo "::group::Simulator caches"
for dir in \
  ~/Library/Developer/CoreSimulator/Caches \
  /Library/Developer/CoreSimulator/Caches
do
  du -sh "$dir"/* 2>/dev/null || true
  du -sh "$dir"/*/* 2>/dev/null || true
done
echo "::endgroup::"
