---
name: beads
description: Git-backed issue tracking for AI agents using beads bd cli. Handles issue creation, dependency management, status tracking, and finding ready work with no blockers. Use when user mentions tasks, issues, bugs, features, work items, blockers, dependencies, beads, bd cli, task tracking, work parallelization, or project management.
---

# Beads Task Management

Beads is a git-backed issue tracker designed for AI coding agents. Issues are stored in `.beads/issues.jsonl` and synced via git, with hash-based IDs (bd-a1b2) for collision-resistant multi-agent workflows.

## Core Concepts

**Available Commands:**
- `/beads:install` - Install bd cli
- `/beads:init` - Initialize in project
- `/beads:ready` - Find work with no blockers
- `/beads:create` - Create issues
- `/beads:list` - List/filter issues
- `/beads:update` - Update issue fields
- `/beads:close` - Close with reason
- `/beads:dep` - Manage dependencies

**Issue Types:** bug, feature, task, chore, docs
**Priority Levels:** 1 (critical) to 5 (low)
**Status Flow:** open → in_progress → blocked → closed

**Dependency Types:**
- `blocks` - Blocker must complete before blocked can start
- `parent` - Hierarchical parent-child breakdown
- `related` - Connected but independent
- `discovered-from` - Found during other work

## Essential Workflows

### Setup
If bd command not found: `/beads:install`
If project not initialized: `/beads:init`

### Basic Work Session
1. Find ready work: `/beads:ready` or `/beads:ready --json` for programmatic access
2. Start work: `/beads:update <id> --status in_progress`
3. Complete work: `/beads:close <id> --reason "Detailed completion summary"`

### Creating Issues
Use descriptive titles and appropriate types. Examples:
```
/beads:create "Fix authentication timeout" -t bug -p 1
/beads:create "Add dark mode toggle" -t feature -p 2 -l "frontend,ui"
```

### Managing Dependencies
**Add blocker:** `/beads:dep add <blocker-id> <blocked-id> --type blocks`
**Add parent-child:** `/beads:dep add <parent-id> <child-id> --type parent`
**Link discovered work:** `/beads:dep add <current-id> <new-id> --type discovered-from`

Use `bd dep tree <id>` to visualize dependencies and `bd dep cycles` to detect circular dependencies (which must be avoided).

## Key Behaviors

**When discovering issues during work:**
1. Create issue immediately
2. Link to current work with `discovered-from` type
3. If it blocks progress, add `blocks` dependency and update current issue to `blocked` status
4. Work on blocker or switch to other ready work

**Breaking down large features:**
1. Create parent issue
2. Create child issues for components
3. Link with `parent` type dependencies
4. Child issues can be worked independently

**Close issues with descriptive reasons** that include what was done, how it was tested, and outcomes. This creates valuable project documentation.

## Important Constraints

- **Avoid circular dependencies** - use `bd dep cycles` to detect
- **Use appropriate dependency types** - `blocks` for actual blockers, `parent` for breakdown, `related` for connections, `discovered-from` for tracking origins
- Changes auto-sync to `.beads/issues.jsonl` in git after 5 seconds
- Hash-based IDs scale with database size (4-6 characters)

## Additional Resources

For detailed workflows and examples, see:
- [workflows.md](workflows.md) - Complex workflow patterns and agent-specific guidance
- [examples.md](examples.md) - Concrete examples for common scenarios
- [reference.md](reference.md) - Complete command reference and troubleshooting

Command documentation is in the `commands/` directory.
