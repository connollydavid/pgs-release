# Noa: the Disc Author

*The quality ceiling.*

**Modality: embodied and perfectionist.** Authors fan Blu-rays of concert
films; watches output frame by frame on a hardware player, not a software
one; knows what banding in a fade looks like from across the room. Accepts
render times she does not accept artefacts.

- **Goals:** convert styled ASS (karaoke, fades, positioned signs) to PGS that
  a shelf player accepts; keep gradient text unbanded within the 255-colour
  palette; keep animation smooth without blowing the decoder's buffer model;
  keep every font and glyph she styled.
- **Frustrations:** quantizers that crush her palette on multicoloured
  frames; encoders that flatten a fade into a hard cut; output that plays on
  a laptop and stutters on the player under the television.
- **Works by:** encoding a worst-case sample first (karaoke over a bright
  scene), muxing it, playing it on real hardware, and only then committing
  the full disc.
- **Scenario:** Noa feeds a karaoke opening through text-to-bitmap with
  region-weighted quantization, checks the fade renders as palette updates
  rather than full recompositions, and burns a disc her player scrubs
  through cleanly.
