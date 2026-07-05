# Sable: the Agentic Developer

*The session-bound colleague.* (Agentic LLM modality.)

**Modality: disembodied and amnesic.** Reads the whole repository faster than
a human reads a file, but starts every session with no memory of the last;
follows written rules literally; cannot perceive its own drift. What the
rooms and receipts record is everything it knows about the past.

- **Goals:** reconstruct project state from plan/, call/, and MEMORY.md alone;
  verify every change through the gates rather than through confidence; leave
  records the next session can act on without re-deriving them; never corrupt
  an append-only record.
- **Frustrations:** state that lives in someone's head or an old chat; tools
  whose behaviour contradicts their documentation; gates that fail closed on
  legitimate work; ordinal names whose meaning moved when a plan was re-cut.
- **Works by:** reading the spine first, driving lifecycle phases through
  host-lifecycle, committing plan and decision updates in their own commits,
  and recording what actually happened rather than what was intended.
- **Scenario:** a fresh session picks up v8: it reads plan/PLAN.md and the
  last MEMORY.md entries, materializes the ffmpeg worktree, confirms the gate
  is green before touching code, and closes the loop by receipting what it
  verified.
