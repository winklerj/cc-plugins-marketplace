---
name: save-session-state
description: Save the current state of a working session to disk so a later session can pick up cleanly. Use whenever the user wants to pause, says things like "save where we are", "I need to stop here", "save state before I lose it", "let's pick this up later", "pause here", "checkpoint this", or when you sense the conversation is approaching length-related drift and want to checkpoint before quality degrades. Captures decisions, open threads, rejections, and natural next moves — the in-flight thinking that hasn't yet earned its way into formal artifacts.
---

# Save session state

Long sessions degrade in a specific way: hedging compounds, earlier statements get treated as more settled than they were, abandoned threads quietly resurface as decisions. A session-state file captures the messy in-flight thinking so the next session can resume on a cleaner footing — without re-reading a noisy transcript.

This is a snapshot, not a summary. Capture what's actually true right now, including what's unresolved.

## Output

Write to:

```
docs/overpowered/session-state/{YYYY-MM-DD}-{session-slug}.md
```

`{session-slug}` is a short kebab-case name for what the session is about. If the session is tied to a tracked piece of work (a project, feature, ticket, or other folder under `docs/overpowered/`), use a matching slug so the relationship is obvious from filenames.

Do not ask permission. Do not display contents in chat. Just write the file. After writing, give the user the full path on its own line so they can copy it for a later restore.

## File template

Adapt sections to the situation. Drop ones that don't apply. Keep entries terse.

```markdown
# Session state: {topic}

Saved: {YYYY-MM-DD}
Saved by: {assistant model and environment, e.g. "Claude Opus 4.7 / claude.ai chat", "Claude Sonnet 4.6 / Claude Code"}

## Context
One or two sentences on what the session is about and why.

## Decided
Things that are settled. State them as commitments, not as discussion.
- ...

## Under discussion
Live threads where the user and assistant haven't converged. Note the current shape of the disagreement or uncertainty.
- ...

## Rejected (and why)
Options that were explicitly considered and dropped. Capturing the *why* prevents the next session from re-proposing them.
- ...

## Open questions
Things flagged but not yet engaged with.
- ...

## Where we left off
The last thing being discussed and the natural next move when resuming.

## Related artifacts
Links to design docs, code files, ADRs, tickets, or other documents the session references.
- ...
```

## What makes a good snapshot

- **Honest about settledness.** If something was discussed but not committed to, it goes under "Under discussion", not "Decided". Inflating decisions is the most common failure mode and the one that contaminates the next session.
- **Captures rejections with reasons.** "Not using X because Y" is more valuable than "not using X" — without the reason, the next session will re-litigate.
- **Points to artifacts, doesn't duplicate them.** If a design doc, ADR, or other artifact already captures the substance, the state file links to it rather than restating it.
- **Names the next move.** "Where we left off" should give the next session enough to act on without re-reading the transcript.

## Anti-patterns

- Treating this as a meeting summary. It's a working state, not a recap.
- Listing under "Decided" anything that wasn't explicitly committed to.
- Asking the user whether to save. Just write it.
- Repeating contents of formal artifacts instead of linking them.
- Padding with context the user already has loaded in their head — write for the future session, but only what the future session won't be able to reconstruct from the linked artifacts.
