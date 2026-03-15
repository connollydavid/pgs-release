# Phase 9a-R1: Subtitle Event Lookahead Window

## The Problem

PGS can't remove individual objects — it can only clear everything
or replace everything with a new Epoch Start. When overlapping
subtitle events have different end times, the encoder must know when
each event expires to re-render the remaining events alone.

```
Sub A: 1s-5s  "Hello"
Sub B: 3s-7s  "World"

Correct timeline:
  1s: Epoch Start — render A alone
  3s: Epoch Start — render A+B composite
  5s: Epoch Start — render B alone (A expired)
  7s: Normal — clear (B expired)
```

Without a lookahead window, the encoder only knows about events as
they arrive. When B arrives at 3s, it doesn't know that at 5s it
needs to re-render B alone.

## Design: Event Buffer with Timeline Computation

### Data structures

```c
typedef struct SubEventEntry {
    char    *text;       /* ASS dialogue text (av_strdup'd) */
    int64_t  start_pts;  /* start time, AV_TIME_BASE units */
    int64_t  end_pts;    /* end time, AV_TIME_BASE units */
} SubEventEntry;
```

These are stored in the `SubtitleEncContext` event buffer:

```c
/* In SubtitleEncContext: */
SubEventEntry *event_buf;    /* buffered subtitle events */
int             nb_events;   /* number of events in buffer */
int             event_cap;   /* buffer capacity */
int64_t         last_ds_pts; /* PTS of last emitted Display Set */
```

### Algorithm

**On new event arrival (PTS = T_new, duration = D):**

1. Compute `end_pts = T_new + D` (in AV_TIME_BASE)
2. **Process expirations:** scan event buffer for events with
   `end_pts <= T_new`. For each expiration point (in chronological
   order):
   - Compute the set of still-active events at that point
   - If the set is non-empty: render composite → Epoch Start DS
   - If the set is empty: emit clear DS (0-object PCS + END)
   - Remove expired events from buffer
3. **Add new event** to buffer
4. **Render current active set:** all events where
   `start_pts <= T_new < end_pts`
   - If same set as last DS: skip (no change)
   - If changed: render composite → Epoch Start DS

**On EOS (stream end):**

1. Find the latest `end_pts` across all buffered events
2. Process all expiration points between `last_ds_pts` and that time
3. Emit final clear DS

### Example walkthrough

```
Input events:
  A: start=1s, end=5s, "Hello"
  B: start=3s, end=7s, "World"

Processing event A (T_new=1s):
  1. No expirations (buffer empty)
  2. Add A to buffer: [{A, 1s-5s}]
  3. Active set at 1s: {A}
  4. Render A → Epoch Start DS at PTS=1s

Processing event B (T_new=3s):
  1. Check expirations before 3s: A ends at 5s > 3s, no expirations
  2. Add B to buffer: [{A, 1s-5s}, {B, 3s-7s}]
  3. Active set at 3s: {A, B}
  4. Different from last DS ({A}): render A+B → Epoch Start at 3s

Processing EOS:
  1. Expiration points: 5s (A), 7s (B)
  2. At 5s: active set = {B}. Render B → Epoch Start at 5s
  3. At 7s: active set = {}. Emit clear DS at 7s
```

### Integration with existing code

The event buffer replaces the current simple coalescing buffer.
Currently coalescing only handles same-PTS events. The lookahead
window handles both same-PTS (composite) and different-PTS
(temporal overlap).

The animation detection path stays as-is — it operates within a
single event's time span. The lookahead window operates across
events.

### Interaction with the DVB-style clear in ffmpeg_enc.c

The `nb = 2` pattern in `do_subtitle_out()` should NOT be used for
PGS when the lookahead window is active. The window handles all
clear DS emission internally. Set `nb = 1` for PGS and let the
enc_sub module handle timing.

### Edge cases

- **Same-PTS, same-duration:** classic coalescing, one composite
- **Same-PTS, different-duration:** composite at start, re-render
  at the shorter event's end
- **No overlap:** simple sequence with clear between each
- **Very long events:** buffer grows but is bounded by concurrent
  event count (typically small for subtitles)
- **Zero-duration events:** skip (already filtered by min_duration)

### Non-goals (for now)

- **Animation within the lookahead window:** animation classification
  and fade encoding still operate per-event. The lookahead window
  determines WHICH events are active; the animation pipeline handles
  HOW each event is rendered over time.
- **Re-rendering active events with animation state:** when A expires
  and B continues, B is re-rendered from scratch (fresh Epoch Start).
  Any animation state (fade progress) on B is restarted. This is
  acceptable — the visual discontinuity is at a moment when A
  disappears, so the viewer's attention is already disrupted.
