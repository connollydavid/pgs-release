# Keep a normalized AI attribution trailer on the upstream series

- Status: accepted
- Scope: upstream-submission
- Date: 2026-07-17

## Context and Problem Statement

Every commit on the pgs8-wip series carries an AI co-author trailer that
includes a model variant descriptor. The 2026-07-17 adversarial review of
FFmpeg's live contribution rules found no upstream rule for or against such
a trailer, no precedent crediting an AI in one, and a demonstrated norm of
hostile review toward undisclosed or low-effort AI output. The pgs9 rewrite
(plan/0020) must set one form for all commits.

## Decision

Operator ruling (2026-07-17): keep the trailer on every commit of the
rewritten series, normalized to `Co-Authored-By: Claude
<noreply@anthropic.com>`, with the variant descriptor removed and the
trailer placed after the sign-off. Disclosure of AI assistance in the RFC
and cover letter stays regardless, per the honest attribution rule in
CLAUDE.md.

## Consequences

- Good: the history itself records the assistance; disclosure cannot drift
  out of sync with the commits; consistent with our attribution rule.
- Bad: the trailer is visible to reviewers primed against AI submissions,
  with no upstream precedent to point at; if reception turns on it, a
  future decision may revisit this one.
