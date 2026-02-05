---
description: Create an Architecture Decision Record (ADR) for documenting important decisions
allowed-tools:
  - Read
  - Glob
  - Grep
  - LS
  - Write
  - Edit
argument-hint: "<title> - Title of the architecture decision"
---

# Create ADR Command

Create a new Architecture Decision Record to document an important architectural decision.

## Process

1. **Check for existing ADR directory** in common locations:
   - `docs/architecture/decisions/`
   - `docs/adr/`
   - `adr/`

2. **Create directory if needed** using the first standard location

3. **Determine the next ADR number** by scanning existing ADRs

4. **Gather decision context** through conversation:
   - What is the problem or opportunity?
   - What decision are you making?
   - What alternatives were considered?
   - What are the expected consequences?

5. **Generate the ADR** following the standard template

6. **Update the ADR index** if a README.md exists in the ADR directory

## Usage Examples

```
/arch:adr Use PostgreSQL for user data storage
```
Creates an ADR about the database choice with guided questions

```
/arch:adr Adopt event-driven architecture for order processing
```
Creates an ADR about an architectural pattern decision

```
/arch:adr Implement rate limiting with Redis
```
Creates an ADR about a technical implementation decision

## ADR Template

The generated ADR will follow this structure:

```markdown
# ADR-XXX: [Title]

## Status
Proposed

## Date
[Today's date]

## Context
[Problem description and forces at play]

## Decision
[The decision being made]

## Consequences

### Positive
- [Benefits]

### Negative
- [Drawbacks]

### Neutral
- [Side effects]

## Alternatives Considered
[Other options and why they weren't chosen]

## References
[Related documents and links]
```

## Notes

- ADRs should be immutable once accepted
- Create a new ADR to supersede an old one rather than editing
- Keep the scope focused on a single decision
- Include enough context for future readers to understand the "why"
