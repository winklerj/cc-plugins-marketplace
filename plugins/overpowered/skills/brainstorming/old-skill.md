---
name: brainstorming
description: "You MUST use this before any creative work - creating features, building components, adding functionality, or modifying behavior. Explores user intent, requirements and design before implementation."
---

# Brainstorming Ideas Into Designs

Help turn ideas into fully formed designs and specs through natural collaborative dialogue.

Start by understanding the current project context, then ask questions one at a time to refine the idea. Once you understand what you're building, present the design and get user approval.

<HARD-GATE>
Do NOT invoke any implementation skill, write any code, scaffold any project, or take any implementation action until you have presented a documented design and the user has approved it.
</HARD-GATE>

## Checklist

You MUST create a task for each of these items and complete them in order:

1. **Explore project context in subagents in subagent(s)** — check files, docs, recent commits
2. **Ask clarifying questions** — one at a time, understand purpose/constraints/success criteria
3. **Propose /learning-experiment** — to provide real data to support approach decisions
3. **Propose 2-3 approaches** — with trade-offs and your recommendation
4. **Present findings** - in sections scaled to their complexity, get user approval
5. **Write findings doc** — save to `docs/overpowered/research/YYYY-MM-DD-<topic>-findings.md` and commit
6. **Transition to research_codebase** — invoke research_codebase command to create file and line level findings relavant to task questions and answers

## Process Flow

```dot
digraph brainstorming {
    "Explore project context in subagents" [shape=box];
    "Visual questions ahead?" [shape=diamond];
    "Use Visual Companion\n(own message, no other content)" [shape=box];
    "Ask clarifying questions" [shape=box];
    "Propose /learning-experiment" [shape=box];
    "Propose 2-3 approaches" [shape=box];
    "Present findings sections" [shape=box];
    "User approves findings?" [shape=diamond];
    "Write findings doc\n(commit to git)" [shape=box];
    "Transition to research_codebase" [shape=doublecircle];

    "Explore project context in subagents" -> "Visual questions ahead?";
    "Visual questions ahead?" -> "Use Visual Companion\n(own message, no other content)" [label="yes"];
    "Visual questions ahead?" -> "Ask clarifying questions" [label="no"];
    "Use Visual Companion\n(own message, no other content)" -> "Ask clarifying questions";
    "Ask clarifying questions" -> "Propose /learning-experiment";
    "Propose /learning-experiment" -> "Propose 2-3 approaches";
    "Propose 2-3 approaches" -> "Present findings sections";
    "Present findings sections" -> "User approves findings?";
    "User approves findings?" -> "Present findings sections" [label="no, revise"];
    "User approves findings?" -> "Write findings doc\n(commit to git)" [label="yes"];
    "Write findings doc\n(commit to git)" -> "Transition to research_codebase";
}
```

**The terminal state is invoking research_codebase.** Do NOT invoke frontend-design, mcp-builder, or any other implementation skill. The ONLY skill you invoke after brainstorming is research_codebase.

## The Process

**Understanding the idea:**

- Check out the current project state first (files, docs, recent commits)
- Before asking detailed questions, assess scope: if the request describes multiple independent subsystems (e.g., "build a platform with chat, file storage, billing, and analytics"), flag this immediately. Don't spend questions refining details of a project that needs to be decomposed first.
- If the project is too large for a single spec, help the user decompose into sub-projects: what are the independent pieces, how do they relate, what order should they be built? Then brainstorm the first sub-project through the normal design flow. Each sub-project gets its own spec → plan → implementation cycle.
- For appropriately-scoped projects, ask questions one at a time to refine the idea
- Prefer multiple choice questions when possible, but open-ended is fine too
- Only one question per message - if a topic needs more exploration, break it into multiple questions
- Focus on understanding: purpose, constraints, success criteria

**Exploring approaches:**

- Propose 2-3 different approaches with trade-offs
- Present options conversationally with your recommendation and reasoning
- Lead with your recommended option and explain why

**Presenting the design:**

- Once you believe you understand what you're building, present the design
- Scale each section to its complexity: a few sentences if straightforward, up to 200-300 words if nuanced
- Ask after each section whether it looks right so far
- Cover: architecture, components, data flow, error handling, testing
- Be ready to go back and clarify if something doesn't make sense

**Design for isolation and clarity:**

- Break the system into smaller units that each have one clear purpose, communicate through well-defined interfaces, and can be understood and tested independently
- For each unit, you should be able to answer: what does it do, how do you use it, and what does it depend on?
- Can someone understand what a unit does without reading its internals? Can you change the internals without breaking consumers? If not, the boundaries need work.
- Smaller, well-bounded units are also easier for you to work with - you reason better about code you can hold in context at once, and your edits are more reliable when files are focused. When a file grows large, that's often a signal that it's doing too much.

**Working in existing codebases:**

- Explore the current structure before proposing changes. Follow existing patterns.
- Where existing code has problems that affect the work (e.g., a file that's grown too large, unclear boundaries, tangled responsibilities), include targeted improvements as part of the design - the way a good developer improves code they're working in.
- Don't propose unrelated refactoring. Stay focused on what serves the current goal.

## After the Design

**Documentation:**

- Write the findings to `docs/overpowered/research/YYYY-MM-DD-<topic>-design.md`
  - (User preferences for finding location override this default)
- Commit the findings document

**User Review Gate:**
After the findings review loop passes, ask the user to review the written findings before proceeding:

> "Findings written and committed to `<path>`. Please review it and let me know if you want to make any changes before we start writing out the implementation plan."

Wait for the user's response. If they request changes, make them and re-run the findings review loop. Only proceed once the user approves.

**Implementation:**

- Invoke the research_codebase skill to create a detailed implementation plan

## Key Principles

- **One question at a time** - Don't overwhelm with multiple questions
- **Multiple choice preferred** - Easier to answer than open-ended when possible
- **YAGNI ruthlessly** - all things considered optimize coherent expected value
- **Explore alternatives** - Always propose 2-3 approaches before settling
- **Incremental validation** - Present findings, get approval before moving on
- **Be flexible** - Go back and clarify when something doesn't make sense
