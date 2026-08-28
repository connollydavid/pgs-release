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

### Complete the MAINTAINERS entries {#maintainers-entries}

- verify: every new fftools file pair appears in MAINTAINERS in the
  style the neighbours use

Applications, ffmpeg lists ffmpeg_dec_sub.c, ffmpeg_dec_sub.h,
ffmpeg_enc_sub.c, ffmpeg_enc_sub.h. The conversion work added
ffmpeg_sub_util.c, ffmpeg_sub_util.h, ffmpeg_sub_render.c,
ffmpeg_sub_render.h, ffmpeg_sub_ocr.c, ffmpeg_sub_ocr.h with no
entry at all. Add the three pairs beside the existing two, bare
filenames as the neighbours use. This commit lands standalone and
folds into the series metadata commit at submission prep.

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

(filled as the tasks run)
