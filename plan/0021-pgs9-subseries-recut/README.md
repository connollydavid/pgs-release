# pgs9 sub-series re-cut

Restructure the 30-patch pgs9-9.0.1 series into four coherent,
independently-submittable sub-series on the n9.0.1 base, per the
structure review (../0020-pgs9-series-remediation/fairy-structure-review.md)
and the rulings in call/0007 and call/0008. This milestone is written
for solo execution: every decision is made below; a session with no
other context can drive it.

Inputs: branch `pgs9-9.0.1` (tip 964fc5e2d9, worktrees of
`software/ffmpeg/.bare`); the verdict's per-patch table; the reconcile
tooling at `scripts/reconcile/` (stop/build-walk/transfer-proof are not
needed, the re-cut is a rebuild, not a rebase, but the walk is).

Standing rules for every new commit:
- build at the commit (`make -j` under the persisted `--enable-shared`
  config), sign-off, message ASCII, no trailing whitespace;
- trailers: preserve any existing Co-Authored-By verbatim, append
  `Co-Authored-By: GLM 5.3 <no-reply@z.ai>`;
- public-API commits bump the exporting library's minor and carry the
  APIchanges entry atomically;
- checkpoints: `recut/cp-*` branches at every sub-series boundary.

## Build sequence

### Pre-flight verification batch {#pre-flight}

- verify: all four checks recorded in this README's findings list

1. Configure wiring: does our tree define CONFIG_LIBASS and
   CONFIG_LIBTESSERACT (grep configure + ffbuild/config.mak of a real
   build; the shipped binaries render text and OCR, so the deps are
   wired SOMEWHERE, find how, and whether the series carries the
   configure hunks). If the hunks are missing from the series, they
   belong in the retitled render/OCR commits.
2. Changelog: the `version <next>:` block placement against the 9.0.1
   block, and whether AV_CODEC_PROP_EXPLICIT_END is real (it should be
   in libavcodec/codec_desc.h inside the encoder commit), the verdict
   likely missed it inside the big patch.
3. Trailer census: which of the 30 commits carry which trailers.
4. The ELBG-backend commit: does it touch pgssubenc (the verdict claims
   a duplicated option hunk with the quantize_method commit)?

### Stage the re-cut worktree {#stage}

- verify: git -C ~/pgs9-wt/recut rev-parse --abbrev-ref HEAD = pgs9-recut

Worktree `~/pgs9-wt/recut`, branch `pgs9-recut` from `n9.0.1`, rerere
already on. Old commits are cherry-picked/replayed from `pgs9-9.0.1`
with `git cherry-pick -x` (or `format-patch` + `am`) and then amended
into shape; `-x` records the source so the audit trail survives.

### Sub-series one: lavu quantization API {#ss1}

- verify: build-walk green over the sub-series; audits clean; fairy
  scan of the sub-series diff returns no structural objection

Assembly (old numbers from the pgs9-9.0.1 order):
1. OkLab move: old #12 (lavu/palette from lavfi), keep pure move.
2. ELBG move: old #17 with its consumers.
3. Quantize API + NeuQuant: old #13, minus any installed
   neuquant/mediancut headers (backends are internal: HEADERS list
   ships quantize.h only; ff_ symbols stay uninstalled).
4. Palettemap as avpriv: old #14 + #15 merged (move + paletteuse
   adopter in one commit; no transient dead module).
5. Median Cut + palettegen adopter: old #16 + #18 merged (the API plus
   the palettegen switch that retires lavfi/palette; folding here, not
   into the OkLab move, because the adopter consumes Median Cut).
   Region-weighted API stays public (documented, generic enough; the
   RFC notes it).
6. ELBG backend: old #19, with any pgssubenc hunk dropped per pre-flight
   finding four.

### Sub-series two: GIF RGBA {#ss2}

- depends: #ss1
- verify: fate gifenc-rgba green; audits clean

7. old #20 whole, plus the `tests/ref/fate/gifenc-rgba` hunk lifted
   out of old #24.

### Sub-series three: PGS encoder {#ss3}

- depends: #ss1
- verify: build-walk; fate api-pgs set green; audits clean

8. `supenc` per-segment DTS: old #3 (existing-muxer behaviour change
   standing on its own; the old #4 fftools DTS hunk moves to the pipeline wiring commit).
9. pgssubenc core with ALL AVOptions defined up front: old #1 + #9 +
   #10 + the option-definition half of #26 + #29; tests folded in
   (fade, multi-object, ap-interval, forced, rate-control from
   #1/#5/#7/#8/#9/#10 as they attach to these features;
   overlap-verify joins the encoder-core item (its epoch logic is encoder behavior); dts goes with the supenc commit; palette-delta and
   palette-reuse with the palette-delta commit). The generic test harness (pgs-test-util.h, arriving with #6) keeps
   its pgs-test-util.h home.
10. palette delta: old #2 with its palette-delta and palette-reuse tests.
11. forced_style, fftools side: the ASS-matching half of old #26: 
    option string lives in the fftools context, forwarded to the
    encoder one-way via av_opt_set; no encoder priv_data read.

### Sub-series four: text<->bitmap conversion {#ss4}

- depends: #ss1 #ss3
- verify: build-walk; encoder end-to-end smoke (srt->sup with
  -c:s pgssub -s 1920x1080); fairy scan; audits clean

12. subtitle bitmap utilities: old #21, retitled `fftools:` (files live
    in fftools; say add, not move, if that is the truth).
13. text render wrapper: old #22, retitled `fftools:`, plus the libass
    configure hunk if pre-flight found it missing.
14. OCR wrapper: old #27, retitled `fftools:`, plus the tesseract
    configure hunk likewise.
15. text-to-bitmap with lookahead: old #23 + #25 merged (the coalescer
    is born as the lookahead design; animation/coalesce/rectsplit tests
    from #24 folded here where they belong).
16. pipeline wiring: old #24 minus its four test programs (moved to 15)
    minus the GIF ref hunk (moved to 7) plus the old #4 DTS hunk;
    quantize_method flows one-way from the CLI (keep the value in the
    fftools output-stream state, forward with av_opt_set).
17. bitmap-to-text via OCR: old #28, with ffmpeg_dec_sub.h in its
    final form (no rewrite-by-later-commit).
18. disposition bridge (old #11) belongs here, it wires stream
    disposition into the conversion; strip its priv_data read the same
    one-way way. (If it proves encoder-only after inspection, keep it
    in the encoder-core commit; decide at execution and record which.)

### Final patch and whole-series gates {#final}

- depends: #ss4
- verify: the whole gate list below, then operator review

19. Changelog (one entry, correct block placement), MAINTAINERS
    (consolidated), tail version bumps, one commit.

Whole-series gates, all mandatory before the branch is pushed:
- build-walk the full `n9.0.1..pgs9-recut` range under the shared
  config (scripts/reconcile/build-walk.sh);
- `nm -D` clean of cross-lib ff_ symbols; encoder registers with every
  option; the four self-contained fate api tests green;
- per-commit audits: sign-off, ASCII, whitespace, trailers (call/0008);
- line-level audit: every old-series added line present in the new
  lineage or consciously dispositioned (the pre-flight findings feed
  this);
- fairy structure re-scan of the full new series (ticket framed the
  same way; verdict recovered from the debug dump per the ledger);
- ledger entries per sub-series as they land; `recut/cp-*` checkpoints.

### Close out {#close}

- depends: #final
- verify: attested operator

Push `pgs9-recut` to the fork, update plan/0020 and PLAN.md, receipts
for the plan/0021 tasks, final memory entry. The master re-cut, RFC,
and submission are OUT of scope (later milestones; rerere replays).

## Findings (pre-flight appends here)



## Deviations from the verdict (decided, do not re-litigate)

- #18 folds into the Median Cut commit (the assembly item that adds it), not into the OkLab
  move: the palettegen adopter consumes Median Cut, so folding it
  earlier would be circular.
- old #4 folds into the pipeline wiring commit, not beside the muxer
  change: it is fftools packet shaping.
- The disposition bridge lands in sub-series four (the disposition-bridge item) unless
  inspection proves it encoder-only.
- Region-weighted quantization stays public API (small, documented,
  generic enough); the RFC flags it.

## Execution mechanics (how the assembly operations are performed)

- Merges of old commits: `git cherry-pick -n A B...` then one commit with
  the new message. Conflicts resolve against each old commit's tree state
  (`git show A:<path>`), never the final tip.
- Splits (old #26): `git cherry-pick -n <commit>`, then `git restore
  --staged --worktree <the-half's files-or-hunks>` for the half that moves
  later, commit the kept half; the other half re-applies at its own item
  via `git checkout <old> -- <paths>` or an extracted diff.
- Hunk lifts between commits: extract with
  `git diff <old>^ <old> -- <path>`, apply at the target item, and
  re-commit the source item from a tree minus that hunk.
- The `-x` cherry-pick lines and the GLM trailer ride along during the
  re-cut for the audit trail; the future submission milestone strips the
  `-x` lines at format-patch export time (one pass, recorded there).

## Review-fix notes (2026-08-22)

- The overlap-verify test belongs to the encoder core (epoch logic), not
  the muxer item; source citations corrected.
- The OkLab palette family takes the same avpriv disposition as
  palettemap, set by the Median Cut commit (the first item whose
  adopters consume it cross-library).
- MAINTAINERS stays consolidated in the final patch (the verdict's
  shape; no operator ruling to flip it).
- Sub-series four declares both dependencies.

## Findings (pre-flight, 2026-08-22)

1. Configure wiring: NOT a defect. The n9.0.1 base's configure already
   carries --enable-libass and --enable-libtesseract (and
   ocr_filter_deps); the series needs no configure hunks, and the
   retitled render/OCR items stay as-is. The verdict's concern does not
   apply to this base.
2. Changelog: REAL defect confirmed. The series inserts a
   `version <next>:` block INSIDE the `version 9.0:` block (mid-file,
   line ~91); it belongs above `version 9.0.1:` at the top. The final
   patch fixes placement with the single consolidated entry.
   AV_CODEC_PROP_EXPLICIT_END is real (three uses in codec_desc.h);
   the verdict missed it inside the big patch.
3. Trailer census: all 30 commits carry Signed-off-by plus
   Co-Authored-By: Claude. The re-cut preserves both and appends the
   GLM trailer per call/0008.
4. ELBG backend: does NOT touch pgssubenc (five files, all lavu and
   docs). The verdict's duplicated-hunk claim was wrong; nothing to
   drop at that item.
