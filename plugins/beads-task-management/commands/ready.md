---
description: Show work ready to be started (no blockers)
allowed-tools: Bash(bd:*)
argument-hint: [--json]
---

Display issues that are ready to be worked on (no open blockers).

## Arguments

- `$ARGUMENTS` - Optional: `--json` for JSON output (useful for programmatic access)

## Execution

```bash
bd ready $ARGUMENTS
```

## Output Formats

### Human-Readable (Default)
Shows ready work in a formatted table with:
- Issue ID (e.g., bd-a1b2)
- Title
- Priority
- Labels
- Assignee

### JSON Format (--json)
Returns structured JSON for programmatic processing:
```json
{
  "ready": [
    {
      "id": "bd-a1b2",
      "title": "Implement feature X",
      "priority": 1,
      "status": "open",
      "labels": ["backend", "urgent"],
      "assignee": "alice"
    }
  ]
}
```

## Understanding Ready Work

An issue is "ready" when:
- Status is "open" or "ready"
- No blocking issues are open
- All dependencies are resolved
- Issue is not blocked by another issue

## Next Steps After Viewing Ready Work

1. **Choose an issue to work on**:
   ```bash
   /beads:update <issue-id> --status in_progress
   ```

2. **View full details**:
   ```bash
   bd show <issue-id>
   ```

3. **Check blocked work**:
   ```bash
   bd blocked
   ```

## Example Usage

```
/beads:ready
/beads:ready --json
```

## Error Handling

If no ready work is available:
- Check blocked issues with `bd blocked`
- View all issues with `bd list`
- Create new issues with `/beads:create`

## Notes

- Ready work is automatically calculated based on dependency graph
- Issues marked as "in_progress" won't show in ready list
- High priority issues (priority 1) should be tackled first
- Use this command at the start of each work session
