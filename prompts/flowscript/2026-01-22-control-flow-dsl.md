# FlowScript: A Terse Control Flow DSL

## Design Philosophy

**Maximize semantic density. Minimize tokens.**

FlowScript draws from the LLM's deep familiarity with:
- Shell pipelines (`|`, `&&`, `||`)
- Regex quantifiers (`*`, `+`, `?`)
- Process algebra (CSP, π-calculus)
- Functional composition (`->`, `|>`)
- State machine notation

Every symbol carries meaning. Every pattern has precedent.

---

## Core Syntax

### Sequential Flow
```
A -> B -> C
```
Execute A, then B, then C. Arrow denotes data/control flow.

### Parallel Execution
```
A | B | C
```
Fork: Execute A, B, C concurrently. Borrowed from shell backgrounding semantics.

### Parallel with Join (Barrier)
```
[A | B | C] -> D
```
Brackets denote synchronization barrier. All must complete before D.

### Conditional Branching
```
A -> {
  ok: B
  err: C
  _: D
}
```
Curly braces = match/switch. `_` = default/wildcard (from pattern matching).

### Short-circuit Conditionals
```
A && B    // B only if A succeeds
A || B    // B only if A fails
A &| B    // B regardless, but capture A's result
```

### Loops
```
A*        // Zero or more (while possible)
A+        // One or more (do-while)
A?        // Zero or one (optional)
A{3}      // Exactly 3 times
A{1,5}    // 1 to 5 times
```
Regex quantifiers. Universally understood.

### Loop with Condition
```
A*[cond]     // while cond
A+[!done]    // until done
```

### Error Handling
```
A ! B        // A, on error execute B (catch)
A !! B       // A, always execute B (finally)
A !? B       // A, on error optionally B (catch + suppress)
```

### Retry Patterns
```
A@3          // Retry A up to 3 times
A@3:exp      // Retry with exponential backoff
A@3:lin      // Retry with linear backoff
A@{3,1s,2x}  // 3 retries, 1s initial, 2x multiplier
```

### Timeout
```
A~5s         // Timeout after 5s
A~5s:B       // Timeout after 5s, then execute B
```

### Named Steps (Labels)
```
#fetch: A -> B
#process: C -> D
#fetch -> #process
```
Hash = label/reference. Enables reuse and visualization.

### Subflows (Composition)
```
@auth -> @process -> @cleanup
```
At-sign = subflow reference. Modular composition.

### State Transitions
```
idle =[start]=> running
running =[pause]=> paused
running =[stop]=> idle
paused =[resume]=> running
```
State machine notation: `state =[event]=> newState`

### Guards (Preconditions)
```
A -> B?[valid] -> C
```
Question mark with bracket = guarded transition.

### Data Annotation
```
A:req -> B:resp -> C
```
Colon suffix = type/data annotation for documentation.

### Comments
```
// Line comment (not rendered)
/* Block comment
   spanning multiple lines (not rendered) */

A -> B  // Inline comment after flow
```
Comments are stripped during parsing. Use for author notes and documentation that shouldn't appear in visualizations.

### Annotations (Rendered Notes)
```
"Validate before processing" A -> B      // Note attached to step A
A -> "on success" B                      // Note attached to edge
A -> B "Payment gateway integration"     // Note attached to step B
```
Quoted strings = annotations rendered in the visualization. Use for explanatory text that should appear in the diagram.

### Grouping (Swimlanes)
```
(frontend):                    // Block form - group contains indented flow
  A -> B -> C

(backend):
  D -> E -> F

(frontend).C -> (backend).D    // Cross-group reference with dot accessor

(auth: A -> B) -> (main: C)    // Inline form - group wraps flow
```
Parentheses = visual grouping/swimlane. Groups steps into named containers for visualization without changing semantics. Useful for showing:
- System boundaries (frontend/backend/database)
- Responsibility zones (user/system/external)
- Workflow phases (validate/process/complete)

### Detach (Fire-and-Forget)
```
A -> B& -> C          // B runs detached, C continues immediately after A
A -> [log& | audit&] -> B   // Fire both, continue to B without waiting
```
Ampersand suffix = detached execution. Borrowed from shell backgrounding.

---

## Combinators (Advanced Patterns)

### Race (First Wins)
```
<A | B | C>
```
Angle brackets = race. First to complete wins, others cancelled.

### Saga Pattern (Compensating Transactions)
```
A^a -> B^b -> C^c
```
Caret = compensation. On failure, unwind: `c -> b -> a`.

### Circuit Breaker
```
A@@{5,30s}
```
Double-at = circuit breaker. 5 failures = open for 30s.

### Debounce/Throttle
```
A~>100ms    // Debounce 100ms
A~|100ms    // Throttle 100ms
```

### Event Stream
```
events >> A -> B
```
Double-angle = stream subscription.

### Broadcast
```
A => [B | C | D]
```
Fat arrow = broadcast to multiple consumers.

---

## Complete Example

```flowscript
// Order Processing Workflow

@validate:
  input:order ->
  checkInventory?[inStock] &&
  validatePayment ! handlePaymentError

@fulfill:
  [pickItems | generateLabel] ->
  shipOrder@3:exp~30s ->
  notifyCustomer

@main:
  receiveOrder:event >>
  @validate -> {
    ok: @fulfill
    err: refundCustomer -> notifySupport
  } !!
  logCompletion
```

### Reading the Example

1. `@validate` subflow: validate input, check inventory (guarded), validate payment with error handler
2. `@fulfill` subflow: pick items AND generate label in parallel, then ship (with retry + timeout), then notify
3. `@main`: on order event, validate, branch on result, always log at end

---

## Visualization Mapping

The DSL maps directly to visual representations:

| Symbol | Visual |
|--------|--------|
| `->` | Arrow/edge |
| `\|` | Fork node |
| `[]` | Join/barrier node |
| `{}` | Decision diamond |
| `*+?` | Loop-back arrow |
| `!` | Error edge (red) |
| `@` | Subflow box |
| `#` | Named node |
| `~` | Timer icon |
| `<>` | Race merge |
| `&` | Dashed arrow (detached) |
| `"text"` | Annotation callout/note |
| `//` `/* */` | (not rendered) |
| `(name)` | Container/swimlane box |

---

## Grammar (EBNF)

```ebnf
flow        = step (connector step)*
step        = note? label? (atomic | compound | ref) modifier* note?
atomic      = identifier annotation?
compound    = parallel | branch | barrier | race | group
parallel    = step ("|" step)+
barrier     = "[" parallel "]"
branch      = "{" (case ":" flow)+ "}"
race        = "<" parallel ">"
group       = "(" identifier ":" flow ")" | "(" identifier "):" indent flow dedent
ref         = "@" identifier | "#" identifier | "(" identifier ")." identifier
connector   = ("->" | "&&" | "||" | "&|" | "!" | "!!" | "!?" | ">>" | "=>") note?
modifier    = quantifier | retry | timeout | guard | compensation | detach
quantifier  = "*" | "+" | "?" | "{" number ("," number?)? "}"
detach      = "&"
retry       = "@" number (":" strategy)?
timeout     = "~" duration (":" step)?
guard       = "?" "[" condition "]"
compensation = "^" identifier
label       = "#" identifier ":"
annotation  = ":" identifier
note        = '"' text '"'
comment     = "//" text newline | "/*" text "*/"
```

---

## Token Efficiency Analysis

Traditional workflow DSL (150+ tokens):
```yaml
steps:
  - name: validate_order
    action: validate
    input: order
    on_error:
      action: handle_error
  - name: check_inventory
    action: check
    condition: in_stock
    parallel:
      - pick_items
      - generate_label
    retry:
      max_attempts: 3
      backoff: exponential
```

FlowScript (25 tokens):
```
validate:order ! handleError -> checkInventory?[inStock] -> [pick | label] -> ship@3:exp
```

**6x token reduction** while maintaining semantic clarity.

---

## Implementation Notes

### Parsing Strategy
1. Tokenize with regex (symbols have fixed meaning)
2. Recursive descent parser (grammar is LL(1))
3. AST nodes map 1:1 to visual elements

### Execution Model
- Each step = async function
- Connectors = control flow primitives
- Modifiers = decorators/wrappers

### Visualization Pipeline
```
FlowScript -> AST -> Graph -> SVG/Mermaid/DOT
```

---

## Extensions (Future)

```flowscript
// Annotations for metadata
%timeout: 30s
%retries: 3

// Imports
use @common/auth
use @common/logging

// Templates
def @crud<T>: create:T -> validate -> persist -> notify

// Instantiation
@crud<Order> -> processPayment
```

---

## Quick Reference Card

```
SEQUENCE:    A -> B -> C
PARALLEL:    A | B | C
BARRIER:     [A | B] -> C
BRANCH:      A -> { ok: B, err: C, _: D }
SHORTCUT:    A && B (and)  A || B (or)
LOOP:        A* (0+)  A+ (1+)  A? (0-1)  A{n}
ERROR:       A ! B (catch)  A !! B (finally)
RETRY:       A@3 (3x)  A@3:exp (backoff)
TIMEOUT:     A~5s  A~5s:fallback
GUARD:       A?[cond]
RACE:        <A | B | C>
SAGA:        A^undo -> B^undo
STREAM:      events >> handler
LABEL:       #name: A -> B
SUBFLOW:     @name -> @other
STATE:       idle =[event]=> running
DETACH:      A& (fire-and-forget)
COMMENT:     // text  /* block */
ANNOTATE:    "note" A  A -> "note" B
GROUP:       (name): ...  (name: A -> B)  (grp).step
```
