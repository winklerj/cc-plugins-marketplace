---
description: Update a beads issue
allowed-tools: Bash(bd:*)
argument-hint: <issue-id> [--status status] [--priority priority] [--type type] [--assignee user] [--labels labels]
---

Update an existing issue in the beads issue tracker.

## Arguments Format

```
<issue-id> [--status status] [--priority priority] [--type type] [--assignee user] [--labels labels] [--title "new title"] [--description "new desc"]
```

## Required Arguments

- **issue-id**: The issue ID to update (e.g., bd-a1b2)

## Optional Update Fields

- `--status`: Change status (open, in_progress, blocked, closed)
- `--priority`: Change priority (1-5)
- `--type`: Change type (bug, feature, task, chore, docs)
- `--assignee`: Reassign to different user
- `--labels`: Update labels (comma-separated, replaces existing)
- `--title`: Update issue title
- `--description`: Update issue description

## Execution

```bash
bd update $ARGUMENTS
```

## Common Update Scenarios

### Start Working on Issue
```
/beads:update bd-a1b2 --status in_progress
```

### Mark as Blocked
```
/beads:update bd-a1b2 --status blocked
```

### Change Priority
```
/beads:update bd-a1b2 --priority 1
```

### Reassign Issue
```
/beads:update bd-a1b2 --assignee bob
```

### Update Multiple Fields
```
/beads:update bd-a1b2 --status in_progress --priority 2 --assignee alice
```

### Update Title and Description
```
/beads:update bd-a1b2 --title "New title" --description "Updated description"
```

### Update Labels
```
/beads:update bd-a1b2 --labels backend,urgent,security
```

## Status Transitions

Common workflow transitions:

1. **Pick up work**:
   ```
   open → in_progress
   ```

2. **Hit blocker**:
   ```
   in_progress → blocked
   ```

3. **Blocker resolved**:
   ```
   blocked → in_progress
   ```

4. **Complete work**:
   ```
   in_progress → closed (use /beads:close instead)
   ```

## Field Behaviors

- **Labels**: Completely replaces existing labels (not additive)
- **Status**: Validates against allowed values
- **Priority**: Must be 1-5
- **Assignee**: Can be any string (no user validation)
- **Title/Description**: Fully replaces previous value

## Verification

After updating, view the changes:
```bash
bd show <issue-id>
```

## Error Handling

If update fails:
- Verify issue ID exists (`bd list` or `bd show <id>`)
- Check status value is valid (open, in_progress, blocked, closed)
- Ensure priority is 1-5
- Verify labels format (comma-separated, no spaces)
- Check beads is initialized

## Notes

- Multiple fields can be updated in one command
- Changes sync to git automatically after 5 seconds
- Use `/beads:close` for completing issues (includes reason)
- Original values remain unchanged for fields not specified
- Issue ID is case-sensitive
- Update timestamp is automatically recorded

## Agent Workflow

When working on an issue:

1. **Start work**:
   ```
   /beads:update <id> --status in_progress
   ```

2. **During work**:
   - Update priority if urgency changes
   - Add labels as needed
   - Document blockers with status change

3. **On completion**:
   ```
   /beads:close <id> --reason "Completed successfully"
   ```
