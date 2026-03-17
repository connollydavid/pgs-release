# Phase 13: PGS Encoder Features (v6)

## Status: Planning

Encoder features beyond v5's optimisations. Ordered by dependency — each step
builds on the previous. Together they bring the encoder to full HDMV spec
coverage and enable random-access seeking into PGS streams.

## 13a: Palette Reuse — PLANNED

Extend v5's palette delta encoding. When the full palette hasn't changed between
Display Sets, omit the PDS segment entirely and reference the previous palette
via `palette_version`. Currently every DS includes at least a delta PDS.

**Depends on:** v5 palette delta cache (already tracks previous palette state).

**Synergy with 13e:** Less PDS data means more CDB headroom for rate control.

**Verification:** FATE test comparing PDS byte count across a sequence of
Display Sets with identical palettes. Expected: zero PDS bytes after the first DS
in a static-palette run.

## 13b: Multiple Composition Objects — PLANNED

PGS allows up to two composition objects per Display Set (HDMV spec limit).
Currently the encoder composites all subtitle regions into a single bitmap.
Promote rect splitting from fftools into the encoder: when two non-overlapping
regions exist (e.g. top and bottom of screen), encode as two separate Object
Definition Segments sharing one palette.

**Depends on:** Existing rect splitting logic in `ffmpeg_enc_sub.c`. This moves
the split decision into the encoder so it works for all consumers, not just
fftools.

**Synergy with 13c:** AP Display Sets must retransmit all active objects. With
two objects, only the changed one needs a new ODS on Normal DS — the other
is referenced by `object_id` without retransmission.

**Synergy with 13d:** Forced subtitles can be a separate object from non-forced
content in the same Display Set.

**Verification:** FATE test with two spatially separated subtitle regions.
Expected: two ODS segments in the output, shared PDS, both `object_id` values
referenced in the PCS composition descriptor.

## 13c: Acquisition Point Display Sets — PLANNED

The third composition state type. Currently the encoder only emits Epoch Start
(full state reset) and Normal (incremental update). Acquisition Point DS
retransmit the current composition state without starting a new epoch — enabling
random-access seeking into a PGS stream.

The encoder needs to periodically emit AP DS at a configurable interval (e.g.
every N seconds or every N Display Sets). The AP DS must include:
- PCS with `composition_state = 0x80` (Acquisition Point)
- Full PDS (not delta — the decoder has no prior state after a seek)
- All active ODS (both objects if 13b is implemented)

**Depends on:** 13b (multi-object) so AP DS retransmits the correct set of objects.
13a (palette reuse) so AP DS knows to force a full PDS even when palettes haven't
changed.

**Synergy with 13e:** AP DS are large (full retransmission). Rate control must
account for their periodic CDB impact.

**AVOption:** `ap_interval` already exists (added in v4, currently unused).
Wire it up.

**Verification:** FATE test seeking into a PGS stream at an AP DS boundary.
Expected: correct rendering from the seek point without needing the Epoch Start.

## 13d: Forced Subtitles — PLANNED

Set the `forced_on_flag` in the PCS composition descriptor for subtitle events
marked as forced. Forced subtitles display even when the user has subtitles
disabled (used for foreign-language dialogue, signs, on-screen text).

**Depends on:** 13b is useful but not required. With multi-object, forced and
non-forced content can coexist as separate objects in one DS. Without it, the
entire DS is either forced or not.

**Input:** The `forced` field on `AVSubtitleRect` (already exists in FFmpeg's
subtitle API).

**AVOption:** `force_all` flag to mark all events as forced (common workflow
for director's commentary tracks).

**Verification:** FATE test encoding a forced event, decoding with the PGS
decoder, verifying the forced flag propagates through the roundtrip.

## 13e: Rate Control — PLANNED

The decoder model (CDB: 1 MB leaky bucket at 16 Mbps, DOB: 4 MB) is tracked
in v5 but doesn't back-pressure the encoder. When a Display Set would overflow
the CDB:

1. Defer the DS to a later PTS where the buffer has drained sufficiently
2. If deferral exceeds a threshold, split the DS (reduce bitmap quality or
   resolution) to fit
3. Log a warning when deferral or splitting occurs

AP DS intervals (13c) must be factored into the budget — they're the largest
periodic cost.

**Depends on:** All previous steps. CDB occupancy depends on PDS size (13a),
ODS count and size (13b), AP frequency (13c). Without these features in place,
rate control can't accurately model the buffer.

**Synergy:** This is the capstone. With palette reuse reducing PDS overhead,
multi-object reducing per-update ODS size, and AP intervals configurable,
rate control can make informed decisions about when to defer or degrade.

**AVOption:** `max_cdb_usage` threshold (0.0–1.0, default 0.9) for the
deferral trigger.

**Verification:** FATE test with a rapid sequence of large bitmap subtitles
that would overflow CDB without rate control. Expected: encoder defers or
splits, output validates against decoder model, no CDB overflow.

## Patch Series Structure

Follows CLAUDE.md discipline: each patch compiles independently, new version
branch `pgs6`, tagged `history/pgs-v6` when complete.

Expected patch count: 5–8 on top of v5's 23 (one per feature + FATE tests).
