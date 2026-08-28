# HANDOVER — read this first (2026-08-28)

Everything a fresh session needs. MEMORY.md has the full append-only
ledger; this is the map.

## Where we are

The pgs9 series lives on branch `pgs9-master`: 28 commits on
upstream/master, tip `bc3272d081`, pushed to connollydavid/FFmpeg.
Canonical worktree `~/pgs9-wt/recut` (WSL); the Where-room pin and the
in-tree handle `software/ffmpeg/pgs9-master` follow the branch.
Milestones delivered: plan/0021 (the four-sub-series re-cut on the
master base), plan/0022 (software validation, including the sanitizer
pass), plan/0023 (encoder completion). Every task across
plan/0020 through plan/0023 carries a recorded receipt.

- Gates GREEN: count-verified walk 25/25 with per-step configure (the
  tip commits are build- and warning-verified individually); fate
  16/16 (fifteen api-pgs targets plus quantize) and fate-sub-pgs
  against the local samples; zero compiler warnings in every series
  file; nm -D clean; lanes clean.
- Sanitizer gate GREEN: the whole fate set plus the CLI conversion
  smokes run clean under ASAN+UBSAN (fail-stop UB, leak detection).
  The pass caught one real library bug (a signed shift in the
  NeuQuant OkLab conversion), fixed.
- call/0009: the quantizer choice lives fftools-side
  (`-sub_quantize_method`); the dead encoder-priv forward is removed.
- The 9.0.1-based `pgs9-recut` @ 4558bebf96 remains on the fork
  (shipped as n9.0.1-pgs9.2); the old series at `pgs9-9.0.1`;
  checkpoints `cp/*` and `recut/cp-*`; ffmpeg store =
  software/ffmpeg/.bare.

## What remains (on operator call)

1. Hardware pass, the gating requirement: needs the operator's device
   list and authoring pipeline. The venue decision (plan/0020)
   unblocks when it is done.
2. Submission prep, which owns the five open tasks: patcheck triage,
   the APIchanges truth pass, the -sub_* texi docs, the security
   pass, and the licence-class record in the gating commits.
3. Keys: z.ai + ollama still in .env; rotate when convenient.

## Key facts and gotchas (do not relearn these)

- ALL commands from WSL (`wsl.exe -d archlinux`); scripts via FILES,
  never inline `bash -c` (quoting and truncation corrupt; three
  incidents, the last silently dropped LD_LIBRARY_PATH so ./ffmpeg
  resolved system libs and misreported our encoder as missing).
- Loader: in-tree ./ffmpeg needs LD_LIBRARY_PATH over ALL in-tree lib
  dirs; without it /usr/lib libs load and manufacture phantom
  failures. Delete stale tests/data/fate/*.err before trusting a
  failure signature. fate-sub-pgs needs FATE_SAMPLES on the make
  line, not merely exported.
- Fairy: openai 2.54.0 + classic httpx 0.28.1 in ~/.venvs/fairies
  (openai 3.x/httpx2 breaks the wrapper). Endpoint
  https://ollama.com/v1 (NOT api.ollama.com; its 301 breaks POST).
  Key in .env. Comms inert by design: allowlist proxy (ollama.com
  only, port 15313) + `--internal` podman net fairy-isolated + gcli
  absent + agent/worker/fairy.py NEVER run (they post). The reviewer
  reads the CHECKED-OUT BRANCH of ~/fairy-run/ffmpeg (NOT head_sha).
- host-lint-ffmpeg v0.19.0 (we released it): series lane is
  base-aware; msg lane takes rev ranges; `--signoff` for the project
  rule. Hooks: sibling binary must be re-copied on every lint bump.
- Gate gotchas: dotted two-part numerals (version-shaped pairs) in
  prose and docs BLOCK the gate (genuine version strings get declared
  in .host-lint-allow, everything else is reworded); "step" is
  manifest vocabulary; em-dashes fail prose zero-tropes; MEMORY.md is
  excluded.
- Walk loops MUST count steps and assert the total (a mistyped range
  completes vacuously); reconfigure at each step when a codec appears
  mid-series.
- Trailers (call/0008): preserve existing Co-Authored-By, append
  `Co-Authored-By: GLM 5.3 <no-reply@z.ai>`; Signed-off-by last.
- WSL2 is PRIMARY; win32 only for direct testing; Windows-side git
  cannot exec the ELF hook binary, so always commit from WSL.
- host-lifecycle v0.50.0: tasks --record appends and never amends, so
  a corrected receipt needs the superseded block removed by hand; the
  remap recheck honours .host-lint-allow.
- Ollama model tags have no `:cloud` suffix (glm-5.2). 19-model
  catalog; deepseek-v4-flash is the cheap scanner, glm-5.2 the
  reviewer.

## Ledger pointers (MEMORY.md, newest last)

final-6 through final-12: the master-lineage work, the plan/0022
delivery, the located undone work. final-13 through final-17:
plan/0023 opened and closed (the epoch palette-cache fix, the
forwarding proof, the UHD smoke, the MAINTAINERS ruling, the
zero-warning sweep). final-18: the full receipt sweep. final-19: the
sanitizer pass. final-20: the dead-forward removal and call/0009.

## Housekeeping notes

- .host-software pins ffmpeg at pgs9-master/bc3272d081; the in-tree
  handle software/ffmpeg/pgs9-master is a detached worktree at the
  pin; the canonical build tree is the WSL worktree.
- .env.example documents the env shape (fairy keys plus the tool
  PATH); real keys only ever live in .env.
- A parallel session workspace ~/pgs9-wt/handover exists (its own
  repo, active), not ours; coordinate before touching it.
- ~/dev/agentic-host (the methodology meta repo) and
  ~/agentic-host-work are separate projects; plan/0075 there tracks
  the FFmpeg pack design.
