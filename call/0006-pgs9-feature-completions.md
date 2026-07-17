# Expose quantize_method and cap the animation scan on the PGS encoder

- Status: accepted
- Scope: upstream-submission
- Date: 2026-07-17

## Context and Problem Statement

The pgs9 remediation surfaced two encoder behaviours that block the
"features complete" precondition the operator set for upstreaming. First,
`fftools` reads a `quantize_method` from encoder private data, but only the
GIF encoder defines that AVOption, so the PGS path silently always uses
NeuQuant, the same dead-option shape as the `forced_style` AVOption the
review found undefined. Second, the animation-change scan iterates once per
millisecond of an event's duration, so a single crafted ASS event with a
very large duration drives billions of iterations and exhausts CPU.

## Decision

Operator rulings, 2026-07-17:

1. **Expose `quantize_method` on `pgssubenc`.** Add the AVOption so the
   existing `fftools` read becomes functional and a user can select
   NeuQuant, ELBG, or Median Cut. Document it in `doc/encoders.texi`.
2. **Cap the animation scan, degrade rather than fail.** Bound the scan by
   a maximum derived from HDMV epoch practicality; beyond the bound, log a
   warning and treat the event as static. A legitimate long event is not
   rejected; the crafted-input CPU-exhaustion shape is removed.

## Consequences

- Good: the encoder's quantization story becomes user-controllable and
  honest (no silently dead option); the crafted-event DoS shape is closed
  without breaking legitimate long subtitles.
- Neutral: the cap is a documented behavioural limit; a genuinely longer
  animation than the bound degrades to static, which is acceptable for the
  HDMV target.
- Bad: two more behavioural changes enlarge the review surface; both are
  small and self-contained.
