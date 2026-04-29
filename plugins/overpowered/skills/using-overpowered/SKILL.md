---
name: using-overpowered
description: Use when starting any conversation - establishes how to find and use skills, requiring Skill tool invocation before ANY response including clarifying questions
---

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, skip this skill.
</SUBAGENT-STOP>

<EXTREMELY-IMPORTANT>
If you think there is even a 1% chance a skill might apply to what you are doing, you ABSOLUTELY MUST invoke the skill.

IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.

This is not negotiable. This is not optional. You cannot rationalize your way out of this.
</EXTREMELY-IMPORTANT>

## Instruction Priority

Overpowered skills override default system prompt behavior, but **user instructions always take precedence**:

1. **User's explicit instructions** (CLAUDE.md, GEMINI.md, AGENTS.md, direct requests) — highest priority
2. **Overpowered skills** — override default system behavior where they conflict
3. **Default system prompt** — lowest priority

Instructions say WHAT, not HOW. "Add X" or "Fix Y" doesn't mean skip workflows.

## How to Access Skills

**In Claude Code:** Use the `Skill` tool. When you invoke a skill, its content is loaded and presented to you—follow it directly. Never use the Read tool on skill files.

**In other environments:** Check your platform's documentation. Skills use Claude Code tool names; non-CC platforms see `references/copilot-tools.md` (Copilot CLI) or `references/codex-tools.md` (Codex) for tool equivalents. Gemini CLI users get the tool mapping loaded automatically via GEMINI.md.

# Using Skills

## The Rule

**Invoke relevant or requested skills BEFORE any response or action.** Even a 1% chance a skill might apply means that you should invoke the skill to check. If an invoked skill turns out to be wrong for the situation, you don't need to use it.

See `references/skill-flow.md` for the full decision flowchart.

When multiple skills could apply, or to understand rigid vs. flexible skill types, see `references/choosing-skills.md`.

## Red Flags

These thoughts mean STOP—you're rationalizing:

| Thought | Reality |
|---------|---------|
| "Simple question / not a real task / overkill" | Questions and actions are tasks. Check for skills. |
| "Let me get context / explore / check files first" | Skills tell you HOW to gather context. Check first. |
| "I remember this skill / I know what that means" | Skills evolve, and knowing ≠ using. Invoke it. |
| "I'll just do this one thing first" | Check BEFORE doing anything. |
