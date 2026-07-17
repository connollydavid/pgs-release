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
