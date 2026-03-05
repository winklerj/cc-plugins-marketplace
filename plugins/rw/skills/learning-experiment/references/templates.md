# Learning Experiment Templates

## Shared conftest.py Templates

### Minimal (no infrastructure needed)

```python
"""Shared fixtures for learning experiments."""

from __future__ import annotations

import pytest
```

### With Database (PostgreSQL)

```python
"""Shared DB fixtures for learning experiments.

Uses a separate database to avoid conflicts with the automated test suite.
"""

from __future__ import annotations

import os

import pytest
import psycopg2

EXP_DB_NAME = os.environ.get("EXP_DATABASE_NAME", "experiments_db")
EXP_DSN = f"dbname={EXP_DB_NAME} host=localhost"


def _force_drop_db(dbname: str) -> None:
    admin = psycopg2.connect("dbname=postgres host=localhost")
    admin.autocommit = True
    cur = admin.cursor()
    cur.execute(f"DROP DATABASE IF EXISTS {dbname} WITH (FORCE)")
    cur.close()
    admin.close()


@pytest.fixture(scope="session")
def test_db():
    """Create experiment database for the session."""
    _force_drop_db(EXP_DB_NAME)

    admin = psycopg2.connect("dbname=postgres host=localhost")
    admin.autocommit = True
    cur = admin.cursor()
    cur.execute(f"CREATE DATABASE {EXP_DB_NAME}")
    cur.close()
    admin.close()

    conn = psycopg2.connect(EXP_DSN)
    conn.autocommit = True
    yield conn

    conn.close()
    _force_drop_db(EXP_DB_NAME)


@pytest.fixture
def db_conn(test_db):
    """Per-test connection with transaction rollback for isolation."""
    test_db.rollback()
    yield test_db
    test_db.rollback()
```

### With File-Based Inputs

```python
"""Shared fixtures for file-based experiments."""

from __future__ import annotations

from pathlib import Path

import pytest

EXPERIMENTS_DIR = Path(__file__).resolve().parent


@pytest.fixture
def experiment_dir(request):
    """Return the directory of the calling experiment."""
    return Path(request.fspath).parent


@pytest.fixture
def input_dir(experiment_dir):
    """Return the inputs/ directory for the calling experiment."""
    d = experiment_dir / "inputs"
    if not d.exists():
        pytest.skip(f"No inputs directory at {d}")
    return d
```

## ExperimentResult Dataclass Template

```python
from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any


@dataclass
class ExperimentResult:
    """Metrics collected for one approach in one experiment run."""

    approach: str

    # Correctness
    true_positives: int = 0
    false_positives: int = 0
    false_negatives: int = 0
    true_negatives: int = 0

    # Performance
    elapsed_ms: float = 0.0
    peak_memory_mb: float = 0.0

    # Custom metrics (experiment-specific)
    custom: dict[str, Any] = field(default_factory=dict)

    # Error log
    errors: list[str] = field(default_factory=list)

    @property
    def precision(self) -> float:
        denom = self.true_positives + self.false_positives
        return self.true_positives / denom if denom > 0 else 0.0

    @property
    def recall(self) -> float:
        denom = self.true_positives + self.false_negatives
        return self.true_positives / denom if denom > 0 else 0.0

    @property
    def f1(self) -> float:
        p, r = self.precision, self.recall
        return 2 * p * r / (p + r) if (p + r) > 0 else 0.0

    @property
    def accuracy(self) -> float:
        total = (
            self.true_positives
            + self.false_positives
            + self.false_negatives
            + self.true_negatives
        )
        correct = self.true_positives + self.true_negatives
        return correct / total if total > 0 else 0.0
```

## Report Generation Template

```python
from datetime import datetime
from pathlib import Path


def generate_report(
    experiment_name: str,
    results: list,  # list of ExperimentResult
    metric_columns: list[tuple[str, str]],  # (attr_name, display_name)
    report_dir: Path,
    decision_criteria: str = "",
) -> Path:
    """Generate a markdown comparison report.

    Args:
        experiment_name: Human-readable name for the report title.
        results: List of ExperimentResult objects to compare.
        metric_columns: List of (attribute_name, column_header) tuples.
        report_dir: Directory to write the report into.
        decision_criteria: Text describing how to interpret results.

    Returns:
        Path to the generated report file.
    """
    report_dir.mkdir(parents=True, exist_ok=True)
    timestamp = datetime.now()
    report_path = report_dir / f"report_{timestamp:%Y%m%d_%H%M%S}.md"

    lines = [
        f"# {experiment_name}",
        f"**Run date:** {timestamp:%Y-%m-%d %H:%M:%S}",
        "",
        "## Results Summary",
        "",
    ]

    # Build table header
    headers = ["Approach"] + [col[1] for col in metric_columns]
    lines.append("| " + " | ".join(headers) + " |")
    lines.append("| " + " | ".join(["---"] * len(headers)) + " |")

    # Build table rows
    for r in results:
        values = [r.approach]
        for attr_name, _ in metric_columns:
            val = getattr(r, attr_name, r.custom.get(attr_name, "N/A"))
            if isinstance(val, float):
                values.append(f"{val:.3f}")
            else:
                values.append(str(val))
        lines.append("| " + " | ".join(values) + " |")

    # Errors section
    any_errors = any(r.errors for r in results)
    if any_errors:
        lines.extend(["", "## Errors", ""])
        for r in results:
            if r.errors:
                lines.append(f"### {r.approach}")
                for err in r.errors:
                    lines.append(f"- {err}")
                lines.append("")

    # Decision
    if decision_criteria:
        lines.extend(["", "## Decision Criteria", "", decision_criteria, ""])

    # Recommendation placeholder
    lines.extend([
        "",
        "## Recommendation",
        "",
        "<!-- Fill in after reviewing results -->",
        "",
    ])

    report_path.write_text("\n".join(lines))
    return report_path
```

## README Template

```markdown
# Experiment: <Descriptive Title>

## Date
<YYYY-MM-DD>

## Hypothesis
<1-2 sentences: what you expect to find and why it matters to the project>

## Approaches

| Approach | Description |
|----------|-------------|
| A: <name> | <brief description of the technique> |
| B: <name> | <brief description of the technique> |
| Baseline (current) | <the production implementation, if applicable> |

## Inputs

| Input | Source | Why Selected |
|-------|--------|-------------|
| <name> | <path or description> | <what it tests> |

## Metrics

| Metric | Type | Why It Matters |
|--------|------|---------------|
| <name> | correctness/performance/quality | <rationale> |

## Decision Criteria

- Adopt B if: <specific measurable condition>
- Keep A if: <specific measurable condition>
- Inconclusive if: <what would require more data>

## Results

> See `reports/` for detailed run outputs.

| Approach | <metric1> | <metric2> | <metric3> |
|----------|-----------|-----------|-----------|
| A | | | |
| B | | | |

## Conclusion

<Filled after running: which approach was selected and why>
```
