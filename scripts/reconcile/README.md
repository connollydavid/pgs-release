# The host-reconcile workaround

These scripts are the manual reconciliation method that carried the pgs9
series onto FFmpeg 9.0.1 (thirty commits over 2233 commits of upstream
drift, six hand stops, all in typed files). They stand in for
`host-reconcile` (connollydavid/host#18) until that tool exists, and
they double as the case-study record of what the tool must handle: every
limitation below is a finding filed on the issue.

## The method

Run the rebase in a dedicated worktree of the bare store with rerere
enabled, then drive each stop:

1. `stop.sh <old-base-sha>` resolves the stop: version headers
   re-derived onto the new lineage, the APIchanges entry inserted at the
   series slot, makefiles union-merged. Review what it printed, then
   `git add` and `git rebase --continue`.
2. `build-walk.sh <new-base>..<branch>` walks per-commit builds under
   the configured tree (configure with `--enable-shared`; it is the
   stricter ABI leg). Run it only after the rebase finishes: apply all
   fixes first, verify second.
3. `transfer-proof.sh <old> <new> <base> [excluded-path]...` carries a
   completed walk across a later fold: it proves each rewritten commit
   differs from its walked counterpart only inside the files the fold
   intentionally changed.

## What the real rebase taught (all filed on host#18)

- Deltas are parent-relative. Computing a version delta from the rebase
  base instead of the commit's original parent double-counts every
  earlier bump in the series (measured: lavu derived one minor too
  high at the Median Cut stop).
- Conflict blocks vary in shape. A version.h conflict may carry the
  full triple, or only MAJOR and MINOR with MICRO outside the block.
  Parse what is present and normalise MICRO file-wide after the splice.
- Three-way merges materialise context duplicates. When one hunk of a
  typed file is resolved by hand, a sibling hunk can still apply
  verbatim and re-add neighbouring old-lineage entries that the hand
  resolution just re-derived. A line-level "everything present" audit
  cannot catch this; audit per-commit introduced content instead.
- Real series carry internal inconsistencies. The ELBG quantizer commit
  bumped the minor twice while its own APIchanges entry documented one
  addition. The reconciler needs a policy for this (the workaround
  resolved provisionally-consistent at the documented delta and left
  the discrepancy visible for the truth pass).
- Verify in a controlled loader environment. An in-tree `./ffmpeg`
  without rpath loads the system libraries under WSL, and a partially
  overridden path mixes system libavfilter with local libavcodec
  (unresolvable `avpriv_elbg_free` after the ELBG move). Set
  `LD_LIBRARY_PATH` across all in-tree library directories.

## See also

`tools/host-ffmpeg-version-reconcile/` is the derive/resolve/rewrite
prototype these scripts complement, and the designated seed of the
`host-reconcile-ffmpeg` articulation. `call/0007` records why the
rebase proceeded without the tool.
