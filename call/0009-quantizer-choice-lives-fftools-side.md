# The quantizer choice lives fftools-side, not on pgssubenc

- Status: accepted
- Scope: upstream-submission
- Date: 2026-08-28

## Context and Problem Statement

call/0006 ruled to expose `quantize_method` on `pgssubenc` so the
fftools read would become functional. The delivered series settled
the architecture the other way around: the encoder receives
already-indexed bitmaps with a finished palette and never
quantizes, so the choice moved to the conversion stage that owns
the work, flowing one way from the CLI through
`enc_sub_set_options` into the conversion context. What remained
in `convert_text_to_bitmap` was a forward that wrote
`quantize_method` and `forced_style` into the output encoder's
private data, where pgssubenc defines neither option: both writes
failed with `AVERROR_OPTION_NOT_FOUND` and the returns were
ignored. That is the same silently-dead option shape call/0006
condemned, relocated rather than removed.

## Decision

Delete the dead forward and its `options_forwarded` guard
(pgs9-master bc3272d081). pgssubenc gains no `quantize_method` or
`forced_style` AVOption: the first would be dead by construction,
and the second is a text-matching concern with no meaning once
the bitmaps exist. If a self-quantizing subtitle encoder ever
appears among the subtitle codecs, the forward can be introduced
then. This disposes of the mechanism half of call/0006; its
animation-scan-cap ruling remains implemented as stated.

Reviewers asking why pgssub lacks a `quantize_method` where gif
has one get this answer: gif quantizes RGBA video inside the
encoder, while pgssub receives indexed bitmaps, so the quantizer
choice belongs to the text-conversion stage and is selectable per
stream through `-sub_quantize_method`.

## Consequences

- Good: no silently-dead option shape survives in the series; the
  option story is honest, one CLI option consumed where the work
  happens.
- Neutral: behaviour is unchanged, since both forwarded writes
  already failed at run time; the per-stream forwarding proof in
  plan/0022 re-verified the real circuit after the removal.
- Bad: none identified.
