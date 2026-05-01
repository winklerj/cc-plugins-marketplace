---
name: brainstorming
description: "You MUST use this before any creative work - creating features, building components, adding functionality, or modifying behavior. Explores user intent before permorming codebase research."
---
# Questions for the User

You are tasked with formulating focused questions for the user *before* doing work (to confirm scope and resolve genuine ambiguity). This command defines the shared question-handling pattern used by other commands such as `/research_codebase` and `/create_plan`.

## Core principle

**Only ask questions that you genuinely cannot answer through code investigation, file reading, or sub-agent research.** Every question you put to the user is a context switch for them — earn it. If you can find the answer by reading the codebase, do that first.

## When to use this pattern

- **Before** starting a research, planning, or implementation task — to surface assumptions, scope ambiguity, or design preferences that the code cannot tell you.
- **After** presenting findings, a plan, or implementation results — to invite follow-up investigation or refinement.

Do NOT use this pattern to:
- Re-confirm details already stated clearly in the user's request
- Ask for information that is plainly visible in the files or git history
- Stall a task that has enough context to proceed

## Pre-task: present informed understanding and focused questions

Before asking anything, you should already have:
1. Read all files the user mentioned (FULLY — no `limit`/`offset`)
2. Spawned locator/analyzer sub-agents to map the relevant code
3. Cross-referenced the user's request against the actual codebase

Then present your understanding and only the questions that remain:

```
Based on [the ticket / your request] and my research of the codebase, I understand we need to [accurate summary].

I've found that:
- [Current implementation detail with file:line reference]
- [Relevant pattern or constraint discovered]
- [Potential complexity or edge case identified]

Questions that my research couldn't answer:
- [Specific technical question that requires human judgment]
- [Business logic clarification]
- [Design preference that affects implementation]
```

If the user corrects a misunderstanding in their answer:
- DO NOT just accept the correction
- Spawn new research tasks to verify the correct information
- Read the specific files/directories they mention
- Only proceed once you've verified the facts yourself

## Post-task: present findings and invite follow-ups

After delivering the primary output (research document, plan, implementation):

1. **Present a concise summary** of what was produced
2. **Include key file references** for easy navigation (use `file:line` format)
3. **Ask whether the user has follow-up questions or needs clarification**

## Handling follow-up questions

When the user has follow-up questions on a task that produced a document (e.g., a research document or plan):

- Append to the **same** document — do not create a new one
- Update the frontmatter:
  - `last_updated`: today's date in `YYYY-MM-DD` format
  - `last_updated_by`: researcher / planner name
  - `last_updated_note`: `"Added follow-up [research|planning] for [brief description]"`
- Add a new section heading: `## Follow-up [Research|Planning] [timestamp]`
- Spawn new sub-agents as needed for additional investigation
- Continue updating the document until the user is satisfied

## Quality bar for questions

A good question:
- Names the specific decision, file, or behavior in question
- Explains *why* you're asking (what choice it unblocks)
- Offers concrete options when there's a clear set (e.g., "A or B?")
- Cannot reasonably be answered by reading the code

A bad question:
- Is open-ended in a way that pushes the design work back to the user
- Asks something already stated in the ticket or request
- Bundles multiple unrelated decisions into one prompt
