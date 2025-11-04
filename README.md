# Claude Code Plugins Marketplace

A repository of plugins that extend Claude Code with specialized agents, automation hooks, and custom commands.

## Available Plugins

### [typescript-tools](plugins/typescript-tools/README.md)

Comprehensive TypeScript development plugin with 13 specialized agents, 5 automation hooks, and git worktree commands for parallel development workflows.

**Key Features:**
- React component development with shadcn/ui
- DBOS workflow development
- E2B sandboxed execution
- Authentication systems
- Quality gates and verification
- Session-based git worktrees

### [beads-task-management](plugins/beads-task-management/README.md)

Git-backed issue tracking integration for AI-driven development workflows using [beads](https://github.com/steveyegge/beads).

**Key Features:**
- Lightweight git-backed task management
- Dependency tracking and blocker detection
- Status workflow (open, in_progress, blocked, closed)
- JSON output for agent automation
- Smart work detection
- Intelligent skill for autonomous task management

## Installation

### Prerequisites

- Claude Code installed
- Git repository
- Node.js or Bun (for plugins with hooks)

### Setup

1. **Clone this repository:**

```bash
git clone https://github.com/winklerj/cc-plugins-marketplace.git
cd cc-plugins-marketplace
```

2. **Enable plugins:**

Create or update `.claude/settings.local.json` in your project:

```json
{
  "plugins": [
    {
      "path": "/path/to/cc-plugins-marketplace/plugins/typescript-tools"
    },
    {
      "path": "/path/to/cc-plugins-marketplace/plugins/beads-task-management"
    }
  ]
}
```

*Note: Enable only the plugins you need by including their paths in the array.*

3. **Verify installation:**

In Claude Code, check available commands and agents:
```
/help
```

For plugins with agents:
```
/agents
```

For plugins with hooks:
```
/hooks
```

## Project Structure

```
cc-plugins-marketplace/
├── LICENSE                       # Apache-2.0 license
├── README.md                     # This file
└── plugins/
    ├── typescript-tools/
    │   ├── agents/              # Specialized agent definitions
    │   ├── commands/            # Custom slash commands
    │   ├── hooks/               # Automation hooks and scripts
    │   └── README.md            # TypeScript tools documentation
    └── beads-task-management/
        ├── .claude-plugin/
        │   └── plugin.json      # Plugin metadata
        ├── commands/            # Beads slash commands
        ├── skills/              # Beads intelligent skill
        └── README.md            # Beads plugin documentation
```

## Creating Your Own Plugin

### Plugin Anatomy

Each plugin needs:

1. **plugin.json** - Plugin metadata and configuration
2. **agents/** - Optional directory for agent definitions
3. **hooks/** - Optional directory for automation hooks
4. **commands/** - Optional directory for custom commands

### Basic plugin.json

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "Description of what your plugin does",
  "author": {
    "name": "Your Name",
    "email": "you@example.com"
  },
  "agents": "./agents/",
  "hooks": "./hooks/hooks.json",
  "commands": ["./commands/my-command.md"]
}
```

### Creating an Agent

Agents are markdown files with YAML frontmatter:

```markdown
---
name: my-agent
description: What this agent does
tools: Read, Write, Edit, Grep
model: sonnet
color: blue
---

# Purpose

Describe what this agent specializes in.

## Instructions

Step-by-step instructions for how the agent should work.
```

### Creating a Hook

Hooks are bash or JavaScript scripts that run at specific events.

**hooks.json:**
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/my-hook.sh",
            "timeout": 5000
          }
        ]
      }
    ]
  }
}
```

**Hook script (my-hook.sh):**
```bash
#!/bin/bash
# Read tool event data from stdin
INPUT=$(cat)

# Do your automation here
echo "Hook executed successfully"

# Exit codes: 0=success, 1=non-blocking error, 2=blocking error
exit 0
```

## Contributing

Contributions are welcome! To add a plugin:

1. Create a new directory under `plugins/`
2. Add your `plugin.json` with metadata
3. Include agents, hooks, or commands
4. Document usage in your plugin's README
5. Submit a pull request

## Testing

Test plugins and hooks manually before relying on them:

```bash
# Test a plugin's hooks (example: typescript-tools SessionStart hook)
CLAUDE_SESSION_DESCRIPTION="test" ./plugins/typescript-tools/hooks/session-start.sh

# Test commands in Claude Code with debug output
claude --debug

# Test beads commands
/beads:ready
/beads:list --status open
```

## License

Apache-2.0 - See [LICENSE](LICENSE) for details.

## Resources

### Plugin Documentation
- [typescript-tools README](plugins/typescript-tools/README.md)
- [beads-task-management README](plugins/beads-task-management/README.md)

### Claude Code Documentation
- [Claude Code Documentation](https://docs.claude.com)
- [Claude Code Hooks Guide](https://docs.claude.com/en/docs/claude-code/hooks-guide)
- [Claude Code Agents](https://docs.claude.com/en/docs/claude-code/agents)
- [Claude Code Skills](https://docs.claude.com/en/docs/claude-code/skills)

### External Dependencies
- [Beads - Git-backed issue tracking](https://github.com/steveyegge/beads)

## Author

**Robb Winkle**  
Email: robb@devfit.com  
GitHub: [@winklerj](https://github.com/winklerj)

## Version

Current version: 1.0.0
