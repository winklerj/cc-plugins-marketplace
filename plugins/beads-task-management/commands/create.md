---
description: Create a new beads issue
allowed-tools: Bash(bd:*)
argument-hint: "<title>" [-d description] [-p priority] [-t type] [-l labels] [--assignee user]
---

Create a new issue in the beads issue tracker.

## Arguments Format

The command expects a title followed by optional flags:

```
<title> [-d "description"] [-p priority] [-t type] [-l "label1,label2"] [--assignee user]
```

## Required Arguments

- **Title**: The first argument(s) before any flags (can be quoted or unquoted)

## Optional Flags

- `-d, --description`: Detailed description of the issue
- `-p, --priority`: Priority level (1-5, where 1 is highest)
- `-t, --type`: Issue type (bug, feature, task, chore, docs)
- `-l, --labels`: Comma-separated labels (e.g., "backend,urgent")
- `--assignee`: Assign to a team member
- `-f, --file`: Bulk create from file (Markdown format)

## Execution

```bash
bd create $ARGUMENTS
```

## Examples

### Simple Issue
```
/beads:create "Fix login bug"
```

### Detailed Issue
```
/beads:create "Implement user authentication" -d "Add JWT-based auth with refresh tokens" -p 1 -t feature -l "backend,security" --assignee alice
```

### Bug Report
```
/beads:create "Crash on startup" -d "App crashes when offline" -p 1 -t bug -l "critical,mobile"
```

### Task
```
/beads:create "Update dependencies" -t task -p 3
```

## Bulk Creation from File

To create multiple issues from a Markdown file:

```
/beads:create -f issues.md
```

File format:
```markdown
# Issue Title 1
Description of issue 1
Labels: backend, urgent
Priority: 1

# Issue Title 2
Description of issue 2
Type: bug
```

## Issue Types

- `bug`: Something broken that needs fixing
- `feature`: New functionality to implement
- `task`: General task or work item
- `chore`: Maintenance work (refactoring, cleanup)
- `docs`: Documentation updates

## Priority Levels

- `1`: Critical/Urgent (blocking work)
- `2`: High (important, work soon)
- `3`: Medium (normal priority)
- `4`: Low (nice to have)
- `5`: Minimal (maybe someday)

## After Creation

The command will:
1. Create the issue and return its ID (e.g., bd-a1b2)
2. Auto-sync to `.beads/issues.jsonl`
3. Display the created issue details

## Next Steps

After creating an issue:
- Add dependencies: `/beads:dep add <blocker-id> <blocked-id>`
- Start work: `/beads:update <id> --status in_progress`
- View details: `bd show <id>`

## Error Handling

If creation fails:
- Ensure beads is initialized (`/beads:init`)
- Check title is provided (required)
- Verify file exists (for bulk creation)
- Check format of labels (comma-separated, no spaces)

## Notes

- Issues are automatically assigned hash-based IDs (bd-a1b2, bd-f14c)
- Title is required; all other fields are optional
- Labels should not contain spaces (use hyphens or underscores)
- Changes are auto-synced to git after 5 seconds
- Use quotes around multi-word values
