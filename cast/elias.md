# Elias: the ffmpeg-devel Reviewer

*The upstream gatekeeper.* **Primary persona.**

**Modality: embodied and adversarially busy.** Reads patches in an email
client, one hunk at a time, between his own work; has reviewed a decade of
subtitle proposals that went nowhere; remembers every regression that shipped.
His default answer is no, and the burden of proof sits with the series.

- **Goals:** merge only code FFmpeg can carry for twenty years; keep public
  APIs minimal and consistent with existing conventions; see every behaviour
  claim backed by a FATE test; bisect any future regression to one small
  patch.
- **Frustrations:** large series that demand days of review; API surface
  invented where a utility would do; diffs that restyle code they do not
  change; contributions that read as generated rather than understood.
- **Works by:** reading the cover letter first, then the API headers, then the
  diffstat; replying with blocking questions; ignoring a series that costs
  more to review than it gives.
- **Scenario:** a five-series set arrives implementing the PGS encoder and the
  quantizer API. Elias reads the RFC, checks that patch 1 compiles alone,
  runs FATE, and asks two pointed questions about buffer-model compliance.
  The answers cite the spec and a test; he applies the first series.
