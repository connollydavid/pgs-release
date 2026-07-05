# Phase 8: PGS Decoder Model Compliance

## Status: Partially Complete — remainder moved to Phase 13

Items 8a (DTS/PTS timing) and 8e (palette optimisation) were implemented
in v5 as Phase 10b and 10a respectively. Items 8b (CDB model), 8c (DOB
model), and 8d (Acquisition Points) are deferred to Phase 13 (v6 encoder
features) where they depend on palette reuse and multi-object support.
Item 8f (object versioning) is also deferred to Phase 13.

## Context

Phase 1 delivered a working PGS encoder with composition state machine,
palette animation, and ODS fragmentation. It deferred three areas that
are required for full HDMV decoder model compliance:

1. **DTS/PTS timing** — ~~all segments currently emit DTS=0~~ **DONE (v5, Phase 10b)**
2. **Buffer model validation** — no check for coded data buffer overflow — **deferred to Phase 13e**
3. **Acquisition Point insertion** — no seek-friendly refresh points — **deferred to Phase 13c**

Additionally, several encoder features were unnecessarily wasteful or
missing polish:

4. **Palette optimization** — ~~PDS currently writes all 256 entries~~ **DONE (v5, Phase 10a — palette delta encoding)**
5. **Object version tracking** — always 0, should increment within epoch — **deferred to Phase 13**
6. **Window sizing validation** — no enforcement of minimum window size — **deferred to Phase 13**

## Patent Basis

All timing formulas and buffer constraints derive from three patents:

| Patent | Relevant content |
|--------|-----------------|
| US7620297B2 (Panasonic) | Decoder model, Rx/Rd/Rc rates, buffer management |
| US8638861B2 (Sony) | Segment syntax, Coded Data Buffer, timing constraints |
| US20090185789A1 (Panasonic) | Stream shaping, composition states, Acquisition Points |

SUPer (cubicibo) used as hardware-validated reference for timing
and buffer model implementation.

## Scope

### 8a: Segment Timestamps (DTS/PTS)

Currently all segments are written with DTS=0. The spec requires:

```
DTS(PCS) = PTS(PCS) - DECODE_DURATION
DTS(first_ODS) = DTS(PCS)
PTS(first_ODS) = DTS(PCS) + ceil(obj_w * obj_h * FREQ / Rd)
DTS(next_ODS) = PTS(previous_ODS)
PTS/DTS(PDS) = DTS(PCS)
PTS/DTS(END) = PTS(last_ODS)    [or DTS(PCS) if no ODS]
```

Where:
- `FREQ = 90000` (90 kHz clock)
- `Rd = 16,000,000` bytes/sec (Coded Data → Decoded Object Buffer)
- `Rc = 32,000,000` bytes/sec (Object Buffer → Graphics Plane)

Decode duration depends on composition state:

**Epoch Start:**
```
DECODE_DURATION = ceil(FREQ * video_width * video_height / Rc)
1920x1080: ceil(90000 * 2073600 / 32000000) = 5832 ticks ≈ 64.8 ms
```

**Non-Epoch-Start:**
```
DECODE_DURATION = max(window_clear_time, object_decode_time) + window_write_time
window_clear_time  = sum(ceil(FREQ * w_h * w_w / Rc))  per unassigned window
object_decode_time = sum(ceil(obj_w * obj_h * FREQ / Rd))  per new object
window_write_time  = sum(ceil(w_h * w_w * FREQ / Rc))  per assigned window
```

**Palette-only (Normal with palette_update_flag):**
```
DECODE_DURATION = window_write_time only (no objects to decode)
```

Implementation: compute segment sizes before writing, then set
timestamps on the 13-byte PG headers. Currently the encoder writes
segments into a flat buffer without headers (the muxer adds them).
This requires either:
- (a) The encoder pre-computes timestamps and passes them via side data, or
- (b) The encoder writes the PG headers itself (`.sup` format), or
- (c) The muxer computes timestamps from segment sizes

Option (a) is cleanest — the encoder knows object dimensions and
composition state. Pass decode_duration via `AVSubtitle` or packet
side data so the muxer can compute DTS = PTS - decode_duration.

### 8b: Coded Data Buffer Model

The reference decoder has a 1 MB Coded Data Buffer that fills at
Rx = 2 MB/s and drains by segment payload size on consumption:

```
fill = min(used + round(delta_ticks * Rx / FREQ), BUFFER_SIZE) - segment_size
if fill < 0: underflow (non-compliant)
```

The encoder must verify that the stream does not cause buffer
underflow. This requires tracking:
- Cumulative segment sizes per display set
- Time gaps between display sets
- Buffer fill level across the stream

For animation sequences (palette-only updates every ~42ms at 24fps),
each Normal PDS display set is ~1300 bytes. At Rx = 2 MB/s, the
buffer refills ~84 KB between frames — no risk. But Epoch Start
display sets with large objects (full-screen 1920x1080 RLE ~100-500 KB)
need sufficient time gap from the previous display set.

If a display set would cause underflow, the encoder should:
1. Delay the display set (shift PTS forward)
2. If delay exceeds acceptable threshold, log a warning
3. Never silently produce a non-compliant stream

### 8c: Decoded Object Buffer Model

The Decoded Object Buffer is 4 MB. Each object consumes
`width * height` bytes (uncompressed, 1 byte per palette index).
Objects persist for the entire epoch.

The encoder must track cumulative object buffer usage within an
epoch and force an Epoch Start when a new object would exceed 4 MB.

For typical subtitles (one or two text lines ~1920x100), each object
is ~192 KB. The 4 MB buffer holds ~20 such objects. Only extreme cases
(many simultaneous full-screen overlays) would hit this limit.

### 8d: Acquisition Point Insertion

For seek support, Acquisition Point Display Sets should be emitted
periodically within long epochs. An Acquisition Point contains
complete copies of all currently-displayed objects and palettes,
allowing a decoder to start mid-stream without decoding from the
last Epoch Start.

Strategy:
- Default interval: configurable, e.g. 5 seconds (matching typical
  video GOP length)
- Emit Acquisition Point when: time since last Epoch Start or
  Acquisition Point exceeds interval AND currently displaying a subtitle
- Content: full PCS + WDS + PDS + ODS (same as Epoch Start, but
  composition state = 0x40 instead of 0x80)
- Objects reuse cached RLE from the epoch (no re-encoding needed)

AVOption: `-acquisition_point_interval` (milliseconds, default 5000,
0 = disabled)

### 8e: Palette Optimization

Currently `pgs_write_pds` writes all 256 palette entries (1282 bytes)
even when only a few colors are used. Typical subtitles use 4-16
colors. Optimized PDS writes only non-transparent entries:

```
Optimized PDS size = 2 + 5 * nb_active_colors
4 colors:  22 bytes  (vs 1282 — 98% reduction)
16 colors: 82 bytes  (vs 1282 — 94% reduction)
256 colors: 1282 bytes (no change)
```

This matters for palette animation: a fade sequence emits many PDS
segments. Shrinking from 1282 to ~22 bytes each reduces stream
bitrate and coded buffer pressure proportionally.

### 8f: Object Version Tracking

Currently the encoder always writes object_version = 0 in ODS.
Per spec, the version number should increment within an epoch when
the same object_id receives new bitmap data. Hardware decoders may
use this to detect stale vs fresh objects.

Implementation: track `obj_version[object_id]` in PGSSubEncContext,
increment on each ODS write, reset on Epoch Start.

## Patch Structure

Single patch for this phase — all items are tightly coupled through
the timing model. Splitting would create intermediate states where
timestamps are partially correct.

```
[PATCH 1/1] lavc/pgssubenc: add decoder model compliance

- Compute DTS/PTS per spec timing formulas (8a)
- Validate coded data buffer (8b)
- Track decoded object buffer (8c)
- Insert Acquisition Points at configurable interval (8d)
- Write only active palette entries in PDS (8e)
- Track object version numbers (8f)
- Add -acquisition_point_interval AVOption
- FATE: verify DTS ordering, buffer model, palette size
```

## Context Structure Changes

```c
typedef struct PGSSubEncContext {
    /* existing fields */
    AVClass *class;
    int composition_number;
    int frame_rate;
    int quantize_method;
    int epoch_active;
    /* ... existing cache fields ... */

    /* Phase 8: decoder model */
    int acquisition_point_interval;  /* ms, 0 = disabled */
    int64_t last_ap_pts;             /* PTS of last Acquisition Point */
    int obj_version[PGS_MAX_OBJECT_REFS]; /* ODS version per object_id */

    /* Buffer model state */
    int64_t coded_buffer_fill;       /* bytes in coded data buffer */
    int64_t coded_buffer_last_pts;   /* PTS of last buffer drain */
    int decoded_buffer_used;         /* bytes in decoded object buffer */

    /* Cached RLE for Acquisition Point reuse */
    uint8_t *cached_rle[PGS_MAX_OBJECT_REFS];
    int cached_rle_size[PGS_MAX_OBJECT_REFS];
} PGSSubEncContext;
```

## Timing Implementation Detail

The encoder currently writes raw segment payloads into a flat buffer.
The PG headers (magic + PTS + DTS + type + size) are added by the
muxer for `.sup` output or by the TS muxer for M2TS.

For DTS computation, the encoder needs to know total segment sizes
before writing headers. Implementation approach:

1. RLE-encode objects first (already done — `pgs_encode_rle`)
2. Compute total display set size from RLE sizes + header sizes
3. Compute DECODE_DURATION from composition state and object dimensions
4. Set packet DTS = PTS - DECODE_DURATION
5. Store per-segment timestamps via AV_PKT_DATA_SUBTITLE_POSITION
   side data (or extend `AVSubtitle` — TBD based on upstream API)

For the `.sup` muxer, DTS goes directly into the PG header.
For M2TS, DTS goes into the PES header.

## FATE Testing

### Timestamp validation
- Encode a subtitle, decode it, verify DTS < PTS for all segments
- Verify DTS monotonically non-decreasing within display set
- Verify PTS(last_ODS) = PTS(END)

### Buffer model
- Encode rapid animation sequence, verify no buffer underflow warnings
- Encode large full-screen object, verify sufficient decode duration

### Acquisition Points
- Encode 10-second subtitle, verify Acquisition Points at expected
  intervals
- Decode from mid-stream Acquisition Point, verify correct display

### Palette optimization
- Encode 4-color subtitle, verify PDS payload < 30 bytes
- Round-trip: encode with optimized PDS, decode, verify identical output

### Object versions
- Encode two subtitles in one epoch, verify object version increments

## Risks

| Risk | Mitigation |
|------|-----------|
| DTS computation breaks existing streams | Default to current behavior when DTS cannot be computed; add `-pgs_timing` option |
| Buffer model too conservative | Calibrate against SUPer output on real Blu-ray content |
| Acquisition Points inflate stream size | Only emit when interval > 0 and subtitle is actively displayed |
| Side data approach rejected upstream | Fall back to extending PGSSubEncContext with timing fields |

## Verification

```bash
# Build and test
make -j$(nproc) && make fate

# Timing validation
./ffmpeg -i test.srt -c:s pgssub -s 1920x1080 /tmp/timed.sup
./ffprobe -v error -show_packets /tmp/timed.sup | grep -E 'pts|dts'
# Verify: dts < pts for all packets, dts values increase

# Buffer model
./ffmpeg -i test_animation.ass -c:s pgssub -s 1920x1080 /tmp/anim.sup 2>&1
# Verify: no buffer underflow warnings

# Acquisition Points
./ffmpeg -i test_long.srt -c:s pgssub -s 1920x1080 \
  -acquisition_point_interval 5000 /tmp/ap.sup
./ffprobe -v error -show_packets /tmp/ap.sup | grep -c 'flags.*K'
# Verify: Acquisition Points at ~5s intervals

# Palette size
./ffprobe -v error -show_packets -select_streams s /tmp/timed.sup \
  | awk '/size/{print $0}'
# Verify: PDS packets < 100 bytes for simple subtitles
```

## References

- US7620297B2 — Decoder model, buffer management, Rx/Rd/Rc rates
- US8638861B2 — Segment syntax, Coded Data Buffer, timing rules
- US20090185789A1 — Stream shaping, Acquisition Point strategy
- SUPer (cubicibo) — Hardware-validated reference implementation
- `docs/pgs-specification.md` — Compiled specification (Section 11)
- PHASE1.md — Deferred items from initial encoder implementation
