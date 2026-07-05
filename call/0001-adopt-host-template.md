# Adopt the host-template methodology

- Status: accepted
- Scope: project
- Date: 2026-07-05

## Context and Problem Statement

This repository grew as a plain meta-repo: a working plan, per-milestone design
documents at the root, four git submodules holding the software, and an
accreted CLAUDE.md. The operator directed adoption of the connollydavid/host
methodology so the project gains standard rooms, verification lanes, and an
upgrade path.

## Decision

Adopted host-template @ `570798099e09a0d9707b01896ace507552ed7090`
(2026-07-05), migration case b (pre-existing CLAUDE.md merged with the spine),
Shallow PR mode. History is untouched: the FFmpeg patch-series provenance
rules out a deep rewrite, so ordinal tells in the log are acknowledged, not
rewritten.

The rename dictionary applied at migration (durable copy; the working
`.host-remap` was transient), inside a boxed block because it names the old
ordinal forms verbatim:

```host-lint:ignore
PHASE1.md  => plan/0001-hdmv-pgs-encoder/README.md
PHASE2.md  => plan/0002-color-quantization-api/README.md
PHASE3.md  => plan/0003-text-to-bitmap-conversion/README.md
PHASE4.md  => plan/0004-region-weighted-quantization/README.md
PHASE5.md  => plan/0005-quantizer-algorithm-integration/README.md
PHASE6.md  => plan/0006-gif-encoder-rgba-quantization/README.md
REVIEW.md  => plan/0007-upstream-review-findings/README.md
PHASE7.md  => plan/0008-ocr-bitmap-to-text/README.md
PHASE8.md  => plan/0009-pgs-decoder-model-compliance/README.md
PHASE8-REVIEW.md    => plan/0010-upstream-suitability-audit/README.md
PHASE8-REVIEW-V3.md => plan/0011-v3-consolidated-claude-review/README.md
PHASE9.md           => plan/0012-v4-review-fixes/README.md
PHASE9-LOOKAHEAD.md => plan/0013-subtitle-event-lookahead/README.md
PHASE10.md => plan/0014-pgs-encoder-optimizations/README.md
PHASE11.md => plan/0015-website-updates/README.md
PHASE12.md => plan/0016-fate-ci-website-visibility/README.md
PHASE13.md => plan/0017-pgs-encoder-features/README.md
PHASE14.md => plan/0018-upstream-submission-restructuring/README.md
```

Milestone numbers were assigned by acceptance chronology (first-commit date of
each document). All eighteen bodies are closed records: renamed, excluded from
the naming and prose audits via `.host-lintignore`, never rewritten.

## Consequences

- Good: standard rooms, tool-checked naming, a recorded template revision to
  upgrade from.
- Neutral: the four software submodules become a `.host-software` bare-store
  recipe; CI materializes worktrees instead of checking out gitlinks.
- Bad: deep links into the old root-level document names break; the boxed
  dictionary above is the lookup table.
