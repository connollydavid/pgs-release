# Migrated software components are repro-exempt for now

- Status: accepted
- Scope: software
- Date: 2026-07-05

## Context and Problem Statement

The methodology requires byte-reproducible builds for software initiated under
it, recorded as a `build`/`toolchain`/`artifact` recipe in `.host-software`.
The four components here (punkgraphicstream, libpgs-jni, libass, ffmpeg)
predate the methodology. The FFmpeg release binaries are built by the
`ffmpeg-release` workflow across six targets against a versioned prebuilt
sysroot bundle; they have never been proven byte-reproducible, and the Java
and JNI components have no recorded artifact hashes at all.

## Decision

Each component carries `repro-exempt = call/0003` (this record) under the
migrated-software escape clause. Interim provenance: release artifacts come
only from the tagged CI runs of `.github/workflows/ffmpeg-release.yml`, which
download and hash-verify the pinned sysroot bundle before building; the
sysroot bundle is the hermetic dependency layer the spine's hermetic-builds
rule cites.

Retire the exemption when a rebuild from the pin reproduces the release
artifacts; at that point record per-platform `[build "ffmpeg" "<platform>"]`
recipes with the expected artifact hashes.

## Consequences

- Good: honest recording; `software --check` still audits pins and citations.
- Neutral: `software --verify-build` warns and skips the rebuild comparison.
- Bad: until retired, the pin is a source anchor, not a full production
  anchor.
