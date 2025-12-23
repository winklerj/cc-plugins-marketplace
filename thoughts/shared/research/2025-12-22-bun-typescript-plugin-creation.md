---
date: 2025-12-22T00:00:00-05:00
researcher: Claude
git_commit: 3f0761a9731a681e4c60355aad2b00f493c1819a
branch: add-new-plugins-to-marketplace
repository: cc-plugins-marketplace
topic: "Creating a new Bun TypeScript plugin"
tags: [research, codebase, bun, typescript, plugin-creation]
status: complete
last_updated: 2025-12-22
last_updated_by: Claude
---

# Research: Creating a New Bun TypeScript Plugin

**Date**: 2025-12-22
**Researcher**: Claude
**Git Commit**: 3f0761a9731a681e4c60355aad2b00f493c1819a
**Branch**: add-new-plugins-to-marketplace
**Repository**: cc-plugins-marketplace

## Research Question
How to create a new plugin for Bun TypeScript projects, and what Bun-specific content exists that could be moved to it.

## Summary

The codebase contains 4 existing plugins with a consistent structure. Bun-specific content is currently scattered throughout the `typescript-tools` plugin, including agents, hooks, and TypeScript configurations. A new `bun-typescript` plugin would require:
1. A `.claude-plugin/plugin.json` configuration
2. Moving Bun-specific agents, hooks, and configs
3. Optional README and supporting documentation

## Detailed Findings

### Plugin Structure Pattern

Each plugin follows this directory structure:
```
plugins/{plugin-name}/
├── .claude-plugin/
│   └── plugin.json        # Required: plugin configuration
├── agents/                 # Optional: agent definitions (.md files)
├── commands/               # Optional: slash commands (.md files)
├── skills/                 # Optional: skill definitions
│   └── {skill-name}/
│       ├── SKILL.md
│       ├── examples.md
│       ├── reference.md
│       └── workflows.md
├── hooks/                  # Optional: hook scripts and config
│   └── hooks.json
└── README.md               # Optional: plugin documentation
```

### plugin.json Required Structure

Based on `plugins/typescript-tools/.claude-plugin/plugin.json`:

```json
{
  "name": "bun-typescript",
  "version": "1.0.0",
  "description": "Bun-specific TypeScript development tools",
  "author": {
    "name": "Author Name",
    "email": "email@example.com",
    "url": "https://github.com/username"
  },
  "repository": "https://github.com/winklerj/cc-plugins-marketplace",
  "license": "Apache-2.0",
  "keywords": ["bun", "typescript", "testing", "development"],
  "commands": "./commands/",
  "agents": ["./agents/agent-name.md"],
  "skills": "./skills/",
  "hooks": "./hooks/hooks.json"
}
```

Component declarations support two patterns:
- **Directory path**: `"./commands/"` - loads all files in directory
- **File array**: `["./agents/agent.md"]` - explicit file list

### Bun-Specific Content to Move

#### Agents (in `plugins/typescript-tools/agents/`)

| File | Bun Usage | Lines |
|------|-----------|-------|
| `react-component-developer.md` | Bun-based project, `bun:test` imports | 3, 11, 233, 234, 316 |
| `quality-gate-agent.md` | `bun eslint`, `bun tsc`, `bun test` | 22, 28, 34, 80, 113, 164 |
| `verification-agent.md` | `bun test` command | 32 |
| `dbos-workflow-developer.md` | bundler considerations, `bun:test` | 112, 113, 115, 565 |
| `dbos-deploy-agent.md` | `import { $ } from "bun"`, `Bun.file()` | 103, 371, 464 |
| `research-agent.md` | `bun add` command | 264 |

#### Hooks (in `plugins/typescript-tools/hooks/`)

| File | Bun Usage |
|------|-----------|
| `session-start.sh` | Runs `bun install` (lines 59, 60) |
| `lint-check.sh` | `bun run lint:fix`, `bun run lint`, `bun run build` (lines 13, 16, 20) |
| `ts-lsp-validator/validate-typescript.ts` | `#!/usr/bin/env bun`, `Bun.stdin.text()` |
| `ts-lsp-validator/README.md` | Bun runtime documentation |
| `ts-lsp-validator/SETUP-SUMMARY.md` | Bun setup instructions |

#### TypeScript Configurations

| File | Bun Setting |
|------|-------------|
| `hooks/tsconfig.json` | `"bun-types"` in types, `"bundler"` moduleResolution |
| `hooks/node-typescript/tsconfig-cache.json` | References `bun-env.d.ts` |

### Proposed New Plugin Structure

```
plugins/bun-typescript/
├── .claude-plugin/
│   └── plugin.json
├── agents/
│   ├── react-component-developer.md    # Move from typescript-tools
│   ├── quality-gate-agent.md           # Move from typescript-tools
│   └── verification-agent.md           # Move from typescript-tools
├── hooks/
│   ├── hooks.json
│   ├── session-start.sh                # Bun install hook
│   ├── lint-check.sh                   # Bun lint/build hook
│   └── ts-lsp-validator/               # Move entire directory
│       ├── validate-typescript.ts
│       ├── README.md
│       └── SETUP-SUMMARY.md
├── configs/
│   └── tsconfig.bun.json               # Bun-specific TypeScript config
└── README.md
```

### Shared vs Bun-Specific Considerations

Some agents have mixed usage (both Node.js and Bun patterns). Consider:

1. **Fully Bun-specific** (move entirely):
   - `ts-lsp-validator/` - Uses Bun shebang and APIs
   - `lint-check.sh` - Uses `bun run` commands

2. **Partially Bun-specific** (consider copying or abstracting):
   - `react-component-developer.md` - Could work with Node too
   - `quality-gate-agent.md` - Commands are Bun-specific but pattern is generic

3. **Runtime-agnostic** (keep in typescript-tools):
   - General TypeScript patterns not tied to Bun

## Code References

- `plugins/typescript-tools/.claude-plugin/plugin.json` - Example plugin configuration
- `plugins/typescript-tools/agents/` - Contains agents to evaluate for moving
- `plugins/typescript-tools/hooks/hooks.json` - Hook configuration pattern
- `plugins/typescript-tools/hooks/ts-lsp-validator/validate-typescript.ts:1` - Bun shebang example
- `plugins/beads-task-management/.claude-plugin/plugin.json` - Simpler plugin example
- `README.md:115-129` - Plugin.json template in main docs

## Architecture Documentation

### Component Types

1. **Commands** - Slash commands with YAML frontmatter defining allowed tools
2. **Agents** - Specialized agents with model, tools, and color configuration
3. **Skills** - Auto-invoked capabilities with SKILL.md + supporting docs
4. **Hooks** - Shell scripts triggered by events (PreCompact, PostToolUse, etc.)

### Path Resolution

All paths in plugin.json are relative to the `.claude-plugin/` directory containing the file.

## Open Questions

1. Should Bun-specific agents be duplicated or moved entirely from typescript-tools?
2. Should shared hooks (session-start.sh) be kept in both plugins or abstracted?
3. Are there additional Bun-specific skills that should be created?
4. Should the dbos-* agents move to bun-typescript or stay in typescript-tools?
