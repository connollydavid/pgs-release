# pgs9 software validation

Complete every pre-submission work item that does not require BD
hardware, on the master re-cut branch (pgs9-master). Hardware
validation (real BD devices) and forge submission are explicitly out
of scope; this plan ends when the series is software-complete and the
only remaining gate is the hardware pass.

Base: branch pgs9-master (19 commits on upstream/master), worktree
~/pgs9-wt/recut. The build-walk of this branch is already green.

## Build sequence

### Full FATE with samples {#fate-samples}

- verify: fate-api-pgs-*, fate-sub-pgs, and the two lane warns cleared

Fetch the fate-suite subset (rsync fate.ffmpeg.org, selective: sub/
plus whatever fate-sub-pgs and our tests reference; ~small) into
FATE_SAMPLES. Run the subtitle FATE set plus our api set with samples
present. This also resolves the two standing lane warns: the
fate-sample provenance warn (sub/pgs_sub.sup arrives with the suite)
and validates fate-sub-ocr-roundtrip end to end.

### Animation-timing boundary fix {#anim-flake}

- depends: #fate-samples
- verify: fate-api-pgs-animation-timing green on repeated runs

The test samples the libass render at exactly the event start
timestamp, where a fade-in renders fully transparent ("First frame
empty"). Sample within the fade window instead (start_ms + step) or
assert non-empty across the first frames; make the test deterministic.

### Decoder-side compliance review {#decoder-review}

- depends: #fate-samples
- verify: findings list dispositioned (fixed, deferred with reason, or
  upstream-scope noted)

Audit pgssubdec against the HDMV spec (docs/pgs-specification.md):
window handling, CLUT/palette sequencing, acquisition-point and epoch
resets, crop flag, forced-flag on decode, composition state
(transitional vs normal), object sequence fragmentation, and
tolerance behaviors (unknown segments skipped, truncated objects).
Only flag issues in the decode path our series touches or depends on;
upstream decoder bugs outside our scope are recorded, not fixed.

### Quantizer benchmarks {#benchmarks}

- depends: #fate-samples
- verify: results table committed under plan/0021 deliverables or
  docs/, methodology stated

Benchmark NeuQuant, ELBG, and Median Cut from the quantize API:
quality (PSNR/SSIM of round-trip palettized frames) and speed
(Mpixels/s) across representative resolutions (SD 720x480, HD
1920x1080, UHD 3840x2160) and palette sizes (16/64/256). Use the
fate bench facility or a small standalone harness built from
libavutil/tests/quantize.c.

### Edge-case matrix {#edge-cases}

- depends: #decoder-review
- verify: new api/fate tests green; findings dispositioned

Exercise and test: huge palettes (up to 256 colours per object),
overlapping events (multi-object windows), very long events
(animation-cap degradation path), forced + rate-control interaction,
palette-delta stress, empty and text-only events through the
conversion, zero-dimension rects, and the supenc NOPTS rejection
path. Add api tests for anything uncovered; our own decoder and the
supenc muxer path included.

### Software playback tier {#software-playback}

- depends: #edge-cases
- verify: our SUP decodes byte-clean in ffmpeg, mpv, and VLC; a
  subtitle muxed into MKV plays in sync for the first event, a forced
  event, and an animation

Author SUP output from the release binary; check ffmpeg's own demux+decode
round trip, mpv playback, and VLC playback. This is the software
substitute for the hardware pass and often predicts device behaviour.

### Docs and API completeness {#docs-api}

- depends: #edge-cases
- verify: doc/encoders.texi pgssub section complete (every AVOption
  documented), doc/APIchanges entries finalized (real dates/hashes at
  submission time is allowed to stay deferred; completeness is not),
  texi build clean in the enabled-doc build

### Clean lane pass {#lanes-clean}

- depends: #docs-api
- verify: host-lint-ffmpeg msg + series lanes report nothing beyond
  dispositioned warns; patcheck on the full series diff reports no
  blocking findings; the two standing warns resolved or re-dispositioned

### Out of scope (next milestone)

Hardware validation plan (device matrix, authoring pipeline, test
discs) and the master-re-cut submission prep (per-series export, -x
strip, APIchanges truth pass).

## Findings

(appended by each task as it runs)

## Progress record (2026-08-27/28 session)

Completed:
- #fate-samples: fate-suite sub/ fetched (35 files, 3.2 MB,
  ~/fate-suite/sub). Sample-based subtitle fates pass 25/25, including
  fate-sub-pgs-remux (decoder vs real PGS sample). Api+quantize set at
  tip: 13/14 (see flake below); quantize failure was a stale binary,
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
  libavcodec/version.h (master's 8.101 + our 2.100; benign, last-wins
  = our intended 2.100... on the master base the intended pair is
  MINOR 9 / MICRO 100 after the encoder bump). Collapse to a single
  pair as a fixup on the encoder commit, then re-run the count-
  verified walk (host-walk3-reset.sh now has per-step configure and
  BASE=upstream/master).
- Branches: pgs9-master @ 62966eff01 + flake fixup 51551aaae6 (local);
  pgs9-recut2 (local) = 4558bebf96; fork pgs9-recut = 4558bebf96.
- Close-out: receipts for the plan/0022 tasks, findings appended above
  this section, HANDOVER final refresh.
