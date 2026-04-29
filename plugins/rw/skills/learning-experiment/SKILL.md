---
name: learning-experiment
description: >
  Set up and run learning experiments that prevalidate assumptions before committing to
  implementation. Use when comparing approaches, proving a refactor won't regress, benchmarking
  alternatives, or testing tradeoffs specific to a use case. Triggers: "experiment",
  "compare approaches", "which is better", "prove this works", "benchmark", "regression guard",
  "learning test", "prevalidate", "tradeoff".
argument-hint: <description or path to experiment spec>
---

# Learning Experiments

Lightweight, persistent experiments that live outside the normal test suite. They use real
inputs to compare approaches, measure outcomes, and guard against regressions.

## What You Will Build

Each experiment produces:
1. **A hypothesis** — what you're testing and why
2. **Real inputs** — actual data from the project, not mocks
3. **Competing implementations** — 2+ approaches side-by-side
4. **Quantitative metrics** — numbers you can compare across runs
5. **A structured report** — markdown summary with a recommendation

## Workflow

### Step 1: Understand the Experiment

Read `$ARGUMENTS`. If it's a file path, read the file. If it's a description, use it directly.

Clarify with the user if any of these are missing:
- **What is being compared?** (approaches, algorithms, configurations)
- **What inputs should be used?** (real files, database records, API responses)
- **What metrics matter?** (accuracy, speed, memory, precision/recall, output quality)
- **What is the decision threshold?** (e.g., "Approach B must be >= Approach A on F1")
- **Are there visual, UI, UX, or display aspects to the experiment** use Visual Companion

Do not proceed until you have answers for all four.

### Step 2: Create the Experiment Directory

Every experiment gets its own folder under `experiments/` at the appropriate project level:

```
experiments/
    conftest.py              # shared setup (create if missing)
    <experiment-name>/
        README.md            # hypothesis, inputs, metrics, decision criteria
        conftest.py          # experiment-specific fixtures
        test_<name>.py       # the experiment tests
        inputs/              # real input data (or symlinks to it)
        reports/             # generated after running
```

**Naming:** Use descriptive snake_case names like `sheet_number_regex`, `clustering_algorithm_comparison`, `batch_size_throughput`.

### Step 3: Set Up Shared conftest.py

If `experiments/conftest.py` does not exist, create it. It provides shared infrastructure
that all experiments use. Adapt to the project's stack:

```python
"""Shared fixtures for learning experiments.

Run:
    uv run pytest experiments/ -v
    uv run pytest experiments/<name>/ -v -s   # single experiment
"""

from __future__ import annotations

import pytest
```

Add shared fixtures as needed (database connections, file loaders, etc.). Keep it minimal —
experiment-specific fixtures belong in the experiment's own conftest.py.

### Step 4: Write the Experiment README

Create `experiments/<name>/README.md` with this structure:

```markdown
# Experiment: <Descriptive Title>

## Hypothesis
<What you expect to find and why it matters>

## Approaches
| Approach | Description |
|----------|-------------|
| A: <name> | <what it does> |
| B: <name> | <what it does> |

## Inputs
<What real data is used and where it comes from>

## Metrics
| Metric | Why It Matters |
|--------|---------------|
| <metric> | <rationale> |

## Decision Criteria
<When would you choose A vs B? What thresholds?>

## Results
<Filled in after running — see reports/>
```

### Step 5: Write the Experiment Tests

Structure the test file with these sections:

#### 5a. Implement Each Approach

Each approach is a standalone function. Self-contained, no shared state between approaches.

```python
def approach_a_simple(input_data):
    """Approach A: <description>."""
    # implementation
    return result

def approach_b_comprehensive(input_data):
    """Approach B: <description>."""
    # implementation
    return result
```

#### 5b. Define Metrics Collection

Create a dataclass or dict to hold metrics per approach. Common metrics:

| Category | Metrics |
|----------|---------|
| **Correctness** | precision, recall, F1, accuracy, exact match rate |
| **Performance** | wall time, throughput (ops/sec), memory peak |
| **Quality** | output diff, visual inspection score, error count |
| **Custom** | domain-specific measures relevant to the experiment |

```python
@dataclass
class ExperimentResult:
    approach: str
    # Add metrics relevant to THIS experiment
    elapsed_ms: float = 0.0
    # ... more metrics
    errors: list[str] = field(default_factory=list)
```

#### 5c. Write Comparison Tests

Structure tests as a class per experiment concern:

```python
class TestApproachComparison:
    """Side-by-side comparison of all approaches."""

    def test_correctness_comparison(self, inputs, expected):
        """Run all approaches and compare correctness metrics."""
        results = []
        for name, func in approaches:
            result = evaluate(name, func, inputs, expected)
            results.append(result)
        # Assert the key comparison
        assert results[1].f1 >= results[0].f1, "B should match or beat A"

    def test_performance_comparison(self, inputs):
        """Benchmark all approaches."""
        # Time each approach over multiple iterations
        ...

class TestEdgeCases:
    """Targeted tests for known tricky inputs."""
    # Parametrized tests for specific cases each approach might handle differently
    ...
```

#### 5d. Generate the Report

Add a test that writes a markdown report to `reports/`:

```python
def test_generate_report(self, all_results):
    """Write structured comparison report."""
    report_dir = Path(__file__).parent / "reports"
    report_dir.mkdir(exist_ok=True)
    report_path = report_dir / f"comparison_{datetime.now():%Y%m%d_%H%M%S}.md"

    lines = [
        "# Experiment Report: <name>",
        f"**Run date:** {datetime.now():%Y-%m-%d %H:%M}",
        "",
        "## Results Summary",
        "",
        "| Approach | <metrics...> |",
        "|----------|-------------|",
    ]
    for r in all_results:
        lines.append(f"| {r.approach} | ... |")

    lines.extend([
        "",
        "## Recommendation",
        "<filled based on decision criteria from README>",
    ])

    report_path.write_text("\n".join(lines))
```

### Step 6: Run and Iterate

```bash
# Run the experiment
uv run pytest experiments/<name>/ -v -s

# Run only benchmarks if marked
uv run pytest experiments/<name>/ -v -m slow
```

Review the report in `experiments/<name>/reports/`. If results are inconclusive,
add more inputs or refine metrics.

## Visual Companion

A browser-based companion for showing mockups, diagrams, and visual options. Available as a tool - not a mode. The companion is available for questions that benefit from visual treatment;

Read the detailed guide before using the Visual Companion: `skills/learning-experiment/visual-companion.md`

## Key Principles

### Use Real Inputs
Experiments exist because synthetic tests don't capture real-world tradeoffs. Use actual
files, database records, or API responses from the project. Put them in `inputs/` or
symlink to existing project data.

### Measure, Don't Guess
Every experiment must produce numbers. "Approach B feels faster" is not an experiment
result. "Approach B processes 1000 records in 450ms vs 820ms for A" is.

### Keep Experiments Persistent
These are regression guards, not throwaway scripts. They should be runnable months later
to verify that assumptions still hold after codebase changes.

### One Experiment, One Question
Each experiment folder answers one question. "Is regex A or B better for sheet numbers?"
is one experiment. "Should we also change the title block parser?" is a separate experiment.

### Baseline Comparison
When testing a refactor or optimization, always include the current production implementation
as a baseline approach. This anchors the comparison in reality.

## Common Experiment Types

### Approach Comparison
Comparing 2+ algorithms or implementations for the same task.
**Metrics:** accuracy, F1, throughput, memory

### Refactor Validation
Proving a refactor produces identical (or better) results.
**Metrics:** output diff (should be empty), performance delta

### Configuration Tuning
Testing different parameter values (batch sizes, thresholds, timeouts).
**Metrics:** throughput curve, error rate at each setting

### Integration Proof
Validating that a library, API, or tool works for your specific use case.
**Metrics:** correctness on your data, latency, failure modes

## Guiding the User on Inputs

If the user hasn't specified inputs, help them identify good candidates:

1. **Look at existing test data** in the project's `tests/` or `fixtures/` directories
2. **Look at real data** the project processes (Input/, data/, samples/)
3. **Ask about edge cases** — what inputs have caused problems before?
4. **Suggest a mix** — include easy cases (sanity check) and hard cases (where approaches diverge)
5. **Minimum viable set** — start with 3-5 representative inputs, expand if results are close

For additional templates and examples, see [references/templates.md](references/templates.md).
