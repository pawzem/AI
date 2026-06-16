# Archetypes — fit analysis from reputable catalogs

When deriving the implementation plan, don't invent structure ad hoc. Reach for **named, well-understood archetypes** from the literature, and for each plausible candidate do an honest fit analysis against *this* problem and *this* codebase. The goal is the **simplest archetype that fits**, with reuse preferred over new machinery.

"Archetype" here spans three layers — pick from each as relevant:
1. **Business/domain archetypes** — recurring shapes of the *domain model* itself.
2. **Application/architecture patterns** — how the domain logic is structured and persisted.
3. **Integration/behavioral patterns** — how parts react and communicate.

## The catalogs (cite the source you're drawing from)

**Arlow & Neustadt — *Enterprise Patterns and MDA: Building Better Software with Archetype Patterns and UML*.** The canonical *business archetype patterns* — primordial domain shapes that recur across enterprises, with built-in variation points ("pattern instances") for tailoring to a domain:
- **Party / PartyRelationship / Accountability** — people & organizations and the relationships/authorities between them.
- **Role** — a party playing a part (customer, staff, admin) rather than baking the part into the party.
- **Product** — the thing offered (a service type, a plan), distinct from its instances.
- **Inventory** — stock/availability of products or resources.
- **Order** — a request for products/services with line items and a lifecycle.
- **Quantity & Money** — typed amounts with units/currency (never raw `BigDecimal`/`int`).
- **Rule** — externalized business rules as first-class, configurable objects (think tenant-configurable policies).
Use these to recognize "we're reinventing Party/Order/Inventory" and to model variation as *configuration of an archetype* rather than a new bespoke type.

**Fowler — *Analysis Patterns: Reusable Object Models*.** Domain-analysis archetypes: **Accountability** (org structure, responsibility), **Party**, **Observation & Measurement** (typed measurements, phenomena), **Quantity**, **Range**, **Phenomenon Type**. Reach here when modeling measurements, classifications, or organizational responsibility.

**Fowler — *Patterns of Enterprise Application Architecture (PoEAA)*.** How to *structure and persist* the logic:
- Domain logic: **Transaction Script** (simple procedural), **Domain Model** (rich OO), **Table Module**, **Service Layer** (the facade over a use case).
- Data source: **Active Record**, **Data Mapper**, **Repository**, **Unit of Work**, **Identity Map**, **Query Object**.
- Distribution/state: **DTO**, **Remote Facade**, **Optimistic/Pessimistic Offline Lock**.
Choosing between Transaction Script and Domain Model is often the first real decision: rich invariants → Domain Model; thin "capture and route" logic → Transaction Script (don't over-model trivial flows).

**Evans — *Domain-Driven Design*; Vernon — *Implementing DDD*.** Tactical: **Aggregate** (consistency boundary — the yellow sticky's destiny), **Entity**, **Value Object**, **Domain Event**, **Domain Service**, **Factory**, **Repository**, **Specification** (composable rule objects). Strategic: **Bounded Context**, **Context Map**, **Anti-Corruption Layer**, **Published Language**, **Shared Kernel**. The storming maps almost directly: events→Domain Events, the constraint→Aggregate (now you name it), policies→Domain Services/Process Managers, green→read models.

**Hohpe & Woolf — *Enterprise Integration Patterns*.** When events cross boundaries: **Message / Channel / Message Router / Message Translator**, **Process Manager** (stateful coordinator for a multi-step flow — a purple policy that spans steps), **Aggregator**, **Idempotent Receiver**. Pair with **Saga** (Garcia-Molina & Salem; popularized for microservices by Richardson) for long-running, compensatable transactions, and the **Transactional Outbox** (Richardson, *Microservices Patterns* / microservices.io) for reliably publishing events from a transaction.

**Gamma et al. (GoF) — *Design Patterns*.** Object-level: **Strategy** (swap an algorithm — per-tenant/per-vertical behavior), **State** (lifecycle/status machines — a Visit moving through states), **Observer** (reactive listeners), **Template Method**, **Composite/Specification** (rule trees), **Adapter** (wrap an external system).

**CQRS & Event Sourcing** (Young; Fowler; Vernon). **CQRS**: separate write model from read models when their shapes diverge or reads vastly outnumber writes (many green stickies → candidate read models/projections). **Event Sourcing**: persist the events themselves and rebuild state — strong when history/audit/temporal reconstruction is core; costly when the domain is simple CRUD.

## Mapping storming shapes → archetypes (a starting lens, not a rulebook)

- **Orange event** → Domain Event / integration event (EIP Message); a pivotal event often marks a Bounded Context seam.
- **Yellow constraint** → DDD Aggregate (the constraint's business boundary becomes the aggregate); recognize it as an Arlow archetype where it fits (Order, Inventory, Party, Product…).
- **Purple policy** → Domain Service, **Process Manager**/**Saga** (if multi-step/long-running), or GoF **Observer**; a tenant-configurable policy → Arlow **Rule** archetype + GoF **Strategy**.
- **Green read model** → CQRS read model / projection; PoEAA **Query Object**.
- **Magenta external system** → **Anti-Corruption Layer** / GoF **Adapter** / PoEAA **Gateway**.
- **Per-vertical / per-tenant variation** → **Strategy** + Arlow **pattern instances** (configure the archetype) rather than a forked type hierarchy.
- **Money/quantity/measurement** → **Money** / **Quantity** / **Observation & Measurement** value objects, never primitives.

## The fit-analysis method (do this, don't just list)

For each archetype that plausibly applies, write a short, honest verdict:

> **<Archetype>** (source) — *Fits because:* … *Doesn't fit because:* … *Cost:* … → **adopt / defer / reject**

Then:

1. **Prefer reuse and extension.** Before introducing an archetype, check whether the existing code already realizes it (an aggregate, policy, read model, or service you can extend). Can the new process **share a model** with an existing one? Extending a proven model beats a parallel new one — say so explicitly when it applies.
2. **Pick the simplest that fits.** Transaction Script over Domain Model when invariants are thin. CRUD over Event Sourcing when there's no audit/temporal need. A direct policy over a full Saga when there's no compensation. Recommend one; justify why the heavier options are *not* warranted.
3. **Judge every generalization on its own.** For each "we could generalize this" idea, write a one-line verdict: **adopt now** (a concrete, present second use exists), **defer** (note it as a future seam, build the simple thing now), or **reject** (speculative). Too many abstraction layers is itself a defect — an abstraction with one caller is a liability. Make the trade-off visible rather than silently abstracting or silently not.
4. **Backward compatibility / migration.** State whether the change is backward compatible. If not, give a concrete migration plan (schema/data migration, dual-write/dual-read window, event versioning/upcasting, feature flag, rollout/rollback). Never a silent break.
5. **Local-first testing.** Prefer something testable on a laptop. Specify the tests the archetype implies — aggregate invariant tests, policy/saga reaction tests, read-model projection tests, contract tests at context boundaries, end-to-end against local infra (Docker Compose / in-memory stubs / local emulators) — and describe how to run them locally, with what to run on a deployed environment only when truly unavoidable.

The output of this stage feeds the *Implementation Plan* section of the consolidated spec (structure in `templates.md`).
