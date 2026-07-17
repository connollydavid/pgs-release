# Upgrade the template baseline to ff04a94

- Status: accepted
- Scope: project
- Date: 2026-07-17

## Context and Problem Statement

The adopted template moved on from the revision recorded at adoption
(`5707980`, 2026-07-05) to `8b578b2`, and its ledger listed pending entries
covering the build-sequence band, the book-mount sub-path, and the scaffold
rename. The operator directed the repository be kept current with
connollydavid/host, which for a prior adoption means the Case C upgrade
through the ledger.

## Decision

Applied the pending ledger entries (`67d63e9`, `962630c`, `ff04a94`) and
advanced the baseline to `ff04a94`; the tool migrated the legacy
single-revision stamp to the baseline form on first listing. Pinned tools
moved with the template: host-lifecycle to v0.40.1 and host-lint to v0.14.2,
in the submodules, in the checksum-verified CI action, and in the installed
hook binary.

Project-side choices the entries left open:

- The durable call/0002 exception is now declared, not hardcoded: the stamp
  carries `book-mount = "/book/"` and the Site workflow reads
  `host-lifecycle book --print-mount` instead of a literal `book` path. The
  reference Site workflow was not adopted verbatim because it publishes only
  the book and keeps surrounding files, while call/0002 requires the authored
  product site from `docs/` republished at the root on every push; the
  existing assemble-and-publish shape stays, made mount-aware. The workflow
  refuses the root-default mount outright so a lost declaration fails the
  build rather than republishing the book over the product site.
- `.host-lint-allow` is retired. host-lint v0.14.2 and `remap --check` both
  read the `LEXICON` as the one allowlist (connollydavid/host-lifecycle#13,
  <https://github.com/connollydavid/host-lifecycle/issues/13>), so the
  duplicate file and the gate step keeping the two identical are removed.
- No plan uses a band and nothing scripts the renamed scaffold verb, so those
  entries carried no project-side edits beyond the tool and spine bump.

## Consequences

- Good: the book's sub-path is a config declaration a future workflow
  regeneration cannot silently drop; the allowlist has one source of truth.
- Neutral: the spine gained the onboarding and band doctrine verbatim;
  project specifics in CLAUDE.md are untouched.
- Bad: none identified; the verify gate ran clean after each change.
