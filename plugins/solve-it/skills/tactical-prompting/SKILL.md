# SKILL.md - Tactical Prompting System

## Purpose
Select and apply proven meta-prompting tactics for AI coding tasks. Each tactic is a reusable pattern with known preconditions, postconditions, and failure modes.

## When to Use This Skill
- Planning how to approach a complex coding task with Claude
- Stuck on a problem and need to try a different prompting approach
- Want to avoid common LLM failure modes (hallucination, architecture pasta)
- Multiple related tasks that might benefit from shared context
- Need to generate high-quality prompts quickly

## Core Concepts

### What Are Tactics?
Tactics are meta-prompting patterns with:
- **Preconditions**: When this tactic applies
- **The Pattern**: The actual prompt structure
- **Postconditions**: What you get out
- **Failure Modes**: What to watch for

Think of them as functions: `apply_tactic(situation) → prompt_text`

### The Five Fundamental Tactics

#### 1. Meta-Prompt (Deductive)
**Pattern**: Principles → Implementation

**When to use**:
- Need high-quality, principled output
- Domain has established best practices (security, testing, architecture)
- Want to avoid cargo-cult solutions

**The spell**:
```
Step 1: "What are all the principles for [doing X well]?"
Step 2: "Now implement [X] following those principles"
```

**Example**:
```
"What are the principles for building secure authentication systems?"
→ [Claude lists principles]
"Now build an authentication system following those principles"
```

**Why it works**: Forces model to surface deep knowledge before implementing
**Warning**: Don't skip step 1 - going straight to implementation loses the benefit

---

#### 2. Split MVP (Progressive Complexity)
**Pattern**: Final → Simplified → Build Simple with Future in Mind

**When to use**:
- Complex feature with risk of "architecture pasta"
- Need clean abstractions that support future growth
- Worried about over-engineering OR under-engineering

**The spell**:
```
Step 1: "Design three versions: MVP (minimal), MVP2 (intermediate), Final (complete)"
Step 2: "Now build MVP with the final design in mind"
```

**Why it works**: Asking to "build MVP with final in mind" surfaces abstractions that make both MVP easy AND migration to final trivial. The LLM's predictive nature generates intermediate patterns that are actually structural.

**Warning**: Asking straight for final design → hallucinated "architecture pasta" that looks right but isn't
**Bonus**: Can skip directly to final if the groundwork abstractions are good enough

---

#### 3. Shared Context Analysis (Context Window Optimization)
**Pattern**: Analyze Multiple Related Tasks Together

**When to use**:
- 3+ tasks that touch the same codebase area
- Tasks that might create merge conflicts if done separately
- Want to discover shared abstractions across tasks

**The spell**:
```
"Analyze how to do tasks A, B, and C. For each:
1. Write a separate analysis document
2. Write a shared context analysis showing overlaps and common patterns
3. Identify abstractions that serve multiple tasks"
```

**Why it works**: 
- Less total context than 3 separate sessions
- Each task designed with knowledge of others
- Fewer merge conflicts
- Often finishes faster than parallel execution

**Warning**: More compaction/longer context, but benefits usually outweigh costs
**Cost vs Benefit**: Better architecture + fewer conflicts > slight context degradation

---

#### 4. DSL Scaffolding (Language-First)
**Pattern**: Language → Interpreter → Instance

**When to use**:
- Repetitive similar tasks (UI components, API endpoints, data transforms)
- Need consistency across multiple instances
- Want to iterate on the pattern itself

**The spell**:
```
Step 1: "Create a concise DSL for describing [X]"
Step 2: "Implement an interpreter for this DSL"
Step 3: "Generate [specific instance] using the DSL"
```

**Example**:
```
"Create a YAML DSL for UI components"
"Implement a React interpreter for this DSL"  
"Generate a user profile form using the DSL"
```

**Why it works**: Separates pattern (DSL) from implementation (interpreter) from instance
**Bonus**: Can iterate on DSL or add new instances trivially

---

#### 5. Contrapositive (Failure-Driven)
**Pattern**: Enumerate Failures → Build to Avoid

**When to use**:
- High-stakes code (security, data integrity, performance)
- Unfamiliar domain with hidden gotchas
- Previous attempts failed mysteriously

**The spell**:
```
"What are all the ways [X] could fail or go wrong?"
→ [Get comprehensive failure list]
"Now build [X] that avoids all of these failure modes"
```

**Why it works**: Surfaces edge cases and domain knowledge before implementation
**Warning**: Can lead to over-engineering if not balanced

---

## Advanced Tactics

### Research → Design → Implement Chain
```
RESEARCH = "Research how to do [GOAL] with [TOOLS]"
DESIGN = "Design a solution for [GOAL] using [TOOLS], given RESEARCH"
PLAN = "Create implementation plan for DESIGN"
IMPLEMENTATION = "Implement according to PLAN"
```

**When to use**: Greenfield projects, unfamiliar tools, complex integration

### Abductive (Example-Based)
```
Step 1: Show 2-3 examples of desired output
Step 2: "Extract the explicit principles from these examples"
Step 3: "Apply those principles to [new case]"
```

**When to use**: Hard to describe but easy to show, style transfer, pattern extraction

---

## How to Use This Skill

### Quick Selection Process
1. **Describe your situation** to Claude
2. Claude identifies which preconditions match
3. Claude recommends 1-3 tactics with reasoning
4. Claude generates the actual prompt text to use
5. You copy/paste into your coding session

### Example Session
```
User: "I need to build a complex dashboard with 10+ widget types"

Claude: "This matches Split MVP + DSL Scaffolding tactics:

Split MVP: Design minimal → intermediate → full dashboard, then build minimal with full in mind
DSL Scaffolding: Create widget DSL → implement renderer → generate each widget type

Recommended: Use DSL Scaffolding because:
- Repetitive similar tasks (widgets)
- Need consistency across types
- Easy to add new widget types later

Here's your prompt:
'Create a concise YAML DSL for describing dashboard widgets. Include properties for data source, visualization type, interactivity, and layout. Then implement a React renderer for this DSL. Finally, generate these 5 widget types: [list].'"
```

---

## Tactic Selection Flowchart
```
Do you have clear examples? 
  → YES: Consider Abductive
  → NO: Continue

Is this high-stakes/security-critical?
  → YES: Use Contrapositive
  → NO: Continue

Do you have 3+ related tasks?
  → YES: Use Shared Context Analysis
  → NO: Continue

Is this complex with hallucination risk?
  → YES: Use Split MVP
  → NO: Continue

Are there established principles/best practices?
  → YES: Use Meta-Prompt
  → NO: Continue

Is this repetitive/pattern-based?
  → YES: Use DSL Scaffolding
  → NO: Start with Meta-Prompt as default
```

---

## Anti-Patterns (What NOT to Do)

❌ **Skipping the meta-level**: Don't go straight to implementation without the tactic setup
❌ **Wrong tactic for situation**: Using Split MVP for simple CRUD is overkill
❌ **Ignoring preconditions**: If preconditions don't match, tactic won't help
❌ **Mixing tactics randomly**: Each tactic has a purpose, use intentionally
❌ **Prompt guessing**: This whole system exists to replace trial-and-error

---

## Evaluation Mindset

After using a tactic, track:
- Did it work better than direct prompting?
- Which preconditions were present?
- What was the failure mode (if any)?
- Would a different tactic have been better?

Build your personal tactic effectiveness data over time.
