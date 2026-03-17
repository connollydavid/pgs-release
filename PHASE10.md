# Phase 10: PGS Encoder Optimizations (v5)

## Status: Complete — released as n8.1-pgs5.0

Encoder improvements beyond the review-mandated fixes in v4.

## 10a: Palette Delta Encoding — DONE

Cache YCbCrA palette entries after each PDS write. On palette-only
updates (Normal DS with palette_update_flag), write only entries
that changed since the last PDS. Full palette on Epoch Start and
Acquisition Point.

For a 16-color subtitle fade at 24fps over 72 frames:
- Before: 72 × 82 bytes = ~5.9 KB of PDS data
- After:  72 × 7 bytes  = ~0.5 KB of PDS data (90% reduction)

## 10b: DTS Computation — DONE

Per-segment DTS in SUP muxer (`supenc.c`): two-pass approach scans
PGS segments for timing parameters, then writes with computed DTS
using PGS_FREQ (90kHz), PGS_RD (16Mbps), PGS_RC (32Mbps) decoder
model constants.

Per-packet DTS in fftools: `DTS = PTS - decode_duration`, clamped
to 0. The encoder computes `decode_duration` from bitmap dimensions
and the HDMV transfer rate model.

## 10c: Event Lookahead Window — DONE

Event buffer replaces simple same-PTS coalescing. Buffers subtitle
events with full time spans, computes change points where the set of
visible subtitles changes, re-renders at each change point. Handles
overlapping events with different durations producing the correct
Display Set sequence. See PHASE9-LOOKAHEAD.md for design.

## Known Issues

### ASS fade encoding regression — FIXED
ASS input with `\fad` tags produces "Invalid argument" from the
PGS encoder after the v5 lookahead window changes. Simple SRT and
non-animated ASS work correctly. The FATE api-pgs-fade test passes
(uses the encoder directly), so the issue is in the fftools→encoder
pipeline path for animated events. Needs investigation.

Fixed: third ff_sub_render_event call in alpha animation path
needed events_loaded guard, matching the two in Pass 1/2.
