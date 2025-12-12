---
name: solve-it
description: Structured problem-solving using George Polya's "How to Solve It" methodology adapted for software engineering. Use when stuck on a difficult problem, debugging complex bugs, can't figure out an approach, facing architectural decisions, need systematic debugging help, or when user mentions "stuck", "difficult problem", "how to approach", "can't figure out", or "Polya method".
---

# Solve It: Polya's Problem-Solving Method for Software

A systematic approach to solving difficult software problems based on George Polya's classic methodology.

## The Four Phases

1. **Understand the Problem** - Clarify what you're solving
2. **Devise a Plan** - Find an approach
3. **Carry Out the Plan** - Execute with verification
4. **Look Back** - Reflect and record learnings

## Phase 1: Understanding the Problem

Before solving, ensure you truly understand:

| Question | Software Translation |
|----------|---------------------|
| What is the unknown? | What should the code do? Expected behavior? |
| What are the data? | What inputs, state, context do you have? |
| What is the condition? | What constraints exist? (performance, compatibility, security) |
| Is the condition sufficient? | Do you have enough info to solve this? |
| Can you draw a figure? | Diagram the architecture, data flow, state transitions |
| Separate the parts | Which components work? Which don't? |

**Key actions:**
- Reproduce the problem
- Articulate expected vs actual behavior
- List all constraints and requirements
- Identify what you know vs what you need to find out

## Phase 2: Devising a Plan

Work through these heuristics to find an approach:

**Pattern Recognition:**
- Have you solved a similar problem before?
- Is there a related solution in the codebase?
- Do you know a pattern, algorithm, or library that fits?

**Adaptation:**
- Can you use an existing solution's method?
- Can you adapt code from a similar feature?

**Simplification:**
- Can you solve a simpler version first?
- What if you ignore constraint X temporarily?
- Can you solve just one part of the problem?

**Reformulation:**
- Can you restate the problem differently?
- Go back to definitions - check docs, specs, types

**Completeness check:**
- Did you use all the available information?
- Did you check all error messages, logs, stack traces?

### Safe Requirement Rephrasing

When restating or simplifying problems, preserve critical constraints:

- **Compare** your restatement to the original requirements
- **List** what was preserved vs. changed
- **Confirm** before proceeding with a simplified version
- **Document** dropped constraints and why they're safe to drop
- Prefer "What if we temporarily ignore X?" over permanently dropping

## Phase 3: Carrying Out the Plan

Execute your plan with verification:

- Implement step by step
- **Verify each step** - Can you prove it's correct?
- Track what you've tried and results
- If stuck, return to Phase 2 for a different approach

## Phase 4: Looking Back

After solving, reflect:

- Does the solution actually work? Verify with tests
- Is there a simpler solution?
- What did you learn?
- Can you apply this solution to other problems?

**Record your learnings:** Run `/solve-it:diary` to capture:
- What the problem was
- How you solved it
- Key insights discovered
- Patterns that might help in future

## Quick Reference Checklist

```
[ ] UNDERSTAND
    [ ] Can I state what should happen vs what happens?
    [ ] Can I reproduce the problem?
    [ ] Do I know all constraints?
    [ ] Have I diagrammed the relevant parts?

[ ] PLAN
    [ ] Have I seen something similar before?
    [ ] Can I find related code/solutions?
    [ ] Can I simplify the problem first?
    [ ] Did I check all available info (logs, errors, docs)?

[ ] EXECUTE
    [ ] Am I verifying each step?
    [ ] Am I tracking what I've tried?

[ ] LOOK BACK
    [ ] Does it actually work?
    [ ] Is there a simpler way?
    [ ] What did I learn?
    [ ] Did I run /solve-it:diary?
```

## Resources

For detailed guidance, see:
- [workflows.md](references/workflows.md) - Step-by-step patterns for debugging, feature implementation, optimization
- [examples.md](references/examples.md) - Concrete scenarios applying the method
