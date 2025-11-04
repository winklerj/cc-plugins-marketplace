# Beads Command Reference

Complete reference for beads commands, options, and troubleshooting.

## Table of Contents
- [Command Quick Reference](#command-quick-reference)
- [Command Details](#command-details)
- [Common Patterns](#common-patterns)
- [Troubleshooting](#troubleshooting)
- [Project Statistics](#project-statistics)

## Command Quick Reference

| Command | Purpose | Common Usage |
|---------|---------|--------------|
| `/beads:install` | Install bd cli | `/beads:install` |
| `/beads:init` | Initialize project | `/beads:init` |
| `/beads:ready` | Find ready work | `/beads:ready --json` |
| `/beads:create` | Create issue | `/beads:create "Title" -t bug -p 1` |
| `/beads:list` | List issues | `/beads:list --status open` |
| `/beads:update` | Update issue | `/beads:update bd-a1b2 --status in_progress` |
| `/beads:close` | Close issue | `/beads:close bd-a1b2 --reason "Done"` |
| `/beads:dep add` | Add dependency | `/beads:dep add bd-a1b2 bd-f14c --type blocks` |
| `/beads:dep remove` | Remove dependency | `/beads:dep remove bd-a1b2 bd-f14c` |
| `/beads:dep tree` | View dependency tree | `/beads:dep tree bd-a1b2` |
| `/beads:dep cycles` | Detect circular deps | `/beads:dep cycles` |

## Command Details

### /beads:install
Installs the beads bd cli tool.

**Options:** None
**When to use:** First time setup, bd command not found
**Prerequisites:** curl, git, sqlite3

### /beads:init
Initialize beads in the current project.

**Arguments:**
- `--branch <name>` - Use separate branch for metadata (for protected main branches)

**Examples:**
```bash
/beads:init
/beads:init --branch beads-metadata
```

**What it creates:**
- `.beads/` directory
- `.beads/issues.jsonl` file
- SQLite database for local caching

### /beads:ready
Show issues ready to work on (no blockers).

**Arguments:**
- `--json` - Output as JSON for programmatic access

**Examples:**
```bash
/beads:ready
/beads:ready --json
```

**JSON Output:**
```json
{
  "ready": [
    {
      "id": "bd-a1b2",
      "title": "Issue title",
      "priority": 1,
      "type": "bug",
      "labels": ["label1", "label2"]
    }
  ]
}
```

### /beads:create
Create a new issue.

**Arguments:**
- `"<title>"` - Issue title (required)
- `-d, --description` - Detailed description
- `-p, --priority` - Priority 1-5 (1=highest)
- `-t, --type` - Issue type: bug, feature, task, chore, docs
- `-l, --labels` - Comma-separated labels (no spaces)
- `--assignee` - Assign to user
- `-f, --file` - Bulk create from markdown file

**Examples:**
```bash
/beads:create "Fix login bug"
/beads:create "Add dark mode" -d "Implement theme toggle" -t feature -p 2
/beads:create "Security fix" -t bug -p 1 -l "security,critical" --assignee alice
/beads:create -f issues.md
```

**Returns:** Issue ID (e.g., bd-a1b2)

### /beads:list
List and filter issues.

**Arguments:**
- `--status` - Filter by status: open, in_progress, blocked, closed
- `--type` - Filter by type: bug, feature, task, chore, docs
- `--priority` - Filter by priority: 1-5
- `--labels` - Filter by labels (comma-separated)
- `--assignee` - Filter by assigned user
- `--json` - Output as JSON

**Examples:**
```bash
/beads:list
/beads:list --status open
/beads:list --type bug --priority 1
/beads:list --labels backend,urgent
/beads:list --assignee alice --json
```

### /beads:update
Update an existing issue.

**Arguments:**
- `<issue-id>` - Issue to update (required)
- `--status` - Change status: open, in_progress, blocked, closed
- `--priority` - Change priority: 1-5
- `--type` - Change type
- `--assignee` - Reassign
- `--labels` - Update labels (replaces existing)
- `--title` - Update title
- `--description` - Update description

**Examples:**
```bash
/beads:update bd-a1b2 --status in_progress
/beads:update bd-a1b2 --priority 1
/beads:update bd-a1b2 --status blocked
/beads:update bd-a1b2 --assignee bob --priority 2
```

### /beads:close
Close an issue with completion reason.

**Arguments:**
- `<issue-id>` - Issue to close (required)
- `--reason` - Completion reason (required)

**Examples:**
```bash
/beads:close bd-a1b2 --reason "Fixed and tested"
/beads:close bd-a1b2 --reason "Duplicate of bd-f14c"
/beads:close bd-a1b2 --reason "Cannot reproduce - need more info"
```

**Good reasons include:**
- What was done
- How it was tested
- Verification results
- Related commits/PRs

### /beads:dep add
Add a dependency between issues.

**Arguments:**
- `<blocker-id>` - Issue that blocks (required)
- `<blocked-id>` - Issue being blocked (required)
- `--type` - Dependency type (optional, defaults to `blocks`)

**Dependency Types:**
- `blocks` - Blocker must complete before blocked can start
- `parent` - Hierarchical parent-child relationship
- `related` - Related but independent
- `discovered-from` - New issue found during other work

**Examples:**
```bash
/beads:dep add bd-a1b2 bd-f14c
/beads:dep add bd-a1b2 bd-f14c --type blocks
/beads:dep add bd-parent bd-child --type parent
/beads:dep add bd-curr bd-new --type discovered-from
/beads:dep add bd-front bd-back --type related
```

### /beads:dep remove
Remove a dependency.

**Arguments:**
- `<blocker-id>` - Blocker issue (required)
- `<blocked-id>` - Blocked issue (required)

**Example:**
```bash
/beads:dep remove bd-a1b2 bd-f14c
```

### /beads:dep tree
Visualize dependency tree for an issue.

**Arguments:**
- `<issue-id>` - Issue to visualize (required)

**Example:**
```bash
/beads:dep tree bd-a1b2
```

**Output:**
```
bd-a1b2: Implement authentication
├── bd-f14c: Setup database [blocks]
│   └── bd-3e7a: Install PostgreSQL [blocks]
└── bd-9b8d: Create user model [blocks]
```

### /beads:dep cycles
Detect circular dependencies.

**Arguments:** None

**Example:**
```bash
/beads:dep cycles
```

**Output if found:**
```
Found 1 circular dependency:
bd-a1b2 → bd-f14c → bd-3e7a → bd-a1b2
```

## Common Patterns

### Issue Types by Use Case

**bug** - Something broken that needs fixing
```bash
/beads:create "Login fails on mobile" -t bug -p 1
```

**feature** - New functionality
```bash
/beads:create "Add export to PDF" -t feature -p 2
```

**task** - General work item
```bash
/beads:create "Update dependencies" -t task -p 3
```

**chore** - Maintenance, refactoring, cleanup
```bash
/beads:create "Refactor authentication module" -t chore -p 3
```

**docs** - Documentation updates
```bash
/beads:create "Document API endpoints" -t docs -p 4
```

### Priority Guidelines

**1 (Critical)** - Blocks other work, security issues, production bugs
**2 (High)** - Important features, significant bugs
**3 (Medium)** - Normal priority work
**4 (Low)** - Nice to have
**5 (Minimal)** - Maybe someday

### Status Best Practices

**open** - Ready to start (default for new issues)
**in_progress** - Currently being worked on
**blocked** - Cannot proceed due to blocker
**closed** - Completed or resolved

Update status when state changes:
- Start work → `in_progress`
- Hit blocker → `blocked`
- Complete → use `/beads:close` (not update --status closed)

## Troubleshooting

### bd command not found

**Problem:** bd command doesn't exist

**Solution:**
```bash
/beads:install
```

Then verify:
```bash
bd --version
```

### Project not initialized

**Problem:** "Error: not a beads project"

**Solution:**
```bash
/beads:init
```

For protected branches:
```bash
/beads:init --branch beads-metadata
```

### Circular dependency detected

**Problem:** Cannot add dependency due to cycle

**Solution:**
```bash
# 1. Detect cycles
/beads:dep cycles

# 2. Identify the cycle in output
# Example: bd-a1b2 → bd-f14c → bd-3e7a → bd-a1b2

# 3. Remove one dependency to break cycle
/beads:dep remove bd-3e7a bd-a1b2

# 4. Verify fixed
/beads:dep cycles
```

### No ready work available

**Problem:** `/beads:ready` shows no issues

**Solutions:**
```bash
# 1. Check blocked issues
bd blocked

# 2. Work on blockers to unblock other work

# 3. Check all open issues
/beads:list --status open

# 4. Create new issues if needed
```

### Issue not updating

**Problem:** Update command succeeds but changes don't appear

**Likely causes:**
- Wrong issue ID (IDs are case-sensitive)
- Sync hasn't completed (wait 5 seconds)
- Local cache out of sync

**Solutions:**
```bash
# Verify issue exists
bd show <issue-id>

# Force sync
bd sync

# Check git status
git status

# Pull latest if needed
git pull
```

### Hash ID too short/long

**Not a problem** - IDs scale with database size:
- 0-500 issues: 4 chars (bd-a1b2)
- 500-1,500 issues: 5 chars (bd-f14c3)
- 1,500+ issues: 6 chars (bd-3e7a5b)

This is automatic and maintains collision resistance.

## Project Statistics

### Useful bd commands (not slash commands)

```bash
# Project overview
bd stats

# Show blocked issues
bd blocked

# Show specific issue details
bd show <issue-id>

# Manual sync
bd sync

# Health check
bd doctor

# Migration (after updates)
bd migrate

# Onboarding info
bd onboard
```

### Monitoring Health

Regular checks:
```bash
# Any circular dependencies?
bd dep cycles

# What's blocked?
bd blocked

# High priority open work?
/beads:list --priority 1 --status open

# Overall stats
bd stats
```

### Git Integration

Issues sync to `.beads/issues.jsonl` automatically after 5 seconds.

For faster sync, install git hooks:
```bash
cd .beads/git-hooks
./install.sh
```

This syncs:
- Before commits (export)
- After pulls (import)

## Command-Line vs Slash Commands

**Slash commands** (use in Claude Code):
- `/beads:install`
- `/beads:init`
- `/beads:ready`
- `/beads:create`
- `/beads:list`
- `/beads:update`
- `/beads:close`
- `/beads:dep`

**Direct bd commands** (use in terminal):
- `bd stats`
- `bd show <id>`
- `bd blocked`
- `bd doctor`
- `bd sync`
- `bd onboard`
- `bd migrate`

Both work the same underlying bd cli - slash commands are wrappers for Claude Code integration.
