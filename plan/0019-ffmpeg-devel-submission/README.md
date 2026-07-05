# ffmpeg-devel submission (v8)

## Status: In progress

The v8 series exists on `pgs8-wip` (two patches: rect bounds validation and
NeuQuant minimum iterations, both green in FATE CI). What remains is the work
that puts the patch set in front of upstream: reference validation, a rebase
onto current upstream, the RFC, and the first series submissions. See
plan/0018-upstream-submission-restructuring/README.md for how the series were
cut.

## Stories

Prioritised by Elias, the primary persona (cast/elias.md): upstream
acceptance is the delivery channel for every other persona.

- As Elias, I want each series to compile and pass FATE at every patch, so
  that a future bisect lands on one small change.
- As Elias, I want the RFC before the large series, so that the architecture
  argument happens once, on the list, before review effort is spent.
- As Noa, I want the encoder validated against a hardware-validated reference
  implementation, so that discs authored with it play on shelf players.
- As Marcus, I want the mpegts forced-flag fix upstream, so that forced
  subtitles survive conversion in stock FFmpeg.

## Build sequence

### Validate encoder output against the SUPer reference {#super-validation}

- verify: attested operator
- inputs: software/ffmpeg/pgs8-wip/libavcodec/pgssubenc.c

Compare v8 encoder output against cubicibo's hardware-validated SUPer
encoder on the worst-case corpus (karaoke, fades, multi-object). Divergences
are spec-interpretation findings; record them in call/ before submission.

### Rebase the series onto current upstream {#rebase-upstream}

- depends: #super-validation
- verify: attested operator

Both FFmpeg master and FFmpeg 8.1 have moved. Rebase `pgs8-wip`
with `scripts/resolve-version-conflicts.sh` in exec mode, then confirm every
patch compiles in sequence per the patch-series discipline in CLAUDE.md.

### Send the RFC to ffmpeg-devel {#rfc-email}

- depends: #rebase-upstream
- verify: attested operator

The template lives in plan/0000-ffmpeg-subtitle-upstreaming/README.md under
the RFC email section. Cite tickets
#6843 and #3819 and the 72 unlocked conversion pairs; disclose AI assistance
per the list's policy.

### Submit the mpegts forced-flag series {#submit-series-a}

- depends: #rebase-upstream
- verify: attested operator

The small standalone fix goes first; it needs no RFC outcome and builds
reviewer trust for the larger series.

### Submit the PGS encoder series {#submit-series-b}

- depends: #rfc-email
- verify: attested operator

The core-value series follows the RFC discussion. Review responses feed back
into this milestone until the series is applied or a new version is cut.
