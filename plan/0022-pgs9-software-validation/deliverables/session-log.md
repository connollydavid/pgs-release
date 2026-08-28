# Session log (frozen dated record)
## Progress record (2026-08-27/28 session)

Completed:
- #fate-samples: fate-suite sub/ fetched (35 files, 3.2 MB,
  ~/fate-suite/sub). The sample-based subtitle fates all pass (25 of
  25); fate-sub-pgs-remux exercises the decoder against a real PGS
  sample. Api+quantize set at tip: 13/14 (see flake below); quantize
  failure was a stale binary,
  fresh rebuild passes. The two standing lane warns are now resolved
  facts (sample provenance real, tested).
- #anim-flake: ROOT-CAUSED with a standalone probe
  (Temp/host-probe.c): libass renders fully transparent (empty bitmap)
  at exactly the fade boundary t=0 and t=end; non-empty from +42 ms on.
  Deterministic, environment-independent, reproduces on the 9.0.1
  branch too. Fix landed: the test now samples at start_ms + frame_ms
  (commit on pgs9-flake-investigation, folded toward pgs9-master).
- #decoder-review: pgssubdec is upstream's decoder carried unchanged.
  Windows parsed as advisory (objects carry absolute x/y), epoch
  flush on state != 0, forced-only option honored, tolerant
  missing-object/palette handling with EXPLODE opt-in. Findings are
  upstream-scope (record, not fix): no WDS-based clipping, no
  end-timestamp model (next-PTS clearing), clamp-to-2 on object
  overflow. No issues in paths our series depends on.
- #benchmarks: harness (deliverables/quantizer-bench.c) + results
  (deliverables/quantizer-bench-results.txt). NEUQUANT/MedianCut/ELBG
  across SD/HD/UHD and 16/64/256 palettes; ELBG fastest at small
  palettes (~15 Mpix/s), MedianCut strongest on quality at 64+,
  NeuQuant most stable across palette sizes.

In progress / next session:
- #edge-cases: api-pgs-edge test draft exists in session temp
  (256-colour palette + zero-dim rect + duplicate-entry palette); the
  draft needs a clean rewrite against the encode_large_subtitle
  pattern from api-pgs-rate-control-test.c. NOTE: tests/data is
  gitignored - force-add the sub-ocr-roundtrip.srt sample if
  re-adding, and the fate-sub-ocr-roundtrip test may need the
  sample-committed-or-test-reworked decision recorded.
- #software-playback, #docs-api, #lanes-clean: not started.
- Master lineage blemish: duplicate lavc MINOR/MICRO defines in
  libavcodec/version.h (the master plus our pairs; benign, last-wins). Collapse to a single
  pair as a fixup on the encoder commit, then re-run the count-
  verified walk (host-walk3-reset.sh now has per-step configure and
  BASE=upstream/master).
- Branches: pgs9-master @ 62966eff01 + flake fixup 51551aaae6 (local);
  pgs9-recut2 (local) = 4558bebf96; fork pgs9-recut = 4558bebf96.
- Close-out: receipts for the plan/0022 tasks, findings appended above
  this section, HANDOVER final refresh.
