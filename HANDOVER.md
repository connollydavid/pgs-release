# HANDOVER — read this first (2026-08-23)

Everything a fresh session needs. MEMORY.md has the full append-only
ledger; this is the map.

## Where we are

The pgs9 FFmpeg series was rebased onto n9.0.1, shipped as release
n9.0.1-pgs9.1, then RESTRUCTURED per a glm-5.2 (Fairies) structure
review into an 18-commit four-sub-series re-cut, verified, and PUSHED:

- Branch `pgs9-recut`, tip `cff4e4008e`, on connollydavid/FFmpeg
  (ls-remote verified). Worktree `~/pgs9-wt/recut`.
- All mechanical gates GREEN: walk 18/18 (configure-per-step,
  --enable-libass), fate 14/14, nm -D clean, msg+series lanes clean,
  smoke verified (srt->sup with -sub_quantize_method), line audit
  fully accounted (39 non-verbatim = intended one-way rework).
- ZERO fftools reads of encoder-private state (all four sites are
  one-way circuits: CLI option -> ost -> ctx -> av_opt_set forward).
- Old series intact at `pgs9-9.0.1`; safe points `cp/ss*-...`,
  `recut/cp-*`; ffmpeg store = software/ffmpeg/.bare.

## The one open item

The fairy structure re-scan VERDICT is blocked by the Ollama Pro
session usage limit (429; three deep scans burned it: 250 rounds on
the wrong branch — staging mistake, fixed; 232 to the tool cap; one
429). OPERATOR decides: wait for quota reset / add usage / accept the
mechanical gates. To re-run when quota returns:
`bash scripts/fairy/run-local.sh /home/dconnolly/fairy-tickets/recut-structure.json --max-patch-bytes 700000 --podman-max-tool-rounds 200 --debug-response-dir /home/dconnolly/fairy-tickets/debug-rescan3`
CRITICAL: the reviewer reads the CHECKED-OUT BRANCH of
~/fairy-run/ffmpeg (NOT head_sha) — it is on pgs9-recut now; keep it
so. Verdict text is recovered from the debug dump's LAST response
message item (model answers prose, not the JSON envelope; see ledger).

## Next milestones (on operator call)

1. Master re-cut of pgs9-recut (rerere replays; scripts/reconcile/
   tooling; this was deferred from plan/0021 by call/0008 ruling).
2. RFC to ffmpeg-devel per the charter's template: propose the split
   API surface (backends internal behind av_quantize_*; palettemap as
   avpriv; region API public but flagged) — call/0008 records it.
3. Submission (four sub-series as separate series; strip `git
   cherry-pick -x` lines at format-patch export; APIchanges
   placeholder dates/hashes finalized THEN — the apichanges-truth
   task).

## Key facts and gotchas (do not relearn these)

- ALL commands from WSL (`wsl.exe -d archlinux`); scripts via FILES,
  never inline `bash -c` with $vars (quoting corrupts: two incidents).
- Loader: in-tree ./ffmpeg needs LD_LIBRARY_PATH over ALL in-tree lib
  dirs; without it /usr/lib libs load and manufacture phantom
  failures. Delete stale tests/data/fate/*.err before trusting a
  failure signature.
- Fairy: openai 2.54.0 + classic httpx 0.28.1 in ~/.venvs/fairies
  (openai 3.x/httpx2 breaks the wrapper). Endpoint
  https://ollama.com/v1 (NOT api.ollama.com — 301 breaks POST). Key
  in .env. Comms inert by design: allowlist proxy (ollama.com only,
  port 15313) + `--internal` podman net fairy-isolated + gcli absent
  + agent/worker/fairy.py NEVER run (they post).
- host-lint-ffmpeg v0.19.0 (we released it): series lane is
  base-aware; msg lane takes rev ranges; `--signoff` for the project
  rule. Hooks: sibling binary must be re-copied on every lint bump.
- Gate gotchas: dotted two-part numerals (version-shaped pairs) in
  prose/docs BLOCK the gate (reword to tag forms); "step" is manifest
  vocabulary; em-dashes fail prose zero-tropes; MEMORY.md is excluded.
- Walk loops MUST count steps and assert the total (a mistyped range
  completes vacuously); reconfigure at each step when a codec appears
  mid-series.
- Trailers (call/0008): preserve existing Co-Authored-By, append
  `Co-Authored-By: GLM 5.3 <no-reply@z.ai>`; Signed-off-by last.
- WSL2 is PRIMARY; win32 only for direct testing; Windows-side git
  cannot exec the ELF hook binary — always commit from WSL.
- Ollama model tags have no `:cloud` suffix (glm-5.2). 19-model
  catalog; deepseek-v4-flash is the cheap scanner, glm-5.2 the
  reviewer.

## Recent ledger pointers (MEMORY.md, newest last)

Re-cut completion + push: "plan/0021 EXECUTED" entry. Gates + the
line-audit catch (animation cap): "whole-series gates" entry. The
fairy staging lesson: "re-scan verdict one". The one-way circuit
design: "SS4 item 16". The full debugging history of the fairy
pipeline: "fairy first-run debugging" through "run eight succeeded".

## Housekeeping notes

.plan docs: plan/0020 (9.0.1 rebase, done), plan/0021 (the re-cut,
completion record inside). .host-software pins ffmpeg at
pgs9-9.0.1/964fc5e2d9 — the Where-room pin still points at the OLD
branch (the re-cut is on the fork but NOT pinned; pin switch is part
of the next release/submission flow, operator-gated). Release
n9.0.1-pgs9.1 assets remain the shipped binaries.

## RESUME STATE UPDATE (2026-08-28, latest — supersedes older sections above)

LATEST: pgs9-master branch exists on the fork @ 62966eff01 (19 commits
on upstream/master, the master re-cut; build OK, FATE 13/14). Known
blemishes + the exact completion path are the last MEMORY.md entry
(2026-08-28 final-6): collapse the lavc defines, fixup on the encoder
commit, autosquash, walk (BASE=upstream/master + per-step configure),
then plan/0022 continuation. The 9.0.1-based pgs9-recut = 4558bebf96
also on the fork (shipped as n9.0.1-pgs9.2). Superseded details below.


THE RE-CUT IS DONE AND PUSHED. pgs9-recut on connollydavid/FFmpeg =
4558bebf96 (18 commits, force-pushed from pgs9-recut2). Every verdict
finding fixed and gated: FATE 14/14, nm -D clean, lanes clean, smoke
verified, dead encoder options removed, supenc DTS logic restored,
api.mak aggregation + all stanzas complete, Changelog 9.0 block
restored, MAINTAINERS wrapper entries in. plan/0021 close-out amended.
LLM setup: .env now has ZAI_API_KEY (z.ai native, MODEL=zai:glm-5.2)
plus the old ollama lines (inert). OPERATOR TO-DOS: rotate both keys
(z.ai + ollama) — stated intent; optional confirmation fairy scan on
4558bebf96 (token-plan cost); master re-cut + RFC + submission
milestones on call. NOTE: a parallel session workspace exists at
~/pgs9-wt/handover (its own repo, active) — not ours; coordinate.
The walk/gate scripts: host-gates-final.sh, host-foldct.py +
host-squash.py (commit-tree rebuilds — the ONLY safe fold/squash
mechanic here), host-rescan-zai.sh (scan runner).
