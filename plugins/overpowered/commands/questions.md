---
name: questions
description: "Use before asking the user anything and after delivering output. Defines the shared question-handling pattern: surface only high-value-of-information questions (ones code can't answer), present informed understanding first, and invite follow-ups after. Referenced by /research_codebase, /create_plan, and other commands that interact with the user mid-task."
---
# Questions for the User

Formulate focused questions before and after work. Shared pattern used by `/research_codebase`, `/create_plan`, etc.

## Principle: Value of Information

Ask only questions with positive **value of information** — ones you cannot answer by reading code, where the answer changes what you'd build. Every question is a context switch for the user; earn it.

This is active learning: query only what you can't infer. Apply Grice's maxims — be informative, relevant, specific; no more.

## Pre-task: present understanding, then disambiguate

Before asking, you should already have:
1. Read all referenced files in full (no `limit`/`offset`)
2. Spawned locator/analyzer sub-agents to map relevant code
3. Cross-referenced the request against the codebase

Then:

```
Based on [request] and my research, I understand we need to [summary].

Findings:
- [detail with file:line]
- [pattern or constraint]
- [edge case]

Open questions (research couldn't resolve):
- [decision requiring human judgment]
- [business logic clarification]
- [design preference]
```

If the user corrects a misunderstanding: don't just accept it. Spawn new research, read the files they cite, verify before proceeding.

## Post-task: summarize and invite follow-ups

After delivering the output:
1. Concise summary of what was produced
2. Key `file:line` references
3. Invite follow-up questions

## Follow-ups on document outputs

When follow-ups extend a research doc or plan:
- Append to the **same** document
- Update frontmatter: `last_updated` (YYYY-MM-DD), `last_updated_by`, `last_updated_note: "Added follow-up [research|planning] for [description]"`
- Add section: `## Follow-up [Research|Planning] [timestamp]`
- Spawn new sub-agents as needed

## Anti-patterns

Don't ask questions that:
- Re-confirm what the request already states
- Could be answered by reading files or git history
- Are open-ended in ways that push design work back to the user
- Bundle multiple unrelated decisions
- Stall a task that has enough context to proceed
