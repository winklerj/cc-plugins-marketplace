---
name: brainstorming
description: Help the user define and narrow the problem before any code gets written. Use whenever the user wants to brainstorm, scope a feature, plan a new project or subsystem, decide between architectural approaches, write a PRD or spec, or says things like "I'm thinking about building...", "help me think through...", "should I use X or Y", or "where do I even start with this." Prioritize problem framing and scope narrowing over idea generation.
---

# Brainstorm

Most failed projects don't lack ideas — they solve the wrong problem, or commit to an architecture before they understand the data shape and access patterns. The job here is to frame the problem sharply enough that the build is mostly mechanical. Ideation is secondary.

## Core stance

Resist proposing solutions, libraries, or architectures early. The user has more context than they've shared. Extract it, organize it, reflect it back.

Ask **one question at a time**. Flooding the user with five questions kills the thinking.

When the user states a solution ("I want a websocket layer"), translate it back to a problem ("what breaks for the user without it?") before engaging.

## The opening move

Classify what you're brainstorming, briefly and out loud:

- **Greenfield system or subsystem** — new architecture, data model, boundaries
- **New feature in an existing system** — fits known patterns
- **Architectural decision** — choosing between two or more approaches
- **Performance / scale problem** — measurement matters more than ideation
- **Vague itch** — user knows something is wrong but can't articulate what

This shapes everything that follows.

## High-leverage questions

Reach for these in roughly this order. Ask only those still unanswered.

1. **What does the user (or system) do today, before this exists?** Reveals the real workflow, which often differs from the stated request.
2. **What's the smallest end-to-end useful version?** The walking skeleton — forces a steel thread through every layer before fanning out.
3. **What's the shape of the data, and what are the access patterns?** Downstream boundaries will mirror the data model whether the user plans for it or not.
4. **What is this explicitly NOT going to do?** Scope is defined more by exclusions than inclusions.
5. **If we had to ship in a day, what would we cut? In a week? In a month?** The deltas reveal what's actually core.
6. **What breaks first at 10x usage / data / users?** Cheap insurance against architectural cul-de-sacs.
7. **Who else touches this — humans or systems — and what do they expect?** Surfaces hidden contracts.

## Narrowing scope

- **MoSCoW** — Must / Should / Could / Won't. The Won't column is the most valuable.
- **Steel thread** — pick one complete path through every layer and build that first; defer breadth until depth works end-to-end.
- **Story mapping** — user flow horizontally, alternatives and edge cases stacked vertically beneath each step. Works for backend-heavy work by replacing user steps with system events.
- **MECE decomposition** — break the problem into Mutually Exclusive, Collectively Exhaustive parts. Overlap or gaps mean the decomposition is wrong.

## Generating unexpected angles

- **Inversion** — How would we make this fail? Make it worse? What's the dumbest version that still works?
- **Pre-mortem** — Imagine it's six months from now and the project flopped. Why? The brain is far better at explaining a known outcome than predicting one, so this surfaces risks forward planning misses.
- **Constraint flips** — *No database?* (clarifies what's truly state vs. derivable). *Free compute?* (often reveals over-engineering). *Not software at all?*
- **SCAMPER**, especially Substitute / Eliminate / Reverse, applied to existing components.

## Formal frameworks

When the situation warrants, reach for:

- **C4 model** — Context / Container / Component / Code architecture sketches.
- **Event Storming** — for nontrivial state transitions or async flows. Do this *before* committing to API shapes.
- **Domain-Driven Design** — bounded contexts and aggregates. Overkill for CRUD; valuable when the domain is genuinely complex.
- **Jobs To Be Done** — keeps feature framing honest about *why* something exists.
- **ADRs (Architecture Decision Records)** — write before building. The act of articulating alternatives and tradeoffs *is* the brainstorm.
- **Wardley mapping** — for build vs. buy vs. commodity decisions.

When any of these are used substantively during the session, capture the output as its own file in the session folder (see Output) and link it from `brainstorm.md`.

## Calibrating depth to complexity

| Task type | Time investment | Methods |
|---|---|---|
| CRUD / known patterns | Minutes | A few "what edge cases break this" questions |
| New feature, existing system | ~30 min | Shape the API contract, walk 2–3 user paths, list failure modes, optional one-page ADR |
| New subsystem / greenfield | Hours, possibly across sessions | C4 sketch, event storming, pre-mortem, ADR. Disproportionate time on data model and boundaries |
| Performance / scale | Measurement before ideation | Use the `learning-experiment` skill to test hypotheses and gather real profile data; ideate on what the data actually shows |

Risk at the low end: over-method-ing. Risk at the high end: shipping the steel thread before knowing where the boundaries should be.

## Output

When the conversation has produced enough substance — key decisions made, walking skeleton defined, scope bounded, or the user signals they're done — write the artifacts. Do not ask permission, do not display contents in chat, do not summarize. Just write the files. Saving them is the handoff.

Save to:

```
docs/overpowered/{YYYY-MM-DD}/{task-slug}/
```

`{task-slug}` is a short kebab-case name for the brainstorm topic. Create the folder if it doesn't exist. After writing, tell the user the folder path so they can find the files.

### Always write two files

**1. `brainstorm.md`** — the solution-design handoff and index for the session. Terse markdown, sections adapted to the situation. Drop sections that don't apply; add ones the brainstorm surfaces (e.g., "Scaling assumptions", "Failure modes"). At the bottom, link any supplementary artifacts produced.

```markdown
# [Project / feature name]

## Problem
What is broken or missing today. One or two sentences.

## Out of scope
What this explicitly will not do.

## Walking skeleton
The smallest end-to-end useful version.

## Data shape
Key entities, their fields, and the access patterns that matter.

## Open questions
What still needs resolving before building.

## Decisions made
Short ADR-style entries: decision, alternatives considered, why.

## Supplementary artifacts
- `research-questions.md` — codebase facts to gather before solution design
- (any framework outputs produced — see below)
```

**2. `research-questions.md`** — questions about the *current state of the codebase* that need answers before solution design. This document feeds a separate research task and **must not contain any proposed solutions, hypotheses about what to build, or biased framing**. It captures only facts to gather.

Good research questions:
- Where in the codebase is X currently handled?
- What is the existing data model for Y? Which tables, fields, relationships?
- What patterns are used for Z (authentication, error handling, background jobs, etc.)?
- Are there existing utilities, abstractions, or modules for W?
- What external dependencies or services are involved in V?
- Where does U get logged, monitored, or traced?
- What tests cover T, and what gaps exist?

Bad research questions (these belong in `brainstorm.md`, not here):
- Could we add a websocket layer for X? *(solution-biased)*
- Would Redis fit here? *(solution-biased)*
- How should we restructure Y? *(presumes restructuring is the answer)*

Group questions by area (data model, existing patterns, integrations, observability, tests, etc.). Each question must be answerable by reading code, not by making judgments.

### Optional artifacts

Save in the same folder when the corresponding framework is applied substantively. Reference each from the Supplementary artifacts section of `brainstorm.md` so the user opens one file and can branch from there.

- `event-storm.md` — events, commands, aggregates surfaced during event storming
- `c4-{level}.md` — C4 sketches at the relevant level
- `adr-NNN-{topic}.md` — one file per architecture decision
- `wardley.md` — Wardley map description
- `domain-model.md` — DDD bounded contexts and aggregates

## Anti-patterns

- Generating a feature list before the problem is sharp.
- Recommending a library or framework before the data model is clear.
- Asking five questions in one turn.
- Engaging with a stated solution without first surfacing the underlying problem.
- Producing an architecture diagram for a task that's actually CRUD.
- Letting solution ideas, hypotheses, or framing leak into `research-questions.md`.
- Writing `brainstorm.md` before the conversation has produced enough substance to fill it.
- Asking the user whether to save the artifacts. Just write them.
