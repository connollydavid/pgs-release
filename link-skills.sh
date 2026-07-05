#!/bin/sh
# Recreate .claude/skills/* symlinks for every *materialized* tool skill.
#
# These symlinks are NOT tracked: a tracked symlink into a tool submodule dangles
# wherever that submodule is not initialized (a fresh clone, CI, a partial init) —
# worktree-absence coherence, call/0005 — and any tree-walking tool (mdBook, a
# linter, find/grep) then trips over the broken link. So we generate them instead,
# for the tools actually present. Run after `git submodule update --init`.
set -eu
cd "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
mkdir -p .claude/skills
n=0
for tool in tools/*/; do
  name=${tool#tools/}; name=${name%/}
  if [ -d "${tool}skills" ]; then
    # allium/specula expose one dir per skill under skills/
    for s in "${tool}skills"/*/; do
      [ -d "$s" ] || continue
      ln -sfn "../../${s%/}" ".claude/skills/$(basename "$s")"
      n=$((n + 1))
    done
  elif [ -f "${tool}SKILL.md" ]; then
    # host-lint ships a single skill at the submodule root
    ln -sfn "../../tools/$name" ".claude/skills/$name"
    n=$((n + 1))
  fi
done
echo "link-skills: linked $n skill(s) from materialized tools"
