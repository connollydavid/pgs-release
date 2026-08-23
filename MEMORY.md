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

## 2026-08-21: pgs9 rebased onto n9.0.1; series verified pitch-ready

The rebase ran in ~/pgs9-wt/rebase901 (branch pgs9-9.0.1, worktree of
software/ffmpeg/.bare). 30/30 commits applied onto n9.0.1 (bf1b838f2a);
only stops needing hand resolution were the version/APIchanges ones.
Version re-derivation: n9.0.1 carries lavc 63 / lavu 61 already, so the
series' major bumps are absorbed and re-derived as minors — lavc ends at
63.2.100, lavu walks 61.2 -> 61.5. The original ELBG-quantizer commit
bumped minor +2 while its own APIchanges entry documented one addition;
resolved provisionally-consistent at +1 (lavu 61.5), shrinking
#apichanges-truth. Fold-fixes during the rebase: the Median Cut commit's
three-way merge had materialized its neighbours' OLD-numbered APIchanges
entries as context duplicates (lavc 62.30 / lavu 60.30 / 60.31 blocks) —
deleted/renumbered, folded into that commit; decorative section-banner
comments (upstream ffmpeg carries none, patcheck "empty comment")
removed from ffmpeg_enc_sub.c and ffmpeg_dec_sub.c at their introducing
commits.

Verification: per-commit build walk 30/30 green under --enable-shared
(pre-banner lineage), then TWO transfer proofs (per-commit-pair tree
identity outside the named changed files) carry the verdict across both
folds; tip builds, pgssub registers with every series option, cross-lib
nm -D clean, fate-api-pgs x4 OK, patcheck hints reduced to single-line
ifs in test code (hint-tier, left for review taste), audits 30/30 clean
(sign-off, message ASCII, trailing whitespace). The audit's non-ASCII
findings are all verbatim-upstream content (Bjorn Ottosson / Clement
Boesch / Kornel Lesinski copyright lines, OkLab math) — legitimate per
the pack's own calibration (diff-ascii-code is code-scoped, not
comment-scoped). sub_ocr_init already carried av_cold; patcheck's flag
was the ENOSYS stub. Checkpoints: cp/901-folded, cp/901-walked,
cp/901-pre-banner, cp/901-final (= 964fc5e2d9, the tip).

Lessons (non-obvious; for the next session):
- WSL2 loader: an in-tree ./ffmpeg WITHOUT rpath silently loads the
  SYSTEM /usr/lib libraries. Always run with LD_LIBRARY_PATH covering
  ALL in-tree lib dirs (libavcodec, libavutil, libavformat,
  libavfilter, libavdevice, libswscale, libswresample). A partial path
  produced a misleading avpriv_elbg_free lookup error (system
  libavfilter vs our ELBG-moved libavcodec); the empty path made the
  encoder look unregistered. The "missing encoder" was environmental.
- A three-way auto-merge can materialize CONTEXT DUPLICATES: when a
  conflicted region is resolved by hand, the same file's non-conflicting
  hunks still apply verbatim, re-adding neighbouring old-version
  entries. The "every added line present" audit cannot catch duplicates;
  audit per-commit introduced content instead.
- Editing a file mid-series (banner removal) causes context/rename
  conflicts in LATER commits touching that file (the lookahead commit
  renames the coalescing section). Resolve by the original commit's
  intent expressed in the new idiom (renamed title, banner-free).
- Transfer-proof technique: proving per-commit-pair tree identity
  outside the changed file carries a completed build-walk verdict
  across a fold without re-walking.
- rerere recorded every hand resolution; the fold cycles replayed them
  without incident.

Still operator-gated: pushing pgs9-9.0.1 to the fork (classifier),
.host-software pin + branch switch (after push), #apichanges-truth
finalization (entries keep 2026-03-xx placeholder dates and xxxxxxxxxx
hashes by design until submission), the Fairies simpast review pass
(needs API keys plus the podman review host), full FATE with samples,
and the plan/0020#cut-pgs9 task receipt (verify: attested operator).

## 2026-08-22: n9.0.1-pgs9.0 released; the 9.0.1 series is the shipped line

Operator order: release binaries and surface them on the project's
Pages site. Chain executed in order. The branch push to the fork first
(the pin rule: never record a pin that is not pushed): pgs9-9.0.1 =
964fc5e2d9192dc24c4459cbc6803ebf079a2c11 on connollydavid/FFmpeg,
verified by ls-remote. The scratch worktree detached so the branch could
materialize canonically; host-lifecycle --materialize created
software/ffmpeg/pgs9-9.0.1 at the pin (embed receipt recorded). The
where-room switch is DONE: .host-software ffmpeg stanza now pins
964fc5e / branch pgs9-9.0.1.

The operator's pending tool batch landed with it (it had to: CI runs
the action, and the migrated .host-software needs the newer tool):
submodules to host-lifecycle v0.50.0 + host-lint v0.18.1, the CI action
pin raised to v0.50.0 with re-derived per-asset sha256s, repro-exempt ->
repro-waiver migration, libass on the connollydavid fork at cc83558b,
.env/.host-envhash scaffolding, and the prototype ignores.

GOTCHA that reddened the gate: the remap phase recheck counts
UNDISPOSITIONED TELLS, and my own prose from the rebase session
introduced dotted-numeral labels ("the 8.1 lineage", "lavu 61.2 ->
61.5") in call/0007, PLAN.md, and plan/0020 — advisory at commit time
(hook prints rc-3 warnings), but a gate failure in the recheck. The
commit hook's advisory and the gate's blocking disposition differ;
reworded all three (two-part dotted numerals flag, three-part tag forms
like n9.0.1 pass). Local gate green after reword; pushed; all five CI
lanes green at c45655a (Verify Gate, FFmpeg FATE — the CI-side FATE
evidence for the pre-release rule, since the local suite lacks fate
samples — Build, Site, FFmpeg Release push-validation).

Release cut: gh release create n9.0.1-pgs9.0 (target main) with notes
matching the previous release shape; the release-created event drives
ffmpeg-release.yml's packaging path (the push path only validates,
packaging is conditional on github.event_name == 'release'), building
six targets x plain/-eng variants from the .host-software pin and
attaching the twelve assets. The site's download section (docs/
index.html) moved to n9.0.1-pgs9.0 and the FFmpeg 9.0.1 base link;
the cards link the releases page generically, so they carry the new
assets without per-asset URLs to keep updated.

## 2026-08-22: release re-cut as n9.0.1-pgs9.1 (executable-bit fix)

The shipped-binary spot check caught a real defect: the release archives
carried NO executable bit (-rw-r--r--), so "download, extract, run" was
broken. Root cause: the release workflow's build job passes binaries to
the packaging job through actions/upload-artifact, which does not
preserve modes; no chmod existed in the Package step. Long-standing —
the n8.1-pgs7.0 archives shipped the same stripped modes. Fixed by
chmod-ing the binaries in the Package step before tarring. Per the tag
discipline (build-config fix increments .build), the n9.0.1-pgs9.0
release and tag were deleted with --cleanup-tag and the release re-cut
as n9.0.1-pgs9.1 from the same pin; the site's version tag follows.
Verified end to end this time: the downloaded linux-x86_64 archive
extracts to -rwxr-xr-x, reports version 964fc5e2d9 (the series tip),
registers pgssub with quantize_method, and encodes SRT to PGS.

Second finding from the same smoke test: the site's plain usage example
(ffmpeg -i subtitles.srt -s 1920x1080 output.sup, no -c:s) fails at
output open — on BOTH the v7 and v9 release binaries, so an
over-optimistic site example rather than a v9 regression. The working
form is -c:s pgssub -s WxH (the encoder needs explicit dimensions;
without them it fails per-frame). Site usage line corrected.

## 2026-08-22: host-reconcile workaround codified; host#18 updated with findings

Operator direction: work around host-reconcile as best we can and update
the bug report. The workaround that carried the n9.0.1 rebase is now
codified at scripts/reconcile/ — stop.sh (typed-file stop resolver:
parent-relative version deltas, lineage re-derivation, APIchanges
insertion at the series slot, makefile union), build-walk.sh (per-commit
build oracle), transfer-proof.sh (carries a walk verdict across a fold
by proving tree identity outside the folded files) — with the method
and the lessons written up in its README. These will carry the master
re-cut for upstreaming. host#18 received an empirical-findings comment
(https://github.com/connollydavid/host/issues/18#issuecomment-5376538743):
the acceptance-scale measurement (30 commits over 2233 of drift, every
hand stop a typed file, zero code conflicts — the work concentrates
exactly where the tool aims) plus five findings beyond the design's
pinned prototype lessons: parent-relative deltas, conflict-block shape
variance, context-duplicate materialisation by sibling hunks, the need
for a policy hook on commit-internal inconsistencies (the ELBG
double-bump), and rerere determinism. The tool's acceptance test stays
a fresh rebase per call/0007.

## 2026-08-22: Fairies on Ollama cloud — endpoint proven, inline-patch shim in

Operator picked deepseek-v4-flash (Ollama Pro, flat subscription) as the
review model; glm-5.2 / kimi-k2.7-code / deepseek-v4-pro stay in reserve
on the same plan. Endpoint facts, measured: the OpenAI-compat base for
the cloud is https://ollama.com/v1 — api.ollama.com 301s to it and the
redirect converts POST badly, which first showed as a misleading 405.
On the right base the Responses API works including function-tool
round-trips (the exact call shape fairy's review loop drives), and
deepseek-v4-flash:preview is in the 19-model catalog. The files API
does not exist (404), which is the one seam: pr_review_wrapper uploads
the patch as a file whenever an openai: reviewer is requested, no
fallback, no flag. The patch text already travels inline in
ReviewContext.patch_text for every provider, so the upload is additive;
scripts/fairy/wrapper.py is a runtime shim (monkeypatches
upload_text_file/delete_uploaded_file to no-ops around
pr_review_wrapper.main) that keeps the Fairies checkout tree untouched
— an upstream proposal for a proper flag/try-except follows separately.
scripts/fairy/smoke.sh re-verifies the whole endpoint contract (auth,
text, tool round-trip, files-probe). Fairies runs from a dedicated venv
~/.venvs/fairies (WSL python is PEP 668 locked; deps: openai,
python-dotenv, watchdog, blessed, httpx). Key lives in the gitignored
.env with OPENAI_BASE_URL. REMAINING for the first review run: the
podman shell host (sshd + containers/provision_remote.py), and staging
our series as the review ticket (the filedb ticket shape is the next
thing to read).

## 2026-08-22: fairy comms made inert (operator ruling: nothing reaches real FFmpeg infrastructure)

Belt-and-braces egress posture, all empirically verified: (1) review
containers run on the fairy-isolated podman network, created by US as
--internal before fairies ever looks (podman_host only creates a
network when missing, and its plain create would NAT) — internal=true,
and a container on it cannot even RESOLVE ollama.com, so the model's
shell has no route out by construction; the repo reaches the container
by podman cp, not the network. (2) The wrapper process's HTTP(S) egress
is forced through scripts/fairy/allowlist-proxy.py (CONNECT-only,
permitting ollama.com:443 alone): ollama.com tunnels (200),
code.ffmpeg.org and github.com get logged 403 refusals. (3) Structural:
gcli is not installed and scripts/fairy/run-local.sh REFUSES to start
if it ever appears; the posting daemons (agent.py/worker.py/fairy.py)
are never invoked — only pr_review_wrapper, via the inline-patch shim,
fed a local stdin ticket; --web-search off is forced; ssh targets
127.0.0.1:2222 only (the fairylocal alias over user-mode sshd; rootless
podman 6.1.0 verified). Residual, recorded honestly: the env-proxy is
advisory for well-behaved HTTP clients (the wrapper's httpx honors it);
the code audit found no other network path in the wrapper. run-local.sh
is the only sanctioned entry point and prints the posture before each
run. Provisioning was cancelled mid-image-build by the operator before
this ruling; the review image state on fairylocal and the review ticket
 staging are the remaining bring-up items.

## 2026-08-22: fairy first-run debugging — complete findings ledger (operator: record all, waste nothing)

Goal: perfunctory glm-5.2 structure scan of the 30-patch series, local
only. Seven runs; each failed differently; every root cause found and
fixed except the last, whose fix is designed below.

RUN MAP AND ROOT CAUSES:
- run1: podman cp of the bare mirror died "archive/tar: write too long"
  — the wrapper's repo push triggered background commit-graph writing
  in the mirror and cp tarred the mid-write tmp file. FIX (applied):
  rm -rf objects/info/commit-graphs in the mirror + `git config gc.auto
  0` + `fetch.writeCommitGraph false`. Mirror pushes are now stable
  (subsequent runs: sync ~1.7s).
- run2: openai.APIConnectionError. ROOT CAUSE: venv skew — openai 3.3.1
  is built on httpx2 (DefaultHttpxClient = httpx2.Client) while my
  earlier `pip install httpx` layered classic httpx 0.28.1; Fairies
  passes a classic httpx.HTTPTransport into the httpx2-based client ->
  AssertionError (surfacing as connection errors deep in retries). FIX
  (applied): pin openai<3 (2.54.0) + classic httpx 0.28.1 — the pair
  Fairies is written for. httpx2 and classic coexist fine (different
  module names); never install openai 3.x for this Fairies checkout.
- run3: 400 "file inputs are not currently supported". My inline-patch
  shim's upload no-op returned "" but the reviewer checks
  `patch_file_id is not None` -> an input_file block with empty file_id
  still went out. FIX (applied): the no-op returns None.
- run4: same 400. SECOND upload site: openai_reviewer appends the
  source-bundle input_file UNCONDITIONALLY once a source bundle exists
  (the source_file_id append is not None-gated). FIX (applied): the shim
  also neutralises pr_review_wrapper.build_source_bundle -> (None, [],
  []) — the model reads sources via its container shell instead.
- run5: schema JSONDecodeError char 0 (empty final text). The model ran
  `cd /work/ffmpeg` but the repo staged as /work/pgs9-9.0.1 (the
  container path is the basename of --repo-root; production stages a dir
  literally named ffmpeg). FIX (applied): FAIRY_REPO_ROOT env in
  run-local.sh; a shared clone at ~/fairy-run/ffmpeg (branch
  pgs9-9.0.1) is the staging source.
- run6: same empty-text failure with the correct /work/ffmpeg. DEBUG
  PAYLOAD (--debug-response-dir, jsonl per attempt, each line has
  request+response+wrapper_request): request1 -> [reasoning,
  function_call(shell)] good; request2 (tool result fed back) ->
  status completed, output [message] with content [{type: output_text,
  text: ""}] — a schema-shaped EMPTY message.
- SMOKING GUN (run7 dump + minimal repro): request2 carries
  previous_response_id (resp_705602) and input = ONLY the new
  function_call_output items — the STATEFUL Responses flavor.
  Ollama's Responses support is explicitly NON-STATEFUL only, so the
  follow-up arrives context-stripped (an orphaned tool result) and the
  model answers empty-conforming. Minimal repro PROVED the stateless
  shape works on this endpoint: input = [original user content,
  function_call item, function_call_output item] -> r2 output [message]
  with the JSON text, no previous_response_id.
- THE FIX (designed, next to implement): stateless-conversion shim in
  scripts/fairy/wrapper.py — monkeypatch the SDK
  openai.resources.responses.Responses.create: cache (input, serialized
  resp.output) per response id; when a call arrives with
  previous_response_id, drop it and send input = cached_input +
  cached_output_items + new_items. This is exactly the repro's working
  shape. No Fairies-tree changes.

STANDING FACTS (verified): the whole pipeline works up to the final
turn — repo sync/mirror/cp, isolated container on fairy-isolated, the
model driving real shell rounds in /work/ffmpeg, schema json_schema
enforcement accepted by the endpoint (strict pr_review_result), 40k
max_output_tokens default (not truncation; status completed throughout).
glmodel effort/verbosity params pass through fine. --debug-response-dir
is the primary diagnostic (dump lines carry request+response both).
Ollama cloud model tags have no :cloud suffix (glm-5.2, not
glm-5.2:cloud); the OpenAI-compat base is https://ollama.com/v1
(api.ollama.com 301s and breaks POST).

## 2026-08-22: run eight succeeded — glm-5.2 delivered the structure verdict

The stateless shim fixed the loop: fourteen agentic rounds (the model
grepped the diff, the repo, option tables, MAINTAINERS), then a full
~21k-char structural review. NEW KNOWN ISSUE (last one): the final
message arrives as MARKDOWN PROSE, not the strict pr_review_result JSON
envelope — the endpoint accepted the json_schema request but did not
enforce it, so the wrapper's json.loads fails at char 0 and discards
the run (exit 3). The CONTENT is intact in the --debug-response-dir
dump (response.output message text); scripts read it from there. A
future shim could coerce prose into the envelope, or the extraction
could be relaxed; not needed for our use.

The verdict is saved with honest attribution at
plan/0020-pgs9-series-remediation/fairy-structure-review.md. Its three
bounce-causes: (1) strand bundling — no maintainer owns lavu+lavc+lavf+
lavfi+fftools+fate+configure in one series; split into four sub-series
(lavu quant API; GIF RGBA; PGS encoder; text<->bitmap conversion), the
same strand shape our own plan/0002-0008 milestones had. (2) The lavu
API-surface decisions: ff_neuquant_* exported in an installed public
header (wrong), fresh avpriv_palette_map_* (worst-of-both middle
ground), PGS-shaped region knobs in the generic API — resolve with the
lavu maintainer before resubmitting; highest-risk single objection.
(3) fftools reading lavc-private state via av_opt_get*(enc->priv_data)
in the disposition bridge, the wiring, forced_style, and
quantize_method — eliminate all; one-way option flow only. It also
independently rediscovered our own known issues (the dangling
quantize_method read before its defining commit, the forced_style
dead-option shape) and flagged candidates needing OUR verification
before acting: CONFIG_LIBASS / CONFIG_LIBTESSERACT configure wiring
(may genuinely be missing!), Changelog version-block ordering and the
possibly-orphaned AV_CODEC_PROP_EXPLICIT_END entry, Co-Authored-By
trailers on three commits, and tests/api as the home for twelve
feature tests. Per-patch keep/merge/split/move table in the saved
review; the re-cut decision is the operator's.

## 2026-08-22: re-cut rulings recorded (call/0008)

Operator ruled: (1) re-cut commits keep existing Co-Authored-By
trailers and append `Co-Authored-By: GLM 5.3 <no-reply@z.ai>`; (2) the
lavu API-surface proposal is a SPLIT disposition — quantizer backends
fully internal (no installed headers, only reachable via the public
av_quantize_* factory) and palettemap as avpriv_* (the versioned
cross-library-private mechanism both lavfi and lavc consume), proposed
in the RFC rather than pre-conceded; (3) the four sub-series re-cut on
n9.0.1 first, master at submission time via rerere. Rationale for (2):
ff_ symbols cannot cross library boundaries in shared builds (the
version scripts export only av*/avpriv* — the exact B1 bug class the
series already fixed), so "internal ff_ headers shared by lavfi/lavc"
is not actually buildable; avpriv_* is the established mechanism for
new cross-lib-private symbols and does not inflate the public API; the
review's middle-ground objection dissolves because each family gets a
coherent home. Still open before the re-cut executes: the verification
checks (libass/tesseract configure wiring, Changelog version-block
order and the AV_CODEC_PROP_EXPLICIT_END orphan, trailer census).

## 2026-08-22: plan/0021 cut, the sub-series re-cut milestone (solo-ready)

The durable plan document is plan/0021-pgs9-subseries-recut/README.md:
four sub-series on the n9.0.1 base in dependency order (lavu
quantization API, then GIF RGBA and the PGS encoder, then the
text<->bitmap conversion), a pre-flight verification batch, per-commit
standing rules (build at commit, sign-off, ASCII, whitespace, the
call/0008 trailer policy, atomic version bumps), per-sub-series gates
(build-walk, fate, fairy structure re-scan via the proven local
pipeline), whole-series gates, and close-out (fork push, receipts,
ledger). Deviations from the verdict are decided in the plan, not open:
the palettegen adopter folds into the Median Cut commit (folding it
into the OkLab move would be circular), the fftools DTS hunk folds into
the pipeline wiring, the disposition bridge lands in the conversion
sub-series unless inspection proves it encoder-only, and the
region-weighted API stays public with the RFC flagging it. Gate notes:
the verdict artifact is path-excluded as an immutable dated review
(.host-lintignore); "step" is manifest vocabulary and flags, so the
plan references assembly items by content name; prose zero-tropes now
enforced on the new docs too. plan/0021 is written so a session with no
other context can execute it end to end.

## 2026-08-22: host-lint-ffmpeg pack recon; the series lane already earns its keep

Installation audit: everything coherent (submodules at exact release tags
lifecycle v0.50.0 + lint v0.18.1, binaries built from those checkouts,
pre-commit AND commit-msg hooks installed with the sibling binary
byte-identical to the v0.18.1 build and the gitlink amendment intact,
24 skills, CI action v0.50.0, gate green). The pack's bare-invocation
"only rules is implemented" message is a STALE STUB: the series lane is
wired and runs on a rev range. On pgs9-9.0.1 it reports 6 flags +
53 warns, verified by hand:

- REAL DEFECT: the palettemap commit (6d601a9a2) defines five
  avpriv_palette_map_* exports and touches no version header; the lavu
  minor bump for them never happened anywhere (the rebase bumped only
  at the quantize/mediancut/elbg commits). The re-cut's palettemap
  commit must carry the bump atomically.
- REAL ARCHITECTURE FINDING: palettegen (02df61ce8) calls
  avpriv_mediancut_* directly and gif (83720ce94) calls
  avpriv_palette_map_* directly: adopters BYPASS the public
  av_quantize_* factory and use the avpriv backend surface. Either the
  adopters go through the public API or the avpriv backend surface is
  deliberate, documented, and version-bumped; feeds the RFC and the
  re-cut assembly.
- RULE REFINEMENT: the version-bump rule should attribute to the
  DEFINITION site only (the paletteuse adopter flags as a false
  attribution: it adds call lines, not definitions).
- FP CLASS: series-provider-before-consumer flags base-provided files
  (libavutil/mem.h, avcodec.h, opt.h, roqvideo.c, framesync.c...) — the
  lane lacks base awareness; ~50 of the 53 warns.
- series-fate-sample flags sub/pgs_sub.sup with no sample provenance —
  disposition needed (samples request or generated sample).

Pack improvement tickets (upstream on host-lint, in priority order):
wire the msg lane over rev ranges (it currently expects a message
file); base-aware provider exemption (files present in the base tree);
definition-site attribution for version-bump; replace the stale usage
stub with real help. Tool development is upstream-first on its main,
then release + re-pin per the reference discipline.

## 2026-08-22: host-lint-ffmpeg v0.19.0 released; the lanes assist the re-cut

The four improvement tickets landed upstream (host-lint main
1f3bae1..ff0516a, tag v0.19.0, submodule re-pinned, hook sibling binary
re-copied, gate green): the series lane is base-aware (the provider rule
exempts files the base tree provides, decided by ls-tree over the
range's start), the version-bump rule attributes to DEFINITION sites
(added lines at column zero; indented call sites no longer flag), the
msg lane accepts a rev range and checks every commit message, and the
bare invocation prints real usage. All 120 pack tests pass; the rebase
onto the tool's moved origin/main was clean. Measured on our series:
53 warns collapse to 5 real findings — the palettemap avpriv-without-
bump flag (real, feeds the re-cut), the fate-sample provenance warn,
and three backport-focus warns that the noise had drowned (commits
citing tickets while carrying formatting changes; actionable in the
re-cut messages). msg over the range: 30 commits, nothing to report.
The tool's release versioning note: origin/main's root Cargo.toml is
aligned with the tag series (0.18.1 -> 0.19.0); the old tag-checkout
showing 0.14.2 was the stale local view, not a second version space.

## 2026-08-22: plan/0021 execution begun; pre-flight done, recut staged

RESUME POINT. The plan doc carries the review fixes (overlap-verify to
the encoder core, mechanics recipes, the -x strip-at-export note, both
deps on the conversion sub-series) and the pre-flight findings
(commit e395e13): configure wiring is NOT a defect (the n9.0.1 base
already ships --enable-libass/--enable-libtesseract; no configure hunks
needed); the Changelog defect is REAL (our version <next>: block sits
inside the version 9.0 block; the final patch moves it to the top);
EXPLICIT_END is real (3 uses); ALL 30 commits carry Signed-off-by +
Co-Authored-By: Claude (preserve both, append GLM per call/0008); the
ELBG-backend commit does NOT touch pgssubenc (the verdict's duplicated-
hunk claim was wrong; nothing to drop). The recut worktree is staged:
~/pgs9-wt/recut, branch pgs9-recut at n9.0.1. NEXT: sub-series one
assembly per the plan (OkLab move -> ELBG move -> quantize+NeuQuant
(internal headers only) -> palettemap avpriv merged with its adopter ->
Median Cut + palettegen adopter (sets the OkLab avpriv disposition too)
-> ELBG backend), cherry-pick -n mechanics per the plan's recipes, the
v0.19.0 lanes as per-commit gates (host-lint-ffmpeg msg/series), build
at each commit, trailers per call/0008. The tasks --record anchor for
pre-flight was not found by the tool (plan-task discovery refused the
anchor; backfill the receipt when the mechanism is understood).

## 2026-08-22: SS1 assembly begun; two items landed, resume map recorded

~/pgs9-wt/recut (pgs9-recut): item 1 (OkLab move) = c36910baf8 clean;
item 2 (ELBG move) = 7317e05af8 with lavu renumbered to 61.2.100 (it is
now the FIRST API-touching commit, so it takes the first minor);
checkpoint cp/ss1-two-items. Both carry the GLM trailer appended per
call/0008; both build under the shared config. GOTCHA that cost a
repair: passing "\$(git log --format=%B)" through the double-shell
quoting pulled a message from the WRONG repo into an amend; all
message-writing now goes through script files only (host-fix-msg.sh
repaired the ELBG commit from the old sha's %B + the -x line + GLM).

VERSION RENUMBER MAP for the remaining SS1 items (the new order shifts
every number; derived, do not re-derive): item 3 (old #13 quantize+NeuQ
f8f47883a7) -> lavu 61.3.100 (its own 61.2 hunk renumbers); item 4 (old
#14+#15 merged, 6d601a9a20 + 7da5895ebf) -> 61.4.100 AND this item ADDS
the missing avpriv palettemap bump + its APIchanges entry (the v0.19.0
lane's real finding); item 5 (old #16+#18 merged, 0bea5f70cc + 02df61ce86)
-> 61.5.100 (old #16's 61.3 hunk renumbers; the merged commit sets the
OkLab family's avpriv disposition); item 6 (old #19 f9f398f1d9) ->
61.6.100 (one more than the old lineage because the palettemap bump is
new). APIchanges entries renumber to match. After item 6: build-walk
the range, msg+series lanes, cp/ss1 checkpoint, ledger.

## 2026-08-22: SS1 four items landed; resume at item five

~/pgs9-wt/recut, checkpoint cp/ss1-four: item 1 OkLab c36910baf8;
item 2 ELBG move 7317e05af2 (lavu 61.2.100); item 3 quantize+NeuQuant
a7eedc4585 (61.3.100, APIchanges entry renumbered); item 4 palettemap
avpriv + paletteuse adopter merged, WITH the missing bump fixed
(61.4.100), message rewritten to name the merge and the fix, 777a953207.
All build under the shared config; all carry the GLM trailer. Lessons
this stretch: a sed renumber that is not STAGED silently misses its
commit (item 3 briefly carried the old number; fixed by --fixup +
--autosquash, shas above are post-squash); the old lineage's context
can drag foreign APIchanges entries through a cherry-pick (the lavc
63.2.100 entry arrived with item 3 and was removed; it returns with the
SS3 encoder item, whose old commit carries it). REMAINING SS1: item 5
(old 0bea5f70cc + 02df61ce86 merged; Median Cut + palettegen adopter;
renumber to 61.5.100; sets the OkLab avpriv disposition), item 6 (old
f9f398f1d9 ELBG backend; 61.6.100). Then: build-walk the range, msg +
series lanes, cp/ss1, ledger. The v0.19.0 lanes are the per-item gates;
MAINTAINERS hunks ride with their commits (the consolidation in the
plan's final item narrows to Changelog + tail bumps; adopted at
execution, record in the plan when closing the milestone).

## 2026-08-23: SUB-SERIES ONE COMPLETE (all gates green)

~/pgs9-wt/recut, branch pgs9-recut, checkpoint cp/ss1-complete. Six
commits: c36910baf8 OkLab move; 7317e05af2 ELBG move (lavu 61.2.100);
a7eedc4585 quantize API + NeuQuant (61.3.100); 016d857168 palettemap
avpriv + paletteuse adopter merged, carrying the previously-missing
version bump (61.4.100); 29e2f614c9 Median Cut + palettegen adopter
merged (61.5.100); b90a35e73b ELBG backend (61.6.100). GATES ALL
GREEN: build-walk six of six under the shared config; msg lane clean
over the range with --signoff; series lane "nothing to report" (the
v0.19.0 base-aware rules); every commit carries Signed-off-by,
Co-Authored-By: Claude where the original did, and the GLM trailer.
The signoff fixes took three passes because two amend-during-rebase
attempts were replayed over; the reliable mechanic (ledgered): mark the
target by todo POSITION (sed 1s/^pick/edit), amend, continue, then
VERIFY with the lane before moving on. lavu ends 61.6.100, one minor
ahead of the old lineage exactly because the palettemap bump is new.
NEXT per plan/0021: sub-series two (GIF RGBA, old 83720ce94c + the ref
hunk from old #24), then the PGS encoder sub-series, then conversion.
The MAINTAINERS-hunks-ride-along decision stands (record at milestone
close). The lavc 63.2.100 APIchanges entry was removed from SS1 and
returns with the SS3 encoder item whose old commit carries it.

## 2026-08-23: SUB-SERIES TWO COMPLETE (all gates green)

Item 7 = 187c861272 (lavc/gif: RGBA input with built-in quantization)
on pgs9-recut, checkpoint cp/ss2-complete: the old GIF commit whole
plus the gifenc-rgba ref hunk lifted from the old wiring commit, so the
ref lands in its final state with the feature it belongs to. Verified:
the committed ref is byte-identical to the old lineage's final ref
(sha 219cb9d6a8e9). Build green; msg lane clean over seven commits
with --signoff; series lane clean. NEXT per plan/0021: sub-series
three (PGS encoder): supenc DTS (old 2bc57a256e; dts test with it);
encoder core + ALL AVOptions + tests merged (old 592efaf419 + 428b6da863
+ 5503aac3f1 + option half of f295cfa198 + 5722ead41c; the lavc
63.2.100 APIchanges entry returns HERE; lavc bumps re-derive: encoder
core is the first lavc API commit -> lavc 63.2.100); palette delta
(old 3b37c1b91b + its tests); forced_style fftools half (old f295cfa198
remainder, no priv_data read).

## 2026-08-23: SS3 item 8 landed (pure supenc); test distribution corrected

Item 8 = 9aa16fa005 (lavf/supenc per-segment DTS), checkpoint
cp/ss3-supenc; lanes clean over eight commits, build green. CORRECTION
TO THE PLAN'S TEST MAP, discovered by execution: the api-pgs-dts test
ENCODES, so every api-pgs test is CONFIG_PGSSUB_ENCODER-gated and none
can exist before the encoder does. ALL the encoder-side tests (dts,
fade, overlap-verify, multi-object, ap-interval, forced, rate-control,
plus pgs-test-util.h from old b92f869fd6) therefore return TOGETHER
with item 9 (encoder core), not distributed to earlier items. NEXT:
item 9, the big merge: old 592efaf419 (encoder) + 428b6da863 (force_all)
+ 5503aac3f1 (max_cdb) + the option-definition half of f295cfa198
(pgssubenc.c + its encoders.texi hunk only) + 5722ead41c
(quantize_method); lavc 63.1.101 -> 63.2.100 with the APIchanges entry
(lavc 63.2.100 codec_desc.h, removed from SS1) re-added; all tests
wired in the same commit; then item 10 (palette delta 3b37c1b91b +
palette-delta/palette-reuse tests) and item 11 (forced_style fftools
half of f295cfa198, no priv_data read). Mechanics notes: old-lineage
mak diffs do not apply onto the new base (hand-place the lines: PROGS
line above the APITESTPROGS aggregation, stanza appended to api.mak);
NEVER pass makefile \$(...) through inline bash -c (command
substitution corrupts the file; the broken-line repair is in
host-fix-makefile.sh).

## 2026-08-23: SS3 item 9 committed; fate-family debugging is the resume task

Item 9 = d84b67052c (lavc/pgssubenc: add HDMV PGS subtitle encoder) —
the merged core (old 592efaf419 + 428b6da863 + 5503aac3f1 +
5722ead41c + the option-definition half of f295cfa198 via extracted
diff + --3way, markers resolved keeping ours), lavc 63.2.100, the
APIchanges entry at the series head, all seven encoder tests + the
util header wired (canonical PROGS line at tests/api/Makefile above
the aggregation; stanzas in tests/fate/api.mak — beware: the item-8
attempts left stale duplicate lines there; the deterministic rewriter
is host-fate4.sh's python). Build green after reconfigure; msg lane
clean over nine commits; series lane shows only the KNOWN fate-sample
warn. UNRESOLVED (resume here): the fate family runs 1/7 —
rate-control PASSES; fade+dts "No rule to make target" (their api.mak
stanzas are missing or malformed — the item-9 stanza-adder's
deduplication check may have skipped them); overlap-verify,
multi-object, ap-interval print "PGS encoder not found" (from
pgs-test-util.h's avcodec_find_encoder, DESPITE LD_LIBRARY_PATH set
and the encoder demonstrably registered — rate-control's identical
lookup works); forced prints "Test A: failed to open encoder".
Suspects to check first: (a) the api.mak stanza inventory vs the seven
names (grep fate-api-pgs tests/fate/api.mak); (b) STALE TEST BINARIES
— make tests/api-clean or touch the sources, the binaries predate the
reconfigure; (c) whether the util header's find is compiled with a
stale TEST define. Checkpoint cp/ss3-encoder. Items 10 (palette delta
+ tests) and 11 (forced_style fftools half) remain after, then SS4.
