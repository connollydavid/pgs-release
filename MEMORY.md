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
