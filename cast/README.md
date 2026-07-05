# Cast: the project's Who

Personas: hypothetical archetypal actors, grounded in research, that keep the
work anchored in who it serves. The process comes from Powell, Keenan and McDaid
(2007), which builds on the personas in Cooper and Reimann's Interaction Design.

The template's worked examples (Mara the human operator and Wren the agentic
LLM, under `host-template/cast/`) illustrate the method at the meta level;
this project's own cast is below.

**Each project builds at least one persona of its own, by discussion**: the
operator and the agent elicit the actual users of the software under
development (allium's `elicit`). Add them here. See
[applying-personas.md](applying-personas.md) for the process.

## The pgs-release cast

Built by discussion with the operator (2026-07-05). Organisation goals: land
the subtitle-conversion capability upstream in FFmpeg (tickets #6843 and
#3819); ship trustworthy prebuilt binaries from the website meanwhile; hold
output quality to what hardware players accept; run the project as a
verifiable agentic project.

| Persona | Archetype |
|---------|-----------|
| [Elias](elias.md) | the ffmpeg-devel reviewer (**primary**) |
| [Marcus](marcus.md) | the media-library archivist |
| [Noa](noa.md) | the disc author |
| [Priya](priya.md) | the pipeline engineer |
| [Sable](sable.md) | the agentic developer (LLM modality) |

Elias is primary because upstream acceptance is the delivery channel for
every other persona: until the series merges, Marcus, Noa, and Priya are
served only by the prebuilt binaries. Story prioritisation for the next
milestones follows him.
