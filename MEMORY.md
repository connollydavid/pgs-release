# MEMORY.md — append-only working memory

## 2026-07-05 — Adopted the host methodology (case b, Shallow PR)

- Template: connollydavid/host-template @ 5707980, stamped in `.host`;
  adoption recorded in call/0001, rename dictionary boxed there.
- Case b: the pre-methodology CLAUDE.md merged with the spine. The merged
  file sits at `CLAUDE.md.proposed` — installing it over CLAUDE.md was left
  as an explicit operator action because the session's permission layer
  (rightly) refuses agent self-modification of standing instructions.
- Durable exception (operator ruling): the Pages root is the content-full
  product site from docs/; the development mdBook publishes under /book/
  (call/0002). Pages source must switch main:/docs → gh-pages after merge.
- The four software submodules converted in place to `.host-software`
  (same pins); CI materializes worktrees via pinned host-lifecycle v0.36.0.
  All components repro-exempt = call/0003 until reproducibility is proven.
- Deferred to operator: `git mv CLAUDE.md.proposed CLAUDE.md`; adding
  tools/allium + tools/specula submodules (permission layer refused
  third-party repos the user had not named; no .allium/.tla specs exist yet,
  so no lane is mandatory); authoring real cast/ personas by discussion;
  installing the host-lint commit hooks (`software --install-hooks` needs a
  local cargo build of tools/host-lint); switching the Pages source.
- Gotchas learned: `.host-remap` treats leading `#` as a comment, so a
  dictionary entry cannot begin with a markdown heading marker; `remap
  --apply` substitutes inside `host-lint:ignore` fenced blocks (the fence
  guards the lint scan only), so the boxed durable copy in call/0001 had to
  be restored from the archive commit afterwards; the standalone host-lint
  binary reads LEXICON while `remap --check` reads `.host-lint-allow` — keep
  both in sync.

## 2026-07-05 — Adoption PR opened (#1); tool findings

- PR: https://github.com/connollydavid/pgs-release/pull/1. Verify receipt
  deliberately unrecorded until the CLAUDE.md swap (its recheck runs the
  prose audit, which the outgoing CLAUDE.md fails).
- The gate's remap recheck refuses a comment-only .host-remap even though
  the host README retires the dictionary after apply; kept one applied
  entry as a workaround. Candidate upstream fixes to raise on
  host-lifecycle: (a) accept an empty dictionary in the recheck, (b) stop
  remap --apply substituting inside host-lint:ignore fences, (c) unify the
  LEXICON / .host-lint-allow split between host-lint and remap --check.
- mdBook under /book/ needed no tool change: book output uses relative
  links, and the publish recheck only tests that mdbook.yml exists. A
  native sub-path option in the publish phase would let call/0002's
  exception retire; considering raising as an enhancement.

## 2026-07-05 — Review fixes landed; adoption completed on the branch

- Claude-driven multi-angle review of PR #1 (the advisor tool was
  unavailable); confirmed findings fixed on the branch: rebase-script
  usage paths, plan link prefixes, letter-suffixed series labels reworded
  to content, stale submodule-layout claims, link-skills.sh exec bit.
- CI single-sources the tool through .github/actions/host-lifecycle:
  pinned version, sha256-verified download, unsupported-runner guard,
  bare stores cached by pin, per-item pin audit, worktree path emitted so
  no workflow hard-codes a branch. gate.yml runs the full
  software --check on every push/PR; mdbook.yml asserts the call/0002
  layout post-assembly.
- Operator directed complete adoption: CLAUDE.md.proposed installed as
  CLAUDE.md; prose and naming audits clean; verify receipt recorded; full
  gate green (no hazards).
- Upstream issues filed: host-lifecycle#11 (remap recheck vs retire
  step), #12 (remap --apply inside host-lint:ignore fences), #13
  (LEXICON vs .host-lint-allow split), #14 (materialize shallow/cache),
  host#17 (publish-phase sub-path mount; would retire call/0002's
  hand-rolled exception).
- Still operator-only: adding tools/allium + tools/specula submodules
  (session permission layer refuses third-party repos in auto mode) and
  flipping the Pages source to gh-pages after the first Site publish.

## 2026-07-05 — Merged; site serving per call/0002

- PR #1 merged to main (all lanes green: gate, build, FATE, six release
  legs, Site). Operator authorized the Pages source flip; done under the
  connollydavid account (the slartibardfast login lacks admin on Pages).
- Pages pipeline wedge, for next time: the pre-flip legacy build of the
  merge commit hung "building" (its checkout had failed on host-template's
  recursive third-party submodules) and blocked the first gh-pages
  deployment ("Deployment failed, try again later"). Flipping the source
  does not enqueue a fresh build by itself; POST /pages/builds does. The
  second explicit request deployed clean.
- Verified live: the product root and /book/ both serve 200 from
  gh-pages:/. The failing legacy build from main:/docs is gone for good.
- Still open: allium/specula submodule adds (operator command, in the PR
  body) and the cast/ personas discussion.

## 2026-07-05 — All four verification tools wired

- Operator authorized the allium and specula submodule adds; wired at the
  template's pins (b86dba9), every lane green on that commit.
- Gotcha with a correction: the first wiring attempt was reported pushed
  but had been silently blocked — the host-lint pre-commit hook fails
  closed on staged gitlinks (git show ":path" exits 128 for mode 160000),
  so every git submodule add commit is rejected once the hook is live.
  Filed as connollydavid/host-lint#19; the installed hook copies carry a
  local skip-gitlinks amendment (tool source untouched). Re-apply the
  amendment if hooks are ever reinstalled before the fix lands.
- The only remaining spine obligation is authoring cast/ personas by
  discussion before planning new work.

## 2026-07-05 — Cast built; the adoption's last spine obligation closed

- Personas by operator discussion: Elias (ffmpeg-devel reviewer, primary),
  Marcus (archivist), Noa (disc author), Priya (pipeline engineer), Sable
  (agentic developer). Rationale in cast/README.md: upstream acceptance is
  the delivery channel for every other persona.
- Next planning session: cut the v8 milestone from plan/PLAN.md's Current
  Work with stories prioritised by Elias (series hygiene, FATE evidence,
  buffer-model answers ready for review).

## 2026-07-05: plan/PLAN.md redistributed into index + charter (c34a143)

PLAN.md (906 lines) split per the spine's plan-room rule: PLAN.md is now
the milestone index + current-work scratch only; the enduring programme
content (context, architecture, acceptance intelligence, submission
strategy + RFC template, deferred backlog, references, release builds)
lives in the standing charter plan/0000-ffmpeg-subtitle-upstreaming/
(number 0000 chosen deliberately, mirroring call/0000: it precedes the
accepted-work sequence). Per-milestone detail was dropped only after a
section-by-section coverage check against the milestone READMEs; unique
facts migrated to the charter. Found but NOT fixed (closed record):
plan/0008's README says 16 OCR conversion pairs (4x4) while old PLAN.md
said 24 (claiming 6 text encoders but listing 4); the README figure is
the record. plan/0019's RFC pointer now names the charter.

## 2026-07-06: plan/0000 charter converted to a single file (3f12251)

Corrects the previous entry: the charter now lives at
plan/0000-ffmpeg-subtitle-upstreaming.md (a single file, mirroring
call/0000's file form), not in a folder. Operator preference, and the
folder layer held nothing. Root cause investigated for an upstream case
study: the template's example milestone (folder + README + spec/) is an
orphaned form. The folder existed to hold spec/ subdirectories; the spine
later moved specs into the software repos but the example was never
re-read, and this adoption copied the surviving container 18 times at
migration, once for plan/0019, and once more for the original 0000. No
host-* tool inspects inside a milestone folder (validate is name-level
only), so both shapes pass silently. Upstream issue to follow: specify
the single-document milestone shape, forbid sibling files, fix the
example, define the 0000 charter kind.

## 2026-07-17: template upgraded to baseline ff04a94 (call/0004)

Case C upgrade through the ledger: entries 67d63e9 (build-sequence band),
962630c (book-mount sub-path), ff04a94 (adopt verb becomes onboarding; the
scaffold-and-stamp primitive is `scaffold`) recorded and the baseline
advanced 7127dc4 -> ff04a94. Tools re-pinned host-lifecycle v0.40.1 and
host-lint v0.14.2 (submodules, the checksum-verified CI action, the
installed hook binary — the hook's sibling binary is a copy the installer
does not refresh; re-copy it on every lint bump). call/0002's /book/
exception is now the declared `book-mount = "/book/"` stamp key and the
Site workflow reads `book --print-mount` (kept our assemble shape: the
reference workflow publishes only the book and would stop republishing
docs/ at the root). `.host-lint-allow` retired: LEXICON is the one
allowlist (host-lifecycle#13 landed), gate sync step removed. Verify gate
green after each change; only pre-existing repro-exempt warns remain.

## 2026-07-17: adversarial review of ffmpeg commit rules; plan/0020 cut

Claude-driven adversarial review checked our recorded rules against live
upstream docs and audited the 29 pgs8-wip commits. Blocking: fftools and
the api tests call ff_sub_* exported from libavutil (libavutil.v exports
av* only, so --enable-shared cannot link); sub_util's only consumers are
fftools+tests, so it moves into fftools on pgs9. Process drift: Forgejo
PRs are an official submission path (2026-02-26) and review runs on the
list or code.ffmpeg.org (2026-07-13); no adopted AI policy exists (plan
0019 wrongly cited one); cosmetic-separation was relaxed 2026-03-25 for
whitespace-only changes. Regressions from the v7 restructure: sign-off on
4/29 commits, non-ASCII in 2 messages + 4 comments, missing lavu bump on
the ELBG avpriv move, doc/ffmpeg.texi untouched by 5 new CLI options.
Lesson: series rewrites shed earlier review fixes; the per-patch build
check needs an --enable-shared leg (it would have caught B1). Remediation
is plan/0020 (pgs9); pgs8-wip freezes under history/pgs-v8.

## 2026-07-17: ffmpeg commit-rule checker designed as a host-lint pack

Operator ruled the ffmpeg commit-rule checker ships as a host-lint
plugin (not standalone), upstream + project rule packs both in v1. Full
task-by-task design posted as host-lint#22: git-style pack dispatch in
the core (`host-lint ffmpeg ...` execs `host-lint-ffmpeg`, exit codes
pass through), a workspace crate on the `host_lint` lib, a rule registry
keyed to developer.texi anchors (pinned at our a7ffc46 tree; live pages
fetched today agree) with three honest tiers (mechanical / receipted
expensive / attested) and a completeness test mapping every texi
rule to a registry entry. Config never enters the ffmpeg tree (clone-
local, in git-common-dir); the pgs project pack (branch/tag grammar) is
data in this repo. Addendum comment maps today's plan/0020 findings to
rules: three caught by the designed corpus, plus additions it forced
(series.doc-updated, series.shared-abi, ascii checks) and refinements
(version-bump covers avpriv moves; build receipts record an
--enable-shared leg; cosmetic-mix encodes the 2026-03-25 relaxation).
Frozen pgs8-wip becomes the known-findings regression fixture; live
acceptance runs on pgs9. Open for operator: pack residence (workspace
recommended), pgs branch grammar vs `-wip` suffix, patcheck depth,
sign-off mode default. Both issue texts pass host-lint naming + prose.

## 2026-07-17: adversarial review of the pack design filed as host-lint#23

Claude-driven adversarial review of host-lint#22, filed as a bug. Found
one live core defect, execution-verified: an explicit nonexistent file
arg exits 0 clean (scan_file silently skips), a fail-open against the
tool's own fail-closed pattern. Design soundness breaks: bare-name pack
dispatch collides with file args (`ffmpeg` names the build artifact in
the very target tree; remedy is a reserved `pack` verb); the
area-prefix blocker fails measured ground truth (46 of 2000 upstream
subjects legitimate: reverts, Bump versions, brace-expansion areas);
include-exists flags generated headers (config.h family needs an
allowlist); per-worktree hook modes contradict the shared common-dir
config; version handshake fails open (the recorded stale-hook-binary
hazard again). Corpus gaps: fixture scope omitted Coding Rules and Code
behaviour chapters; missing rules (alphabetical-order, MAINTAINERS
coverage, checkasm, GPL gating, sample provenance, standalone-compile
leg); filter/BSF registrations escape the checklist triggers; core
naming lane not chained in target-clone hooks; no corpus-vs-live-
upstream drift lane (the pinned texi predates the cosmetic relaxation,
proving the need). Process: tiers were assigned by intuition where
call/0037 precedent demands corpus calibration (new task); LGPL fixture
licensing in an Unlicense repo unresolved. Lesson: measure before
tiering, and every allowlist the engine has (generated files, reserved
names, exempt paths) exists because a blocker met reality; design new
blockers by running them over accepted history first.

## 2026-07-17: review fixes folded into the pack design (host-lint#22, revised)

Consolidated revision posted on host-lint#22 superseding the opening
post's build sequence and the addendum's deltas; every host-lint#23
finding absorbed task-by-task with the finding names inline as the
audit trail. Sequence changes: new root core-fail-closed-file-args (the
live core fix ships first); pack-dispatch reworked to the reserved
`pack` verb with a strict version handshake; new tasks
fixture-licensing (before diff-lane), corpus-calibration (tiers freeze
only after measuring rules over accepted upstream history; the 46
ground-truth subjects become must-pass fixtures), and
upstream-drift-lane (network CI acknowledging live-doc drift per
rule-bearing section). series-lane gains the generated-header
allowlist, all registration-table triggers, version_major.h + HEADERS
parsing, and the new rules; build-receipts gains legs, the common-dir
receipt home, config digest, and note/warn semantics; hook-installer
chains the core naming scan and goes worktree-private for config.
host-lint#23 stays open for the core defect only. Operator decisions
now five: residence, pgs branch grammar, patcheck depth, sign-off
default, and the calibration flag-tier rate. All texts lint clean.

## 2026-07-17: pack build sequence underway; seven commits on host-lint main

Implementation of the host-lint#22 revised sequence began upstream-first
in the tools/host-lint submodule (its worktree now sits on main, ahead
of the recorded v0.14.2 pin; the pin bump waits for the 0.15.0 release
per the sequence). Pushed 241a870..e75c6c4: core-fail-closed-file-args
(the host-lint#23 live bug; explicit unscannable file args exit 2),
engine-surface (reporting surface + ENGINE_VERSION into the lib),
pack-dispatch (reserved pack/packs verbs, exit-code passthrough,
HOST_LINT_VERSION export), workspace-split (host-lint-ffmpeg skeleton
with strict skew refusal, never exits 0; CI stages both binaries), the
fixture-licensing policy README, a found-during fix (the repo's own
--all was red at flag tier at v0.14.2: four lib.rs comments quoted
tells literally, against the .host-lintignore contract; reworded, not
muted), and the re-derived kani digest ledger. Gates green locally: 93
unit/property, 149 integration, --all advisory-only, obligations
strict-discharge all 51 dispositioned (kani 0.67.0 re-ran both proofs
after installing rustup user-locally; kani needs rustup, system cargo
alone cannot drive it). lint-skill.sh fails locally only for missing
PyYAML; CI covers it. Churn lesson, operator-prompted: after two
consecutive tooling failures, stop and diagnose the root cause or take
the escape; and compose commit messages against the trope list up
front instead of lint-amend loops.

## 2026-07-17: pgs9 five-theme integration verified (combined tip, unpushed)

Five Fable sub-agents remediated pgs8-wip in independent worktrees; their
fixup! commits (keyed to series-commit subjects) were combined into
~/pgs9-wt/integrate (branch pgs9, backup pgs9-combined-backup): 82 commits,
all cross-branch conflicts resolved, zero markers. VERIFIED: configure
--enable-shared + make ffmpeg links and runs, pgssub encoder present, nm -D
clean of relocated symbols - the review's one blocking finding (cross-lib
ff_ symbols breaking shared builds) is closed across all themes. Autosquash
to clean history was deliberately deferred (tip-authored fixups won't
localize to mid-series targets; the series is re-cut against master, 2386
commits behind, next). Sub-agents found+fixed: forced_style AVOption never
defined (dead feature), 3 HIGH encoder input-safety defects,
ff_ass_subtitle_header_full cross-lib call; pending rebase edits: committed
319KB ELF test binary, quantize.h bisect break, palette copy-not-move.
call/0006 records two operator feature rulings (expose quantize_method, cap
animation scan). BLOCKED: pushing pgs9 to fork needs operator (classifier-
gated); Where-room pin stays pgs8-wip until pushed + master-rebased.
Remaining work is submission-prep, deferred behind features-complete +
hardware validation.

## 2026-07-17: pgs9 fold reversed to coherent-series (supersedes the deferral)

Corrects the prior entry's "autosquash deliberately deferred": operator
directed folding every fix into the commit that introduced the defect AS
EARLY AS POSSIBLE, coherent + bisectable at every commit ("100% tight from
the start" for upstream review), using git rerere so resolutions replay
through the later master rebase. rerere enabled in the ffmpeg store config
(shared by all pgs9-wt worktrees). The autosquash of the 82-commit combined
tip into 29 coherent commits is IN PROGRESS in ~/pgs9-wt/integrate (active
rebase, ~step 21/82 at compact). The hard enc_sub conflict is NOT a punt: two
agents renamed the same code two ways (verification event_buf->coalesce,
symbols ff_sub_->sub_), resolved by union-merge. Full resume block +
conflict-resolution rules + post-fold steps (rebase edits, call/0006 fixups,
per-commit build-walk oracle, master rebase, Where-room switch) are in
scratchpad/integration-notes.md under "RESUME HERE". Safe points:
pgs9-combined-backup (verified builds shared + runs), history/pgs-v8 (pushed),
5 theme branches + deliverables intact.

## 2026-07-19: pgs9 fold + rebase-edits + features done; master rebase remaining

Resumed the coherent fold from the paused step-21 rebase and drove it to
completion. pgs9 = 3532e2a43e (fold/cp-pre-master), 30 commits (Median Cut
+ region-weighted MERGED to kill a circular forward-reference each had on
the other's symbol), 0 fixup!, bisectable end-to-end (default build walk
60/60, zero errors). Messages polished (30/30 sign-off, 4 tests->fate
rewrites via handover/deliverables/messages/apply.sh). call/0006 features
in: lavc/pgssubenc quantize_method option (+doc/encoders.texi), fftools
animation-scan CPU cap (SUB_ANIM_SCAN_MAX_MS). Tip builds + links
--enable-shared. Structural fixes applied at source: quantize.h typedef
heal, quantize.c av_quantize_alloc heal, palette copy-not-move at the
OkLab move with the vf_palettegen/vf_paletteuse migrations corrected, the
319KB ELF dropped. Checkpoints fold/cp-{muxinit-resolved,pre-edit,render-
folded,wire-pipeline,pre-merge,pre-master}. REMAINING: the master rebase
(git rebase --onto upstream/master 6e7c3efe70 pgs9 - NOT plain `rebase
upstream/master`, which replays 328 commits), then re-derive EVERY
version.h + APIchanges across the version-bumping commits (lavc 62->63,
lavu 60->61, cumulative MINOR bumps) + resolve code conflicts from ~2386
commits of upstream drift; then operator-gated fork push + .host-software
pin switch. The master rebase is conflict-heavy and non-uniform - it wants
per-commit resolution, not a bulk script.

Lessons (non-obvious; for the next session):
- Per-commit vs final-tip: "byte-identical to combined-backup" means at
  EACH commit, not just the tip. I misdiagnosed enc_sub as event_buf
  (the tip's state) when the text-to-bitmap intermediate actually used
  coalesce; event_buf arrives at the lookahead commit. Compare the
  reference's state AT the commit under review, never the final tip.
- Blanket take-theirs / take-ours breaks when the two sides carry
  different FIX-STATES. region-weighted's quantize.c was itself broken
  (the heal lands at Median Cut/ELBG), so take-theirs silently reverted
  my NeuQuant heal. Always ask which side holds the correct state and
  merge: keep the heal, add the new content.
- Separate fix-application from the build-walk verification. I conflated
  them; the walk timed out (minutes per commit) and walk-time fixes
  cascaded. Apply ALL fixes via an interactive rebase FIRST, then run
  the walk to verify. Run the walk in the background or in CI.
- rerere records whatever you `git add`, including WRONG resolutions, and
  replays the bad postimage on the next run. After a botched resolution,
  override rerere (resolve fresh / drop the recording) or it propagates.
- Conflict formats VARY; never assume a generic shape for scripted
  resolution. version.h conflicts were MAJOR+MINOR in some commits and
  MINOR+MICRO in others; my regex missed the first and left markers
  (parse failure). Read the actual conflict block before scripting, or
  resolve by hand.
- A circular dependency between two commits (each uses a symbol the
  other defines) is NOT fixed by reordering - reorder just reverses the
  forward reference. Merge the commits, or re-split so each is self-
  contained.
- Checkpoint branches at every milestone (fold/cp-*) recovered me from
  three botched operations. Keep making them.
- FFmpeg configure writes ffbuild/config.mak (not ./config.mak), and
  the build walk's per-commit make is incremental after the first only
  if config.mak persists (it does - untracked).
- FFmpeg source comments are terse; rationale belongs in the commit
  message, not a multi-line block above a constant.

## 2026-07-19: host-reconcile — the version-reconciler generalised to a 4th methodology tool; design filed on connollydavid/host#18

The version-reconciler prototype (tools/host-ffmpeg-version-reconcile/,
built today: derive/resolve/rewrite, tested against the real pgs9 state)
surfaced a bigger pattern: reconciling TYPED files (version metadata,
changelogs, manifests) across a moving base, via git MERGE DRIVERS, is a
general methodology concern, not an FFmpeg-specific one. The decision:
don't implement the full tool here. Instead:

- **The design is filed as a complete handover on connollydavid/host#18**
  (https://github.com/connollydavid/host/issues/18, 22KB body, label
  `enhancement`). It is drawn entirely from this project's pgs9 friction
  (the case study) + the prototype's four bug-lessons. Implementation
  happens on the host repo (the methodology's development home), not here.

- **host-reconcile** (general core: merge-driver framework + declaration
  system + agent affordances + series lifecycle) + **host-reconcile-ffmpeg**
  (the FFmpeg articulation: version.h/version_major.h/APIchanges typing +
  patcheck interop + Makefile.sources/FATE/MAINTAINERS completeness).
  Future articulations: host-reconcile-rust (Cargo.toml), -node, -python.
  Mirrors the host-lint + host-lint-ffmpeg pattern. This is a 4th host-*
  tool joining grammar/lint/lifecycle; the spine grows a reconcile lane.

- **The existing prototype stays in pgs-release as the case-study artifact
  + the seed of host-reconcile-ffmpeg.** Its resolve/rewrite/derive are
  tested; the pgs9 rebase can use it directly while host-reconcile is
  implemented upstream. The prototype's four bugs (LIB-prefix split,
  placeholder-sha over-consumption, version_major.h empty-guard,
  conflict-format variance) are the spec's pinned invariants + Kani targets
  in the filed design.

- **Naming:** "rebase" rejected (merge drivers fire during any merge, not
  just rebase); "merge-driver" is the mechanism not the name; host-*
  convention is purpose-named → **host-reconcile** (consistent with the
  prototype's "...-version-reconcile" seed). Binary `reconcile`.

- **Alignment, not replacement:** FFmpeg documents NO quilt/stgit idiom
  (doc/ grep is clean; the flow is git format-patch + send-email +
  patchwork/Forgejo + the in-tree tools/patcheck). host-reconcile-ffmpeg
  COMPLEMENTS patcheck (style/sanity) on the version-metadata +
  bisectability + completeness lane; it does not impose a quilt/stgit model
  FFmpeg never adopted.

- gh auth switched to connollydavid (active) for the filing.

The pgs9 master rebase (onto fast-forwarded origin/master, --onto 6e7c3efe70)
is **BLOCKED on host-reconcile** (connollydavid/host#18), by operator decision
(2026-07-19): the rebase is the articulation's acceptance test (Phase 2
verify in the filed design), so it must run against the real tool, not the
prototype — running it now with the prototype would consume the test
informally and mean redoing it. A peer agent implements host-reconcile on
the host repo; pgs9 waits. Do NOT start the rebase with the prototype alone.
Also pending (not urgent until the rebase unblocks): fast-forward the fork's
master from upstream (origin/master is at 482395f830, 2176 behind
upstream/master 9bc73ba344; `gh repo sync connollydavid/FFmpeg --source
FFmpeg/FFmpeg --branch master`, then `git fetch origin`). The plan room
records the block at plan/0020#cut-pgs9.

Uncommitted on-disk state (operator gates commits): the prototype at
tools/host-ffmpeg-version-reconcile/ (untracked), and edits to MEMORY.md +
plan/0020-pgs9-series-remediation/README.md (the block note). The
fold/cp-* checkpoint branches + pgs9 (3532e2a43e) are the safe points.

## 2026-08-21: methodology re-read; verify gate green; the august ledger gap

Operator directed: read and follow connollydavid/host to keep this repo an
agentic project. Full verify sweep run from WSL with the release binaries
on PATH (source .env): validate plan+call ok, software --check exit 0
(only the four known repro-waiver warns), prose clean, reconcile clean,
book ok, upgrade ledger current at baseline ff04a94. GOTCHA: the applied-
ledger verify for 4a98d92 shells out to `host-lifecycle` BY NAME; without
the tools on PATH the gate reports a false HAZARD ("claimed applied but
its verify no longer holds"). Always run the gate with .env sourced.
Ledger gap found and reconstructed from the tree (no entries cover it):
host-lint advanced v0.14.2 -> v0.18.1 with the ffmpeg pack shipped
(host-lint-ffmpeg workspace: checklist/cosmetic/diff/forge/mail/
maintainers/msg/receipt modules), host-lifecycle v0.40.1 -> v0.50.0
(renamed repro-exempt -> repro-waiver; .host-software migrated), libass
switched to the connollydavid fork at cc83558b, and .env/.host-envhash
scaffolding added. The hook sibling binary was stale at the v0.14.2
build; re-copied the v0.18.1 release build over .git/hooks/host-lint
(smoke test clean; the pre-commit script's skip-gitlinks amendment for
host-lint#19 is present and was not touched). The CI action pin was
raised v0.40.1 -> v0.50.0 with re-derived per-asset sha256s (left
uncommitted to land with the operator's tool-bump batch). Windows-git
phantom: tools/specula shows "modified content" from Windows git (cannot
hash scripts/infra/run_model_check.sh) and clean from WSL; the
submodules and stores are WSL-owned, so read them from WSL only.

## 2026-08-21: overriding goal set — pgs9 onto n9.0.1; WSL2 primary; Fairies vendored

Three operator orders. (1) OVERRIDING GOAL: rebase the pgs9 series onto
FFmpeg 9.0.1 "Lei" (tag n9.0.1 = bf1b838f2a, released 2026-08-12, latest
stable of release/9.0, cut from master 2026-06-26) and make it pitch
perfect for potential upstreaming. This LIFTS the 2026-07-19 block (the
rebase waiting on host-reconcile, host#18): that issue is still open,
cut as the design-only plan/0075 in connollydavid/agentic-host, queued
behind plan/0072. The override is recorded as call/0007. Recon facts:
the series base 6e7c3efe70 sits on the 8.1 lineage (pgs7-8.1), not
master; the true merge-base with n9.0.1 is 67c886222f (328 commits of
pgs history below the series); upstream drift intersects our touched
files in only ~22 files (Makefiles, registration tables, version
headers, docs); pgssubenc and the fftools subtitle pipeline files do
not collide. rerere is enabled in the ffmpeg store, so resolutions from
this rebase replay on any later master re-cut. (2) WSL2 is the primary
development environment; win32 is for direct win32 testing only; all
gates, commits, and builds run from WSL. (3) Fairies
(code.ffmpeg.org/michaelni/Fairies, GPL-2.0-or-later, michaelni's LLM
review pipeline for the ffmpeg forge) vendored as tools/fairies at
cd67a6a. Its intended use for the pitch-perfect pass: the simpast-runs
offline replay harness runs our series through the same reviewer
pipeline the forge uses, without touching the live forge.
