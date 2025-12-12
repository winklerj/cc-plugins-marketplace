# Solve It: Workflow Patterns

Detailed workflows applying Polya's method to common software engineering scenarios.

## Table of Contents
- [Debugging a Bug](#debugging-a-bug)
- [Implementing a Complex Feature](#implementing-a-complex-feature)
- [Performance Optimization](#performance-optimization)
- [Understanding Unfamiliar Code](#understanding-unfamiliar-code)
- [When You're Completely Stuck](#when-youre-completely-stuck)
- [Recording Learnings](#recording-learnings)

---

## Debugging a Bug

### Phase 1: Understand the Bug

1. **What is the expected behavior?** Write it down explicitly
2. **What is the actual behavior?** Document exactly what happens
3. **Can you reproduce it?**
   - Find minimal reproduction steps
   - Note: intermittent bugs need more data collection first
4. **What changed recently?** Check git history, deployments, config changes
5. **Draw the flow:** Trace the code path from input to output

### Phase 2: Devise a Debugging Plan

**Hypothesis formation:**
- What could cause this difference between expected and actual?
- List 3-5 hypotheses ranked by likelihood

**Information gathering plan:**
- What logs/traces would confirm or refute each hypothesis?
- Where should you add instrumentation?

**Simplification strategies:**
- Can you reproduce with simpler inputs?
- Can you isolate to a single component?
- What if you bypass X - does it still fail?

### Phase 3: Execute the Debugging Plan

1. Start with highest-likelihood hypothesis
2. Add targeted logging/tracing
3. Test hypothesis - did you confirm or refute?
4. If refuted, move to next hypothesis
5. Track everything you try and what you learned

### Phase 4: Look Back

- Root cause found - does the fix address it completely?
- Are there related bugs that share this root cause?
- Should you add regression tests?
- **Run `/solve-it:diary`** to record the debugging approach

---

## Implementing a Complex Feature

### Phase 1: Understand the Feature

1. **What is the desired outcome?** User story or acceptance criteria
2. **What are the inputs and outputs?** Data types, formats, sources
3. **What are the constraints?**
   - Performance requirements
   - Security requirements
   - Compatibility requirements
   - Timeline/scope constraints
4. **Draw the architecture:** How does this fit into the existing system?

### Phase 2: Devise an Implementation Plan

**Use a task tracking tool to capture your plan:**

If using **beads** (git-backed, local):
```
# Create parent feature
/beads:create "User Authentication System" -t feature -p 1

# Break into sub-tasks
/beads:create "JWT token generation" -t task -p 2
/beads:create "Password hashing" -t task -p 2
/beads:create "Login API endpoint" -t task -p 2

# Link dependencies
/beads:dep add <parent-id> <child-id> --type parent
/beads:dep add <blocker-id> <blocked-id> --type blocks
```

If using **Linear** (team-based):
- Create a project or cycle for the feature
- Break into issues with estimates
- Set dependencies and priorities

**Decomposition strategies:**
- Break into independent sub-tasks
- Identify dependencies between sub-tasks
- Find the smallest demonstrable increment

**Pattern matching:**
- Is there similar code in the codebase?
- What patterns does the codebase use for similar features?
- Are there libraries that solve part of this?

**Risk identification:**
- What's the riskiest/most uncertain part?
- Consider tackling that first (spike)

### Phase 3: Execute the Implementation

1. Start with the smallest working increment
2. Update task status as you work (`/beads:update <id> --status in_progress`)
3. Verify each component works before combining
4. Write tests as you go (or first, if TDD)
5. If blocked, return to Phase 2 with new information
6. Close completed tasks with detailed reasons (`/beads:close <id> --reason "..."`)

### Phase 4: Look Back

- Does it meet all acceptance criteria?
- Is the code clean and maintainable?
- What would you do differently next time?
- **Run `/solve-it:diary`** to capture design decisions

---

## Performance Optimization

### Phase 1: Understand the Performance Problem

1. **What is the performance target?** Specific numbers (latency, throughput)
2. **What is current performance?** Measure, don't guess
3. **Where is the bottleneck?** Profile before optimizing
4. **What are the constraints?** Memory, CPU, network, cost

### Phase 2: Devise an Optimization Plan

**Analysis:**
- What does profiling tell you?
- What's the theoretical limit?
- What's the biggest opportunity (80/20 rule)?

**Strategy selection:**
- Algorithmic improvement (big-O)
- Caching
- Parallelization
- Batching
- Resource allocation

**Simplification:**
- Can you optimize just the hot path?
- What if you relax constraint X?

### Phase 3: Execute the Optimization

1. Change ONE thing at a time
2. Measure after each change
3. Record: change made → performance impact
4. Stop when target is met (avoid premature optimization)

### Phase 4: Look Back

- Did you hit the target?
- What was the actual bottleneck vs your initial guess?
- Are there monitoring/alerts to catch regressions?
- **Run `/solve-it:diary`** to document what worked

---

## Understanding Unfamiliar Code

### Phase 1: Understand What You Need to Know

1. **What is your goal?** Fix a bug? Add a feature? Review?
2. **What scope do you need?** One function? One module? Whole system?
3. **What do you already know?** Language, framework, domain?

### Phase 2: Devise an Exploration Plan

**Top-down approach:**
- Start with entry points (main, handlers, routes)
- Follow the primary flow
- Note what you don't understand for later

**Bottom-up approach:**
- Start with the specific code you need to change
- Trace dependencies upward
- Understand immediate context first

**Hybrid (usually best):**
- Skim top-down for structure
- Deep-dive bottom-up for specifics

### Phase 3: Execute the Exploration

1. Read with a specific question in mind
2. Draw diagrams as you go
3. Use debugger/logging to trace actual execution
4. Write notes - you will forget

### Phase 4: Look Back

- Can you explain the code to someone else?
- Update documentation if it was missing/wrong
- **Run `/solve-it:diary`** to capture your understanding

---

## When You're Completely Stuck

If you've tried everything and are truly stuck:

### Re-examine Phase 1: Do You Really Understand?

- Explain the problem out loud (rubber duck debugging)
- Can you state the problem in ONE sentence?
- Are you solving the right problem?
- Are there hidden assumptions you haven't questioned?

### Re-examine Phase 2: Is Your Approach Wrong?

**Try the opposite:**
- If you're adding code, try removing code
- If you're debugging top-down, try bottom-up
- If you're being careful, try being aggressive (on a branch)

**Change the question:**
- Instead of "How do I make X work?" ask "Why doesn't X work?"
- Instead of "How do I add feature Y?" ask "What's the simplest thing that could work?"

**Get fresh perspective:**
- Walk away for 15 minutes
- Explain to someone else
- Search for similar problems online

**Simplify drastically:**
- Remove ALL complexity - make the simplest possible version work
- Add complexity back one piece at a time

### When to Ask for Help

You've genuinely tried when you can answer:
- What exactly is the problem?
- What have you tried?
- What did each attempt reveal?
- What's your current best hypothesis?

---

## Recording Learnings

### When to Record

Run `/solve-it:diary` when:
- You solved a difficult problem
- You discovered a non-obvious solution
- You found a useful debugging technique
- You made an important design decision
- You learned something about the system

### What Gets Captured

The diary records:
- Task summary and context
- Design decisions with rationale
- Challenges and how they were overcome
- Code patterns discovered
- Future recommendations
