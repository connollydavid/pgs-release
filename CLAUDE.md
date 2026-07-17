# CLAUDE.md: operating manual for an agentic project

This file tells you, the agent, how to work in this repository. Follow it
exactly. The rules are written to be literal: when one says "do X", do X. Do
not look for a cleverer path. When something is unclear or could mean two
things, stop and ask the human before you act. Clarity beats cleverness here.

## What this repository is

This repository is an **agentic project** (e.g. `agentic-acme`). It is the
externalized *thought* about a piece of software: the plans, the decisions, the
specifications, the people it serves, and the rules you work under. The software
itself (the *action*) lives beneath the project as a bare store with worktrees
(the *Where* room). You write thought in the project and action in
the worktree. Keep them separate.

You are working in a *template*. A real project replaces the example personas
with its own and adds its software as the hosted bare store with worktrees. The
structure below stays the same.

## The five rooms

The host has five rooms, one for each question you ask about any piece of work.
Put each kind of file in its room. Do not invent new top-level folders.

| Question | Room | What goes here |
|----------|------|----------------|
| Who  | `cast/` | personas: the people (human or agent) the software serves |
| What | `<software>/` (with the code) | specifications: behaviour (`.allium`), timing (`.tla`), verified in the software's own CI |
| When | `plan/` | the milestone index and one folder per milestone |
| Where | `<software>/` | the hosted software, a bare store with worktrees; you add it |
| Why  | `call/` | decisions, in MADR format (see `call/0000`) |
| How  | `CLAUDE.md` + `tools/` | this manual, and the verification tools |

`STRUCTURE.md` is the short map of the same thing. Read it once.

## How you work: four principles

These four principles govern every change. They exist because language models
make predictable mistakes; each principle blocks one.

### 1. Think before coding

- State your assumptions in plain text before you write code.
- If the request could mean more than one thing, list the meanings and ask which
  one. Do not pick one silently.
- If a simpler approach exists than the one you first reached for, say so.
- If any part of the request is unclear, stop and name the unclear thing. Ask.
  Do not guess.

The goal: the human never reads your output and says "that is not what I meant."

### 2. Keep it simple

- Write the least code that solves the stated problem. Nothing speculative.
- Do not add features that were not asked for.
- Do not add an abstraction (a base class, an interface, a wrapper) for
  something used in exactly one place. Write the concrete thing.
- Do not add configuration for a value that has exactly one setting. Hardcode it.
- Do not handle errors that cannot happen given the current inputs.
- If your code is long and the same result fits in a fraction of the lines,
  rewrite it short before you show it.

### 3. Make surgical changes

- Touch only the lines the request needs. Clean up only the mess you made.
- Do not "improve" nearby code, comments, names, or whitespace that the request
  did not ask about.
- Do not refactor working code that is not part of the request.
- Match the existing style exactly: tabs or spaces, snake_case or camelCase,
  whatever the file already uses.
- If your change leaves an import or variable unused, remove it in the same
  commit. If you spot unrelated dead code or a bug, mention it to the human; do
  not silently fix or delete it.

Check: every line you changed must trace to the request. If a line does not,
revert it.

### 4. Drive to a verifiable goal

Turn every task into a goal you can check, then loop until the check passes.

- "Add validation" becomes: write tests for the invalid inputs, then write code
  until those tests pass.
- "Fix the bug" becomes: write a test that reproduces the bug, then change code
  until that test passes.
- "Refactor X" becomes: confirm the tests pass, refactor, confirm they still pass.

For any task with more than one step, write a short numbered plan first, and give
each step a check:

```
<what you will do> -> verify by: <how you will confirm it worked>
```

If the success check is weak ("make it work"), ask the human to make it concrete
before you start.

## Names, numbers, and milestones

Numbers are identity. Slugs are content. Ordering lives in the index, never in
the name.

- A milestone is a folder in `plan/` named `NNNN-slug`: a four-digit
  zero-padded number, a hyphen, then a lowercase hyphenated slug, for example
  `0001-example-milestone`. Decisions in `call/` use the same `NNNN-slug` form.
- Name a milestone after its content rather than its position. `0003-ci-pipeline` is
  good. Do **not** name things by ordinal position (`phase-one`, `M2`) or by a
  bare numeral (a header that is just "3" or "5.5"). Positions move when a plan
  is re-cut; content names stay attached to their content.
- The number is assigned when the work is accepted, and it never changes. To
  read sequence, read the index, not the filenames.
- `tools/host-lifecycle` allocates these numbers and checks the names for you.
  Use it (see below) instead of numbering by hand.

## Decisions: `call/`

When you make a choice that someone later will ask "why?", record it as a
decision in `call/`, in MADR (Markdown Any Decision Record) format. The bootstrap
decision `call/0000` explains the format and links to the MADR spec. One file per
decision, `NNNN-slug.md`, number assigned when the decision is accepted.

`call/` records decisions about **the software under development**, why your
software is built as it is. It does **not** hold methodology decisions. The
methodology is settled in this spine (`CLAUDE.md` + `STRUCTURE.md`), inherited by
copy-at-version; a change to it is made in the template and propagated by
`host-lifecycle upgrade`, never re-litigated as a project `call/`.

**Anti-ouroboros.** A project must avoid feeding on its own methodological tail. If a
`call/` decision restates a methodology rule that is then settled or changed
upstream in the spine, retire it the MADR way: set `Status: superseded by the
spine` in place (records are immutable: you change status, never delete). The
live (`accepted`) Why room then holds only decisions still in force.
`host-lifecycle validate` fails an `accepted` decision that is missing a `Scope:`
header or declares `Scope: methodology`. The template ships `call/0000` only as a
worked example; replace it with your software's own decisions.

**Inherit from the source, not from a host.** You inherit the methodology from
*this template* (the versioned source you copy-at-version) alone. A host or
management repo's **top-level instance contents** (its `call/`, `plan/`,
`MEMORY.md`, the project-specific parts of its `CLAUDE.md`) are that project's own
rooms and bind no adopter. Do not read them as normative.

## Specs, with the software they constrain

A spec states what the software must do; a tool turns it into a check. Specs live
**with the software they describe** (in the software repo, beside the code, and
verified by **that repo's CI**), the way tests live next to code, so a spec and the
code it constrains move, version, and break together:

- Behaviour and requirements as `.allium` files, authored and maintained through
  the allium skills (`elicit`/`distill`/`tend`/`weed`/`propagate`), checked by
  `tools/allium` (`allium check` validates structure; `allium analyse` adds
  data-flow, reachability, terminal-state and deadlock analysis; `allium plan`
  derives the test obligations the suite must discharge). The software's CI runs
  `check` + `analyse` + `plan` and fails on any error or warning.
- Timing and concurrency as `.tla` files, checked by `tools/specula` (TLA+/TLC),
  run by the software's CI.

A present spec carries its full lane (see "Mandatory when used", below). Wire the
tool and its skills before authoring.

The host's `plan/<milestone>/` *references* a spec (by path and the software pin);
it does not contain it. Do not place specs in the host's `plan/` tree. Quarantining
a spec from its software is a bad smell (the spec drifts from the code). A spec that
ended up under `plan/*/spec/` is relocated into the software repo.

## Personas: `cast/`

`cast/` holds the personas: short profiles of the people the software serves. A
persona is a hypothetical archetypal user, not a real individual. The examples
here (`mara.md`, a human operator, and `wren.md`, an agentic LLM) show the two
modalities; replace them with your project's own.

Build at least one persona by discussion with the human before planning the work
it serves. `cast/applying-personas.md` gives the cited process for doing this.
Follow it.

## The verification ladder

Different kinds of property need different checkers, and different *strengths* of
checker. Route each claim to the lane, and to the rung, that can prove it. The base
lanes:

1. **Hygiene**: `tools/host-lint`. Catches naming tells: ordinal labels and bare
   numerals leaking into commit messages, headers, and comments. Runs as a git
   hook. **Self-referential software is excluded, not bypassed.** Software that
   *detects* tells (a linter, parser, validator, grammar tool) must embed them in
   test fixtures, docs, and sometimes source, legitimate self-reference the hook
   would otherwise flag. Exclude that corpus through the tool's ignore mechanism
   (`.host-lintignore`), which the per-file hook scan MUST honor; validate each
   excluded file line-by-line so no real tell hides among the examples, and keep
   ordinary source scanned (reword an example comment rather than mute the file).
   When a tracked *document* must instead reproduce a tell **verbatim** (an old-name
   remap table, or a frozen dated review citing another document's numbered steps),
   it is **boxed in the file, not path-excluded**: wrap it in a fenced code block
   tagged `host-lint:ignore` (markdown only), and the naming scan skips that block
   while the rest of the file stays linted. A regular code block and inline
   backticks stay scanned, so a tell cannot be laundered by quoting it. The choice is
   three-way: reword a pedagogical example or a document's own ordinal label into
   content; box an irreducible literal citation; and path-exclude only the immutable
   record (the append-only memory log, dated review artifacts) and the
   self-referential corpus above.
   **Never `--no-verify` past the gate to land a fixture.** That silently defeats
   the lane, the same "let red hide" failure as a CI matrix that fail-fast-cancels
   its own jobs. (A fix to either, once found, is a behaviour change: ship it as a
   patch release with a matching tag.) **Legitimate tell-shaped tokens are
   declared, not silenced.** A version string, product name, or cited tracker
   reference that merely *looks* like a tell is declared in a provenance-checked
   allowlist (host-lint's `LEXICON`): each entry the full contextual phrase, masked
   before detection; a tracker reference carries its backing URL. Because a sound,
   declarable escape then exists, the identifier/reference tier MAY escalate an
   advisory warn into a blocking flag (the committed `strict` directive), so an
   *un*declared tell-shaped token becomes a hard signal. The allowlist is provenance,
   not a mute button: the tool refuses a bare master key, a phrase that is *itself* a
   tell (rename it, do not declare it), and an un-cited tracker reference (`#N`,
   `owner/repo#N`, or an opted-in `PROJ-NNNN` key); URL liveness is re-derived by a
   network-having lane, never the offline hook.

   **Prose hygiene is the same lane, applied continuously.** Beyond naming tells,
   `host-lint --prose` audits authored docs for the LLM-slop prose tropes that
   tropes.fyi names (decoration dashes and arrows, tricolons, hypophora, and so on).
   The bar matches the naming audit: authored docs carry **zero** prose tropes, as an
   **ongoing** rule, not a one-time migration. It is wired into the **receipts
   mechanism**: the `verify` phase **applies** the prose audit and **generates** a
   receipt, and `software --check` re-verifies that receipt by re-running the prose
   audit (`host-lifecycle prose`, host-lint's `--docs` engine run in-process, so the
   gate needs no host-lint on PATH), so a doc that regresses to slop re-opens it as a
   HAZARD. The one exception
   is `MEMORY.md`, the **agent's own append-only working memory**: it is excluded from
   both the naming and prose audits via `.host-lintignore`, never rewritten.

   **The methodology grows by reflective practice, because an agent is blind to its own
   drift.** An agent perceives neither the register it emits nor the restatements its own
   change stales, so both are re-examined on purpose, **prompted** at the trust
   boundaries (the verify gate, adoption), **mechanical-first**, and **operator-validated**.
   Two arms run under this one principle. The first, **gather**, looks forward and grows
   the living grammar: the lane enforces a shared corpus of tells, and that corpus is
   incomplete by nature, so new tell-shapes that emerge in practice are swept up rather
   than waited for. Discovery is **mechanical-first**: sweep the history and recent work
   for a recurring shape the lane does not catch. An agent seldom perceives its own
   register as a tell, so this reflection is **prompted**, at the verify gate before a
   milestone closes and at adoption, and the agent assists rather than leads. **The
   operator validates** whether a surfaced shape is a genuine tell or legitimate domain
   vocabulary, by one test: is the shape a property of how models segment work, or of
   this project's own domain? Authority over a grammar change rests with the operator;
   an agent proposes a change and never approves one.

   **A confirmed tell graduates into the shared grammar; legitimacy stays local.** The
   two run in opposite directions because a tell is a property of machine register that
   recurs across projects, while a legitimate token (a version string, a product
   identifier, a cited tracker reference) belongs to one project. So a confirmed tell is
   **proposed upstream** to the shared grammar the lane consumes, where every project
   gains it on the next bump; the project that finds it does not edit that shared source
   itself. A legitimate tell-shaped token stays in the per-project `LEXICON`. The host's
   own maintainer validates universality and releases the graduation.

   **Growth never inverts the disposition order, and it looks forward.** Reword a
   positional or ordinal reference into content by default, since a content name is
   almost always available; box or declare an irreducible citation; declare the
   numeral-free contextual prefix when a shape is a genuine quantity; and reserve a
   graduation for the residue that still recurs once rewording is impossible. Harvesting
   at adoption proposes what to catch from then on, and leaves the immutable past alone,
   which migration disposes of by renaming live files and boxing frozen records. When a
   later grammar bump flags an existing **live** doc, reword it; a **frozen** record is
   boxed. A graduation that proves to over-flag is narrowed by a later grammar release,
   the same as any behaviour fix.

   **The second arm, reconcile, looks backward at the project's own restatements.**
   Copy-at-version keeps the verbatim spine current, but a project also *restates*
   methodology in its own prose: its room map, its components, its verifiers, its
   recorded layout. When a spine change moves a concept, that restatement silently
   drifts, because the upgrade propagates the spine yet never re-reads the paraphrase.
   **Prefer pointing over paraphrasing**: define each methodology concept once, at a
   stable `{#id}` anchor on a heading in an authored doc (its home), and *point* at it from elsewhere
   with a `[text](FILE#id)` link rather than restating it. For example, a home is the
   heading `## Components {#components}` (the `{#id}` sits at the end of the heading) and a
   pointer is `[components](STRUCTURE.md#components)`. The concepts are `components`,
   `verifiers`, `software-root`, and `spec-home`. The first two are project-local, read from
   its `.host-software`: the `[software]` members are the `components` (a project *with* a
   single-file entrance sets it apart with an `[entrance]` stanza naming that member; most have none), and the
   `[verification]` drivers are the `verifiers`. The last two are the fixed layout:
   `software-root` is where the project's software lives (`software/`) and `spec-home` is
   where its specs live, with the software. The lifecycle manifest is phases only, so no adopter
   inherits another project's facts; `manifest --check` rejects a project-fact stanza.
   `host-lifecycle reconcile` runs three checks over the tracked docs, operable at the
   weak-agent bar: **link-integrity** (every concept link resolves to its home),
   **declared-anchor** (the link names a real concept), and **coverage** (each
   project-local home names its full `.host-software` set, so a dropped tool fails by
   absence, the bite). Coverage guards the home and a pointer cannot drift; an enumeration
   left un-pointed is the author's choice and is not guarded. The earlier inline
   `<!-- host-reconcile: KIND -->` annotation is
   **deprecated**: it is kept checking during the transition and a surviving annotation is
   warned, and the form retires a spine revision later, never silently inert.
   **The trigger is conditional and host-aware.** **Adoption** runs the full reconcile
   once; for a **development host** that authors its spine changes, the **verify gate** is
   the binding trigger: `software --check` runs reconcile in its recheck. **Disposition is
   three-way**, as for a flagged tell: convert a live restatement to a pointer, box a
   frozen citation, forward-correct an immutable record (a `call/` body, a `Status: done`
   doc, `MEMORY.md`). A reconcile fix stays **local** and never propagates, the mirror of a
   gathered tell graduating **upstream**. A sibling check closes decision-status drift:
   `host-lifecycle validate` HAZARDs an `accepted` `call/` decision whose `Scope:` names
   `host-template`, since its rule is now spine-resident and belongs superseded there.
   **The entrance check is reconcile's standalone sibling.** A document read out of context
   cannot point at a definition, so a single-file entry restates the spine and stales, whether
   a front-door README or a standalone `SKILL.md` loaded on its own. The entrance check holds
   such a document by coverage and generation, the way reconcile holds a linkable one by
   pointers. A project declares one entrance, a global singleton, in an `[entrance]` stanza in
   `.host-software`: the `member` it belongs to (set apart from `components`), the `document`
   within that member (default `README.md`, so a `SKILL.md` or a landing page is reached by
   path), and the concepts it `restates` (`true` for every concept, or a named subset).
   `host-lifecycle entrance --check` then holds the document complete against the declared
   concepts: it generates the `.host` stamp and covers the rest. A document that restates only
   home-less doctrine declares no checkable concept, and the tool says so rather than claim a
   coverage it cannot deliver.
   The legacy per-member marker is retired: a surviving `front-door = true` or `entrance =
   true` on a `[software]` member is a loud error, not the entrance, so declare the stanza.
2. **Requirements**: `tools/allium` (MIT, by JUXT). Does the software meet the
   behaviour the spec states? Author and maintain `.allium` specs **through the
   allium skills**, not by hand: `elicit`/`distill` to author, `tend` to evolve,
   `weed` to find spec↔code divergence, `propagate` to generate the tests. Gate
   each spec in the software's CI with `allium check` (structure) + `allium
   analyse` (data flow, reachability, terminal states, deadlock) + `allium plan`
   (test obligations).
3. **Timing and concurrency**: `tools/specula` (Apache-2.0). TLA+ model
   checking: are the orderings and timings correct? Model-check each `.tla` with
   TLC in the software's CI.

**Deeper rungs, `tools/host-prove`** (our tooling, Unlicense). The base lanes are
*bounded*: TLC checks one finite instance, allium's tests sample inputs. When a claim
must hold for *all* parameter values or *all* inputs, host-prove drives three heavier
verifiers as agentic skills, each turning the tool's output into one machine-readable
verdict so the rung runs down to a small model:

4. **Symbolic / parametric**: **Apalache** (TLA+ to SMT/Z3; the `apalache-symbolic`
   skill). Proves a `.tla` invariant across a whole symbolic parameter family at once,
   where TLC can only enumerate one instance.
5. **Proof / unbounded**: **TLAPS** (`tlapm`; the `tlaps-proof` skill). A deductive,
   machine-checked proof that a property holds for all states, the must-hold-for-all
   claims bounded and symbolic checking cannot close. (Authoring a proof needs a strong
   model; the skill scopes a weak model to running and maintaining existing proofs.)
6. **Code-conformance**: verify the *implementation* against the spec, beyond tests
   and trace validation. This rung is **target-specific**: Rust uses **Kani** (the
   `kani-conformance` skill), C uses CBMC, and so on. The methodology prescribes the
   *obligation*; the project picks the verifier its language supports. (Prefer
   byte/char-level targets: `str::split`/`Vec` make CBMC-style checkers blow up.)

Read the ladder as: hygiene, then requirements, then bounded timing (TLC), then symbolic
(Apalache), then proof (TLAPS), with code-conformance (Kani et al.) the orthogonal rung
that ties a proven spec to the running code. The deeper rungs are **opt-in and inert**
(see below): nothing installs or runs until a project declares one.

**Mandatory when used (RFC-2119).** Adopting a lane is optional (not every
project needs TLA+); **once a spec of a kind exists, its tool, skills, and CI
lane are required.** A component carrying any `.allium` spec MUST wire `tools/allium`
and its skills and run `check` + `analyse` + `plan` in that repo's CI, and the
`plan` obligations MUST be discharged by the software's tests. A component carrying
any `.tla` spec MUST wire `tools/specula` and TLC-check it in that repo's CI. A spec
present without its full lane is a **defect**, not a choice. The lanes are not
reference decoration. The tools are referenced submodules; their skills are
generated, gitignored symlinks (`link-skills.sh`), wired before you author a spec.
This is **enforced**, not only stated: `host-lifecycle software --check` raises a
HAZARD when a materialized component carries a `.allium` with no `allium check` +
`allium analyse` CI workflow, or a `.tla` with no TLC lane.

The deeper rungs work the same way, one level up: they are **opt-in and inert until a
project declares a rung** by dispositioning an obligation `kani:`/`apalache:`/`tlaps:`
(below). A declaration then obliges that rung's CI lane and a re-deriver that runs.
`software --check` HAZARDs an obligation that declares `kani:` with no `cargo kani` lane,
`apalache:` with no `apalache-mc` lane, or `tlaps:` with no `tlapm` lane, and it HAZARDs a
declared rung whose shared re-deriver, host-prove, does not run, since a re-derivation that
cannot run leaves the rung undischarged however complete the CI config reads. So install the
re-deriver where the gate runs, the same way the verifier itself is installed. The digest a
rung records is **earned** through `obligations --rederive --record-digests`, which re-runs the
proof and records only on a pass, in place of a hand edit, so a fresh digest stands for a
passing re-derivation on the current inputs. The mere presence of a `.tla` or a crate never
activates a rung; only the declaration does, so a project pays for a heavier verifier exactly
when, and only when, it chooses to.

**Obligations are discharged, not just emitted.** `allium plan` derives a test
obligation for every config default, entity, enum, invariant, rule and transition.
Each obligation MUST be **dispositioned** in a sibling `<spec>.obligations` manifest
(the remap-dictionary discipline applied to tests) as `test:<name>` (a named test
discharges it), `structural` (the spec's own `check`/`analyse` lane covers it),
`waived: <reason>` (an honest, recorded gap), or a deeper-rung proof: `kani:<harness>`,
`apalache:<inv>`, or `tlaps:<theorem>` (a host-prove rung discharges it, stronger than
a test, for all inputs/parameters). `host-lifecycle obligations <spec> --tests <dir>
[--prove <dir>]` fails on any undispositioned obligation, any stale disposition, any
`test:<name>` absent from the test sources, and any rung proof name absent from the
`--prove` sources; the software's CI runs it, and `software --check` HAZARDs a
`.allium` that has no `.obligations` manifest. An
obligation left undispositioned is a defect. Discharge is total, per component.

**A verification lane reports clean only after it performs its check (no-hollow-green,
`call/0035`).** A `test:` disposition is name-presence until it carries an `exercises=<symbol>`
link to a function the discharging test drives. `host-lifecycle obligations --strict-discharge`
then HAZARDs a `test:` whose named test does not reference that symbol, an `#[ignore]`'d
discharging test, a behavioural obligation relabelled `structural`, or a `waived:` lacking a
reason. The link is an auditable heuristic, weaker than a proof: the claim that a test truly
drives the rule is the opt-in re-derivation below, and what the tool cannot mechanically
establish is labelled *attested* rather than asserted as proved. The strict check is staged
warn-then-retire, so bumping the tool never reddens a green ladder. The build lane obeys the
same rule: `software --verify-build` prints its clean line only when a build was verified and
none was left unrun, and it exits non-zero on an in-scope build it could not rebuild, so it
never attests a guarantee it did not establish.

**A rung is discharged by re-derivation, not by name-presence (`call/0018`).** That a
proof *exists* is not that it *passes*. `--prove` only lints that the rung's named
target is present (AVAILABLE ≠ DISCHARGED). The real discharge is
`host-lifecycle obligations <spec> --rederive <dir>`, which re-runs each rung's verifier
through host-prove **in its recorded pinned toolchain** and requires a PASS at the
declared `bound=`, checkable anywhere, with no keys and no dependence on a specific CI;
it generalizes the reproducible-build re-derivation (which reproduces a recorded artifact
hash) so the same re-derivation applies to proofs as well as artifacts. The cheap offline signal is **input-digest staleness**: a
rung may declare `inputs=<files>`, `--rederive --record-digests` fingerprints them with
`git hash-object` into a committed `<manifest>.digests` ledger, and a later offline run
reports the proof **STALE** if those inputs drifted without a fresh re-derivation.
Enforcement is **project-pluggable**: a required check, any CI, a pre-push hook, or the
operator running the verify phase; the methodology prescribes the re-derivation and ships
the re-deriver, and never bakes in a CI.

Two rules govern the tools:

- **Reference, don't vendor.** Each tool is a git submodule pinned to a commit.
  Keep its code out of this repository. This governs an **adopter** consuming
  the tools. A **development host** that *authors* a host-* tool is the exception:
  it develops that tool as a Where-room software component of its own (materialized
  and released through the lifecycle like any software it builds) and consumes the
  built result (binary + worktree-sourced skills) from that worktree, rather than
  referencing its own source as a foreign submodule. Reference is for the consumer;
  the producer of a tool embeds it.

  Almost every project references the host-* tools and releases none of its
  own, and for such a project this release-side complement of the carve-out is
  a no-op, so a first read stops here. The rule binds only where two facts
  about your own repository both hold: your repository releases a host-* tool
  of its own, and it carries host-template as a submodule whose pins include
  that tool. If the first is false, as it is for a project that only consumes
  the tools, the rule does not apply and you change nothing, with no template
  pin to look for. Where both hold, the producer carries that tool's pin twice,
  once in its own Where room and again inside the vendored template, so a
  release is unfinished until every carried-template pin surface for that tool
  is bumped to the released commit, and `host-lifecycle software --check`
  HAZARDs any carried-template pin left behind.
  The producer re-pins the carried template when it releases the tool, just as
  it embeds the tool when it develops it.
- **Instruct, don't patch.** Drive the tools through this manual and their own
  interfaces. Do not edit a tool's source to make it fit. If a tool needs a
  change, raise it upstream.

The *output* a tool produces about your project (a report, a counterexample, a
generated check) belongs to your project, not to the tool's license, the same
way a compiler's license does not cover the program it compiles.

## The host-* tools

Three of the tools are ours, released into the public domain (Unlicense):

- **host-grammar**: the shared rules for valid names and numbers. A library, not
  a command. Both tools below depend on it.
- **host-lint**: the *checker*. It reads text and flags naming tells.
- **host-lifecycle**: the *generator*. It allocates numbers and scaffolds
  milestones, decisions, and personas without spending model tokens on
  mechanical work. Run `host-lifecycle next <dir>` for the next number and
  `host-lifecycle validate <dir>` to check a folder. It also materialises and
  audits the *Where* room: `host-lifecycle software --materialize|--check <dir>`
  realises the `.host-software` bare store + worktrees and verifies each is at its
  pin.

Because the generator and the checker share `host-grammar`, what host-lifecycle
emits is exactly what host-lint accepts. Trust that symmetry; do not number by
hand.

### The lifecycle phases, every phase emits a receipt

host-lifecycle ships one Claude **skill per lifecycle phase**, generated into
`.claude/skills/` by `link-skills.sh` exactly as the allium/specula skills are:
**classify** (preview + case), **adopt** (governance + rooms + stamp), **embed**
(the software as a bare store with worktrees), **remap** (the dictionary rename),
**verify** (the gate sweep: `validate`, `software --check`, `obligations`,
`book --check`), **publish** (the doc site), **upgrade** (the ledger), and
**release** (the strict, tool-carried release: verify, build in the recorded
toolchain, re-derive the artifact hash, re-pin, tag, receipt). Each owns the
judgment around its mechanical command.

The phases (their order, modality, command, and the evidence each carries) are
not re-typed in prose; they live once in the tool-readable **`lifecycle.manifest`**
(one `[phase "<name>"]` stanza each), which `host-lifecycle` reads at the project's
adopted `.host` revision for `--next`, the `book` order, and the receipt gate. Read
the whole lifecycle at a glance with `host-lifecycle manifest <path>`.

Unlike a verification lane, which is conditional on a spec existing, the lifecycle
is **driven by the tool, never hand-operated**, and the rule is **every phase
emits a receipt**, not "every phase runs". Modality is first-class: a phase may be
**conditional** (embed and release apply only with a Where room) or **recurring**
(once per software component), so it can legitimately not run; even then it records
a **receipt** written by the tool, in `.host-receipts` for a methodology-version phase
(adopt, upgrade) and `.host-lifecycle-receipts` for an operational one: `done` with re-derivable
evidence, `skip` with a cited reason, or tool-computed `n-a`. `host-lifecycle
software --check` re-verifies each `done` by the manifest's closed `recheck =` and
**HAZARDs a phase with no receipt**, the one defect the gate needs; a protected
core (`verify`, `skippable = false`) refuses a skip outright. Operating a phase
ad-hoc (hand-scaffolding rooms, hand-renaming files, hand-rolling the site or a
release) leaves no receipt, and so is a defect by construction.

### Never adopt a software repository in place

A host is a *separate meta-repo*; the software it governs lives beneath it as the
*Where* room (a bare store with worktrees recorded in `.host-software`). The two
stay separable and independently versioned. That is the whole point of "keep
them separate". So at **first adoption** (no `.host` stamp yet), if the target
directory is itself a software repository (it carries a root build manifest
(`Cargo.toml`, `package.json`, `go.mod`, `pyproject.toml`, …) and is not already
managing software via `.host-software`), you **MUST** refuse to continue.
`host-lifecycle classify <dir>` enforces this: it prints the refusal and exits
non-zero instead of a case letter, rather than letting you turn the code repo
into the host.

Refusing is not the end of the task. Embed the software the right way instead:
create or choose an empty host repository (e.g. `agentic-<name>`), `adopt` it
there, then add the software as the Where room with a `[software "<name>"]`
stanza in the host's `.host-software` (the repo's URL, a pinned SHA, the worktree
set) and `software --materialize`. The classify refusal prints these exact steps.

### Onboarding a project: init, adopt, and the two shims

Starting a project is one engine with two purpose-named faces. `host-lifecycle init
<name>` creates a fresh `agentic-<name>` in a new folder. `host-lifecycle adopt`
brings a folder under the methodology by one of three routes: a software repository
is refused in place (above), an empty `agentic-<name>` folder is adopted in place,
and any other folder is arbitrary, so the tool elicits a name, creates the host at
`../agentic-<name>`, and leaves the source folder untouched. `host-init` and
`host-adopt` are the same binary under those two names, the human-facing commands over
the `init` and `adopt` verbs.

Three invariants hold across the onboarding surface. The **source is read-only** on
the arbitrary-folder route: the new host lands elsewhere, and the source, even a home
directory, is never written. A **present, non-empty target refuses** rather than
overwrite, unless forced. The **name is the one field elicited**, because it carries
operator intent a folder cannot supply: the verb accepts it by flag or the `HOST_NAME`
environment variable, else prompts on a controlling terminal, else exits with a
distinct code and a machine-parseable line naming the missing field, so a scripted or
agent caller re-invokes with the name supplied. Never invent the name.

The scaffold-and-stamp primitive is `host-lifecycle scaffold <dir> <revision>`, the
adopt phase's command, which `adopt` and `init` build on. A spawned MCP surface
(`host-lifecycle mcp`) exposes `init` and `adopt` as tools over stdio, eliciting the
name through the client when it declares the capability and falling back to the verb's
backstop otherwise; the MCP tools are an enhancement, never mandatory.

## Audited plans and append-only memory

Two disciplines keep the host trustworthy across sessions.

- **Audited plans.** Every change to `plan/` (the milestone index or any
  milestone document) and every decision in `call/` is committed and pushed
  immediately, in its own commit, not batched with code. After you finish a step
  in the software, update the plan to say what you actually did, in a separate
  commit.
- **Append-only memory.** `MEMORY.md` is a running log of decisions, discovered
  constraints, and lessons. Add a short entry whenever you finish something
  significant, hit a non-obvious bug, or find an unexpected constraint, as you
  go, not at the end. Commit it on its own and push it. Never rewrite or delete an
  old entry; if one was wrong, add a new entry that corrects it and points back.

The test for both: a new session with no memory of this conversation should be
able to read `plan/`, `call/`, and `MEMORY.md` and continue without repeating a
past mistake.

## The task graph: in-plan tasks are receipted nodes

A milestone's `## Build sequence` is not loose prose. Each step is a **task**: an
anchored `### ` heading under that section, ending in `{#anchor}` (the placement
stock mdBook honors), for example `### Gather the data {#gather-data}`. Its
identity is global, `plan/NNNN#anchor`, so a receipt and a dependency hang on a
stable anchor, never a position that renumbers when a plan is re-cut. An anchored
`### ` heading belongs only under `## Build sequence`, and a build-sequence `### `
without an anchor is refused, so a task is never confused with an ordinary
subsection.

A few bullets under each task heading carry its fields:

```
## Build sequence

### Gather the data {#gather-data}

- verify: cargo test gather
- inputs: src/gather.rs

### Ship it {#ship-it}

- depends: #gather-data
- verify: attested call/0007
```

- **`depends`** names the prerequisites: a local `#anchor`, or a cross-milestone
  `plan/NNNN#anchor`. A task with no `depends` takes the previous task in the
  section (the linear default), and the first task is a root. The project's tasks
  form **one graph** across milestones, and `host-lifecycle tasks` derives the
  **ready frontier** (the tasks whose prerequisites all carry a done receipt),
  which a coordinator may run in parallel.
- **`verify`** is a command the gate re-runs (mechanical), or `attested <call/NNNN
  | operator>` (a decision the gate resolves, or an operator confirmation).
- **`inputs`** names the files a mechanical verify covers, fingerprinted so the
  gate flags a done as stale once they drift (`call/0018`'s input-digest
  staleness, one level down).

**Declare prerequisites; the tool derives parallelism.** State for each task only
what must finish before it. The needs-question is local and conservative, and a
missing edge merely over-serializes (safe), while a guessed "independent" edge
races two workers (a corruption), so the author never answers "what can run at
once?" A coordinator fans a frontier out to parallel workers **only when they are
resource-isolated** (separate worktrees), since `depends` orders work, it does not
lock a shared resource.

**Group a long sequence with a band, never an ordinal.** To divide a build
sequence into named groups, mark a `### ` heading with a single `- band` bullet:
it is a **band**, a content-named divider over the tasks that follow, not a task
node. A band carries no receipt or edge and does not reset the linear default, so
task-to-task chaining runs straight across it, and ordering stays in the `depends`
edges rather than in a band's name or position. Give a band a content name and its
own `{#anchor}`, so it reads as a referenceable divider in the book. Never name a
group by ordinal position (a work-unit noun ahead of an ordinal); that is the
position-naming the milestone-naming rule forbids, and the naming gate blocks it
in both its numeric and its spelled forms.

**Every task emits a receipt, and the gate is mandatory.** `host-lifecycle tasks
--record` writes a receipt into `.host-task-receipts` (it reads the task's own
`verify`/`inputs`, so you never re-type them), a tool-written ledger you never
hand-edit. `software --check` HAZARDs a task with no receipt, a `done` whose
mechanical inputs drifted or whose citation does not resolve, a `skip` without a
resolvable `call/NNNN`, and an orphan receipt whose task was renamed or removed. A
`done` is re-derivable, never self-asserted: the cheap gate checks the input
digest, and `tasks --rederive` re-runs the command and refreshes it. These task
receipts are a third receipt kind beside the methodology-version and operational
ledgers.

## Software and submodule discipline

The **tools** are submodules; the **software** is a bare store with worktrees.
Both follow a commit-upstream-first rule:

- **A tool submodule:** commit and push inside it (on `main`) first, then commit
  the updated submodule pointer in the host and push.
- **The software:** commit and push inside the canonical worktree first, then
  record the new SHA as the `.host-software` `pin` and push that host commit. The
  recorded pin is the audit anchor a gitlink used to be.

Never push a host commit whose tool pointer or software pin is not yet pushed. If
a push fails (no network, no auth), stop, tell the human which commits are
unpushed, and do not start work that depends on them.

**Tag every release.** A version bump (a change to the `version` in a tool's or
the software's manifest (`Cargo.toml`, …)) **MUST** be accompanied by a matching
annotated git tag `vX.Y.Z` at the release commit, pushed alongside it (`git tag -a
vX.Y.Z -m "<name> vX.Y.Z" && git push origin vX.Y.Z`). The tag **is** the release:
a tag-triggered CI job builds the artifacts from it (e.g. a `v*` release workflow).
An untagged version bump is an unreleased version, a defect; back-fill the tag at
its bump commit. Do not re-pin `.host-software` (or a tool pointer) to a
version-bumped commit that carries no matching tag.

**Worktree-absence coherence.** A separately-materialized path (the
software worktree, or a tool submodule) is absent (or empty) until materialized; a
fresh clone, CI, and a partial submodule init do not have it. So **do not git-track
an artifact that depends on such a path existing** (a skill symlink into
`<software>/` *or* into `tools/<tool>/skills/`): gitignore it and **generate** it
after materialization: `link-skills.sh` produces `.claude/skills/*` for the tools
present, and the software's links are recreated after `software --materialize`.
Where an automated context genuinely needs the path, it materializes first;
otherwise it must tolerate the absence. `host-lifecycle software --check` flags any
tracked symlink whose target is not itself tracked here as a `HAZARD`. And: an
un-materialized CI job must exercise each runtime-critical artifact. "done" means
the whole CI sweep is green, not one artifact built.

**Worktrees live under `software/`.** Every materialized Where-room worktree
**MUST** surface at `software/<name>/<branch>/` *under* the host root, never a bare
external path disjoint from the tree. The rule an agent relies on is: *if you build it, its
files live under the host root*, so an edit through the default-cwd path lands in
the tree under test. When a backing store genuinely must live elsewhere (another
filesystem or platform (e.g. a native-Windows build that cannot sit on a WSL
share)), record it on the parallel-worktree line as `store=<path>` (and optionally
`host=<os>`, the OS that **materializes** the store, i.e. where you run
`host-lifecycle`, *not* the build platform; for a Windows Dev Drive reached from WSL
that is `linux`, even though the build's own `attest-host` is `windows`). Off-platform,
`host=` makes `--materialize`/`--check` skip the line rather than fail.
`software --materialize` then realises the store at that path and the in-tree
`software/<name>/<branch>/` as a **symlink / directory junction / bind-mount** to it. `host-lifecycle software --check` **HAZARDs** any recorded worktree path that
escapes the host root, and any `store=` line whose in-tree handle is missing or
does not resolve to the store. A disjoint external worktree with no in-structure
handle is the wrong-tree footgun (edits silently land in a tree not under test)
and is a defect, not a layout choice.

**Reproducible builds, the production anchor.** Software *initiated* under the
methodology has **reproducible builds**: its deployed artifact MUST be byte-reproducible
from the pinned source plus a recorded build recipe (a pinned `toolchain` and `build`
command in `.host-software`). That is what makes the pin a true production anchor (a
clean rebuild from the pin equals what is deployed) rather than just a source pin.
Record per component which line ships (`deploy`) and the artifact's expected hash
(`artifact = <path> <sha256>`); `host-lifecycle software --check` attests these cheaply
(a present artifact that matches is **verified**; one built by a local toolchain that
differs from the canonical hash is **noted, not failed**, the same reasoning
`--install-hooks` uses, since the recorded hash is the pinned build host's output), and
a CI job runs `host-lifecycle software --verify-build` to rebuild from the pin and fail
unless the artifact reproduces. `--verify-build`, not `--check`, is the reproducibility
proof. For **greenfield** software, non-reproducibility is a defect designed out from the
start.

**Hermetic builds, the dependency bundle.** Reproducibility and hermeticity are the same
lane: a component that ships static or self-contained release binaries MUST be able to
reproduce them offline from pinned inputs, never from whatever a network fetch returns at
build time. The recommended mechanism is a reusable, versioned, hash-pinned **dependency
bundle**: vendor the dependency layer once, publish it as a downloadable release (the pattern
`pgs-release` uses for its prebuilt sysroot), and have every build download and verify that
bundle and build with no network. Record it per component as `deps-bundle = <url> <sha256>`
in `.host-software`. `host-lifecycle software --verify-build` and `release` then perform the
one controlled, pinned download, verify the sha (the provenance half of the gate), stage the
vendored sources, and build under `--network none` (the egress half). The gate invariant is
specific and enforceable: a component recording a `deps-bundle` MUST build offline, its staged
bundle sha MUST match the recorded one, and `software --check` HAZARDs a `deps-bundle` pin that
has drifted from the producer's committed `deps-bundle.lock`. A component that genuinely cannot
vendor offline, such as one with a network-fetching `build.rs` or a non-Rust toolchain, may
carry `hermetic-exempt = call/NNNN` citing a software-scoped case decision, the same escape
shape as `repro-exempt`; the exemption is never available where offline vendoring is feasible.

**Multi-platform builds.** A component whose *one* source pin ships on several platforms
records one `[build "<name>" "<platform>"]` subsection per platform under its
`[software "<name>"]` stanza, each carrying its own `build`/`toolchain`/`artifact`/`deploy`
(and optional `repro-exempt`) plus an `attest-host` naming the OS (`linux`, `windows`,
`macos`) that reproduces it. `--check` and `--verify-build` iterate the builds and attest
each only on its `attest-host`. A build whose host is not the current one is skipped, and
the run does not fail (a Linux runner cannot reproduce the Windows artifact, and is not asked to).
The flat single-build fields remain the form for a single-platform component.

**Escape clause (migrated software only).** Pre-existing software brought under the
methodology may not be reproducible yet. It may carry `repro-exempt = call/NNNN` citing a
recorded **case decision**, a software-scoped `call/` decision documenting why it is not
yet reproducible and the interim provenance. `--verify-build` then warns and skips the
rebuild comparison; `--check` still requires the citation to resolve. The exemption is
meant to be retired as the component converges on reproducibility, and is **never**
available to greenfield software.

## Upgrading

Adopting is one event; the template moves on. The `.host` stamp records the `baseline`
ledger entry (every entry at or before its position in `UPGRADING.md` counts as applied).
The `applied` set of out-of-order entries lives in `.host-receipts` (the methodology-version
trail); `host-lifecycle migrate-receipts` moves it there from a legacy `.host`. `UPGRADING.md` is the ledger of actions, one `[upgrade "<revision>"]`
stanza each, ordered by file position; a stanza may declare `independent` or
`depends = <id> …` (logical prerequisites, distinct from the `requires` tool-version
floor) and a `verify` post-condition.

To upgrade, fetch the template to the target revision, then:

- `host-lifecycle upgrade <dir>` lists every ledger entry **not yet applied**, by
  ledger position, never git ancestry (ledger SHAs are a linear-commit artifact and
  some are orphaned from HEAD). A legacy single-`revision` stamp is migrated once to a
  `baseline`. `upgrade --next` prints the single next safe action.
- Apply an entry, then record it with `host-lifecycle upgrade --record <id>` (an id,
  an unambiguous prefix, or a ledger ordinal). The tool validates the id, refuses if a
  `depends` is unapplied, runs the entry's `verify` post-condition (or, when it has
  none, requires an explicit `--unverified call/NNNN` citation) and appends an
  append-only claim. **You never hand-edit the stamp.**
- A late **independent** entry may be cherry-applied without an earlier unrelated one:
  the deferred entries stay pending and **re-list**. A forgotten or premature record
  can never silently hide owed work (fail-safe). `upgrade --advance` later compacts a
  contiguous applied run into the `baseline`.
- `host-lifecycle software --check` re-checks every recorded claim (a `verify` that no
  longer holds, or an applied entry whose `depends` is unapplied, is a loud `HAZARD`).

The tool carries the process. Even a low-capability agent upgrades by reading one
line and running one command, never editing the stamp by hand. Re-stamp is the tool's
job, not yours.

## Provenance

The four working principles are rewritten, in our own words, from observations by
Andrej Karpathy on where LLM coding goes wrong, by way of Jiayuan Zhang
(@forrestchang) and the andrej-karpathy-skills contributors. The persona process
in `cast/applying-personas.md` follows Powell, Keenan and McDaid (2007) on
personas in XP, with later agile work cited alongside it. This manual is released
into the public domain (Unlicense); the credit here is acknowledgement, not a
license obligation.

## Project specifics: pgs-release

"Work as if you live in the early days of a better world."

This section carries the rules that are this project's own. The methodology
above is the spine, inherited verbatim from the template; nothing here may
contradict it.

### What this project is

PunkGraphicStream (v0.7.2) converts ASS (Advanced SubStation Alpha) subtitle
files into PGS/SUP (Presentation Graphic Stream) subtitle files for Blu-ray
discs. It is a Java application with a native C library (libpgs-jni) wrapping
libass via JNI. The larger ongoing effort is contributing subtitle conversion
(quantizer API, text-to-bitmap, OCR bitmap-to-text) upstream to FFmpeg.

Read `plan/PLAN.md` first for FFmpeg work. The PGS format specification is
`docs/pgs-specification.md`.

### The Where room: four components

The software lives under `software/` as bare stores with worktrees, recorded
in `.host-software`:

| Component | What it is |
|-----------|------------|
| `software/punkgraphicstream/` | Main Java application (Maven project) |
| `software/libpgs-jni/` | Native C JNI wrapper around libass |
| `software/libass/` | libass, pinned to 0.17.4 |
| `software/ffmpeg/` | FFmpeg, our upstream contribution branch |

### Build commands

Java application, from `software/punkgraphicstream/master/`:

```bash
mvn compile              # Compile
mvn package              # Build JAR (target/pgs-0.0.1-SNAPSHOT.jar)
mvn test                 # Run tests (JUnit)
mvn test -Dtest=MyTest   # Run single test class
mvn clean                # Clean build artifacts
```

Compiler warnings (`-Xlint:unchecked`, `-Xlint:deprecation`) are enabled.

FFmpeg, from `software/ffmpeg/pgs8-wip/`:

```bash
./configure --disable-doc && make -j$(nproc)      # Build
FATE_SAMPLES=/tmp/fate-samples make fate-sub-pgs  # Run PGS FATE test
```

FFmpeg style: 4-space indent, no tabs, 80-char lines, K&R braces, and
`snake_case` function names.

### Architecture of PunkGraphicStream

The processing pipeline is multi-threaded:

```
ASS file -> RenderRunnable -> QuantizeRunnable (N threads) -> EncodeRunnable -> .sup file
             (JNI/libass)      (NeuQuant color reduction)     (PGS encoding)
```

RenderRunnable opens ASS via JNI, iterates timecodes, renders frames to
BufferedImages and detects animation changes. QuantizeRunnable color-quantizes
images using the NeuQuant neural-net algorithm on one thread per CPU.
EncodeRunnable encodes quantized frames to PGS/SUP format via SupGenerator.
Thread coordination uses blocking queues plus semaphores, with an
AtomicBoolean for cancellation.

Key packages (`name.connolly.david.pgs.*`):

| Package | Purpose |
|---------|---------|
| (root) | Core domain: `Timecode`, `FrameRate`, `Resolution`, `SubtitleEvent`, `Render` |
| `.color` | NeuQuant color quantization, YCrCb Rec709 color space |
| `.concurrency` | Pipeline runnables and `EncodeQueue` |
| `.console` | CLI entry point |
| `.ui` | Swing GUI entry point and dialogs |
| `.util` | PES/TS packets, SUP reporting, `ProgressSink` interface |

Key design decisions:

- `Render` is an enum singleton managing native library lifecycle.
- `Timecode` uses Facebook's "flicks" (1 sec = 705,600,000 flicks) for
  frame-rate-precise timing without floating point.
- `FrameRate` enum: FILM (24), FILM_NTSC (23.976), TV_PAL (25),
  TV_NTSC (29.97), HD_PAL (50), HD_NTSC (59.94).
- `Resolution` enum: NTSC_480, PAL_576, HD_720, HD_1080.
- Java 1.6 target (being modernized): originally required no diamonds, no
  try-with-resources, no lambdas.

Entry points: GUI is `name.connolly.david.pgs.ui.PunkGraphicStream`, CLI is
`name.connolly.david.pgs.console.PunkGraphicStream`.

### Website style

- British English in prose (colour, optimisation, behaviour). American
  English in code identifiers, CSS properties, and API names (color,
  quantize).
- Exception: "quantizer" and "quantization" always use American spelling even
  in prose. The FFmpeg API name `av_quantize_*` is the canonical form and we
  do not mix spellings of the same term.
- Never rename directories (`color-distance/`) or CSS properties for British
  spelling.

### Publishing: the site root is the product's

**Durable exception to the methodology's publish phase (operator ruling,
2026-07-05).** The GitHub Pages root, https://connollydavid.github.io/pgs-release/,
is the content-full public product site, served from `docs/`. The development
mdBook that `host-lifecycle book` generates MUST publish under the `/book/`
sub-directory of that site, never at the site root. `docs/` stays the authored
product site; the book is generated output and is never committed.

### Honest attribution

When Claude simulates expert perspectives, role-plays reviewers, or generates
analysis from multiple viewpoints, documentation MUST make clear these are
Claude-driven prompts, not human experts. Never imply human review where none
occurred. Use language like "Claude-driven review across simulated
perspectives" rather than "expert panel review".

### Upstream review discipline

When reviewing, only flag issues in OUR code. Never fix, reorder, or restyle
pre-existing upstream code, even if it violates conventions. Our patches must
be minimal diffs against upstream.

Review in three passes (upstream style, then security, then functional). For
each finding, determine whether we introduced it or it is pre-existing. Only
fix what we introduced. Document intentional trade-offs in commit messages.

FFmpeg extraction patterns learned on this work:

- **API boundary validation.** When moving code from a filter (with AVOption
  validation) into a library API, the library must validate its own inputs.
  AVOption constraints do not follow the code. Any parameter feeding shifts,
  array indices, or division needs bounds checking at the API boundary.
- **Heap allocation changes.** When replacing inline struct arrays with
  heap-allocated contexts, void return types may need to become int to
  propagate allocation failures. Trace NULL safety through the full call
  chain.

### Static builds (MUST)

When producing release binaries, link third-party dependencies statically
wherever the host OS allows:

- Build all deps (zlib, freetype, fribidi, harfbuzz, libass, and the rest)
  from source as `.a` files into an isolated sysroot.
- Never use system or Homebrew shared libraries for release builds; they will
  not be present on the user's machine.
- Use `--disable-shared --enable-static` for autoconf deps and
  `-DBUILD_SHARED_LIBS=OFF` for CMake deps.
- Isolate pkg-config with `PKG_CONFIG_LIBDIR="$PREFIX/lib/pkgconfig"` and
  `PKG_CONFIG_PATH=""`.
- Pass `--pkg-config-flags=--static` and `--extra-cflags/ldflags` pointing at
  the sysroot to the top-level build.
- On Windows/mingw: add `-static-libgcc`. `libwinpthread-1.dll` cannot be
  eliminated. harfbuzz's CMake detects pthreads via `find_package(Threads)`
  on non-MSVC Windows and emits `-lpthread` into `harfbuzz.pc`; bundle the
  DLL in the zip instead.
- On Linux: add `-static-libgcc -static-libstdc++` to avoid pulling in
  `libgcc_s.so` and `libstdc++.so` (harfbuzz brings C++ object files into the
  final link).
- Only platform-mandated dynamic libs are acceptable (glibc on Linux,
  libSystem.dylib on macOS, kernel DLLs on Windows).

The prebuilt sysroot is published as a versioned dependency-bundle release
(the pattern the spine's hermetic-builds rule cites); the deps workflows under
`.github/workflows/` build and publish it.

### FFmpeg release versioning

FFmpeg release tags follow the format `n{ffmpeg-version}-pgsN.{build}`, for
example `n8.0.1-pgs3.0` (first build of series v3 on the 8.0.1 base):

- Increment `.build` for rebuilds on the same series (build config fixes).
- Increment `N` for a new series version.
- Do not reuse an existing tag for a retry. Delete with `--cleanup-tag` and
  increment build.
- Only bump the tag after a confirmed stable build (all 6 targets green,
  artifacts verified).
- Run FATE locally before cutting a release.

This scheme governs the FFmpeg patch-series releases. The spine's `vX.Y.Z`
tag rule governs tool and software manifest version bumps, which this project
does not make.

### Branch and version discipline (MUST)

Each patch series version gets its own branch. Never commit new-version work
on an old-version branch.

- **Branch naming:** `pgs{N}` for version N on master, `pgs{N}-8.0.1` for
  version N on 8.0.1.
- **History tags:** `history/pgs-v{N}` tags the final state of each version.
- **New phase of work means a new version:** when starting new features
  beyond review fixes, create a new branch (`pgs{N+1}`) from the current
  HEAD. Do not continue on `pgs{N}`.
- **Freeze old branches:** once `history/pgs-v{N}` is tagged, `pgs{N}` is
  frozen. Only cherry-pick critical fixes if needed for a release.
- **Before committing:** verify you are on the correct branch for the work
  being done. `git branch --show-current` should match the version you
  intend to modify.

### Patch series discipline (MUST)

Every patch in a series MUST compile independently when applied in sequence.
This is non-negotiable for upstream submission and bisectability.

- **Before committing a patch:** verify that every `#include` references a
  file that exists at that point in the series, either from upstream or from
  an earlier patch.
- **Dependency order:** if patch B includes a header created by patch A,
  patch A MUST come first. Plan the series order BEFORE writing patches.
  Draw the dependency graph.
- **Two-patch structure:** Patch 1 creates new files (FATE trivially passes),
  Patch 2 refactors the consumer (FATE must be bit-for-bit). The
  library/header patch always comes before its consumer.
- **Verification:** after building a series, run
  `git rebase upstream/master --exec 'make -j$(nproc)'` to confirm every
  patch compiles. This is not optional. Do it before pushing.

### Merge provenance

This file merged the pre-methodology CLAUDE.md (last at commit fe72149's
parent history) with the template spine on 2026-07-05. Rules subsumed by the
spine and dropped from this section: "Think Before Coding" (spine principle
1), "Simplicity First" (principle 2), the general half of "Surgical Changes"
(principle 3), "Goal-Driven Execution" (principle 4), and "Document Before
You Work" (the spine's audited plans and append-only memory). The epigraph at
the top of this section is preserved from the original file.
