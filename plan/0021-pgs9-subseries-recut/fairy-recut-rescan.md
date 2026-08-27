# Review: Subtitle conversion series (restructured, 18 commits)

I scanned the full range `bf1b838f2a..cff4e4008e` commit-by-commit. The four-sub-series shape described in the PR body is mostly visible in the tree, but the restructure did **not** land cleanly. There are several structural defects a maintainer would block on, and they cluster exactly in the areas the PR body claims were fixed ("atomic version bumps", "tests folded into their features", "merges that eliminate churn"). Listed structure-first, line-level last.

---

## Blocking structural objections

### 1. `tests/fate/api.mak` was destroyed; no API test runs in FATE anymore

This is the most serious issue and is plainly an unintentional artifact of the restructure.

- **Commit 9aa16fa005 (`lavf/supenc: compute per-segment DTS`)** deletes the *entire* original `tests/fate/api.mak` (49 lines: `fate-api-flac`, `fate-api-h264`, `fate-api-band`, `fate-api-seek`, `fate-api-threadmessage`, `fate-api-enc-parser`, **and** the aggregation block):
  ```
  FATE_API-$(CONFIG_AVCODEC) += $(FATE_API_LIBAVCODEC-yes)
  FATE_API = $(FATE_API-yes)
  FATE-yes += $(FATE_API) $(FATE_API_SAMPLES)
  fate-api: $(FATE_API) $(FATE_API_SAMPLES)
  ```
  …leaving a single blank line. This is completely unrelated to the SUP muxer change and has no business in that commit.
- **Commit 212f317265 (`lavc/pgssubenc`)** then rebuilds `api.mak` with *only* the PGS `FATE_API_LIBAVCODEC-$(CONFIG_PGSSUB_ENCODER)` entries and never restores the aggregation.
- The final `tests/fate/api.mak` (63 lines) contains **no** `FATE_API =`, **no** `FATE-yes += $(FATE_API)`, and **no** `fate-api:` target. `tests/Makefile` only does `FATE += $(FATE-yes)` — nothing ever feeds `FATE_API_LIBAVCODEC-*` into `FATE-yes`.

Result: every `fate-api-*` test, both the pre-existing ones (`flac`, `h264`, `band`, `seek`, `threadmessage`, `enc-parser`) **and** the 13 new PGS tests, is silently dropped from FATE. `tests/api/Makefile` still lists the old progs so they still *build*, but nothing *runs* them. The PR body's "tests folded into their features" goal is defeated — the new tests are wired to nothing. A maintainer will revert this file to the base and re-add the PGS entries without touching the aggregation.

### 2. `libavutil/version.h` carries a duplicate `#define LIBAVUTIL_VERSION_MINOR 6`

Introduced in 29e2f614c9 and carried through b90a35e73b into the final tree:
```c
#define LIBAVUTIL_VERSION_MAJOR  61
#define LIBAVUTIL_VERSION_MINOR   6

#define LIBAVUTIL_VERSION_MINOR   6
#define LIBAVUTIL_VERSION_MICRO 100
```
A stray duplicate macro definition. It compiles, but it's an obvious merge/restructure artifact.

### 3. lavu version bumps are incoherent and not atomic

The PR body explicitly promises "atomic version bumps." The actual sequence:

| commit | claims | actual `version.h` | `APIchanges` says |
|---|---|---|---|
| c36910baf8 (move OkLab) | nothing | no bump | — |
| 7317e05af2 (move ELBG) | — | 1 → 2 | — |
| a7eedc4585 (quant API + NeuQuant) | "Bump lavu minor version" | **no bump (stays 2)** | `lavu 61.3.100` |
| 016d857168 (palette map avpriv) | "avpriv exports bump the lavu minor" | 2 → **4** (skips 3) | no entry |
| 29e2f614c9 (Median Cut) | "bump the lavu minor" | 4 → 5 (+ dup line) | `lavu 61.3.100` (wrong) |
| b90a35e73b (ELBG) | "Bump lavu minor version" | 5 → 6 | `lavu 61.6.100` for ELBG **and** for `av_quantize_add_region`/`AV_QUANTIZE_MAX_REGIONS` |

Problems:
- a7eedc4585 says it bumps but doesn't; its `APIchanges` entry references `61.3.100`, a version that never exists.
- Minor 3 is skipped entirely; the NeuQuant API is effectively attributed to no bump and the Median Cut `APIchanges` entry mis-claims `61.3.100` instead of `61.5.100`.
- `av_quantize_add_region()` and `AV_QUANTIZE_MAX_REGIONS` were added in 29e2f614c9 (Median Cut), but their `APIchanges` entry is in b90a35e73b under `61.6.100`. The entry is in the wrong commit and pinned to the wrong version.
- 016d857168 says it bumps for avpriv exports but has no `APIchanges` entry at all.

The `APIchanges` version numbers and the `version.h` numbers do not agree. This is exactly the "non-atomic, churny" shape the restructure was supposed to eliminate.

### 4. `lavf` behavior change with no version bump and no `APIchanges`

9aa16fa005 substantially changes the SUP muxer's on-disk timing model (per-segment DTS/PTS per the HDMV decoder model instead of a single PTS/DTS for the whole display set). This is a user-visible muxer behavior change, yet `libavformat/version.h` is never touched in the whole series and there is no `APIchanges` entry for `lavf`.

### 5. `Changelog`: the `version 9.0` release block was erased

- 212f317265 inserted `version <next>:` *immediately after* the `version 9.0:` header, so the `<next>` block was physically sitting inside the 9.0 section (malformed).
- The final Changelog commit cff4e4008e moved `<next>` to the top, but in doing so it **deleted the entire original 9.0 feature list** ("Extend AMF Color Converter…" through "Remove deprecated NVENC options…"). The final file has:
  ```
  version 9.0:

  version 8.1:
  ```
  i.e. an empty 9.0 release-notes section. The 9.0 notes must be restored.

### 6. `fate-sub-ocr-roundtrip` references a sample file that isn't in the PR

`tests/fate/subtitles.mak` (added in fe62e65888) has:
```make
fate-sub-ocr-roundtrip: CMD = transcode srt $(SRC_PATH)/tests/data/sub-ocr-roundtrip.srt ...
```
but `tests/data/sub-ocr-roundtrip.srt` is **not** committed anywhere in `bf1b838f2a..cff4e4008e` (no `tests/data/` path in the diff). The file exists on other branches (`pgs9-9.0.1`), so this is a missing-file regression in this PR's head: the test, if enabled, fails immediately.

---

## Structural objections (would be raised, likely block)

### 7. PGS encoder options `quantize_method` and `forced_style` are dead

In `libavcodec/pgssubenc.c` both `s->quantize_method` and `s->forced_style` are declared and registered as AVOptions (and documented in `doc/encoders.texi`), but **neither is ever read inside the encoder**:
```
$ grep -n 's->quantize_method\|s->forced_style' libavcodec/pgssubenc.c   # (only the option table + struct field)
```
The actual quantization for the text→bitmap path is done in `fftools/ffmpeg_enc_sub.c` via `get_quantize_algo(ctx)`, which reads the **fftools-owned** `ctx->quantize_method`, not the encoder's. The ASS-style forced matching is also done in fftools (`ass_style_is_forced`), which sets `AV_SUBTITLE_FLAG_FORCED` on the rects before they reach the encoder. The one-way `av_opt_set` forward into `enc->priv_data` therefore flows into a dead end — the encoder receives the value and ignores it.

This contradicts the PR body's "one-way option flow" framing: the flow is one-way, but the receiving side is a no-op. A maintainer will either (a) make the encoder actually use these, or (b) drop them from the encoder's option table and `encoders.texi` and keep them as fftools-only CLI options (which is how they're really used). Documenting no-op encoder options in the public encoder docs misleads non-ffmpeg API users.

### 8. `quantize_method` numeric mapping is inconsistent and in one case broken

The public enum is `AV_QUANTIZE_NEUQUANT=0, AV_QUANTIZE_MEDIAN_CUT=1, AV_QUANTIZE_ELBG=2`. Consumers disagree:

- **`pgssubenc.c`** option + **`doc/encoders.texi`** pgssub section: "0=NeuQuant, 1=ELBG, 2=Median Cut" — **wrong** (1 is MEDIAN_CUT, 2 is ELBG).
- **`gif.c`** option: `{.i64 = AV_QUANTIZE_MEDIAN_CUT}, 0, AV_QUANTIZE_NEUQUANT, …}` — min=0, **max=0**. The valid integer range is [0,0], so option parsing will reject `1` and `2`, while the *default* is `1` (outside the declared max). The const names (`elbg`/`mediancut`/`neuquant`) are present but the numeric range is broken.
- **`fftools/ffmpeg_enc_sub.c` `get_quantize_algo`**: bounds `>= AV_QUANTIZE_NEUQUANT && <= AV_QUANTIZE_MEDIAN_CUT` — i.e. allows 0..1, so **ELBG (2) is rejected** and silently falls back to NeuQuant.

These three must be reconciled to the enum order. The GIF range should be `0, AV_QUANTIZE_ELBG`; the pgssub help/doc should say `1=Median Cut, 2=ELBG`; `get_quantize_algo` upper bound should be `AV_QUANTIZE_ELBG`.

### 9. `avpriv_`/`AVPriv` naming and non-installed headers

`palettemap.h` and `mediancut.h` are **not** in the `HEADERS` list of `libavutil/Makefile` (only `quantize.h` is), yet they declare `avpriv_palette_map_*` / `avpriv_mediancut_*` functions with `AVPrivPaletteMapContext` / `AVPrivMedianCutContext` typedefs. Using `avpriv_` for cross-library-private symbols whose headers aren't installed is acceptable in principle, but:
- `AVPriv…` typedef prefix is not an established FFmpeg convention; `avpriv_` functions normally operate on opaque or internal structs without a public `AVPriv`-prefixed type name.
- `palette.h` exposes `ff_srgb_u8_to_oklab_int`/`ff_oklab_int_to_srgb_u8` (internal `ff_` prefix) in a non-installed header — fine, but the mix of `ff_` (neuquant, palette) and `avpriv_` (palettemap, mediancut) for sibling "moved-to-lavu" code is inconsistent. A maintainer will ask for one convention.
- `avpriv_palette_map_color()` is exported but **unused** anywhere in the tree — dead exported symbol.

### 10. Commit hygiene: duplicated trailers and mis-described commits

- Multiple commits carry repeated identical `Signed-off-by`/`Co-Authored-By` pairs (9aa16fa005 has *three* copies; 2781805adb, 10822ee32f, f568106b42, 47815c8765, b90a35e73b have duplicates). Cherry-pick noise that should be cleaned.
- f568106b42 (`fftools: add subtitle bitmap utility`) commit message says "Move … into `libavutil/sub_util.{h,c}`" but the files are actually `fftools/ffmpeg_sub_util.{c,h}`. The body mis-describes the destination library.
- 9aa16fa005 (`lavf/supenc`) touches `tests/fate/api.mak` destructively (item 1) — an unrelated file with no explanation in the commit message.

### 11. MAINTAINERS incomplete

`fftools/ffmpeg_sub_util.{c,h}`, `fftools/ffmpeg_sub_ocr.{c,h}`, `fftools/ffmpeg_sub_render.{c,h}` are added but not listed in `MAINTAINERS`, while the sibling `ffmpeg_dec_sub`/`ffmpeg_enc_sub` and the lavu/pgssubenc files are. Inconsistent.

---

## Line-level / smaller nits

- **`fftools/ffmpeg_enc_sub.c` `convert_text_to_bitmap` fail path frees a borrowed pointer.** `forced_style_str = ctx->forced_style` (borrowed), and the `fail:` label does `av_free(forced_style_str)`. On the success path `return 0` is hit before `fail`, so today this only fires on an error path where `forced_style_str` was never replaced with an owned copy — so it would free `ctx->forced_style` and leave a dangling pointer in the context. The variable is never reassigned to a freshly allocated copy anywhere. Either drop the `av_free` on `fail` (it's borrowed) or actually `av_strdup` it at assignment time. This is a latent double-free/UAF if any `goto fail` is ever taken while `ctx->forced_style` is set.

- **`fftools/ffmpeg_enc.c` forced-flag propagation mutates the input subtitle.** `AVSubtitle local_sub = *sub` is a shallow copy; `local_sub.rects[j]->flags |= AV_SUBTITLE_FLAG_FORCED` writes through to the original `AVSubtitleRect` objects. When `nb > 1` (e.g. ASS, or `needs_clear`), or when the same decoded subtitle is fanned out to multiple outputs, the forced flag set on the first iteration persists into later iterations/outputs. This is probably benign (forced is monotonic) but worth a comment or a per-rect flag mask that's reset.

- **`fftools/ffmpeg_enc.c` forced-subs-filter early `return 0` leaks the packet.** The `if (j == 0) return 0; /* no matching rects */` happens *before* `av_new_packet`, so `pkt` is uninitialized — fine — but the caller's loop still owes a clean return; verify the caller doesn't `av_packet_unref(pkt)` on a 0 return from this path. (It looks OK, but the early return is in a `for (i = 0; i < nb; i++)` loop and `nb` may be 2 for `needs_clear`; returning mid-loop skips the clear packet entirely, which for a filtered-out event is correct, but the asymmetry should be called out.)

- **`libavcodec/gif.c` RGBA transparency state.** `gif_quantize_rgba` sets `s->transparent_index = 255` when `has_transparency`, else `-1`, per frame. But the palette-loaded short-circuit `else if (!memcmp(s->palette, palette, AVPALETTE_SIZE)) palette = NULL;` skips re-emitting the palette on identical palettes, and `transparent_index` is only (re)set inside `gif_quantize_rgba` (always called) — OK — but the GCE logic that consumes `s->transparent_index` may run with a stale index if a later frame has the same palette but different transparency. Worth a deliberate test.

- **`libavformat/supenc.c` `base_pts` when `pkt->pts == AV_NOPTS_VALUE`.** `base_pts` stays 0 and all segments derive from 0; `seg_dts = base_pts - FFMIN(decode_dur, base_pts)` → 0. Silent emission of a zero-timed display set. The old code also had a fallback, but the new code's per-segment math is meaningless without a real PTS. At minimum log a warning and return `AVERROR_INVALIDDATA` instead of writing a garbage-timed SUP.

- **`doc/encoders.texi` GIF section not updated.** The GIF encoder gained `quantize_method` and `dither` AVOptions but the `@section GIF` docs were not touched — only the pgssub section was added. New GIF options are undocumented.

- **`doc/APIchanges` placeholders.** Several new entries use `2026-03-xx - xxxxxxxxxx` instead of a real date/hash. Acceptable mid-development but must be finalized before merge.

---

## What did land well

- The lavu quantization API surface (`quantize.h` is the one installed header; `av_quantize_*` is a clean public API) is reasonable, and NeuQuant/MedianCut/ELBG are behind it as intended.
- The ELBG move (7317e05af2) correctly updates all five consumers (`a64multienc`, `cinepakenc`, `msvideo1enc`, `roqvideoenc`, `vf_elbg`) and the `libavcodec/Makefile`/`libavfilter/Makefile` in one commit — no transient dead module.
- The `vf_palettegen` / `vf_paletteuse` adoption happens in the same commits that introduce the replacement lavu code, so there's no transient duplication on the palette side.
- The PGS encoder itself is self-contained, registers correctly in `allcodecs.c` / `Makefile`, and the `AV_CODEC_PROP_EXPLICIT_END` + `av_subtitle_needs_clear()` helper is a clean way to generalize the existing DVB-clear hack in `do_subtitle_out` (the `needs_clear` rewrite of the old `AV_CODEC_ID_DVB_SUBTITLE && i == 1` special-case is good).
- The HDMV timing-model math in `supenc.c` is well-commented and the underflow guard `FFMIN(decode_dur, base_pts)` is present.

## Recommendation

**Request changes.** The series should not merge until at least items 1, 2, 3, 5, 6, 8 are resolved: restore `tests/fate/api.mak` (old content + aggregation + PGS additions), fix the duplicate `VERSION_MINOR` line, make the lavu version bumps atomic and match `APIchanges`, restore the Changelog 9.0 block, commit (or remove the test for) `tests/data/sub-ocr-roundtrip.srt`, and fix the `quantize_method` numeric mappings across gif/pgssub/enc_sub/texi. Items 4, 7, 9–11 are strongly recommended fixes; item 7 (dead encoder options) in particular needs a design decision. The line-level nits can follow.
---
Saved 2026-08-27 (glm-5.2 via Fairies, 299 agentic rounds, local-only
run). Machine-generated review, not a human maintainer. All blocking
findings mechanically verified as real; fix batch executed same day.
