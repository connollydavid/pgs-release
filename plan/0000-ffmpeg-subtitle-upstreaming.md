# FFmpeg subtitle upstreaming programme

## Status: Standing

This is the programme charter: the enduring context that spans every
milestone in the plan. It records why the work exists, the architecture it
follows, what upstream acceptance requires, and the backlog of work not yet
cut into a milestone. The milestone index lives in [plan/PLAN.md](PLAN.md);
each milestone's own record lives in its folder.

## Context

FFmpeg has no PGS subtitle encoder (ticket #6843) and no way to convert
text subtitles to bitmap format (ticket #3819). This blocks 72 subtitle
conversion pairs (18 text decoders × 4 bitmap encoders).

The programme builds seven things:

1. PGS encoder (self-contained, no dependencies on the rest)
2. Generic color quantization API (pure utility in libavutil)
3. Text-to-bitmap conversion (rendering in libavfilter, orchestrated by fftools)
4. DVD subtitle encoder consolidation (first consumer of shared API)
5. Median Cut + ELBG algorithm integration + GIF cleanup (complete unification)
6. GIF encoder RGBA quantization (direct RGBA-to-GIF without filter pipeline)
7. OCR bitmap-to-text conversion (reverse of plan/0003, via Tesseract)

## Architecture

### Library boundaries

```
libavutil    ← quantizer API, OkLab, dithering, palette mapping
libavcodec   ← encoders (accept SUBTITLE_BITMAP only, unchanged)
libavfilter  ← text-to-RGBA rendering (where libass already lives)
fftools      ← detect type mismatch, orchestrate render + quantize
```

Dependency order: `libavutil ← libavcodec ← libavformat ← libavfilter ← fftools`

- libavfilter already has libass (`vf_subtitles.c`)
- libavcodec CANNOT depend on libavfilter
- Putting libass in libavcodec was the 2022 rejection reason
- fftools already orchestrates sub2video: same pattern

The quantizer API accepts palettes of 2-256 colours because the bitmap
targets differ: DVD uses 4, DVB 16, PGS 256.

### Data flow (plan/0003)

```
AVSubtitleRect (SUBTITLE_ASS or SUBTITLE_TEXT)
  │
  ▼ fftools/ffmpeg_enc.c detects type mismatch
  │
  ├─ avfilter_subtitle_render_frame()         ← libavfilter (libass)
  │   └─ rasterize -> composite -> crop -> RGBA buffer
  ├─ av_quantize_generate_palette()          ← libavutil
  ├─ av_quantize_apply()                     ← libavutil
  └─ rewrite rect: type=BITMAP, data[0]=indices, data[1]=palette
  │
  ▼ AVSubtitleRect (type=SUBTITLE_BITMAP)
  │
  ▼ any bitmap encoder (pgssub, dvbsub, dvdsub, xsub)
```

## Upstream Acceptance Intelligence

### Key risks

| Risk | Evidence | Mitigation |
|------|----------|-----------|
| **Text-to-bitmap rejected in 2022** | [Coza's 12-patch series](https://patchwork.ffmpeg.org/project/ffmpeg/cover/20220503161328.842587-1-traian.coza@gmail.com/): wrong location (libavcodec), called "hacky" | Rendering in libavfilter (where libass lives); send RFC first |
| **Subtitle filtering is contentious** | Active [RFC](https://www.mail-archive.com/ffmpeg-devel@ffmpeg.org/msg181951.html) (May 2025) + [$1000 bounty dispute](https://www.mail-archive.com/ffmpeg-devel@ffmpeg.org/msg181991.html) | Don't build subtitle filter infrastructure; use utility function pattern |
| **Large series get stuck** | softworkz's 25-patch set: 9 versions, never merged | 2-4 patches per series |
| **AI code policy** | [RFC July 2025](https://www.mail-archive.com/ffmpeg-devel@ffmpeg.org/msg183437.html): AMD patch rejected as "AI slop" | Disclose assistance; thorough human review |
| **Ticket #6843** | [PGS encoder requested](https://trac.ffmpeg.org/ticket/6843) | Reference in commits |
| **Ticket #3819** | [Subtitle type incompatibility](https://trac.ffmpeg.org/ticket/3819) | plan/0003 addresses directly |

### Key reviewers

- **Lynne**: skeptical of subtitle architecture changes
- **Anton Khirnov**: design purity
- **Hendrik Leppkes**: subtitle architecture
- **Michael Niedermayer**: security, edge cases

## Submission Strategy

Tests are included in the same patch as the code they test (supporting
evidence, not separate patches).

```
RFC email
plan/0001:  [PATCH 1/1] PGS encoder + composition states    ← DONE (2cc882f669), includes state machine
plan/0002 (api):  [PATCH 1/2] OkLab move + Quantizer API   ← DONE (8e60ec654f, 8d7abb5328)
plan/0002 (map):  [PATCH 1/2] Palette mapping extraction   ← DONE (3326aa9602, 557d01153a)
plan/0003:  [PATCH 1/2] Text-to-bitmap + rect splitting     ← DONE
plan/0003 (anim): [PATCH 1/1] Text-to-bitmap: universal animation ← DONE
plan/0004:  [PATCH 1/2] Region-weighted quantization          ← DONE (fd72cd4d83, b4ed0c4e82)
plan/0005:  [PATCH 1/5] Median Cut + ELBG algorithm integration  ← DONE
plan/0006:  [PATCH 1/1] GIF encoder RGBA quantization          ← DONE (d215fe732d)
plan/0009:  [PATCH 1/1] PGS decoder model compliance            ← PARTIAL (DTS+palette done in v5; buffer model+AP -> plan/0017)
```

Total: ~20 patches across 9 submissions. Each series is independent
(plan/0009 depends on plan/0001 only). How the submission series were cut
for v8 is recorded in
plan/0018-upstream-submission-restructuring/README.md.

### Milestone dependency for animation

Animation support spans plan/0001 (encoder state machine, done) and
its animation amendment (animation-aware conversion), which calls the encoder
with palette-only Normal Display Sets to produce fade effects.

```
plan/0001 (encoder + composition states) ← DONE
                        │
plan/0003 (text-to-bitmap) --> animation amendment (universal animation pipeline)
```

plan/0002 and plan/0005 are unaffected by animation work. plan/0004
(region-weighted quantization) improves karaoke quality specifically during
animation.

### RFC email (before any patches)

```
Subject: [RFC] PGS subtitle encoder, quantization API,
         and text-to-bitmap subtitle conversion

I'm working on a PGS subtitle encoder (ticket #6843) and
text-to-bitmap subtitle conversion (ticket #3819) that would
unlock 72 currently broken decoder-encoder pairs.

Architecture:
- Color quantization API in libavutil (NeuQuant with OkLab,
  variable palette 2-256, dithering extracted from vf_paletteuse)
- Text rendering utility in libavfilter (where libass already
  lives via vf_subtitles.c: no new external dependencies)
- Orchestration in fftools (same pattern as sub2video)
- Encoders unchanged: still accept SUBTITLE_BITMAP only

The rendering lives in libavfilter because libavcodec cannot
depend on libass (Coza's 2022 series was rejected for this).
The API is public (avfilter_subtitle_render_*) because ff_
symbols are invisible to fftools in shared builds.

I deliberately avoided building subtitle filter infrastructure
(buffersrc/sink, AVFrame subtitle support). The subtitle
filtering discussion has fundamental unresolved design
questions (sparse/overlapping event timing vs contiguous
frame scheduling). Our utility function approach is orthogonal:
it works with existing AVSubtitle, requires no AVFrame
changes, and can serve as a building block for a future
text2graphicsub filter if that infrastructure lands.

The implementation is 2 patches, ~500 lines. Each phase in
the series is independently useful and independently testable.

Code at [repo URL]. Tested with roundtrip encode/decode.
```

### Patch discipline

- 4-space indent, no tabs, 80-char lines
- K&R style, `snake_case` functions, `CamelCase` types
- Each patch compiles and passes `make fate` independently
- Commit messages: `area: short description\n\ndetails`
- No cosmetic + functional changes mixed
- Tests included with the code they test (not separate patches)

### Upstream requirements for new public API (plan/0002)

| Requirement | Action |
|-------------|--------|
| Version bump | `libavutil/version.h`: MINOR 25->26, MICRO->100 |
| APIchanges | `doc/APIchanges`: list new public functions |
| Header guard | `AVUTIL_QUANTIZE_H` |
| Free naming | `av_quantize_freep()` (`**ptr` pattern) |
| Opaque context | Struct definition in .c only |
| Errors | Alloc returns NULL; operations return negative `AVERROR` |
| Doxygen | `@param[in]`, `@param[out]`, `@return`, `@note` |

A public API is required because plan/0003, plan/0004 and plan/0005 all
call `av_quantize_*` across library boundaries.

## Deferred work

Backlog items discussed but not yet cut into a milestone. When one is
taken up, cut a milestone for it and move the detail there.

### Rate control (deferred from plan/0017)

- **CDB event deferral**: current `max_cdb_usage` drops events. Full
  deferral would re-queue events in the fftools event buffer and retry when
  CDB has refilled. Requires changes to `ffmpeg_enc_sub.c` event loop.
  Deferred because `avcodec_encode_subtitle` is synchronous: no EAGAIN.

### Upstream fixes (not our code, but we could submit)

- **movenc.c**: doesn't write `AV_DISPOSITION_FORCED` to MP4 track
  metadata. The read side (isom.c) handles it. One-line fix.
- **dvbsubdec.c**: doesn't set `AV_SUBTITLE_FLAG_FORCED` per-rect.
  DVB forced is stream-level only. Bridge via disposition (our forced-flag
  patch) works around this.
- **dvbsubenc.c**: doesn't read `AV_SUBTITLE_FLAG_FORCED`. PGS->DVB
  transcoding loses forced flag at the content level.

### Features (discussed, not started)

- **Subtitle stream merging**: merge forced + non-forced input streams
  into one PGS output. Discussed as "Approach E" (priority queue in fftools
  accepting events from multiple decoders). Significant fftools work.
- **Over-broad animation detection**: `strchr(rect->ass, '{')` triggers
  multi-timepoint scanning for any ASS override tag, including non-animated
  ones like `{\b1}`. Check for animation-specific tags (`\fad`, `\move`,
  `\t`, `\fade`) instead. See the over-broad animation detection finding in
  plan/0010-upstream-suitability-audit/README.md.
- **GIF global palette option**: cache the first frame's palette for
  subsequent frames (plan/0006 uses a per-frame palette and has no
  `stats_mode=diff_frames` equivalent, so animated GIFs with changing
  content may use more bandwidth than the filter pipeline).

## References

### Patents (specification basis)

| Patent | Assignee | Covers |
|--------|----------|--------|
| US20090185789A1 | Panasonic | Stream shaping, decoder model, composition states |
| US8638861B2 | Sony | Segment syntax, buffering model, timing constraints |
| US7620297B2 | Panasonic | Decoder model, object buffer management, transfer rates |

### Compiled specification

- `docs/pgs-specification.md`: Synthesized from patents + reverse engineering

### Reference implementations (cited for spec interpretation, not code)

- FFmpeg `libavcodec/pgssubdec.c`: Reference decoder
- SUPer: Hardware-validated PGS encoder (composition state transitions,
  decoder model compliance, palette animation sequences)

## Release Builds

Pre-built binaries are distributed via GitHub Actions (`ffmpeg-release.yml`).

### Configuration

Minimal subtitle-focused FFmpeg build (`--disable-everything` + selective enables):
- **Subtitle decoders**: ASS, SSA, SRT, WebVTT, PGS, DVB, DVD, XSUB, MOV text, and others
- **Subtitle encoders**: pgssub (ours), ASS, SRT, WebVTT, MOV text, DVB
- **Container muxers/demuxers**: MKV, MP4, MOV, MPEG-TS, SUP, SRT, ASS, WebVTT, AVI (for copy)
- **Parsers**: H.264, HEVC, AV1, VP9, AAC, AC3 (bitstream framing for `-c copy`)
- **BSFs**: h264_mp4toannexb, hevc_mp4toannexb, aac_adtstoasc, extract_extradata
- **Filters**: subtitles (libass overlay), null, anull, copy, acopy
- **libass**: statically linked (from the pinned libass component in `.host-software` on Windows; system package on Linux/macOS)

### Targets

| Target | Runner | Toolchain |
|--------|--------|-----------|
| linux-x86_64 | ubuntu-24.04 | native gcc |
| linux-arm64 | ubuntu-24.04-arm | native gcc |
| macos-x86_64 | macos-13 | native clang |
| macos-arm64 | macos-14 | native clang |
| windows-x86_64 | ubuntu-24.04 | mingw-w64 cross |
| windows-arm64 | ubuntu-24.04 | llvm-mingw cross |
