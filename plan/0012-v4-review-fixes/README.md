# Phase 9: v4 Series — Address Expert Panel Review

## Status: Complete

Applied all findings from PHASE8-REVIEW-V3.md to produce v4 of the
patch series (branch `pgs4`, tagged `history/pgs-v4`). All critical,
high, and medium fixes integrated. v5 built on top with additional
optimisations (Phase 10).

## Phase 9a: Critical fixes (R1-R7)

1. **R1: Clear Display Sets** — emit zero-rect PCS+END at subtitle
   end time. This is the encoder's responsibility: when called with
   `num_rects > 0`, schedule a clear DS at `PTS + duration`. The
   fftools layer must call the encoder a second time at end time.

2. **R2: Eliminate duplicate libass wrapper** — remove
   `libavfilter/subtitle_render.{h,c}` entirely. The renderer code
   lives only in `fftools/ffmpeg_enc_sub.c`. Tests that need renderer
   access use the `fftools/ffmpeg_sub_util.h` pattern (already exists
   for animation utils) or link against a shared helper object.

   For tests that call `ff_sub_render_alloc` etc (animation-timing,
   coalesce): extract the renderer into a self-contained `.c` file
   in fftools that both `ffmpeg_enc_sub.c` and the tests can link.
   Same for OCR — remove `libavfilter/subtitle_ocr.{h,c}`.

   This also resolves R24 (unconditionally compiled into libavfilter)
   and R25 (pipe-to-I in library).

3. **R3: Integer overflow in DOB** — change `dob_used` and `needed`
   to `int64_t`, cast `w * h` products.

4. **R4: NULL palette check** — validate `data[1] != NULL` in
   `pgssub_encode()` before accessing palette.

5. **R5: `avpriv_` prefix** — rename `ff_palette_map_*` to
   `avpriv_palette_map_*` for cross-library calls. Same for any
   `ff_mediancut_*` called from libavfilter.

6. **R6: Patch reordering** — move PGS encoder before wiring patch.

7. **R7: Changelog + version bump** — add Changelog entry, bump
   libavcodec MINOR for PGS encoder.

## Phase 9b: High-priority fixes (R8-R16)

8. **R8: Series split** — restructure into submission batches:
   - Batch 1: Palette/quantization (patches 1-9)
   - Batch 2: PGS encoder (standalone)
   - Batch 3: GIF RGBA (standalone)
   - Batch 4: Subtitle conversion + OCR

9. **R9: ffmpeg_sub_util.h** — move function bodies to a `.c` file.
   Compile as a separate fftools object. Tests link against it.

10. **R10: palettemap internal structs** — move `FFColorInfo`,
    `FFColorNode`, etc. to `palettemap_internal.h` or into `.c`.
    Only expose opaque `FFPaletteMapContext`.

11. **R11: Remove AV_QUANTIZE_NB** from public header. Use internal
    bounds checking.

12. **R12: Document `quality` parameter** as algorithm-specific hint.

13. **R13: Add documentation** — `doc/encoders.texi` for PGS,
    `doc/ffmpeg.texi` for OCR options.

14. **R14: Fix memory leak** on split error path in
    `convert_text_to_bitmap()`.

15. **R15: Dimension validation** — check `width/height <= 65535`
    and `rect->x + rect->w <= avctx->width` in encoder.

16. **R16: Fix coalesced animation** — preserve all events when
    re-rendering peak frame for alpha animation.

## Phase 9c: Medium fixes (R17-R25)

17. **R17: Standardise Co-Authored-By** — use one format throughout.
18. **R18: Resolve dithering enum** — use `FFDitheringMode` directly
    in `vf_paletteuse.c`.
19. **R19: FF-prefix internal types** — `FFNeuQuantContext`,
    `FFMedianCutContext`, `FFLabColor`.
20. **R20: `av_quantize_alloc` error reporting** — consider int
    return (or document NULL-only pattern).
21. **R21: Region API documentation** — clarify dual-mode behavior.
22. **R22: `av_clip_uintp2`** — convert where applicable.
23. **R23: DOB on Acquisition Points** — track correctly.
24. **R25: pipe-to-I in caller** — already resolved by R2.

## Phase 9d: Polish

25. Document `MAX_REGIONS` in header.
26. Fill APIchanges placeholder hashes.
27. Fix commit date ordering.
28. Parameterise RTL language list.
29. Deduplicate region-sampling code in `quantize.c`.
