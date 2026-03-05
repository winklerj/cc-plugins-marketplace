# rw - Robb Winkle's Development Workflow Tools

Development workflow plugin for Claude Code. Tools for prevalidating assumptions, comparing approaches, and guarding against regressions.

## Skills

### learning-experiment

Set up and run learning experiments that compare approaches with real data before committing to an implementation.

**Invoke:** `/rw:learning-experiment <description or path to spec>`

**What it does:**
- Creates a structured experiment folder with tests, inputs, and reports
- Guides you through defining hypothesis, inputs, metrics, and decision criteria
- Generates quantitative comparison reports in markdown
- Experiments persist as regression guards

**Example:**
```
/rw:learning-experiment Compare two regex approaches for extracting sheet numbers from title blocks
```

## Installation

Add to your project's `.claude/settings.local.json`:

```json
{
  "plugins": [
    {
      "path": "/path/to/cc-plugins-marketplace/plugins/rw"
    }
  ]
}
```
