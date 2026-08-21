#!/bin/bash
# Build-walk oracle: every commit in the range must build in the current
# (already-configured) build tree. Run inside the ffmpeg worktree with the
# build configured (use --enable-shared: the stricter ABI leg).
#
# Usage: build-walk.sh <new-base>..<?>  (a rev range, e.g. n9.0.1..pgs9-9.0.1)
set -u
RANGE="${1:?usage: build-walk.sh <base>..<branch>}"
cd "$(git rev-parse --show-toplevel)" || exit 9
for c in $(git rev-list --reverse "$RANGE"); do
  git checkout -q --detach "$c" || { echo "FAIL checkout $c"; exit 1; }
  log="${TMPDIR:-/tmp}/walk-$(git rev-parse --short "$c").log"
  if make -j"$(nproc)" > "$log" 2>&1; then
    echo "OK $(git rev-parse --short "$c") $(git log -1 --format=%s "$c")"
  else
    echo "BUILD FAIL $(git rev-parse --short "$c") $(git log -1 --format=%s "$c")"
    tail -25 "$log"
    exit 1
  fi
done
git checkout -q "${RANGE#*..}"
echo "WALK-COMPLETE"
