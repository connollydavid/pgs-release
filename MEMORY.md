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
