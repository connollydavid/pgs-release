#!/bin/bash
# Transfer proof: carry a completed build-walk verdict across a fold that
# rewrote commits, by proving each post-fold commit differs from its
# pre-fold counterpart only inside the named exclusion set (files the fold
# intentionally changed). Any diff outside the set voids the transfer.
#
# Usage: transfer-proof.sh <old-branch> <new-branch> <base> [exclude-path]...
set -u
OLD="${1:?old branch}"; NEW="${2:?new branch}"; BASE="${3:?base}"; shift 3
cd "$(git rev-parse --show-toplevel)" || exit 9
EXCL=(); for p in "$@"; do EXCL+=(":!$p"); done

old=$(git rev-list --reverse "$BASE..$OLD")
new=$(git rev-list --reverse "$BASE..$NEW")
[ "$(echo "$old" | wc -l)" = "$(echo "$new" | wc -l)" ] || { echo "COUNT MISMATCH"; exit 1; }
rc=0
while read -r o <&3 && read -r n <&4; do
  d=$(git diff "$o" "$n" -- . "${EXCL[@]}" | wc -l)
  [ "$d" -gt 0 ] && { echo "TREE DIFF outside exclusions: $o vs $n ($d lines)"; rc=1; }
done 3<<<"$old" 4<<<"$new"
[ "$rc" -eq 0 ] && echo "TRANSFER PROVEN: all pairs identical outside ${*:4:-<nothing>}"
exit "$rc"
