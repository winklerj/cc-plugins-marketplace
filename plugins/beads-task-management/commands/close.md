---
description: Close a beads issue with reason
allowed-tools: Bash(bd:*)
argument-hint: <issue-id> --reason "completion reason"
---

Close an issue in the beads issue tracker with a completion reason.

## Arguments Format

```
<issue-id> --reason "reason for closing"
```

## Required Arguments

- **issue-id**: The issue ID to close (e.g., bd-a1b2)
- **--reason**: Reason for closing (required for documentation)

## Execution

```bash
bd close $ARGUMENTS
```

## Common Close Reasons

### Completed Work
```
/beads:close bd-a1b2 --reason "Implemented successfully, tests passing"
/beads:close bd-a1b2 --reason "Fixed bug, verified in production"
/beads:close bd-a1b2 --reason "Feature completed and deployed"
```

### Duplicate
```
/beads:close bd-a1b2 --reason "Duplicate of bd-f14c"
```

### Won't Fix
```
/beads:close bd-a1b2 --reason "Won't fix - working as intended"
/beads:close bd-a1b2 --reason "No longer needed per team discussion"
```

### Cannot Reproduce
```
/beads:close bd-a1b2 --reason "Cannot reproduce, need more info"
```

### Invalid
```
/beads:close bd-a1b2 --reason "Invalid - not a bug"
```

## What Happens When Closing

1. Issue status changes to "closed"
2. Reason is recorded in issue history
3. Timestamp of closure is recorded
4. Issue no longer appears in active work lists
5. Changes auto-sync to git

## Best Practices

### Good Close Reasons
- Specific and descriptive
- Include verification details
- Reference related work
- Document outcomes

Examples:
```
"Feature implemented with JWT authentication, all tests passing"
"Bug fixed in commit abc123, deployed to production"
"Merged PR #42, verified in staging"
```

### Poor Close Reasons
- Too vague
- No context
- No verification

Examples:
```
"Done"
"Fixed"
"Complete"
```

## Verification After Closing

Check the closed issue:
```bash
bd show <issue-id>
```

View all closed issues:
```bash
bd list --status closed
```

## Reopening Issues

If you need to reopen a closed issue:
```bash
/beads:update <issue-id> --status open
```

## Impact on Dependencies

When closing an issue:
- Dependent issues may become unblocked
- Check newly ready work: `/beads:ready`
- Review dependency tree: `bd dep tree <id>`

## Error Handling

If close fails:
- Verify issue ID exists
- Ensure --reason flag is provided
- Check reason is quoted if it contains spaces
- Verify beads is initialized

## Agent Workflow

Typical completion workflow:

1. **Complete the work**:
   - Implement feature/fix
   - Write tests
   - Verify functionality

2. **Close the issue**:
   ```
   /beads:close <id> --reason "Detailed completion summary"
   ```

3. **Check for newly ready work**:
   ```
   /beads:ready
   ```

4. **Move to next issue**:
   ```
   /beads:update <next-id> --status in_progress
   ```

## Notes

- Closing an issue is different from deleting (issues are never deleted)
- Closed issues remain in history for tracking and reference
- Reason helps with project retrospectives and auditing
- Use descriptive reasons for better project documentation
- Changes sync to git automatically after 5 seconds
- Closed issues can be filtered and searched
