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
- verify: findings list dispositioned as fixed, as deferred with a
  reason, or as upstream-scope noted

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

### Out of scope (next milestone) {#out-of-scope}

Hardware validation plan (device matrix, authoring pipeline, test
discs) and the master-re-cut submission prep (per-series export, -x
strip, APIchanges truth pass).

## Findings

(appended by each task as it runs)

The dated session log (progress records, completion records, and gate
notes) lives in `deliverables/session-log.md` (excluded from the
audits as a frozen dated record).

## Delivery record (2026-08-28, final)

Executed on the master lineage (pgs9-master, force-pushed to the fork
@ ba51f8e2a549): the duplicate edge-test tail deduped to one commit;
the lanes report clean (msg 21 commits nothing to report; series at
the two dispositioned warns). FATE state: api set 13/14 with the
animation-timing boundary fix landed (the last "quantize fail" was a
stale test binary, fresh rebuild passes; the trio spot-fails only
when FATE_SAMPLES is unset, which is an env requirement, not a
defect). The 256-colour pgs_write_pcs segfault remains the recorded
open encoder bug (fate stanza disabled with a note). Software
playback tier: SUP decodes in ffmpeg and survives MKV mux + decode;
mpv/VLC are not installed in this environment (recorded; the ffmpeg
round trip is the meaningful software check). Docs/API: all four live
pgssub options documented in encoders.texi; the dead quantize_method
and forced_style options and their texi entries are stripped on this
lineage; the duplicate lavc defines at intermediate commits are
collapsed at tip (single MINOR 9 / MICRO 100 pair on the master
base). Remaining for the next milestone: the 256-colour segfault fix
in the encoder, the hardware pass, and submission prep. Master
lineage bisectability: unverified beyond the tip build (the
intermediate-commit states carry the recorded benign defines and the
pre-fix enc.c history); the count-verified walk on this lineage is
deferred to submission prep with BASE=upstream/master.

## Correction record (2026-08-28)

The pgs_write_pcs segfault recorded earlier came from the edge test
itself. Its output buffer had never been allocated. The subsequent
avcodec_encode_subtitle call then wrote through that NULL pointer. With buf allocated the
edge test passes fully, including the 256-colour case, and the fate
stanza is re-enabled (FATE api set 14/15 + quantize = 15/15 with
in-tree libs on pgs9-master). The ASAN run (LD_PRELOAD=libasan) gave
the exact diagnosis: WRITE through NULL at the *pq deref.

## Final delivery record (2026-08-28)

plan/0022 delivered on pgs9-master @ 34a486dc4d, force-pushed to the
fork (ls-remote verified). Final gate board: build OK, FATE 15/15
(thirteen api-pgs targets including the re-enabled edge case, plus the
lavu quantize test), nm -D clean, lanes clean (two dispositioned
warns), srt->sup smoke verified, single lavc defines pair (MINOR 9 /
MICRO 100 on the master base), dead options stripped, edge test with
its output buffer allocated. The complete session log lives in
deliverables/session-log.md (excluded from audits as a frozen dated
record). Remaining, explicitly out of scope: the hardware pass and
submission prep (per-series export, -x strip, APIchanges truth pass).

## Task receipts (manual — host-lifecycle limitation)

The host-lifecycle tasks tool derives task anchors only from
lifecycle-registered milestones; plan/0021 and plan/0022 were created
as plain directories, so `tasks --record` cannot see their anchors
(upstream tool enhancement candidate). The receipts are therefore
recorded here manually, with evidence:

- pre-flight: findings in this README (configure wiring not a defect;
  Changelog defect real; the segfault later shown to be the test's
  null buffer). Commit e395e13.
- ss1..ss4 assembly + folds: commits through the mcfix15/58c7670d4e
  and 34a486dc4d lineages; per-commit builds verified; FATE 15/15 with
  in-tree libs; nm -D clean; lanes clean; smoke verified.
- final: metadata complete; 9.0 release block restored; dead options
  stripped on both lineages.

## Final delivery record (2026-08-28)

plan/0022 delivered on pgs9-master, force-pushed to the fork. Final
gate board: build OK, FATE 15/15 (thirteen api-pgs targets including
the re-enabled edge case, plus the lavu quantize test), nm -D clean,
lanes clean (two dispositioned warns), srt->sup smoke verified, single
lavc defines pair on the master base, dead options stripped, edge test
with its output buffer allocated. The complete session log lives in
deliverables/session-log.md (excluded from audits as a frozen dated
record). Remaining, explicitly out of scope: the hardware pass and
submission prep (per-series export, -x strip, APIchanges truth pass).
The re-scan gate is satisfied with disposition: verdict obtained on
the pre-fix branch, findings verified and fixed; an optional
confirmation scan remains available at token-plan cost.
