---
name: feature-stormer
description: This skill should be used to turn a feature idea, change request, or an existing event-storming diagram into a reviewed, domain-driven implementation plan. Trigger it for "storm this feature", "run feature-stormer", "event-storm this and plan it", "I have an event storming, turn it into a plan", "design and plan this new capability", "do a gap analysis + event storming for X", or any request to model a business process (Brandolini-style event storming) and produce a gated, human-reviewed implementation plan grounded in the existing code. Use it even when the user only describes a task and never says "event storming" — whenever the work needs understanding a process, finding gaps/risks, modeling it, and producing an approved plan.
---

# Feature Stormer

Turn a task description — or an event storming the user already has — into a reviewed implementation plan, by walking a **gated, human-in-the-loop** pipeline: understand the code, analyse gaps and risks, model the business process as a Brandolini event storming, validate it with the user, then derive an archetype-grounded implementation plan. Interim work lives in drafts; the run ends with **one** consolidated markdown file.

This is a deliberate, multi-turn collaboration, not a one-shot generator. Going slow and asking is the point.

## Core principles (apply in every stage)

- **Human-gated.** Each stage ends at a checkpoint. Do not advance to the next stage until the user explicitly approves. State the gate; wait.
- **Ask, don't decide.** When you hit ambiguity, a missing acceptance criterion, an unclear boundary, or a design fork — surface it as a question. Never silently resolve it and move on. The user's domain knowledge is the input you cannot derive from code.
- **Drafts hold artifacts; the conversation holds decisions.** Write analysis, diagrams, and plans to draft files so the user can read them. But every question and every checkpoint also happens **in the terminal** — summarize what you produced and ask the open questions in chat. Never bury a question where the user must open a file to find it.
- **Domain language, not code.** Events, commands, and policies use the business's ubiquitous language ("booking confirmed"), never code identifiers (`BookingEntity.save()`).
- **Re-validate after every change.** Any edit to a diagram → re-run the event-storming self-review checklist before showing it. The grammar is easy to break with a one-line edit.
- **Simplest thing that fits.** Prefer reuse and the least machinery that satisfies the present need. Every proposed abstraction or generalization gets an explicit verdict (adopt now / defer / reject) — speculative reuse is a cost, not a win.
- **No silent breaks.** Every change is backward compatible or carries a migration plan. Say which.

## Workflow

Work through these stages in order. Read the referenced files when you reach the stage that needs them.

**1 — Gather input.** Detect the branch:
- *User has an event storming* (a diagram, a `*.md`/`*.mmd`, or a description of one): ingest it, restate it back, and treat Stage 5 as *validate & adapt* rather than *generate*.
- *User has only a task*: capture the task in their words. Ask for the goal, the actors, and the business outcome — not the solution.
Confirm the working-folder location for drafts (default `feature-stormer/<feature-slug>/` at repo root). → **Gate:** shared understanding of the task.

**2 — Understand the codebase context.** Explore the relevant code, bounded contexts, existing aggregates/events/policies, tests, and conventions (CLAUDE.md, existing event-storming/plan docs). Use the `Explore` agent for breadth. Summarize what already exists that this task touches or could reuse. → **Gate:** user confirms your read of the landscape.

**3 — Gap / risk analysis.** Interrogate the task for: missing or vague acceptance criteria; unclear scope boundaries (what's in / out, which contexts); missing test scenarios (edge cases, failure paths, concurrency); and backward-compatibility impact. List these as **open questions**, not decisions. See `references/templates.md` (gap categories). → **Gate:** none yet; questions feed Stage 4.

**4 — Draft analysis for review.** Write the draft analysis md (structure in `references/templates.md`): task summary, scope/out-of-scope, assumptions, gaps & risks, open questions. Then in the terminal: summarize it and ask the open questions. → **Gate:** user answers the questions / accepts the analysis.

**5 — Event storming (business-process level).** Produce the storming as a mermaid diagram. Read `references/event-storming.md` first — it is the law for color grammar (the palette **and** the allowed-adjacency connection rules), the constraint convention (list the business rules between command and event; never name aggregates), the Rules of the Game, building blocks, and anti-patterns. Then **run the self-review checklist** there before showing anything. If the user supplied a storming, validate it against the same checklist and adapt. → **Gate:** internal — diagram passes the checklist.

**6 — Per-process + joined diagrams.** Produce one mermaid diagram per business process **and** one joined diagram showing cross-process flow. Skeletons in `references/templates.md`. Add them to the analysis draft, and in the terminal summarize each and ask your questions. → **Gate:** user has seen all diagrams.

**7 — Readability check.** Ask whether the diagrams render readably. If not, generate SVGs into separate files via `scripts/render-svg.sh` (fallbacks documented inside). → **Gate:** user confirms readable.

**8 — Validate the storming with the user.** This is the heart of the modeling. Walk `references/event-storming.md` § *Validation with the user*: read the timeline forward as a narrative, then **backward from the outcome** to surface missing preconditions; locate pivotal/key events, hotspots, and opportunities. Ask about **each hotspot** and propose a resolution (Rule of the Game: none may be left dangling), and check the process ends in a stable state and every stakeholder is reasonably happy. After every diagram change, re-run the self-review checklist. → **Gate:** user **accepts** the event storming.

**9 — Implementation plan.** Only after acceptance. First ask if there's anything specific the user wants included. Then read `references/archetypes.md` and build the plan (structure in `references/templates.md`): for each candidate archetype from the reputable catalogs, do an explicit fit analysis; assess extending/sharing existing code; give a verdict on every generalization idea (guard against over-abstraction); state backward-compatibility or a migration plan; and define a **local-first** testing strategy with concrete tests. Add the plan to the draft. → **Gate:** none yet; leads to Stage 10.

**10 — Plan review.** Summarize the plan in the terminal and ask the review questions there (plan body stays in the draft). → **Gate:** user **approves** the plan.

**11 — Consolidate.** Replace all drafts with **one** consolidated markdown file (template in `references/templates.md`): Analysis + Event Storming (diagrams) + Implementation Plan. Confirm the final path, write it, then delete the draft working folder (confirm before deleting). → **Done.**

## Asking well

Most questions here are open-ended (domain judgement, trade-offs) — ask them as plain prose in the terminal. Reserve `AskUserQuestion` for genuinely discrete forks (e.g. "event-source this aggregate, or keep it CRUD?"). Batch related questions so the user isn't drip-fed.

## Working files & final output

- All interim artifacts live in the one working folder. The draft analysis grows in place across stages (it accretes the diagrams and then the plan).
- At Stage 11 the drafts are **dropped** in favour of a single consolidated file. The pipeline's value is the gated conversation; the repo should be left with one clean spec, not a trail of scratch files.

## References

- `references/event-storming.md` — color grammar (palette **and** allowed-adjacency connection rules), the constraint convention, the Rules of the Game, building blocks (Brandolini's definitions), common mistakes/antipatterns, symmetries, the self-review checklist, and validation-with-user techniques.
- `references/archetypes.md` — the fit-analysis method plus catalogs of named archetypes from reputable sources (Arlow & Neustadt, Fowler, Evans/Vernon, Hohpe & Woolf, GoF), and how event-storming shapes map to them.
- `references/templates.md` — gap categories, the draft-analysis structure, mermaid skeletons (per-process + joined), SVG rendering, and the final consolidated-spec template.
- `scripts/render-svg.sh` — render a `.mmd`/fenced mermaid block to SVG, with fallbacks when `mmdc` isn't installed.
