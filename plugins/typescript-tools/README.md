# TypeScript Tools Plugin

A comprehensive plugin for TypeScript development that provides specialized agents, automation hooks, and git worktree commands for parallel development workflows.

## Features

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

Add this plugin to your `.claude/settings.local.json`:

```json
{
  "plugins": [
    {
      "path": "/path/to/cc-plugins-marketplace/plugins/typescript-tools"
    }
  ]
}
```

## Requirements

- Claude Code
- Git repository
- Node.js or Bun (for hooks)
- TypeScript project (for TypeScript-specific features)

## License

Apache-2.0 - See [LICENSE](../../LICENSE) for details.
