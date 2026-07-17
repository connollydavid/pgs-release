# Plan index

The enduring programme context (why the work exists, architecture, upstream
acceptance intelligence, submission strategy, deferred backlog, references,
release builds) lives in the standing charter,
[plan/0000-ffmpeg-subtitle-upstreaming.md](0000-ffmpeg-subtitle-upstreaming.md).
Each milestone's own record lives in its folder.

## Milestones

The milestones, in acceptance order; 0001 through 0018 are closed records.

| Milestone | Title |
|---|---|
| [0000](0000-ffmpeg-subtitle-upstreaming.md) | FFmpeg subtitle upstreaming programme (standing charter) |
| [0001](0001-hdmv-pgs-encoder/README.md) | HDMV PGS subtitle encoder |
| [0002](0002-color-quantization-api/README.md) | Color quantization API and palette mapping |
| [0003](0003-text-to-bitmap-conversion/README.md) | Text-to-bitmap subtitle conversion |
| [0004](0004-region-weighted-quantization/README.md) | Region-weighted quantization |
| [0005](0005-quantizer-algorithm-integration/README.md) | Quantizer algorithm integration |
| [0006](0006-gif-encoder-rgba-quantization/README.md) | GIF encoder RGBA quantization |
| [0007](0007-upstream-review-findings/README.md) | Upstream review findings |
| [0008](0008-ocr-bitmap-to-text/README.md) | OCR bitmap-to-text subtitle conversion |
| [0009](0009-pgs-decoder-model-compliance/README.md) | PGS decoder model compliance |
| [0010](0010-upstream-suitability-audit/README.md) | Upstream suitability audit |
| [0011](0011-v3-consolidated-claude-review/README.md) | v3 consolidated Claude-driven review |
| [0012](0012-v4-review-fixes/README.md) | v4 review fixes |
| [0013](0013-subtitle-event-lookahead/README.md) | Subtitle event lookahead window |
| [0014](0014-pgs-encoder-optimizations/README.md) | PGS encoder optimizations (v5) |
| [0015](0015-website-updates/README.md) | Website updates for v4/v5 |
| [0016](0016-fate-ci-website-visibility/README.md) | FATE CI and website test visibility |
| [0017](0017-pgs-encoder-features/README.md) | PGS encoder features (v6) |
| [0018](0018-upstream-submission-restructuring/README.md) | Upstream submission restructuring (v7) |
| [0019](0019-ffmpeg-devel-submission/README.md) | ffmpeg-devel submission (v8, in progress) |
| [0020](0020-pgs9-series-remediation/README.md) | pgs9 series remediation |

## Current Work

_Scratch buffer: what we're doing right now._

The host methodology adoption completed 2026-07-05 (recorded in call/0001
through call/0003 and MEMORY.md).

Active milestone: plan/0019 (ffmpeg-devel submission, v8). The series lives
on `pgs8-wip` (master base, off `pgs7`) with two patches: rect bounds
validation and NeuQuant minimum iterations. Next tasks per the milestone's
build sequence: SUPer reference validation, then the upstream rebase, then
the RFC and first series submissions.
