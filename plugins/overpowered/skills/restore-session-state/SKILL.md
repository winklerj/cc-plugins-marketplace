---
name: restore-session-state
description: Resume a working session from a previously saved state file. Use whenever the user provides a path to a file under docs/overpowered/session-state/, or says things like "continue where we left off", "pick up the last session", "resume the session on X", "load session state". Load the file and any artifacts it links to before responding.
---

# Restore session state

Session state files live at:

```
docs/overpowered/session-state/{YYYY-MM-DD}-{session-slug}.md
```

## Loading

The primary pattern is path-as-parameter: the user pastes the path returned by `save-session-state` and you load that file. No selection logic, no guessing. Read it directly.

Natural language is supported as a friendlier fallback:
- If the user names a session ("the auth refactor session", "yesterday's debugging conversation"), look for a matching file in `docs/overpowered/session-state/`. If multiple match, ask which one.
- If the user says only "where we left off" or "the last session", use the most recently modified file in that directory.
- If no file matches, say so plainly and ask for the path.

After loading the state file, also load any artifacts it links to under "Related artifacts" — those are usually where the substance lives. The state file alone is a thin index, not the whole picture.

## On resuming

Acknowledge the pickup briefly — name the topic and the "Where we left off" line. Do not recap the whole state file in chat; the user wrote it (or watched it get written) and doesn't need it read back.

Then either ask what the user wants to do next, or proceed with the natural next move if it's obvious from "Where we left off".

## Trusting the file

Treat sections according to their meaning:

- **Decided** entries are commitments. Don't reopen them unless the user does.
- **Under discussion** entries are live. They may need fresh thinking, not assumed resolution.
- **Rejected** entries should not be re-proposed. The "why" in the file is the reason; only reopen if the user explicitly does.
- **Open questions** are fair game to engage with.

If the file's `Saved by` field shows a different model or environment, treat the substance as still valid but be aware that style or assumptions may differ from the current session.

## Anti-patterns

- Recapping the entire state file as the first response.
- Treating "Under discussion" items as settled because they appear in the file.
- Re-proposing rejected options without the user reopening the topic.
- Loading the state file but ignoring the artifacts it links to.
- Guessing which file to load when multiple plausibly match — ask instead.
