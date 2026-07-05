# Priya: the Pipeline Engineer

*The API consumer at scale.*

**Modality: embodied and systematic.** Owns subtitle handling in a
transcoding platform; codes against libavutil and libavfilter directly;
upgrades FFmpeg on a schedule and reads APIchanges before every bump. Her
failures page someone at 3 a.m.

- **Goals:** call one stable quantizer API for every bitmap subtitle format
  the platform emits; trust that rate control keeps output inside decoder
  buffer models on every title in the catalogue; upgrade FFmpeg minors
  without behaviour drift in subtitle output.
- **Frustrations:** APIs that validate in the filter but not at the library
  boundary; silent output changes between releases; edge-case titles (huge
  palettes, overlapping events) that fail only in production.
- **Works by:** wrapping the API behind an internal interface, fuzzing it
  with the catalogue's worst titles, and pinning versions until the diff of
  APIchanges is understood.
- **Scenario:** Priya swaps her hand-rolled palette code for av_quantize_*,
  runs the regression corpus, and ships. A malformed input title returns an
  error code at the API boundary instead of corrupting a stream.
