# Event storming — rules of the game (process level)

This skill models at the **process-modelling** level (Brandolini's middle level, between *big-picture* exploration and *software-design*): the story of how a process unfolds over time, in domain language, independent of UI screens and database tables. If a sticky describes a click, a table row, or an API call, it's at the wrong level.

Source of truth: Alberto Brandolini / Avanscoperta *EventStorming MasterClass* takeaways, and the community **ddd-crew EventStorming glossary**. What follows is the working subset this skill enforces.

## Color grammar — the palette

One shape = one meaning. A misused color is a modeling error, not cosmetic. Reproduce this `classDef` block at the top of every diagram:

```
    classDef event          fill:#FFA94D,stroke:#CC7722,color:#000
    classDef command        fill:#4D9FEC,stroke:#2C6FB0,color:#000
    classDef actor          fill:#FFE066,stroke:#B89A1A,color:#000
    classDef constraint     fill:#FFF3BF,stroke:#D6C34A,color:#000
    classDef policy         fill:#C69AE0,stroke:#7E3FBF,color:#000
    classDef readModel      fill:#9CD97A,stroke:#3F8C2B,color:#000
    classDef externalSystem fill:#FFC2D1,stroke:#D24B6E,color:#000
    classDef hotspot        fill:#E64980,stroke:#A61E4D,color:#FFF
    classDef opportunity    fill:#69DB7C,stroke:#2F9E44,color:#000
```

| Sticky | Color | Meaning | Label form |
|---|---|---|---|
| **Domain event** | orange | a fact that happened, relevant to domain experts | **past tense**: "invoice accepted for processing" |
| **Command / action** | blue | a decision, action, or intent | **imperative**: "send invoice" |
| **Actor / person** | **yellow** | who issues the command (Brandolini prefers the fuzzy "people": role, segment, or named person) | a role noun: "booker", "accountant" |
| **Constraint** (consistent business rule) | **pale yellow** | the rule(s) that decide whether the command yields the event | **a list of conditions** — see below |
| **Policy** | purple (lilac) | reactive logic — "whenever X, we do Y" | **starts with "whenever…"** |
| **Read model** | green | the information needed to take a decision | a question/info: "is there a slot?" |
| **External system** | pink | a system outside your control ("whatever you can put the blame on") | a system noun: "Payments" |
| **Hotspot** | neon pink | an open question, conflict, risk, or assumption | the question itself |
| **Opportunity** | bright green | an idea / good thing to pursue (value exploration) | the idea |

Note the two yellows (Brandolini's "small yellow person" vs the consistency sticky) and the two pinks (a pale **pink** external system vs the **neon pink** hotspot) — keep them distinct.

A **temporal trigger** is an event tagged `(temporal)` — "month-end reached (temporal)" — usually feeding a policy. Optional: a pale-yellow **Definition** sticky clarifies a term (non-controversial, unlike a hotspot) — but don't define everything; that turns the session into database design in disguise.

## The constraint (NOT a named aggregate)

This skill **does not name aggregates** on the board. The yellow sticky between a command and its event is the **constraint** — the *consistent business rule(s)* that must hold for the command to produce the event. Express it as the **list of conditions**, e.g.:

```
"send invoice"  ──▶  [ company is active;  NIP matches our company ]  ──▶  "invoice accepted for processing"
   command                         constraint (yellow)                          event
```

Why this, not a noun:
- Brandolini's own guidance is **"postpone naming"** and **"look for state machines"** — the constraint is a little state machine that exposes consistent behaviour; its *boundaries are business boundaries, not technical ones*. Naming it (and choosing the DDD Aggregate / archetype) is deferred to the implementation-plan stage.
- A list of conditions captures the real design content (the invariant) instead of bikeshedding a name.
- **It surfaces the failure path for free.** When a constraint fails, there's usually a rejection event ("invoice rejected — NIP mismatch"). Model those too; they're where the interesting requirements hide.

(The historical name for this sticky is "aggregate," now legacy in EventStorming because it's DDD jargon for business stakeholders. Worked examples you may have locally — e.g. `appointer/kalendarz-event-storming.md` — predate this and use nouns; follow the constraint convention for new diagrams.)

## Color grammar — allowed combinations (the connection rules)

The colors connect in a fixed grammar — "the picture that explains everything." **Only these transitions are legal.** Drawing an illegal edge is a modeling error to fix before showing the user.

**Legal forward edges:**

| From → To | Meaning |
|---|---|
| Read model → Actor | the information is shown to the person who decides |
| Actor → Command | the person decides to issue a command (read model in hand) |
| Command → Constraint | the command is checked against the business rule |
| Command → External system | a command can be handed to an external system |
| Constraint → Event | if the rule holds, the event is emitted |
| External system → Event | external systems produce events |
| Event → Read model | events get translated into one or more read models |
| Event → Policy | events activate policies ("whenever…") |
| Event → External system | events can notify an external system |
| Policy → Command | a policy issues the next command |
| Temporal (time) → Policy | scheduled/seasonal triggers fire policies |

**Illegal combinations — the tell-tale errors:**

- **Event → Command directly.** Forbidden. *"There has to be a lilac between the orange and the blue"* — a reaction is always mediated by a **Policy**. If you drew event→command, you're hiding a policy; name it.
- **Command → Event directly.** Forbidden — a command must pass through a **Constraint** (or an external system) that decides the outcome. A direct command→event hides the business rule.
- **Read model → External system**, and **Read model → Command when a person decides.** A read model *informs the actor*, who then issues the command — **Read model → Actor → Command**. It never drives a system. Only when the decision is fully automated (no human actor) may a read model feed the command (or its policy) directly.
- **Read model → Event**, **Actor → Event**, **Policy → Event**, **Constraint → Command** — all forbidden; they break the sentence.
- An external system's effect **re-enters your model as an Event** (then a Policy may react) — it does not directly issue domain commands.

## The Rules of the Game

When modelling a process (and the software underneath), respect these four rules (Brandolini):

1. **Every process ends in a stable state** — usually a combination of an **Event + Read model**. If a flow just trails off, it isn't finished.
2. **The colour grammar must be respected** — see the allowed-combinations table above.
3. **Every involved stakeholder should be reasonably happy** — visualize value with good/opportunity (green) and problem (red/magenta) stickies; a step that's bad for an actor is a design smell.
4. **Every hotspot raised during modelling must be addressed** — none left dangling at the end.

## Building blocks — Brandolini's definitions

- **Events** are the backbone: semantically robust facts at a point in time, fine-grained, and the best unit of ubiquitous language (better than nouns). Start from them.
- **Policies** are the most interesting element — the whole spectrum of organisation reaction: habits, tacit/explicit agreements, codified rules, *inconsistent* rules (different actors doing the same rule differently), stateless **listeners** (e.g. send a notification), and **process managers / sagas**. Challenge automation: sometimes the win is making a *human* step easier, not faster.
- **Read models** are designed *driven by the needs of the consequential decision* — model the question the decider needs answered, not a screen.
- **External systems** have a deliberately fuzzy definition — "whatever you can put the blame on" (can even be "the weather"). Include them only when they genuinely participate.
- **Storage is not an external system.** A database, cache, queue, or repository is persistence plumbing, not a participant. "row inserted", "saved to DB", "cache invalidated" are not domain events. Model the business, not the plumbing.

## Common mistakes & antipatterns

- **Events that aren't past-tense facts** — "create invoice" (command), "invoice" (noun). Events *happened*.
- **CRUD-flavored events** hiding meaning — "invoice updated". Ask what changed and why it matters.
- **Persistence/technical stickies** — "saved", "API called", "queue drained". Plumbing.
- **Storage as an external system** — see above.
- **Naming the constraint as an aggregate noun** — list the conditions instead; postpone naming.
- **Skipping the policy** — event wired straight to a command (see grammar).
- **Skipping the constraint** — command wired straight to an event.
- **Orphan events / "and then a miracle happens"** — an event with no cause. Mark the gap; don't invent the cause.
- **Rush-to-the-goal vs. solve-everything** — don't try to model every branch at once; reach the end of the happy path, and mark each unexplored alternative as a **hotspot** so it isn't lost. Conversely, don't pretend corner cases don't exist — *raise the bar* with the most extreme real scenarios; a simple model that collapses on them is wrong.
- **Conversational scripting** — modeling a dialog as "Option A proposed / Option A rejected / …". Focus on the **termination condition** ("agreement reached"); a conversational step may emit several events at once.
- **Mixed levels / happy-path tunnel vision / color-grammar violations.**

## Good practices

- **Start from domain events**, then ask where each comes from: a user decision → command, an external system, time, or a cascading reaction → policy.
- **Listen and track terms** — collect the words people use (Order, Reservation, Seat, Invoice…). Some are synonyms, some aren't; this is your ubiquitous language and a clue to bounded contexts.
- **Watch for symmetries** — they're a cheap correctness check:
  - *Cause/effect symmetry*: a command's effect should echo the command ("reserve seat" → "seat reserved").
  - *Complementary commands*: most actions have a reverse ("place reservation" / "cancel reservation"). Say it out loud — "place/cancel reservation" beats "lock/release seat".
  - *Open-close symmetry*: whatever you open at the start should be closed at the end (same constraint/state machine). If it isn't, something is left in an inconsistent state.
- **Pivotal events** — pick the 3–4 events that define key moments; they're candidate **bounded-context boundaries** (technical homework after acceptance).
- **Temporal milestones** — for season/big-bang-driven domains, lay blue time markers across the timeline.
- **Mark uncertainty as a hotspot** rather than guessing.

## Self-review checklist (run BEFORE showing the user)

After producing or editing any diagram, verify — and fix — before presenting. Re-run this **every** time the diagram changes:

1. **Color grammar — adjacencies.** Every edge is in the legal table; read models feed the **actor** (Read model → Actor → Command), not the command, wherever a person decides; no event→command, command→event, or read-model→external-system; a lilac sits between every orange→blue reaction.
2. **Tense/voice.** Events past tense; commands imperative; policies "whenever…".
3. **Constraints.** Yellow stickies list conditions (not aggregate nouns); failure/rejection events modeled where a constraint can fail.
4. **Causality.** Every event has a cause (constraint / external system / temporal); every command a trigger (actor / policy / time). No orphans except marked hotspots.
5. **External systems.** Each genuinely participates; no storage/plumbing on the board.
6. **Rules of the game.** Each process ends in Event+Read model; stakeholders' value visible; hotspots all have a home.
7. **Language & level.** Domain terms, consistent; uniformly process-level; no UI/DB mechanics.
8. **Symmetries.** Cause/effect and open-close symmetries hold (or the asymmetry is intentional and noted).
9. **Renders.** The mermaid parses (palette block present; unique node ids; quoted labels).

Only after this passes do you show the diagram and ask the user to validate.

## Validation with the user (Stage 8)

Drive the validation actively — don't just ask "looks right?":

- **Explicit walkthrough, three roles.** You *tell the story* (as the naive narrator — being wrong is useful, it makes experts correct you), the user *validates* it, and you *keep the model in sync* (add events, split lanes, rewrite) as you learn.
- **Forward narrative.** Read the timeline left-to-right as plain English. Where does the user hesitate?
- **Reverse narrative** (the most powerful consistency check). Pick a terminal or pivotal event and walk backward: *"which events need to happen for this one to be possible?"* This reliably surfaces forgotten preconditions and unexplored alternatives ("this needs to happen here — but what if it doesn't?").
- **Pivotal events.** Confirm the 3–4 events that change the process's phase.
- **Hotspots — address every one.** For each red sticky: raise it, propose a concrete resolution (or two options), let the user choose. Resolving a hotspot edits the diagram → re-run the self-review checklist.
- **Value & opportunities.** Ask *why* each actor does what they do and whether they're reasonably happy (money isn't the only currency — time, stress, trust count). Mark opportunities (green) and problems (magenta). Challenge policies by repeating them with **"always"** and **"immediately"** and watching the expert auto-correct.

Treat acceptance as explicit: the user confirms the storming reflects the real process before you move to the implementation plan.
