# Rebase pgs9 onto the current FFmpeg stable release

- Status: accepted
- Scope: upstream-submission
- Date: 2026-08-21

## Context and Problem Statement

The pgs9 series (30 commits, folded coherent and bisectable) sits on the
8.1 lineage; the recorded next step was a rebase onto upstream master,
blocked since 2026-07-19 on host-reconcile (connollydavid/host#18)
because that rebase was reserved as the new tool's acceptance test.
host#18 remains open: implementation was cut as a design-only milestone
(plan/0075 in agentic-host), queued behind the FFmpeg pack, so the block
has no tool to wait on in any near horizon. Meanwhile FFmpeg 9.0.1 "Lei"
(tag n9.0.1, commit bf1b838f2a, released 2026-08-12) is the current
stable of the release/9.0 branch, which was cut from master on
2026-06-26.

## Decision

Operator ruling, 2026-08-21:

1. The overriding goal is the series rebased onto n9.0.1 and pitch
   perfect for potential upstreaming; the target is the stable tag, not
   the master tip.
2. The 2026-07-19 reservation of the rebase as host-reconcile's
   acceptance test is lifted. The rebase proceeds without waiting for
   the tool; when host-reconcile exists, its acceptance test runs
   against a fresh rebase instead.

## Consequences

- Good: the series reaches a current stable base now, with rerere
  recording resolutions that replay on any later master re-cut; the
  upstream-quality work (series lane, patcheck, shared-build walk,
  FATE, Fairies review) is unblocked.
- Neutral: host-reconcile loses this rebase as its first acceptance
  run and will need a fresh one; the version and APIchanges
  reconciliation is done per commit by hand rather than by merge driver.
- Bad: hand resolution of version metadata across the 9.0.1 drift
  repeats work the tool was meant to automate.
