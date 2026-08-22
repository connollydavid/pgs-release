# Re-cut rulings: trailers, lavu API surface, base order

- Status: accepted
- Scope: upstream-submission
- Date: 2026-08-22

## Context and Problem Statement

The fairy structure review (plan/0020/fairy-structure-review.md) set the
re-cut shape: four sub-series, per-patch merges and splits, and three
open questions the operator must rule on before execution — the AI
attribution trailers, the libavutil API surface disposition
(avpriv versus ff_ versus av_), and which base the re-cut targets first.

## Decision

Operator rulings, 2026-08-22:

1. **Trailers**: every re-cut commit keeps its existing Co-Authored-By
   trailers verbatim and appends
   `Co-Authored-By: GLM 5.3 <no-reply@z.ai>`. FFmpeg has no adopted AI
   policy; the trailers are honest attribution on both counts.
2. **API surface**: split disposition, proposed to the lavu maintainer
   in the RFC rather than pre-conceded — quantizer backends fully
   internal to libavutil (no installed header, reachable only through
   the public av_quantize_* factory), and the palettemap family as
   avpriv_* (the versioned cross-library-private mechanism lavfi and
   lavc both consume), each exporting commit bumping the lavu minor.
3. **Base order**: re-cut the four sub-series on the n9.0.1 base first
   (keeps the release line coherent); the master re-cut happens at
   submission time, with rerere replaying the recorded resolutions.

## Consequences

- Good: attribution stays honest without rewriting history; the API
  proposal matches FFmpeg's existing mechanisms (avpriv for cross-lib
  private, factory-only public API), giving the RFC a concrete,
  self-aware ask; the 9.0.1-first order preserves the shipped line.
- Neutral: the avpriv disposition may still be overridden in list
  review; the re-cut structure makes changing one family local.
- Bad: appending a trailer to every commit lengthens messages the
  reviewer skims.
