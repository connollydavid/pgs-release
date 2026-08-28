# pgs9 encoder completion

Close the located undone work on the PGS encoder so the series is
state of the art before the hardware sweep. The milestone covers the
six items surfaced in the completion review, each re-grounded against
the delivered pgs9-master lineage (tip abb82b5b17, 22 commits on
upstream/master, worktree ~/pgs9-wt/recut in WSL).

Re-grounding changed three of the six. The PDS worst-case size is
already guarded (the writer checks `buf_end - q < 3 + 2 + nc * 5`,
libavcodec/pgssubenc.c), so its item becomes a proof inside the
full-palette edge run. The option-forwarding flag lives in a context
allocated per output stream (fftools/ffmpeg_enc_sub.c, enc_sub_alloc),
so its item becomes a two-stream smoke that proves the isolation at
run time. The MAINTAINERS item is wider than style: the three
ffmpeg_sub_* file pairs have no entry at all. One genuine defect
surfaced: the epoch reset clears pds_cache_valid and leaves the
pds_cache contents stale, which can drop a palette entry from a delta
PDS after a new epoch.

Inputs: branch pgs9-master at ~/pgs9-wt/recut; the api-pgs test
harness (tests/api/Makefile stanza, pgs-test-util.h); the standing
rules from plan/0021 (build at the commit, sign-off, ASCII messages,
no trailing whitespace, trailers per call/0008). Every non-trivial
command goes through a script file in WSL (the wsl.exe inline
truncation hazard), with LD_LIBRARY_PATH at the in-tree libs and
stale fate .err files removed before reading failure signatures.

## Out of scope

The hardware pass, the master re-cut submission prep (per-series
export, APIchanges truth pass), the CLI -sub_* texi documentation, and
the security pass on the encoder files stay deferred to their recorded
milestones. Fix and metadata commits land standalone on pgs9-master
now and fold into their owning commits (palette delta, series
metadata) at submission prep.

## Build sequence

### Close the epoch palette-cache hole {#epoch-cache-reset}

- verify: api-pgs-epoch-cache red on the pre-fix tree, green on the
  fixed tree, and the api-pgs set stays green

At an Epoch Start the encoder clears pds_cache_valid and the object
versions and never clears the pds_cache contents (libavcodec/
pgssubenc.c, the PGS_EPOCH_START branch). A palette entry that is
transparent at the new epoch keeps its pre-epoch cache bytes, because
the transparent-entry skip happens before the cache update. If the
entry later turns opaque with a value equal to those stale bytes, the
delta encoder reads it as unchanged and omits it, and the decoder,
which received nothing for that entry this epoch, renders the wrong
colour.

Fix: zero the whole cache in the same branch. A zeroed entry has
alpha zero, and only entries with alpha greater than zero are ever
transmitted, so a zeroed cache can never falsely match an entry that
must be sent.

Test: add api-pgs-epoch-cache to the api harness. Epoch one sets an
entry opaque; the next epoch start makes it transparent; a following
palette update restores the epoch-one value. Scan the written PDS for
the entry and fail when it is missing. Run the test against the
pre-fix tree first and confirm it fails, then apply the fix.

### Correct the edge-test record and prove the full palette {#full-palette-proof}

- verify: api-pgs-edge green on the fixed tree; the header names the
  real history

The api-pgs-edge header still records a known issue: a full
256-colour palette segfaults pgssub_write_pcs on first encode, the
case excluded pending an encoder fix. The segfault was the test's own
missing output allocation, fixed by b258be4ce6, and the test now
exercises the full palette as its first case while the header still
claims it is excluded. The first case is also mislabelled: it calls
the palette duplicate, and the entries are distinct.

Correct the header to tell the real story and rename the case to what
it proves: a full 256-entry palette through PCS and PDS, which also
exercises the PDS writer's worst-case size guard. Run api-pgs-edge
green on the fixed tree and record the run in the findings.

### Prove per-stream option forwarding {#per-stream-forward}

- verify: the two-stream smoke shows each SUP carrying its own
  options, with no forward logged against the wrong stream

Each output stream gets its own SubtitleEncContext through
enc_sub_alloc, so options_forwarded cannot gate one stream's forward
with another stream's state. The property is unproven at run time.
Smoke one command with two subtitle output streams carrying different
-sub_* choices, decode both SUPs, and check each carries its own
quantize choice and forced styling.

### Smoke UHD {#uhd-smoke}

- verify: srt to sup at 3840x2160 round-trips clean through pgssubdec

The encoder takes width and height from the frame, and no smoke has
run at 3840x2160 on this lineage. Convert an srt sample to sup at
UHD, then decode the sup back and confirm the display sets.

### List the maintainer for every series-added file {#maintainers-entries}

- verify: every file the series adds wholesale carries
  David Connolly <david@connol.ly> in MAINTAINERS, the moved elbg
  and palette entries are gone, and the commit is pushed to the fork

Operator ruling, 2026-08-28: MAINTAINERS is a duty roster, and the
developer docs document self-listing through the reviewed patch as
the normal path. Every file the series adds wholesale carries the
full RFC form beside it: the five fftools pairs (the three
ffmpeg_sub_* pairs had no entry at all), quantize, mediancut,
neuquant, palettemap (a family glob that covers the internal
header), and pgssubenc. The elbg and palette entries are dropped:
rename detection shows both are moves of upstream code with no
upstream maintainer, so the move claims nothing. Landed standalone
on pgs9-master (d6b6a7b4ff) and folds into the series metadata
commit at submission prep.

### Walk and gate the series {#series-gates}

- verify: the count-verified build walk green across
  upstream/master..pgs9-master; the api-pgs set and fate-sub-pgs
  green; per-commit audits clean

Run the walk with a configure step at every commit (the generated
codec_list.c from the tip state leaks into early commits otherwise),
then the fate sweeps and the audit batch: sign-off, ASCII, whitespace,
trailers, and the message lane.

### Close out {#close-out}

- depends: #series-gates
- verify: attested operator

Push pgs9-master, record the task receipts, update plan/0020 and
PLAN.md, write the memory entry.

## Findings (execution appends here)

- MAINTAINERS (2026-08-28): done at pgs9-master d6b6a7b4ff, pushed.
  The three ffmpeg_sub_* fftools pairs had no entry at all; the
  delivered series also claimed the moved elbg and palette files,
  which upstream maintains under no name, so those lines are gone.
  The push carried abb82b5b17 as well, which the fork had been
  missing (its tip was b258be4ce6). One boundary call, recorded for
  review: palettemap.c and palettemap.h hold code extracted from
  vf_paletteuse, and the ruling was applied file-level (the files
  are added wholesale by the series), so the claim stands there; a
  content-level reading would drop it too.

- Epoch palette-cache hole (2026-08-28): fixed at pgs9-master
  4801ab8c08, red confirmed before the fix. The regression test
  api-pgs-epoch-cache drives an entry opaque in epoch one,
  transparent at the epoch-two boundary (opened by a height change),
  then restored to the epoch-one value; the pre-fix tree failed on
  the restore step exactly as the analysis predicted (stale cache suppressed
  the delta write), and the fixed tree passes. The whole api-pgs
  fate set stayed green, 15 targets including the new one. A build
  warning note for submission prep: pgs-test-util.h emits
  unused-function warnings for helpers a given test does not take;
  the edge test carries the same shape, and a `static inline` pass
  over the header would silence the family.

- Full-palette edge record (2026-08-28): corrected at a58e6f9c12.
  The header no longer claims an open encoder segfault and the case
  label no longer calls the distinct-entry palette duplicate;
  api-pgs-edge runs green.

- Per-stream option forwarding (2026-08-28): proven at run time.
  One srt, duplicate-mapped into two pgssub streams in one mkv,
  with -sub_quantize_method differing per stream. With the same
  method on both streams the extracted SUP files are byte-identical;
  with NeuQuant against Median Cut they differ decisively (105872
  against 63765 bytes), so each stream ran its own value through its
  own conversion context. Median Cut against ELBG differs likewise.
  NeuQuant against ELBG is byte-identical for this content, the
  algorithms coinciding, which is why the Median Cut cases carry the
  proof. Side observation: Median Cut's entry ordering RLE-compresses
  this content a third smaller than NeuQuant's.

- UHD smoke (2026-08-28): srt to sup at 3840x2160 encodes clean
  (217933 bytes, 24 packets, epoch and delta structure intact) and
  decodes cleanly through pgssubdec, proven by a DVB transcode of
  the decoded bitmaps. The null-muxer decode attempt is not a valid
  subtitle sink; the transcode is the decoder proof.

- Zero-warning ruling (2026-08-28, operator): every warning new to
  our code is unacceptable, so the census was swept in a scratch
  worktree. The tip build showed five shapes in our files: dead
  Encoder and encoder-context locals in render_active_set
  (fftools/ffmpeg_enc_sub.c), seven unused-function warnings from
  the shared test header across its includers, a dead local in the
  edge test's encode_rect, and 1 MB encode buffers on the stack in
  the fade, coalesce, and animation-timing tests. The files the
  series only modifies (gif, supenc, ffmpeg.c, ffmpeg_mux_init.c,
  ffmpeg_opt.c, vf_elbg, vf_palettegen, vf_paletteuse) carry zero
  warnings at the tip, so nothing new hides there. Fixed at
  pgs9-master d854c88265: the dead locals are gone, the header
  helpers are static inline, and the big buffers are heap-allocated
  (a Windows default stack is 1 MB). Every file the series adds or
  modifies now compiles with zero warnings, and the affected fates
  stayed green. This supersedes the submission-prep note above that
  deferred the header warnings.

- Series gates (2026-08-28): the count-verified build walk ran
  upstream/master..pgs9-master with per-step configure, 25/25 green
  (the range before the warning-fix commit, which is build-verified
  at its own commit). fate-sub-pgs passes against the local fate
  samples. The four session commits carry the sign-off and the GLM
  trailer with clean whitespace. Remaining: close out (push done,
  receipts, index, this record).

- Dead forward dispositioned (2026-08-28): the quantize_method and
  forced_style forward in convert_text_to_bitmap, recorded above as
  a submission-prep note, is removed at pgs9-master bc3272d081.
  Both writes targeted options pgssubenc does not define and always
  failed; the real one-way circuit reaches the conversion directly.
  call/0009 records the disposition and the reviewer-facing answer
  for why pgssub has no quantize_method where gif does.
