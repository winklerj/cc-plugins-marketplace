# Beads Task Management Plugin for Claude Code

A comprehensive Claude Code plugin for [beads](https://github.com/steveyegge/beads) - a git-backed issue tracking system designed for AI coding agents.

## Overview

Beads provides lightweight, git-backed task management perfect for AI-driven development workflows. This plugin integrates beads seamlessly into Claude Code with slash commands and an intelligent skill for autonomous task management.

## What is Beads?

Beads is:
- **Git-backed**: All issues stored in `.beads/issues.jsonl`, synced via git
- **Lightweight**: SQLite for local caching, no server required
- **Agent-friendly**: JSON output, dependency tracking, ready work detection
- **Distributed**: Works across teams without central infrastructure
- **Hash-based IDs**: Collision-resistant IDs like `bd-a1b2` for multi-worker workflows

## Features

- **Smart Work Detection**: Automatically finds issues with no blockers
- **Dependency Management**: Four types (blocks, parent-child, related, discovered-from)
- **Status Tracking**: Open, in_progress, blocked, closed workflow
- **Priority Management**: 1-5 priority levels
- **Type System**: bug, feature, task, chore, docs
- **JSON Support**: Programmatic access for agent workflows
- **Git Integration**: Auto-sync to repository

## Installation

### Install the Plugin

```bash
# Clone or copy to your Claude Code plugins directory
cp -r plugins/beads-task-management ~/.claude/plugins/
```

### Install Beads CLI

Use the included command:

```
/beads:install
```

Or install manually:

```bash
# Quick install (all platforms)
curl -fsSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash

# Homebrew (macOS/Linux)
brew tap steveyegge/beads && brew install bd

# npm (Node.js)
npm install -g @beads/bd
```

## Quick Start

### 1. Initialize Beads in Your Project

```
/beads:init
```

For protected branches:
```
/beads:init --branch beads-metadata
```

### 2. Create Your First Issue

```
/beads:create "Add user authentication" -d "Implement JWT-based authentication" -t feature -p 1 -l "backend,security"
```

### 3. Find Work to Do

```
/beads:ready
```

### 4. Start Working

```
/beads:update bd-a1b2 --status in_progress
```

### 5. Complete Work

```
/beads:close bd-a1b2 --reason "Implemented JWT authentication with refresh tokens, all tests passing"
```

## Available Commands

### `/beads:install`
Install the beads bd cli tool.

```
/beads:install
```

### `/beads:init`
Initialize beads in the current project.

```
/beads:init
/beads:init --branch beads-metadata
```

### `/beads:ready`
Show work ready to start (no blockers).

```
/beads:ready
/beads:ready --json
```

### `/beads:create`
Create a new issue.

```
/beads:create "Issue title" [-d description] [-p priority] [-t type] [-l labels] [--assignee user]

Examples:
/beads:create "Fix login bug" -t bug -p 1
/beads:create "Add dark mode" -d "Implement dark theme toggle" -t feature -p 2 -l "frontend,ui"
```

### `/beads:list`
List and filter issues.

```
/beads:list [--status status] [--type type] [--assignee user] [--labels labels] [--json]

Examples:
/beads:list
/beads:list --status open
/beads:list --type bug --priority 1
/beads:list --assignee alice --json
```

### `/beads:update`
Update an existing issue.

```
/beads:update <issue-id> [--status status] [--priority priority] [--type type] [--assignee user] [--labels labels]

Examples:
/beads:update bd-a1b2 --status in_progress
/beads:update bd-a1b2 --priority 1 --assignee bob
/beads:update bd-a1b2 --status blocked
```

### `/beads:close`
Close an issue with a completion reason.

```
/beads:close <issue-id> --reason "completion reason"

Examples:
/beads:close bd-a1b2 --reason "Feature implemented and tested, deployed to production"
/beads:close bd-a1b2 --reason "Duplicate of bd-f14c"
/beads:close bd-a1b2 --reason "Won't fix - working as intended"
```

### `/beads:dep`
Manage dependencies between issues.

```
# Add dependency
/beads:dep add <blocker-id> <blocked-id> [--type type]

# Remove dependency
/beads:dep remove <blocker-id> <blocked-id>

# Visualize tree
/beads:dep tree <issue-id>

# Detect cycles
/beads:dep cycles

Examples:
/beads:dep add bd-a1b2 bd-f14c --type blocks
/beads:dep add bd-a1b2 bd-f14c --type parent
/beads:dep tree bd-a1b2
/beads:dep cycles
```

## Beads Skill

The plugin includes an intelligent skill that Claude Code can automatically activate when working with tasks and issues.

### Skill Activation

The skill activates when you mention:
- Tasks, issues, or work items
- Project progress or tracking
- Finding work to do
- Beads or bd cli
- Blockers or dependencies
- Task organization or prioritization

### What the Skill Does

1. **Workflow Guidance**: Provides step-by-step task management
2. **Best Practices**: Ensures proper issue creation and dependency management
3. **Status Tracking**: Helps maintain accurate issue states
4. **Dependency Analysis**: Guides complex dependency relationships
5. **Agent Automation**: Optimized for autonomous agent workflows

### Example Usage

```
User: "What work should I focus on next?"
Claude: [Activates beads skill]
        Let me check what work is ready...
        [Runs /beads:ready]
        ...provides prioritized recommendations...

User: "I found a bug while implementing feature X"
Claude: [Activates beads skill]
        I'll create an issue and link it to your current work...
        [Runs /beads:create and /beads:dep commands]
```

## Dependency Types

### blocks (Default)
One issue must complete before another can start.

```
/beads:dep add bd-db-setup bd-user-model --type blocks
```
"Database setup" must complete before "User model" can begin.

### parent (Parent-Child)
Hierarchical breakdown of large features.

```
/beads:dep add bd-auth-system bd-login-ui --type parent
/beads:dep add bd-auth-system bd-jwt-impl --type parent
```
"Auth system" is broken into "Login UI" and "JWT implementation" sub-tasks.

### related
Connected issues that can be worked on independently.

```
/beads:dep add bd-frontend-login bd-backend-auth --type related
```
Both can proceed in parallel but are related.

### discovered-from
New issues found during other work.

```
/beads:dep add bd-current-work bd-new-issue --type discovered-from
```
Tracks where issues were discovered for context.

## Workflow Examples

### Starting a Work Session

```
1. /beads:ready
2. Review ready work
3. /beads:update bd-a1b2 --status in_progress
4. Work on the issue
5. /beads:close bd-a1b2 --reason "Completed successfully"
```

### Creating a Feature with Sub-tasks

```
1. /beads:create "User Authentication System" -t feature -p 1
   Returns: bd-a1b2

2. /beads:create "Login UI" -t task -p 2
   Returns: bd-f14c

3. /beads:create "JWT Implementation" -t task -p 2
   Returns: bd-3e7a

4. /beads:dep add bd-a1b2 bd-f14c --type parent
5. /beads:dep add bd-a1b2 bd-3e7a --type parent
```

### Handling Blockers

```
1. Working on bd-a1b2
2. Discover blocker: database not configured
3. /beads:create "Setup PostgreSQL database" -t task -p 1
   Returns: bd-f14c
4. /beads:dep add bd-f14c bd-a1b2 --type blocks
5. /beads:update bd-a1b2 --status blocked
6. /beads:update bd-f14c --status in_progress
7. Work on blocker first
```

### Agent Workflow

```bash
# Get ready work as JSON
/beads:ready --json

# Parse and select highest priority
# Start work
/beads:update <id> --status in_progress

# During work, discover new issue
/beads:create "Security vulnerability found" -t bug -p 1

# Link to current work
/beads:dep add <current-id> <new-id> --type discovered-from

# If it blocks current work
/beads:dep add <new-id> <current-id> --type blocks

# Complete work
/beads:close <id> --reason "Detailed completion summary with verification"

# Find next work
/beads:ready --json
```

## Best Practices

### Issue Creation
- ✅ Use clear, actionable titles
- ✅ Include detailed descriptions
- ✅ Set appropriate priority (1=critical, 5=low)
- ✅ Add relevant labels
- ✅ Choose correct type (bug, feature, task, chore, docs)

### Dependency Management
- ✅ Use appropriate dependency types
- ✅ Avoid circular dependencies
- ✅ Keep dependency chains short
- ✅ Document why dependencies exist
- ✅ Review and update regularly

### Status Updates
- ✅ Update status promptly
- ✅ One in_progress issue at a time
- ✅ Document blockers clearly
- ✅ Track progress accurately

### Closing Issues
- ✅ Write descriptive completion reasons
- ✅ Include verification details
- ✅ Reference commits/PRs
- ✅ Document outcomes

## Integration

### Git Commits

Reference beads issues in commit messages:

```bash
git commit -m "Implement JWT authentication

Implements bd-a1b2: Add JWT token generation and validation
Closes bd-f14c: Setup authentication middleware"
```

### Pull Requests

Reference in PR descriptions:

```markdown
## Related Issues
- Closes bd-a1b2
- Addresses bd-f14c
- Related to bd-3e7a
```

### CI/CD

Use in automated workflows:

```bash
# Get next work item
NEXT_ISSUE=$(bd ready --json | jq -r '.ready[0].id')

# Check for blockers
bd blocked --json
```

## Directory Structure

```
beads-task-management/
├── .claude-plugin/
│   └── plugin.json           # Plugin metadata
├── commands/
│   ├── install.md            # Install beads cli
│   ├── init.md               # Initialize beads
│   ├── ready.md              # Show ready work
│   ├── create.md             # Create issues
│   ├── list.md               # List/filter issues
│   ├── update.md             # Update issues
│   ├── close.md              # Close issues
│   └── dep.md                # Manage dependencies
├── skills/
│   └── beads/
│       └── SKILL.md          # Main beads skill
└── README.md                 # This file
```

## Troubleshooting

### bd command not found

```
/beads:install
```

### Project not initialized

```
/beads:init
```

### Circular dependency detected

```
bd dep cycles
# Identify cycle and remove one dependency
/beads:dep remove <id1> <id2>
```

### No ready work available

```
bd blocked  # Check blocked issues
bd list --status open  # See all open issues
# Work on blockers or create new issues
```

## Advanced Usage

### Bulk Issue Creation

Create `issues.md`:

```markdown
# Setup Database
Description: Configure PostgreSQL for production
Labels: backend, infrastructure
Priority: 1

# Create User Model
Description: Implement user model with validation
Labels: backend, models
Priority: 2
```

Then:
```
/beads:create -f issues.md
```

### Filtering and Querying

```bash
# High priority bugs
/beads:list --type bug --priority 1

# All open backend work
/beads:list --status open --labels backend

# Alice's in-progress work
/beads:list --assignee alice --status in_progress --json
```

### Project Statistics

```bash
bd stats
bd list --status closed  # View completed work
bd blocked  # See blocked issues
```

## Resources

- [Beads GitHub Repository](https://github.com/steveyegge/beads)
- [Claude Code Documentation](https://docs.claude.com/claude-code)
- [Claude Code Skills](https://docs.claude.com/en/docs/claude-code/skills)
- [Custom Slash Commands](https://docs.claude.com/en/docs/claude-code/slash-commands)

## Contributing

Contributions are welcome! Please submit issues or pull requests to improve this plugin.

## License

Apache-2.0

## Author

Robb Winkle
- GitHub: [@winklerj](https://github.com/winklerj)
- Email: robb@devfit.com

## Acknowledgments

- [Steve Yegge](https://github.com/steveyegge) for creating beads
- Anthropic for Claude Code
