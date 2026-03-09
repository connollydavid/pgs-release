# Phase 7: OCR Bitmap-to-Text Subtitle Conversion

## Status: In Progress

Implementation complete in ffmpeg submodule (2 commits on `pgs-series`).
Language testing at 105/114 (92%). CI integration (Tesseract static
builds) in progress. FATE tests and dedup CLI options not yet implemented.

## Context

Phases 1-6 built a complete text-to-bitmap subtitle pipeline (PGS
encoder, quantization API, libass rendering, animation support, GIF).
Phase 7 is the reverse: bitmap subtitles (PGS, DVB, DVD, XSUB) to
text (ASS, SRT, WebVTT, MOV text) via OCR.

FFmpeg already has partial infrastructure:
- `vf_ocr.c` -- Tesseract video filter (LGPL 2.1+, 143 lines)
- `configure` -- `--enable-libtesseract` wired up
- `avlanguage.{h,c}` -- ISO 639 language code conversion (484 languages)

But the subtitle conversion path is explicitly blocked:
- `ffmpeg_mux_init.c:905-909` rejects bitmap-to-text with an error

This blocks 16 conversion pairs (4 bitmap decoders x 4 text encoders).

### Prior art

No prior bitmap-to-text subtitle conversion has been attempted in FFmpeg.
The existing `vf_ocr.c` is a video filter that reads text from video
frames into frame metadata -- not a subtitle conversion path. Our work
is the first to implement this direction.

## Architecture

Symmetric to Phase 3 (text-to-bitmap):

| Direction | Library | Utility | Orchestration |
|-----------|---------|---------|---------------|
| Text-to-bitmap (Phase 3) | libass | `subtitle_render.{h,c}` | `ffmpeg_enc.c` |
| Bitmap-to-text (Phase 7) | Tesseract | `subtitle_ocr.{h,c}` | `ffmpeg_enc.c` |

### Why this placement

- `vf_ocr.c` already proves Tesseract in libavfilter works (LGPL 2.1+)
- Putting Tesseract in libavcodec would repeat the 2022 Coza rejection
  (external library dependency in wrong layer -- see PHASE3.md)
- The probe-and-free pattern from `ffmpeg_mux_init.c` (text-to-bitmap
  gate at lines 893-904) gives the blueprint for runtime detection
- `ff_convert_lang_to()` lives in libavformat, accessible from fftools

### Licensing

Tesseract is Apache 2.0. Compatible with LGPL v2.1+ when used as an
external optional dependency (same pattern as libass, x264). FFmpeg's
`configure` handles this with `--enable-libtesseract`. Our code is
licensed LGPL 2.1+ (matching `vf_ocr.c`).

### Data flow

```
AVSubtitleRect (SUBTITLE_BITMAP)
  |
  v  fftools/ffmpeg_enc.c: convert_bitmap_to_text()
  |
  +-- bitmap deduplication (skip OCR for palette-only changes)
  +-- palette-to-grayscale conversion
  +-- avfilter_subtitle_ocr_recognize()     <-- libavfilter (Tesseract)
  +-- PSM 6 -> PSM 7 fallback (RTL/complex scripts)
  +-- RTL period fixup (post-processing)
  +-- position mapping: rect (x,y) -> \pos() or \an
  +-- build ASS Dialogue line
  +-- dedup buffer: extend or emit
  |
  v  AVSubtitleRect (SUBTITLE_ASS)
  |
  v  any text encoder (ass, subrip, webvtt, mov_text)
```

## Patch Structure

Two-patch structure (matching Phase 3 pattern):

```
Patch 1: lavfi: add bitmap subtitle OCR utility via Tesseract
  - New: libavfilter/subtitle_ocr.{h,c}
  - Modified: libavfilter/Makefile, configure
  - Modified: doc/APIchanges, libavfilter/version.h
  - Self-contained, FATE trivially passes (no behavioral change)

Patch 2: fftools: auto-convert bitmap subtitles to text via OCR
  - Modified: fftools/ffmpeg_enc.c (convert_bitmap_to_text,
    bitmap_to_grayscale, dedup state, positioning, language mapping)
  - Modified: fftools/ffmpeg_mux_init.c (lift gate, add options)
  - Activates the feature, unlocks 16 conversion pairs
```

### Upstream submission notes

- Each patch compiles and passes `make fate` independently
- Patch 1 is new files only (trivial FATE pass)
- Patch 2 modifies existing fftools code (FATE must be bit-for-bit)
- ASCII only in comments -- no Unicode arrows, em-dashes, curly quotes
- 4-space indent, 80-char lines, K&R braces, `snake_case` functions
- Declarations at top of block
- All public API functions documented with Doxygen `@param[in]/[out]`
- APIchanges must list ALL public functions added
- Ticket reference: #3819 (subtitle type incompatibility)

## New Files

### `libavfilter/subtitle_ocr.h` -- Public OCR API

```c
AVSubtitleOCRContext *avfilter_subtitle_ocr_alloc(void);
void avfilter_subtitle_ocr_freep(AVSubtitleOCRContext **ctx);
int avfilter_subtitle_ocr_init(AVSubtitleOCRContext *ctx,
                                const char *language,
                                const char *datapath);
int avfilter_subtitle_ocr_set_pageseg_mode(AVSubtitleOCRContext *ctx,
                                            int mode);
int avfilter_subtitle_ocr_recognize(AVSubtitleOCRContext *ctx,
                                     const uint8_t *data, int bpp,
                                     int linesize, int w, int h,
                                     char **text, int *avg_confidence);
```

- `CONFIG_LIBTESSERACT` gated (stubs return `AVERROR(ENOSYS)`)
- Opaque context, alloc/freep/init pattern matching `subtitle_render.h`
- Confidences copied to `av_malloc`'d memory (clean API boundary --
  caller uses `av_free()`, not Tesseract's `TessDeleteIntArray`)
- `|`-to-`I` post-processing for common OCR misread at word boundaries

### `libavfilter/subtitle_ocr.c` -- Implementation

Based on `vf_ocr.c` init/recognition pattern:
- `TessBaseAPICreate()` + `TessBaseAPIInit3(tess, datapath, language)`
- `TessBaseAPIRect(tess, data, bpp, linesize, 0, 0, w, h)`
- `TessBaseAPIEnd()` + `TessBaseAPIDelete()`

Per-language configuration:
- `user_defined_dpi=72` (subtitle bitmaps are low-resolution)
- `preserve_interword_spaces=0` for RTL scripts (ara, fas, heb, urd,
  yid, syr, pus, snd, uig) -- setting 1 causes word merging in RTL
- `preserve_interword_spaces=1` for all other scripts (prevents
  spurious spaces in CJK)

## Bitmap Preprocessing

### `bitmap_to_grayscale()` -- Two strategies by palette complexity

**Blocky sources** (nb_colors <= 8, e.g. DVD 4-color):

Binary text-body extraction. Count pixels per palette entry, identify
the most common opaque entry (alpha > 128) as text body. Render text
pixels black, everything else white. DVD subtitles have thick opaque
outlines that confuse OCR when rendered as grayscale; binary extraction
isolates just the text.

**Anti-aliased sources** (nb_colors > 8, e.g. PGS 256-color):

Luminance-alpha mapping: `gray = 255 - (alpha * lum / 255)`. Light
opaque text becomes dark (black), transparent/dark pixels become light
(white). This avoids identifying a "text body" color, which fails when
the outline has more pixels than the text fill.

16px white padding (`GRAYSCALE_PAD`) added around bitmap for both
strategies -- Tesseract needs margin for reliable text block detection.

### Rejected approach: color-distance alpha mapping

Identified text body by pixel count, then mapped nearby colors by alpha
proximity. Failed because outlined text has MORE outline pixels than fill
pixels, so the outline was identified as "text body." Replaced by the
nb_colors threshold approach above.

### Rejected approach: bitmap upscaling

Originally included bilinear (PGS) and nearest-neighbor (DVD) upscaling
to minimum width before OCR. Exhaustive testing (72 scenarios: 8 DVD
palettes x 3 words + 8 PGS palettes x 3 words + 8 PGS-inverted
palettes x 3 words) proved that with proper grayscale conversion,
upscaling is completely unnecessary. All 72 tests pass at 24pt/173px
(smaller than any real subtitle). Upscaling was compensating for a bad
grayscale conversion, not a Tesseract limitation. Removed entirely.

## PSM Mode Selection

Tesseract's Page Segmentation Mode (PSM) determines layout analysis.
No single mode works for all scripts:

| PSM | Description | Multi-line | Arabic/RTL | Myanmar | CJK |
|-----|-------------|-----------|------------|---------|-----|
| 6 | Uniform block (default) | YES | FAIL | FAIL | YES |
| 7 | Single text line | FAIL | YES | YES | YES |
| 4 | Single column | YES | FAIL | FAIL | YES |

### Fallback strategy (implemented)

1. OCR with PSM 6
2. If result is empty or very short (< 3 chars for bitmap > 100px wide),
   retry with PSM 7
3. User can override with `-sub_ocr_pageseg_mode N`

This handles multi-line Latin/CJK (PSM 6 succeeds) and single-line
RTL/Myanmar/Indic (PSM 6 fails, PSM 7 fallback succeeds).

Known limitation: multi-line RTL text may only return one line.
Tesseract does not reliably detect multiple RTL lines.

## Language Selection

```
Container metadata -> ff_convert_lang_to() -> iso639_to_tesseract() -> Tesseract
  "eng"/"fre"/"ger"     AV_LANG_ISO639_2_TERM     "eng"/"fra"/"deu"
  "chi"/"zho"                                       "chi_tra" (override)
```

- Default: "eng" (same as `vf_ocr.c`)
- User override: `-sub_ocr_lang jpn` (takes priority)
- Multi-language: Tesseract supports `eng+jpn` syntax
- Fallback: stream has no language tag -> "eng"

ISO 639-2/B (bibliographic, MKV) differs from 639-2/T (terminological,
Tesseract) for ~20 languages: `fre`->`fra`, `ger`->`deu`, `chi`->`zho`.
`ff_convert_lang_to()` handles this. Special cases (Chinese script
variants: `chi`->`chi_tra`) handled by `iso639_to_tesseract()`.

### RTL post-processing

Tesseract outputs RTL sentence periods at visual left (logical line
end = start of string in LTR byte order). Post-processing moves leading
`.` to end of its line. Implemented in `ffmpeg_enc.c`.

## Positioning

### Alignment detection (`\an` tag)

Canvas divided into 9 zones (numpad layout). `compute_alignment()`
maps bitmap rect center to zone:

```
 7 | 8 | 9  (top)
 4 | 5 | 6  (middle)
 1 | 2 | 3  (bottom)
```

### Per-format output

| Format | What we emit |
|--------|-------------|
| ASS | `{\an7\pos(x,y)}` -- top-left anchor at bitmap origin |
| ASS (movement) | `{\an7\move(x1,y1,x2,y2)}` when bitmap dedup detects position change |
| SRT | `{\anN}` from alignment detection |
| WebVTT | None (FFmpeg encoder ignores positioning) |
| MOV text | None (FFmpeg encoder ignores positioning) |

ASS `PlayResX`/`PlayResY` in the header must match source video
dimensions so `\pos` coordinates are meaningful.

## Deduplication

PGS fade sequences produce many display sets for one logical subtitle:
same bitmap with changing palette alpha, each ~42ms apart. Without
deduplication, OCR emits dozens of duplicate text events. Deduplication
is core, not optional.

### Bitmap deduplication (implemented, always on)

For each incoming SUBTITLE_BITMAP rect:
1. Compare `data[0]` (indexed pixel buffer) against cached previous
   - Same dimensions AND same pixel indices = same visual content
   - Palette changes (fades) don't affect `data[0]` -- only `data[1]`
2. If match: extend previous event's `end_display_time`, skip OCR
3. If mismatch: flush previous buffered event, OCR new bitmap
4. On stream end: flush final buffered event

O(w*h) `memcmp` per event -- negligible vs OCR cost (~100ms per call).

### Movement detection (implemented)

When bitmap dedup detects same bitmap at different (x, y) positions:
- Buffer position changes with timestamps
- On flush: if only 2 positions, emit `\move(x1,y1,x2,y2)` for ASS
- If >2 positions: emit at first position with full duration
  (ASS `\move` only supports linear A-to-B motion)

### Minimum subtitle duration (implemented)

`-sub_ocr_min_duration` (default 200ms). Events shorter than this after
deduplication are discarded. Catches stray fade frames that slip through
bitmap dedup (e.g. first frame of a fade-in). PGS fade frames are ~42ms;
meaningful subtitles are >= 500ms.

### Open-ended duration handling (implemented)

PGS events with `end_display_time == UINT32_MAX` (no explicit end).
Duration inferred from gap to next event's PTS. Caps at 10 seconds
if no subsequent event arrives.

### Future: text-level dedup (`-sub_ocr_dedup` modes)

Not yet implemented as CLI options. Planned modes:
- `bitmap` (current default, always on)
- `text` -- OCR every event, merge if text matches within merge gap
- `both` -- bitmap first, then text comparison
- `none` -- no deduplication

### Future: merge gap (`-sub_ocr_merge_gap`)

Not yet implemented. How long a subtitle can disappear and reappear
before it counts as a new subtitle. Default would be 100ms.

## Configuration Options

| Option | Type | Default | Status |
|--------|------|---------|--------|
| `sub_ocr_lang` | string | auto/eng | Implemented |
| `sub_ocr_datapath` | string | NULL | Implemented |
| `sub_ocr_pageseg_mode` | int | 6 (with 7 fallback) | Implemented |
| `sub_ocr_min_duration` | int (ms) | 200 | Implemented |
| `sub_ocr_dedup` | enum | bitmap | Not yet (always bitmap) |
| `sub_ocr_merge_gap` | int (ms) | 100 | Not yet |
| `sub_ocr_min_confidence` | int | 0 | Not yet |

## Language Testing Results

Comprehensive UDHR Article 1 roundtrip test (text -> PGS -> text via
OCR). 14 languages excluded (broken tessdata: vertical CJK, math, dead
scripts). **105 pass, 9 fail** (92%).

### Fixes that enabled 105/114 pass rate

1. **`preserve_interword_spaces=0` for RTL** -- fixed ara, fas, heb
   word merging (3 languages recovered)
2. **RTL period fixup** -- move leading `.` to end of line
3. **ASS format for rendering** (not SRT) -- ASS at 1920x1080 with
   48pt font gives Tesseract clear glyphs vs SRT at 384x288 with 16pt
4. **Per-script font selection** -- Arial default, Noto Sans for
   Vietnamese/Middle French, per-script Noto for non-Latin
5. **PSM 6+7 fallback** -- handles RTL and Myanmar

### 9 remaining failures (tessdata quality)

All are fundamental LSTM model limitations. No config variable or
preprocessing can fix these:

| Lang | Issue |
|------|-------|
| bre | o->0, ha->na (poor tessdata) |
| fao | e->ae confusion |
| hye | h->r (Armenian glyph confusion) |
| khm | Stacked vowel marks dropped |
| lao | Vowel marks dropped |
| mya | Fundamentally broken tessdata |
| pan | Empty output (Gurmukhi unrecognizable) |
| urd | One-char swap in common word |
| yor | Combining acute accents lost |

Fix requires fine-tuning the LSTM model with script-specific training
data. Beyond our scope.

### Configs tested and found ineffective

- `textord_min_linesize` (1.25-3.0): no change
- `thresholding_method=2` (Sauvola): no change
- DPI changes (72/150/300): no change for Khmer/Lao
- Font size changes (48/60/72): no consistent improvement
- Letter spacing in ASS: breaks Arabic completely

## FATE Testing

Extensive FATE coverage planned. End-to-end roundtrip tests exercise
both text-to-bitmap (Phase 3) and bitmap-to-text (Phase 7) together,
proving reversibility. All OCR tests gated on `CONFIG_LIBTESSERACT`.

### Testing discipline (lessons from Phases 1-6)

- A test that compares output-against-itself is NOT a real test.
  Roundtrip tests MUST compare against the known-correct input string.
- Use realistic input dimensions. Real Blu-ray PGS subtitles use ~72pt
  at 1920x1080. Match real-world conditions.
- DVD uses composited grayscale (`bitmap_to_grayscale` text-body
  extraction). PGS uses luminance-alpha mapping. Test both paths.
- OCR output depends on Tesseract version and training data. Tests use
  simple, high-contrast synthetic inputs where OCR is deterministic
  across Tesseract 4.x/5.x.

### Test categories

**API unit test (Patch 1):** Init/cleanup, error codes, basic
recognition of synthetic grayscale image. Valgrind-clean.

**Per-format tests (Patch 2):** PGS->SRT, DVD->SRT, DVB->SRT using
existing FATE samples.

**Deduplication tests:** PGS fade sequence -> verify single text event
(not N duplicates). Compare dedup on vs off.

**Positioning tests:** PGS with top-positioned subtitle -> verify
`\an`/`\pos` tags in ASS/SRT output.

**Roundtrip tests (key):** SRT->PGS->SRT, ASS->PGS->ASS, SRT->DVB->SRT.
Verify text content and timing survive the round trip. These prove both
pipelines work together end-to-end.

**Language tests:** Verify auto-detection from container metadata and
manual override with `-sub_ocr_lang`.

### Test input generation

Synthetic inputs only -- no copyrighted content:
- SRT/ASS files with simple Latin-script text
- PGS files generated by our own encoder (Phase 1)
- PGS fade sequences from our animation pipeline (Phase 3a)

## Usage

```bash
# PGS to SRT (bitmap dedup on by default)
ffmpeg -i movie.mkv -map 0:s:0 -c:s srt output.srt

# PGS to ASS with positioning
ffmpeg -i movie.mkv -map 0:s:0 -c:s ass output.ass

# DVD subtitles to SRT (Japanese)
ffmpeg -i movie.mkv -map 0:s:0 -c:s srt -sub_ocr_lang jpn output.srt

# Custom training data path
ffmpeg -i movie.mkv -map 0:s:0 -c:s srt \
  -sub_ocr_datapath /usr/share/tessdata output.srt

# Override page segmentation mode
ffmpeg -i movie.mkv -map 0:s:0 -c:s srt -sub_ocr_pageseg_mode 7 output.srt
```

## File Manifest

### New files

| File | Library |
|------|---------|
| `libavfilter/subtitle_ocr.h` | libavfilter |
| `libavfilter/subtitle_ocr.c` | libavfilter |

### Modified files

| File | Change |
|------|--------|
| `fftools/ffmpeg_enc.c` | `convert_bitmap_to_text()`, `bitmap_to_grayscale()`, dedup state, positioning, language mapping, PSM fallback, RTL fixup |
| `fftools/ffmpeg_mux_init.c` | Lift bitmap-to-text gate, add OCR options |
| `libavfilter/Makefile` | Add `subtitle_ocr.o` |
| `configure` | Gate `subtitle_ocr` on `CONFIG_LIBTESSERACT` |
| `doc/APIchanges` | List new public functions |
| `libavfilter/version.h` | Version bump |

## Risks

| Risk | Mitigation |
|------|-----------|
| Tesseract accuracy on anti-aliased PGS | Luminance-alpha grayscale preserves edges; PSM 6 uniform block |
| DVD 4-color blocky text | Binary text-body extraction isolates text from outline |
| Missing training data at runtime | Clear error message, default "eng", document requirements |
| Upstream acceptance | Follows `vf_ocr.c` pattern; symmetric to accepted text-to-bitmap |
| PGS fade sequence spam | Bitmap dedup skips OCR entirely for palette-only changes |
| Multi-rect PGS (top/bottom split) | OCR each rect independently, separate dialogue lines |
| RTL/complex script failures | PSM 6->7 fallback; per-language interword_spaces config |
| 9 tessdata-quality failures | Documented as fundamental LSTM limitations; beyond our scope |

## References

- `libavfilter/vf_ocr.c` -- reference Tesseract C API integration
- `libavfilter/subtitle_render.{h,c}` -- API design pattern (symmetric)
- `fftools/ffmpeg_enc.c:convert_text_to_bitmap()` -- symmetric function
- `fftools/ffmpeg_mux_init.c:893-910` -- gate pattern
- `libavformat/avlanguage.{h,c}` -- ISO 639 conversion
- FFmpeg ticket #3819 -- subtitle type incompatibility
