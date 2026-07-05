# Upstream Review Findings

Systematic review of all 19 commits on `pgs-series` for FFmpeg upstream
submission readiness. Findings organized by severity.

## Status Key

- [ ] Not started
- [x] Fixed

---

## A. CRITICAL (would block merge)

### A1. Non-ASCII characters in source files -- DONE

Fixed via rebase with exec. All em-dashes, Unicode arrows, and
box-drawing characters replaced with ASCII equivalents across 12 files.
Author names in copyright headers preserved verbatim.

### A2. Non-ASCII in commit messages -- DONE

Fixed via rebase with exec. Em-dashes replaced with `--` in 2 commits.

### A3. Missing Signed-off-by on 7 commits -- DONE

Added `Signed-off-by: David Connolly <david@connol.ly>` to all 7.

### A4. Inconsistent Signed-off-by email -- DONE

Standardized to `david@connol.ly` across all 19 commits.
Also fixed trailer ordering (Signed-off-by before Co-Authored-By)
on 5 commits.

---

## B. BUGS (functional defects)

### B1. Memory leak: `data[1]` alloc failure in `quantize_rgba_to_rect` -- DONE

Fixed: `av_freep(&rect->data[0])` before returning ENOMEM.

### B2. Memory leak: `data[1]` alloc failure in `fill_rect_bitmap` -- DONE

Fixed: `av_freep(&rect->data[0])` before returning ENOMEM.

### B3. Partial realloc inconsistency in `sub_coalesce_append` -- DONE

False positive: if `texts` realloc succeeds but `durations` fails,
`cap` is not updated, so the next call re-enters the realloc block
and retries both. Added comment documenting this invariant.

### B4. Dangling `sub->rects` in `convert_text_to_bitmap` -- DONE

Fixed: realloc first, assign `sub->rects = new_rects` immediately,
then alloc `bot_rect` in a separate check.

### B5. ELBG codebook values not clamped below zero -- DONE

Fixed: replaced `FFMIN(cb[x], 255)` with `av_clip(cb[x], 0, 255)`.

### B6. Median Cut palette count discarded -- DONE

Fixed: return `ret` (actual count from `ff_mediancut_learn`)
instead of `ctx->max_colors`.

---

## C. SECURITY (integer overflow)

### C1. `gif.c:479` -- `int nb_pixels = w * h` -- DONE

Fixed: `if ((int64_t)w * h > INT_MAX) return AVERROR(EINVAL);`

### C2. `pgssubenc.c:354` -- `rect->w * rect->h * 4` -- DONE

Fixed: `int64_t alloc64` intermediate with `> INT_MAX` check.

### C3. `ffmpeg_enc.c` -- `rw * rh` in 4 locations -- DONE

Fixed: all 4 use `(int)FFMIN((int64_t)rw * rh, INT_MAX)` pattern.

### C4. `subtitle_render.c:206-208` -- `stride * bh` allocation -- DONE

Fixed: `(size_t)stride * bh` for malloc, plus
`(int64_t)canvas_w * canvas_h > INT_MAX / 4` in alloc.

### C5. `neuquant.c` / `mediancut.c` -- missing `nb_pixels` overflow guard -- DONE

Fixed: `if (nb_pixels > INT_MAX / 4)` in `av_quantize_generate_palette`.

### C6. `palettemap.c:192-193` -- `y_start * linesize` overflow -- DONE

Fixed: cast to `(size_t)` for both pointer offsets.

---

## D. API BOUNDARY (missing validation)

### D1. `palettemap.c:555` -- no dither enum range check -- DONE

Fixed: `if (dither < 0 || dither >= FF_NB_DITHERING)` check added.

### D2. `palettemap.c:555` -- no w/h/x_start/y_start validation -- DONE

Fixed: `if (w < 0 || h < 0 || x_start < 0 || y_start < 0)` check added.

### D3. `palettemap.c:525` -- no NULL check on `palette` param -- DONE

Fixed: `if (!palette) return NULL;` before allocation.

### D4. `palettemap.c:588,593` -- no NULL check in get_palette/get_nodes -- DONE

Fixed: added `if (!ctx) return NULL;` to both functions.

### D5. `subtitle_render.c:47` -- no upper bound on canvas dimensions -- DONE

Fixed in C4: `(int64_t)canvas_w * canvas_h > INT_MAX / 4` check.

---

## E. STYLE -- Lines over 80 characters

### E1. Our new code -- DONE

All wrapped: AVOption entries, enum comments, function declarations,
Doxygen lines, function calls in ffmpeg_enc.c, gif.c, pgssubenc.c,
palettemap.c/h, subtitle_render.h, quantize.h.

### E2. Verbatim upstream copies (skip)

Lines in `palettemap.c` dithering code are verbatim from
`vf_paletteuse.c`. Reformatting would break extraction diff.

### E3. Test files -- DONE

All test files wrapped: fade, timing, coalesce, quantize tests.

---

## F. STYLE -- Other

### F1. Hardcoded 256 instead of AVPALETTE_COUNT -- DONE

Fixed: `prev_palette[256]` and 3x `FFMIN(..., 256)` in pgssubenc.c
now use `AVPALETTE_COUNT`.

### F2. Missing spaces in operators (skip)

**palettemap.c:** `{.srgb=srgb}` and `color>>24` are verbatim from
`vf_paletteuse.c`. Fixing would break extraction diff verifiability.

### F3. Include order -- DONE

Fixed: `palettemap.h` is now first include in `palettemap.c`.

### F4. Internal structs exposed in header (skip)

Design concern. Making `color_node` opaque would require a larger
refactor of `ff_palette_map_get_nodes()`. Defer to reviewer feedback.

### F5. Unused include -- DONE

Fixed: removed `#include "pixfmt.h"` from `palettemap.h`.

### F6. Doxygen `[in]/[out]` inconsistency -- DONE

Fixed: standardized to plain `@param` throughout `palettemap.h`.

### F7. Const-casts without comment -- DONE

Fixed: added `/* libass API takes non-const but does not modify */`
comment before the first libass cast in `subtitle_render.c`.

### F8. Missing libass log callback (skip)

Functional change, not a style fix. libass log integration could be
a follow-up patch if reviewers request it.

### F9. Alphabetical ordering in Makefile -- DONE

Fixed: `mediancut.o` moved before `mem.o` in `libavutil/Makefile`.

### F10. `av_assert0` in library code (skip)

False positive: caller loop bounds guarantee `box->len >= 1` and
`new_box->len >= 1`. The assert is defensive and can never fire.
`av_assert0` is widely used in FFmpeg library code for invariants.

### F11. Missing `const` qualifier -- DONE

Fixed: `const int32_t *n` in `contest()` in `neuquant.c`.

### F12. Missing Doxygen on internal functions (skip)

Low priority. `neuquant.h` functions are internal (`ff_` prefix)
and have clear signatures. Not worth the churn.

---

## G. COMMIT MESSAGE ISSUES

### G1. Inconsistent trailer ordering -- DONE (in A4)

Fixed during A4: all 19 commits now have Signed-off-by before
Co-Authored-By.

### G2. Missing ticket references (defer)

Commits 8-11 (fftools animation/coalescing) relate to #3819 but have
no `Ref:` trailer. Low risk -- can add during final submission rebase.

### G3. Body lines slightly over 72 characters (defer)

1-2 lines at 73-74 chars in 2 commits. Cosmetic, unlikely to be
flagged. Can fix during final submission rebase.

### G4. Misleading "Extract" wording (defer)

Median Cut commit says "Extract" but it implements. Can reword during
final submission rebase.

---

## H. DESIGN CONCERNS (may be raised by reviewers)

### H1. `quality` parameter ignored for Median Cut

`av_quantize_generate_palette` accepts `quality` (1-30) but Median Cut
ignores it entirely. Document this or use quality to control box-split
iterations.

### H2. Region-sampling code duplication

**quantize.c:255-342:** The region-sampling logic (find max_px, compute
per_region, call `build_region_samples`) is copy-pasted across all 3
algorithm branches. Extract to a helper.

### H3. Over-broad animation detection

**ffmpeg_enc.c:1318:** `strchr(text, '{')` treats any `{` as animation.
Common static ASS tags like `{\an8}` trigger the expensive multi-pass
render path. Consider checking for animation-specific tags only.

### H4. Magic numbers in fftools

Repeated values without named constants:
- `42` (frame_ms fallback, line 808)
- `32` (transparent gap threshold, animation.c:187)
- `256 * 4` (palette buffer size, 6+ occurrences)
- `1024 * 1024` (subtitle_out_max_size, defined in 2 places)
- `10` (quality argument, 3+ places)
- `254` (palette version limit, line 1002)

### H5. Stale `elbg_filter_deps` in configure

**configure:4112:** `elbg_filter_deps="avcodec"` but ELBG code has
moved to libavutil. The dependency is now incorrect (though harmless
since avcodec is almost always enabled).

### H6. APIchanges split inconsistency

**doc/APIchanges:14-23:** All 8 subtitle_render functions listed under
one version (lavfi 11.13.100), but they were added across 2 commits.
Either squash the commits or add separate version bumps.

### H7. `quantize_method` field unused within PGS encoder

**pgssubenc.c:47:** The AVOption stores the value but the encoder never
reads it -- it exists solely for external query via `av_opt_get_int`.
Add a comment explaining this pattern.

---

## Fix Summary

| Category | Total | Fixed | Skipped | Deferred |
|----------|-------|-------|---------|----------|
| A. Critical | 4 | 4 | 0 | 0 |
| B. Bugs | 6 | 6 | 0 | 0 |
| C. Security | 6 | 6 | 0 | 0 |
| D. API boundary | 5 | 5 | 0 | 0 |
| E. Line length | 3 | 2 | 1 | 0 |
| F. Style | 12 | 7 | 5 | 0 |
| G. Commit msgs | 4 | 1 | 0 | 3 |
| H. Design | 7 | 0 | 0 | 7 |
| **Total** | **47** | **31** | **6** | **10** |

**Skipped items** (with rationale):
- E2: Verbatim upstream copy -- reformatting breaks diff verification
- F2: Verbatim upstream copy -- same rationale as E2
- F4: Design concern -- opaque structs require larger refactor
- F8: Feature request -- libass log callback is functional, not style
- F10: False positive -- assert invariant guaranteed by caller bounds
- F12: Low priority -- internal `ff_` functions, clear signatures

**Deferred items** (for final submission rebase):
- G2-G4: Commit message tweaks (ticket refs, line wrap, wording)
- H1-H7: Design concerns (document in commit messages or address
  if reviewers raise them)

All fixes applied in-place to the originating commit via
`git rebase --exec`. No fix-up commits. 19 commits on `pgs-series`,
all with consistent `Signed-off-by: David Connolly <david@connol.ly>`.
Build clean, FATE tests pass (quantize, gifenc-rgba).
