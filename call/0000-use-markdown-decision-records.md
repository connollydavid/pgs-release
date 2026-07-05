# Use Markdown decision records (MADR)

*(Worked example; replace with your software's own decisions.)*

- Status: accepted
- Scope: example
- Date: 2026-06-14

## Context and Problem Statement

Architectural decisions about the software under development need a durable, citable
home, separate from MEMORY.md (lessons learned, backward-looking) and PLAN.md
(the milestone index). Without one, the reasoning behind a choice evaporates and
gets re-litigated.

## Decision

Adopt MADR (Markdown Architectural Decision Records) for this log:

- Files are named `NNNN-topic-slug.md`, zero-padded to width four, numbered
  monotonically from this `0000` bootstrap, lowercase-and-dashes, no `ADR-`
  prefix.
- A record's number is its identity, not a sort key; this log is the ordering
  authority.
- Numbers are assigned at merge, so two branches do not collide on the same
  `NNNN`.
- Disambiguation by home: a bare number at the plan root names a milestone; a
  numbered file under `call/` names a decision.

## Consequences

- Good: decisions carry structured status and supersession and a stable, citable
  identity; this log documents its own format as record zero.
- Neutral: this is one of two numbered registers (milestones and decisions),
  told apart by home, and kept explicit to avoid confusion.
