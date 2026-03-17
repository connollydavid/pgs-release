# Phase 11: Website Updates for v4/v5

Comprehensive update of all five documentation pages to reflect v4 and v5 work,
normalise to British English (prose only, never code identifiers), and fix
cross-page consistency.

## Context

The website currently describes v3 (14 patches) in its Patches section while
acknowledging v5 elsewhere. FATE test count is wrong. Branch links are stale.
Spelling oscillates between British and American English. Footer/links structure
varies between pages.

## Data

- **v5 patch count:** 23 patches on upstream master
- **v5 FATE tests:** 13 (sub-pgs, quantize, api-pgs-fade, api-pgs-animation-util,
  api-pgs-animation-timing, api-pgs-coalesce, api-pgs-rectsplit, gifenc-rgba,
  sub-ocr-roundtrip, api-pgs-palette-delta, api-pgs-dts, api-pgs-overlap-verify,
  sub-pgs-overlap)
- **v5 new features over v4:** palette delta encoding, per-segment DTS in SUP muxer,
  per-packet DTS in fftools, event lookahead window, AV_CODEC_PROP_EXPLICIT_END,
  clear Display Sets
- **v4 over v3:** avpriv_ cross-library prefixes, palettemap_internal.h,
  sub_util moved to libavutil, FF-prefixed structs, doc/encoders.texi,
  independent compilation verified, quantize_method range fix

## Rules

1. **British English in prose, American in code.** Prose: colour, organisation,
   recognised, optimisation. Code identifiers, CSS properties, API names: color,
   quantize, etc. Never change `color-distance/` directory name or CSS `color:`.
2. **One commit per page.** Easier to review and revert.
3. **No new content beyond what exists.** Update stale references, fix spelling,
   align structure. Do not add new sections or features.

## Steps

### 11a: development.html

- [ ] Update header: "fifth" → current iteration count still fine, but fix
  "Latest" link from v3 to v5 with correct patch count
- [ ] Update Patches section: add v5 patches to A-E structure (palette delta
  goes in A, DTS/lookahead/overlap go in B, clear DS in E, FATE test patch standalone)
- [ ] Update v4 patch count from 18 to match (already correct)
- [ ] Update FATE count: 9 → 13
- [ ] Update FATE list: add api-pgs-palette-delta, api-pgs-dts,
  api-pgs-overlap-verify, sub-pgs-overlap
- [ ] British English pass on all prose
- [ ] Verify all branch links point to correct remotes

### 11b: index.html

- [ ] British English pass on prose (link text "Color distance" → "Colour distance")
- [ ] Verify version tag is current (n8.0.1-pgs3.0 — correct until next release)

### 11c: quantizers/index.html

- [ ] Update patches link: pgs3 → pgs5
- [ ] British English pass: "Color Quantization" title, "color quantization"
  prose, "16-color palette" table headers, "high-colour-count" (already British)
- [ ] Prose "color" → "colour" where not a code identifier

### 11d: color-distance/index.html

- [ ] Fix dead link: phase4-dvd-investigation branch → remove or point to valid ref
- [ ] British English pass: title "Color Distance" → "Colour Distance",
  prose instances. Keep code identifiers (sRGB, OkLab), CSS, and JS unchanged.
  Keep paper citation in original language ("Color Research & Application")
- [ ] Add back-link consistency if missing

### 11e: ocr-languages/index.html

- [ ] British English pass (minimal — mostly data)
- [ ] Add Links section before footer for consistency with other pages

### 11f: Cross-page review

- [ ] Verify all inter-page links work
- [ ] Verify footer style consistency
- [ ] Final read-through of all five pages
