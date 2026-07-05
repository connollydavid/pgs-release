# Applying personas during planning

The XP-Persona process (Powell, Keenan & McDaid 2007) runs as a workshop with all
interested parties (developers, customer representatives, management) before
development begins. Steps one to six come from Interaction Design (persona
development); steps seven to nine from XP story development. The aim is the
*minimum beneficial investigation* before development starts, after which
requirements and plans evolve.

1. **Brainstorm organisation goals.** Record what the organisation wants the
   project to achieve; these reflect its intention.
2. **Brainstorm possible personas.** Start broad, then combine through
   discussion to between two and twelve personas. Give each a **name**; the team
   refers to personas by name when making decisions, which keeps the view on the
   user rather than the system. Unless user research is available, the customer
   has the final say.
3. **Brainstorm persona goals.** Set between two and six goals per persona; each
   goal states what the persona wants to achieve through the system. "A persona
   exists to achieve his goals, and the goals exist to give meaning to a persona"
   (Cooper 2004).
4. **Brainstorm persona personalization.** Give each persona a personality and a
   technical ability relative to the system; a short paragraph or bullets of
   personal detail and nuance.
5. **Brainstorm persona scenarios.** Describe interactions, not tasks: how a
   persona uses the system to reach a goal. No implementation detail in a
   scenario.
6. **Select the primary persona.** This is the one who *must* be satisfied but cannot be
   satisfied by an interface designed for any other persona (Cooper 2004). It
   takes highest priority and feeds story prioritisation. More than one primary
   persona implies a separate interface for each.
7. **Create stories.** From the persona goals and scenarios, write the user
   stories.
8. **Prioritise stories**, using the primary persona as the guide.
9. **Estimate stories**, estimated and agreed by customer and developers.

In our pipeline: steps one to six are the `cast/` work (built by discussion);
steps seven to nine become `plan/` (milestones are the stories, prioritised by
the primary persona, estimated); persona goals and scenarios feed `spec/`, where a
scenario becomes acceptance criteria becomes a behavioural spec.

Complementary practice reinforces the same steps (departing only on strong later
evidence): Cohn's "As a `<persona>`, I want `<goal>` so that `<reason>`" template
reinforces the named-persona stories of steps two and seven; Gothelf's
proto-personas reinforce the assumption-first workshop of steps two to five;
Patton's story mapping reinforces the create-and-prioritise of steps seven and
eight; behaviour-driven scenarios reinforce step five becoming executable
acceptance criteria.

**Sources.** Primary: Powell, S., Keenan, F. & McDaid, K. (2007), "Enhancing
Agile Requirements Elicitation with Personas," IADIS Int'l Journal on Computer
Science and Information Systems, vol. 2(1), pp. 82-95, ISSN 1646-3692.
Complementary: Cohn, *User Stories Applied* (2004); Patton, *User Story Mapping*
(2014); Gothelf, *Lean UX* (proto-personas); Jeffries, "The Three C's of User
Stories" (2001); Cooper & Reimann, *About Face* (2003); Agile Alliance on BDD.
