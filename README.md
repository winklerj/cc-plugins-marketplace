# Claude Code Plugins Marketplace

A repository of plugins that extend Claude Code with specialized agents, automation hooks, and custom commands.

## What's Inside

### typescript-tools Plugin

The main plugin for TypeScript development that provides:

- **13 Specialized Agents** - Expert assistants for specific coding tasks
- **5 Automation Hooks** - Event-driven workflow automation
- **Git Worktree Commands** - Tools for parallel development

## Agents

Agents are specialized assistants that handle specific types of coding tasks. Each agent has focused expertise and follows consistent patterns.

| Agent | Purpose |
|-------|---------|
| `react-component-developer` | Create production-ready React components with TypeScript, shadcn/ui, and Tailwind CSS |
| `dbos-workflow-developer` | Build reliable applications using DBOS workflows, queues, and durable execution |
| `e2b-typescript-developer` | Develop with E2B sandboxed execution environments |
| `auth-gate-agent` | Implement authentication and authorization systems |
| `integration-planner` | Plan and design system integrations |
| `quality-gate-agent` | Enforce code quality standards and best practices |
| `research-agent` | Research technical solutions and gather context |
| `verification-agent` | Verify implementations meet requirements |
| `subagent-creator` | Create new specialized agents |
| `hook-creator` | Build custom Claude Code hooks |
| `task-parallelization-planner` | Break down complex tasks for parallel execution |
| `tools-lister` | Document available tools and capabilities |
| `dbos-deploy-agent` | Handle DBOS deployment processes |

### Using Agents

In Claude Code, invoke an agent by name:

```
@react-component-developer create a button component with variants for primary, secondary, and outline styles
```

Agents have no memory of previous conversations - they start fresh each time. Give them complete context in your request.

## Hooks

Hooks trigger automatically at specific points in your workflow to automate repetitive tasks.

### SessionStart Hook

Creates an isolated git worktree for each Claude Code session, enabling parallel development.

**What it does:**
- Generates unique task ID and branch name
- Creates worktree in `../worktrees/` directory
- Installs dependencies automatically
- Enables working on multiple tasks simultaneously

### PreCompact Hook

Creates a checkpoint commit before Claude Code compacts its context window due to memory limits.

**What it does:**
- Commits work-in-progress automatically
- Saves session context to markdown file
- Records elapsed time and session metadata
- Prevents losing work during long sessions

### UserPromptSubmit Hook

Adds project guideline files to every prompt automatically, ensuring Claude always has access to your standards.

**What it does:**
- Injects guideline files into context
- Runs quickly with 5-second timeout
- Non-blocking for smooth operation

### PostToolUse Hooks (Quality Check + TypeScript Validator)

Runs after file modifications to ensure code quality.

**What it does:**
- Validates file length (max 500 LOC)
- Checks naming conventions (kebab-case)
- Validates TypeScript types with LSP
- Provides immediate feedback on issues

## Commands

Custom slash commands for specialized workflows.

### `/worktree <description>`

Creates a new git worktree for isolated task development.

**Example:**
```
/worktree add user authentication feature
```

**Creates:**
- Branch: `task/abc123de-add-user-authentication-fe`
- Path: `../worktrees/abc123de`
- Auto-runs dependency installation

**Benefits:**
- Work on multiple features simultaneously
- Switch between tasks without stashing changes
- Each worktree has its own branch and working directory

## Installation

### Prerequisites

- Claude Code installed
- Git repository
- Node.js or Bun (for hooks)

### Setup

1. **Clone this repository:**

```bash
git clone https://github.com/winklerj/cc-plugins-marketplace.git
cd cc-plugins-marketplace
```

2. **Enable the plugin:**

Create or update `.claude/settings.local.json` in your project:

```json
{
  "plugins": [
    {
      "path": "/path/to/cc-plugins-marketplace/plugins/typescript-tools"
    }
  ]
}
```

3. **Verify installation:**

In Claude Code, check available agents:
```
/agents
```

Check registered hooks:
```
/hooks
```

## Project Structure

```
cc-plugins-marketplace/
├── LICENSE                    # Apache-2.0 license
├── README.md                  # This file
└── plugins/
    └── typescript-tools/
        ├── agents/           # Specialized agent definitions
        ├── commands/         # Custom slash commands
        └── hooks/           # Automation hooks and scripts
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

Test hooks manually before relying on them:

```bash
# Test SessionStart hook
CLAUDE_SESSION_DESCRIPTION="test" ./plugins/typescript-tools/hooks/session-start.sh

# Test with debug output
claude --debug
```

## License

Apache-2.0 - See [LICENSE](LICENSE) for details.

## Resources

- [Claude Code Documentation](https://docs.claude.com)
- [Claude Code Hooks Guide](https://docs.claude.com/en/docs/claude-code/hooks-guide)
- [Claude Code Agents](https://docs.claude.com/en/docs/claude-code/agents)

## Author

**Robb Winkle**  
Email: robb@devfit.com  
GitHub: [@winklerj](https://github.com/winklerj)

## Version

Current version: 1.0.0
