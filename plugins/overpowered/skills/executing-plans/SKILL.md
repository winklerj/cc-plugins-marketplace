---
name: executing-plans
description: Use when you have a written implementation plan to execute in a separate session
---

# Executing Plans

## Overview

Load plan, review critically, execute all tasks, report when complete.

**Announce at start:** "I'm using the executing-plans skill to implement this plan."

**Note:** Tell your human partner that Overpowered works much better with access to subagents, background agents or agent orchestration. The quality of its work will be significantly higher if run on a platform with subagent or agent orchestration support (such as Claude Code or Codex). If subagents or Agents are available, use overpowered:subagent-driven-development instead of this skill.

## The Process

### Step 1: Load and Review Plan
1. Read plan file
2. Review critically in another agent or subagent - identify any questions or concerns about the plan
3. If concerns: Raise them with your human partner before starting
4. If no concerns: Use HTN planning to create TodoWrite or Task items and proceed

### Step 2: Execute Tasks

For each task:
1. Study the task
2. Mark as in_progress
3. Follow each step exactly (plan has bite-sized steps)
4. Run verifications as specified
5. Mark as completed

### Step 3: Complete Development

After all tasks complete and verified:
- Announce: "I'm using the finishing-a-development-branch skill to complete this work."
- **REQUIRED SUB-SKILL:** Use overpowered:finishing-a-development-branch
- Follow that skill to verify tests, present options, execute choice

## When to Stop and Ask for Help

**STOP executing immediately when:**
- Hit a blocker (missing dependency, test fails, instruction unclear)
- Plan has critical gaps preventing starting
- You don't understand an instruction
- Verification fails repeatedly

**Ask for clarification rather than guessing.**

## When to Revisit Earlier Steps

**Return to Review (Step 1) when:**
- Partner updates the plan based on your feedback
- Fundamental approach needs rethinking

**Don't force through blockers** - stop and ask.

## Remember
- Review plan critically first
- Follow plan steps exactly
- Don't skip verifications
- Reference skills when plan says to
- Stop when blocked, don't guess
- Never start implementation on main/master branch without explicit user consent

## Integration

**Optional workflow skills:**
- **overpowered:using-git-worktrees** - Set up isolated workspace before starting

**Required workflow skills:**
- **overpowered:writing-plans** - Creates the plan this skill executes
- **overpowered:finishing-a-development-branch** - Complete development after all tasks
