---
description: List beads issues with optional filters
allowed-tools: Bash(bd:*)
argument-hint: [--status status] [--type type] [--assignee user] [--labels labels] [--json]
---

List issues in the beads issue tracker with optional filtering.

## Arguments

All arguments are optional filters:

- `--status`: Filter by status (open, in_progress, blocked, closed)
- `--type`: Filter by type (bug, feature, task, chore, docs)
- `--assignee`: Filter by assigned user
- `--labels`: Filter by labels (comma-separated)
- `--priority`: Filter by priority (1-5)
- `--json`: Output in JSON format for programmatic access

## Execution

```bash
bd list $ARGUMENTS
```

## Examples

### List All Issues
```
/beads:list
```

### Filter by Status
```
/beads:list --status open
/beads:list --status in_progress
/beads:list --status closed
```

### Filter by Type
```
/beads:list --type bug
/beads:list --type feature
```

### Filter by Assignee
```
/beads:list --assignee alice
```

### Filter by Labels
```
/beads:list --labels backend
/beads:list --labels urgent,critical
```

### Combine Filters
```
/beads:list --status open --type bug --priority 1
```

### JSON Output
```
/beads:list --json
/beads:list --status open --json
```

## Output Format

### Human-Readable (Default)
Displays issues in a formatted table:
```
ID       | Title                    | Status      | Type    | Priority | Assignee
---------|--------------------------|-------------|---------|----------|----------
bd-a1b2  | Fix login bug           | open        | bug     | 1        | alice
bd-f14c  | Add authentication      | in_progress | feature | 2        | bob
```

### JSON Format (--json)
Returns structured JSON:
```json
{
  "issues": [
    {
      "id": "bd-a1b2",
      "title": "Fix login bug",
      "status": "open",
      "type": "bug",
      "priority": 1,
      "labels": ["backend", "critical"],
      "assignee": "alice",
      "created": "2025-01-15T10:30:00Z",
      "updated": "2025-01-15T14:20:00Z"
    }
  ]
}
```

## Status Values

- `open`: New issue, not yet started
- `in_progress`: Currently being worked on
- `blocked`: Cannot proceed due to dependencies
- `closed`: Completed or resolved

## Sorting

Issues are sorted by:
1. Priority (highest first)
2. Creation date (newest first)
3. Status (open > in_progress > blocked > closed)

## Viewing Details

To see full details of a specific issue:
```bash
bd show <issue-id>
```

## Error Handling

If no issues match filters:
- Double-check filter values
- Try removing filters one at a time
- Verify beads is initialized
- Check if any issues exist with `bd stats`

## Notes

- Without filters, all issues are displayed
- Filters can be combined for precise queries
- JSON output is useful for agent workflows
- Use `bd stats` for quick project overview
- Large issue lists may be paginated
