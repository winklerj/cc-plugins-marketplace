# Design Explainer — Prompt Template

Use this template to generate a learning-oriented design document aimed at a junior engineer. Fill in the bracketed sections, delete any you don't need, then paste the whole thing as a prompt.

---

## Role and audience

You are writing a design explainer for a **junior engineer** who is competent at coding but new to this system. Optimize for understanding, not exhaustiveness. Prefer short sentences, concrete examples, and prose over bullet lists. Use Mermaid diagrams where they genuinely help (`flowchart` for structure, `sequenceDiagram` for time-based flows, `stateDiagram-v2` for state machines). Do not diagram for the sake of diagramming.

## Inputs

**Design / system name:** [NAME]

**One-sentence description:** [WHAT IT IS]

**Source material to draw from:** [PASTE CODE, EXISTING DOCS, RFCS, TICKETS, TRANSCRIPTS, OR LINKS HERE]

**Known areas of confusion for newcomers (optional):** [E.G. "PEOPLE ALWAYS CONFUSE THE QUEUE WITH THE BUFFER"]

## Required structure

Produce a markdown document with the following sections, in this order. Include every heading even if the section is brief.

### 1. Context and motivation
What problem does this design solve? What was the situation before, and why wasn't it good enough? Mention one or two alternatives that were considered and rejected, with the reason.

### 2. Goals and non-goals
Two short lists. Non-goals are as important as goals — they tell the reader what they can stop worrying about.

### 3. Glossary
Define any domain-specific or overloaded terms that appear later. If a common word (e.g. "session", "tenant", "job") has a specific meaning here, say so.

### 4. High-level overview
One Mermaid `flowchart` with roughly 5–7 boxes showing the major components and their connections, followed by a paragraph of prose explaining the picture. This is the one diagram the reader should remember — make it clear.

### 5. Component deep-dives
One subsection per major component. For each, cover:
- What it owns (and what it deliberately doesn't)
- Its inputs and outputs
- Any interesting internal state or invariants

Keep each deep-dive focused; link out rather than inlining everything.

### 6. Key flows
Pick 2–4 representative scenarios that together exercise most of the system. Good candidates: the happy path, a cache miss or cold start, a failure and recovery, a config change. For each, use a Mermaid `sequenceDiagram` and a short narrative walkthrough.

### 7. Trade-offs and alternatives considered
A short section. For each major decision, one line on what was chosen and one line on what was rejected and why. Builds trust that the design is intentional.

### 8. Gotchas and common mistakes
The stuff that actually trips people up. Subtle ordering requirements, silent failure modes, easy-to-misread names, places where the code does the opposite of what it looks like it does. This section pays dividends for years.

### 9. Where to go next
Pointers to the code entry point, related docs, the on-call runbook if relevant, and ideally one small exercise the reader can do to verify understanding (e.g. "trace what happens when a request arrives with an expired token").

## Style rules

- Write in prose paragraphs by default; reserve bullets for genuinely enumerable things.
- Explain *why* before *how*. A junior can read the code for *how*.
- Prefer one excellent diagram over three mediocre ones. If a Mermaid diagram is getting messy, drop it and describe the thing in words instead.
- Avoid jargon that isn't in the glossary.
- When you introduce a component, say what it replaces or wraps — tying new things to familiar ones accelerates understanding.
- Call out anything counterintuitive explicitly ("you might expect X, but actually Y, because…").

## Output

Return the full document as markdown, ready to commit to a repo.
