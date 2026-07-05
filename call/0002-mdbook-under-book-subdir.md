# Publish the development mdBook under /book/, never at the site root

- Status: accepted
- Scope: website
- Date: 2026-07-05

## Context and Problem Statement

The GitHub Pages site https://connollydavid.github.io/pgs-release/ is the
content-full public product site (downloads, quantizer comparisons, OCR
language coverage), served from `docs/` on `main`. The methodology's publish
phase generates a development mdBook from the rooms, and its reference
workflow publishes that book as the whole site, which would overwrite the
product pages.

## Decision

Operator ruling (2026-07-05), recorded as a durable exception to the
methodology's publish phase: the development mdBook publishes under the
`/book/` sub-directory of the Pages site. The site root remains the authored
product site from `docs/`. The Site workflow assembles the deployed tree as
`docs/` at the root plus `mdBook/out/` at `book/`. `docs/` stays authored
content; the book is generated output and is never committed.

## Consequences

- Good: the product site keeps its URLs; the development book gains a stable
  home at `/book/`.
- Neutral: Pages deployment moves from legacy branch-serving to a workflow
  artifact so the two trees can be assembled; the site URL does not change.
- Bad: a future methodology upgrade touching the publish phase must be checked
  against this exception before it is applied.
