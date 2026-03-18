# Phase 14: Upstream Submission Restructuring (v7)

## Status: Planning

Restructure the v5+v6 patch stack (32 patches on top of FFmpeg 8.1) into
independent upstream submission series ordered by controversy level.

## Motivation

The current v5+v6 stack couples the PGS encoder (low controversy) with the
quantization API and text-to-bitmap pipeline (high controversy). If the
quantization API stalls in review, everything stalls. Decoupling lets the
encoder merge independently.

## Series Mapping

Patches 1-43 are upstream FFmpeg 8.1 release commits — not part of our series.
Mapping starts at patch 44.

### Series A: Standalone fixes (submit first, merge fast)

| v5/v6 # | Commit | Description |
|---------|--------|-------------|
| 73 | `0f73c18470` | lavf/mpegts: DVB forced types 0x30-0x35 |

1 patch. No dependencies. Submit immediately.

### Series B: PGS encoder + bitmap features (the core deliverable)

| v5/v6 # | Commit | Description | Notes |
|---------|--------|-------------|-------|
| 44 | `ac50e9d93d` | lavc/pgssubenc: PGS encoder core | Foundation |
| 62 | `fa80dd3402` | lavc/pgssubenc: palette delta PDS | Encoder feature |
| 63 | `6ced590822` | lavf/supenc: per-segment DTS | Muxer timing |
| 64 | `4b358203de` | fftools: PGS packet DTS | fftools timing |
| 66 | `5f2ef4c10a` | tests: FATE coverage for v5 | Tests |
| 67 | `a4262366a4` | tests: palette reuse | Tests |
| 68 | `4c46183261` | tests: multi-object | Tests |
| 69 | `88d3bf362e` | tests: AP interval | Tests |
| 70 | `18e48a70f8` | force_all option | Encoder option |
| 71 | `d0ba769aac` | max_cdb_usage rate control | Encoder option |
| 72 | `4f23a1f0ea` | disposition bridge | fftools (bitmap path) |
| 74 | `4d24411183` | forced_subs_filter | fftools CLI option |
| 61 | `5856c39963` | doc: PGS encoder docs | Documentation |

~13 patches. Only dependency: FFmpeg 8.1. No new public APIs.
The encoder accepts SUBTITLE_BITMAP input — works for PGS/DVD remux.

**Challenge:** Patches 64 and 72 touch `fftools/ffmpeg_enc_sub.c` which is
created in the text-to-bitmap series (Series D, patch 56). For Series B,
these fftools changes need to go into `fftools/ffmpeg_enc.c` or a new file
that doesn't depend on the text-to-bitmap infrastructure.

**Decision needed:** Do we create a minimal `fftools/ffmpeg_enc_sub.c` stub
in Series B (DTS + disposition bridge + filter only) and expand it in
Series D? Or put the DTS/bridge logic in `fftools/ffmpeg_enc.c`?

### Series C: Quantization API (submit in parallel with B)

| v5/v6 # | Commit | Description |
|---------|--------|-------------|
| 45 | `73ed205596` | lavu: OkLab palette utilities |
| 46 | `93305b122a` | lavu: NeuQuant quantization API |
| 47 | `c9a1ee2801` | lavu: palette mapping extraction |
| 48 | `7ae7415b05` | lavfi/vf_paletteuse: use lavu palette mapping |
| 49 | `bb8c24b786` | lavu/quantize: region-weighted palette |
| 50 | `b02798b6d9` | lavu: ELBG move from lavc to lavu |
| 51 | `8b1b76834c` | lavu: Median Cut quantizer |
| 52 | `7b58c356fb` | lavfi/vf_palettegen: use lavu Median Cut |
| 53 | `483c750c90` | lavu: ELBG quantizer algorithm |
| 57 | `72d7958027` | lavc/gif: RGBA input with quantization |

~10 patches. Independent of Series B. Adds generic quantization API to
libavutil with NeuQuant, Median Cut, and ELBG algorithms. Also benefits
GIF encoding (patch 57).

### Series D: Text-to-bitmap pipeline (after B + C merge)

| v5/v6 # | Commit | Description |
|---------|--------|-------------|
| 54 | `cdf27be210` | lavu: subtitle bitmap utilities |
| 55 | `bc32c66bb9` | lavfi: libass text rendering utility |
| 56 | `fcb6fd01f3` | fftools: text-to-bitmap conversion |
| 60 | `77a0deb623` | fftools: wire conversion into pipeline |
| 65 | `55a025810a` | fftools: event lookahead window |
| 75 | `6190c8e773` | forced_style option |

~6 patches. Depends on B (encoder) + C (quantization). This is the
controversial subtitle infrastructure — libass rendering, fftools subtitle
conversion, overlapping event handling.

### Series E: OCR (optional, after D)

| v5/v6 # | Commit | Description |
|---------|--------|-------------|
| 58 | `94b54ae84a` | lavfi: Tesseract OCR utility |
| 59 | `ac5ed1f991` | fftools: bitmap-to-text via OCR |

2 patches. Optional. Adds Tesseract-based PGS/DVD → SRT conversion.

## Implementation: v7 branch structure

- `pgs7-wip` — work branch for restructuring
- `pgs7-a` — Series A (1 patch, mpegts fix)
- `pgs7-b` — Series B (~13 patches, encoder + bitmap features)
- `pgs7-c` — Series C (~10 patches, quantization API)
- `pgs7-d` — Series D (~6 patches, text-to-bitmap)
- `pgs7-e` — Series E (2 patches, OCR)
- `pgs7` — final combined branch (= v6 equivalent, all series merged)

Each series branch is based on `upstream/master` (or the prior series for
D and E). The combined `pgs7` should produce identical output to `pgs6`.

## Key challenges

1. **fftools/ffmpeg_enc_sub.c split**: This file contains both bitmap-path
   code (DTS, disposition bridge, forced filter) and text-to-bitmap code
   (libass rendering, quantization, event lookahead). Series B needs the
   bitmap-path parts without depending on Series D's text-to-bitmap parts.

2. **Patch splitting**: Some v5 commits may need to be split. E.g., patch 61
   (docs) covers both PGS encoder and OCR options.

3. **Header dependencies**: `pgs-test-util.h` and shared headers need to
   exist in Series B even though some functions are only used by Series D tests.

4. **Compilation verification**: Each series must compile independently.
   This needs `git rebase --exec 'make -j$(nproc)'` per series branch.

## Next steps

1. Decide on the fftools/ffmpeg_enc_sub.c split strategy
2. Create Series A branch (trivial — 1 cherry-pick)
3. Create Series B branch (most work — extract encoder-only code)
4. Verify B compiles and passes FATE without C/D/E
5. Create C, D, E branches
6. Verify combined pgs7 matches pgs6 output
