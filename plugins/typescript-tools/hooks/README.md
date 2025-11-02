# Claude Code Hooks - Overview

This directory contains custom hooks that extend Claude Code's functionality through event-driven automation.

## Available Hooks

### 1. SessionStart Hook - Git Worktree Task Isolation

**File**: `session-start.sh`
**Event**: SessionStart
**Documentation**: [README-session-start.md](./README-session-start.md)

Automatically creates an isolated git worktree for each Claude Code session, enabling parallel development and task-specific branches.

**Key Features**:
- Generates unique task ID and branch name
- Creates worktree in `../worktrees/` directory
- Auto-installs dependencies with bun
- Stores worktree path for cleanup
- Non-blocking error handling

**Usage**:
```bash
export CLAUDE_SESSION_DESCRIPTION="add user authentication"
claude
# Hook creates: task/abc123-add-user-authentication branch in ../worktrees/abc123
```

### 2. PreCompact Hook - Compaction Checkpoint

**File**: `compaction-checkpoint.sh`
**Event**: PreCompact
**Documentation**: [README-compaction-checkpoint.md](./README-compaction-checkpoint.md)

Automatically creates a checkpoint commit before Claude Code compacts the context window due to memory limits. Preserves work-in-progress state during long sessions.

**Key Features**:
- Creates WIP checkpoint commit before compaction
- Tracks and records session elapsed time
- Saves session context to markdown file
- Extracts feature name from branch
- Skips validation for fast checkpointing
- Non-blocking with 30-second timeout

**Session Context File**:
- Located in `.claude/session-context/`
- Contains git status, diffs, and recent commits
- Includes session metadata and next steps

### 3. UserPromptSubmit Hook - Add Guideline Context

**File**: `add-guideline-context.sh`
**Event**: UserPromptSubmit
**Documentation**: [README-add-guideline-context.md](./README-add-guideline-context.md)

Automatically adds project guideline files to every prompt's context, ensuring Claude always has access to standards and best practices.

**Key Features**:
- Adds 3 guideline files to context automatically
- Non-blocking with 5-second timeout
- JSON-based context additions
- Logs warnings for missing files

**Guideline Files Added**:
- `docs/orchestrator-agents/GITHUB_CLI_CHECKPOINT_GUIDELINES.md`
- `docs/orchestrator-agents/LINEAR_MCP_COORDINATION_GUIDELINES.md`
- `docs/orchestrator-agents/REPOSITORY_GUIDELINES.md`

### 4. PostToolUse Hook - Quality Check

**File**: `node-typescript/quality-check.js`
**Event**: PostToolUse
**Matcher**: `Write|Edit|MultiEdit`

Runs quality checks after file modifications to ensure code meets project standards.

**Key Features**:
- Validates file length (max 500 LOC)
- Checks naming conventions (kebab-case)
- Ensures files are in correct directories
- Provides actionable feedback

### 5. PostToolUse Hook - TypeScript LSP Validator

**File**: `ts-lsp-validator/validate-typescript.ts`
**Event**: PostToolUse
**Matcher**: `Write|Edit|MultiEdit`
**Timeout**: 15 seconds

Validates TypeScript files using Language Server Protocol for real-time type checking.

**Key Features**:
- LSP-based validation for accuracy
- Detects type errors immediately
- 15-second timeout for large files
- JSON output with diagnostics

## Hook Configuration

All hooks are configured in `.claude/settings.local.json`:

```json
{
  "hooks": {
    "PreCompact": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/compaction-checkpoint.sh",
            "timeout": 30000
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/session-start.sh",
            "timeout": 30000,
            "blocking": false
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/add-guideline-context.sh",
            "timeout": 5000
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "node $CLAUDE_PROJECT_DIR/.claude/hooks/node-typescript/quality-check.js"
          },
          {
            "type": "command",
            "command": "bun $CLAUDE_PROJECT_DIR/.claude/hooks/ts-lsp-validator/validate-typescript.ts",
            "timeout": 15000
          }
        ]
      }
    ]
  }
}
```

## Hook Events Reference

Claude Code supports these hook events:

- **SessionStart**: When a new session begins
- **SessionEnd**: When a session ends
- **UserPromptSubmit**: When user submits a prompt
- **PreToolUse**: Before any tool executes (can block)
- **PostToolUse**: After tool completes (cannot block)
- **Stop**: When main agent stops responding
- **SubagentStop**: When subagent completes
- **PreCompact**: Before context window compaction
- **Notification**: When Claude Code sends notifications

## Testing Hooks

### View Registered Hooks

In a Claude Code session:
```
/hooks
```

### Test Individual Hook

Test hooks manually before relying on them:

```bash
# SessionStart hook
CLAUDE_SESSION_DESCRIPTION="test" ./.claude/hooks/session-start.sh

# UserPromptSubmit hook
echo '{"prompt":"test"}' | CLAUDE_PROJECT_DIR=$(pwd) ./.claude/hooks/add-guideline-context.sh

# Quality check hook
echo '{"tool":"Write","params":{"file_path":"test.ts"}}' | node ./.claude/hooks/node-typescript/quality-check.js

# TypeScript validator
echo '{"tool":"Write","params":{"file_path":"test.ts"}}' | bun ./.claude/hooks/ts-lsp-validator/validate-typescript.ts
```

### Debug Mode

Run Claude Code with debug logging:
```bash
claude --debug
```

This shows:
- When hooks are triggered
- Hook command being executed
- Hook stdout/stderr output
- Hook exit codes
- Execution time

## Creating New Hooks

### Basic Hook Structure

```bash
#!/bin/bash
# Hook description and purpose

set -e  # Exit on error

# Read input from stdin (tool event data)
INPUT=$(cat)

# Do your work here
# ...

# Output result (optional)
echo "Hook completed successfully"

# Exit with appropriate code:
# 0 = success
# 1 = non-blocking error
# 2 = blocking error (prevents operation)
exit 0
```

### Hook Best Practices

1. **Use Absolute Paths**: Hook threads reset cwd between bash calls
   ```bash
   # Good
   "$CLAUDE_PROJECT_DIR/.claude/hooks/my-script.sh"

   # Bad
   "./.claude/hooks/my-script.sh"
   ```

2. **Handle Errors Gracefully**: Use `set -e` and provide clear error messages
   ```bash
   set -e
   if ! command -v tool &> /dev/null; then
     echo "Error: 'tool' not found" >&2
     exit 1
   fi
   ```

3. **Keep Hooks Fast**: Use timeouts and optimize for performance
   ```json
   {"timeout": 5000, "blocking": false}
   ```

4. **Make Configurable**: Use environment variables for customization
   ```bash
   AUTO_COMMIT=${AUTO_COMMIT:-true}
   TIMEOUT=${TIMEOUT:-10}
   ```

5. **Test Thoroughly**: Test with various scenarios before deployment
   ```bash
   # Test success case
   # Test error cases
   # Test timeout scenarios
   ```

6. **Log Appropriately**: Use stdout for results, stderr for warnings
   ```bash
   echo "Success" >&1
   echo "Warning: file missing" >&2
   ```

### Advanced: JSON Output

Hooks can output JSON for advanced control:

```bash
#!/bin/bash

# Add context to the prompt
cat <<EOF
{
  "contextAdditions": [
    "path/to/file1.md",
    "path/to/file2.md"
  ]
}
EOF
```

## Security Best Practices

1. **Input Validation**: Always validate and sanitize inputs
2. **Path Restrictions**: Limit file access to authorized directories
3. **Command Injection Prevention**: Use absolute paths, escape arguments
4. **Minimal Permissions**: Operate with least privilege
5. **No Secret Exposure**: Never log sensitive data
6. **Exit Code Safety**: Use exit code 2 to block unsafe operations

## Directory Structure

```
.claude/hooks/
├── README.md                           # This file
├── README-session-start.md             # SessionStart hook documentation
├── README-compaction-checkpoint.md     # PreCompact hook documentation
├── README-add-guideline-context.md     # UserPromptSubmit hook documentation
├── session-start.sh                    # SessionStart hook script
├── compaction-checkpoint.sh            # PreCompact hook script
├── add-guideline-context.sh            # UserPromptSubmit hook script
├── node-typescript/                    # Quality check hook
│   ├── quality-check.js
│   └── ...
├── ts-lsp-validator/                   # TypeScript LSP validator
│   ├── validate-typescript.ts
│   ├── tsconfig.json
│   └── ...
└── tsconfig.json                       # Shared TypeScript config

.claude/session-context/                # Session context files (generated)
└── pre-compaction-*.md                 # Checkpoint context files
```

## Common Use Cases

### 1. Code Formatting (PreToolUse)
Run formatters before files are written:
```bash
prettier --write "${FILE_PATH}"
```

### 2. Command Logging (PreToolUse on Bash)
Log all bash commands to audit trail:
```bash
echo "[$(date)] ${COMMAND}" >> .audit-log
```

### 3. File Protection (PreToolUse)
Prevent modifications to critical files:
```bash
if [[ "${FILE_PATH}" == "critical.ts" ]]; then
  echo "Cannot modify critical file"
  exit 2  # Block operation
fi
```

### 4. Notifications (Stop, SubagentStop)
Send notifications on completion:
```bash
osascript -e 'display notification "Task completed" with title "Claude Code"'
```

### 5. Context Enrichment (PreToolUse)
Add additional context before tool execution:
```json
{
  "contextAdditions": ["relevant/file.md"]
}
```

## Troubleshooting

### Hook Not Running

1. Check configuration: `cat .claude/settings.local.json | grep -A 10 HookEvent`
2. Verify executable: `ls -l .claude/hooks/hook-script.sh`
3. Test manually: `./.claude/hooks/hook-script.sh`
4. Check debug logs: `claude --debug`

### Hook Timing Out

1. Increase timeout in settings.local.json
2. Optimize hook script for performance
3. Consider using `run_in_background` for long operations

### Hook Errors

1. Check exit code (0=success, 1=non-blocking, 2=blocking)
2. Review stderr output in debug logs
3. Validate input/output format
4. Test with sample inputs manually

## Resources

- [Claude Code Hooks Guide](https://docs.claude.com/en/docs/claude-code/hooks-guide)
- [Claude Code Hooks Reference](https://docs.claude.com/en/docs/claude-code/hooks)
- [Git Worktree Integration](../../docs/orchestrator-agents/GITHUB_CLI_CHECKPOINT_GUIDELINES.md#git-worktree-integration)
- [Project Guidelines](../../docs/orchestrator-agents/REPOSITORY_GUIDELINES.md)

## Contributing

When adding new hooks:

1. Create hook script in `.claude/hooks/`
2. Make script executable: `chmod +x hook-script.sh`
3. Add configuration to `settings.local.json`
4. Test thoroughly with manual execution
5. Create detailed documentation (README-hook-name.md)
6. Update this overview document
7. Test with `claude --debug` in real session

## Version History

- **2025-10-10**: Added PreCompact hook for checkpoint commits before compaction
- **2025-10-10**: Added SessionStart hook for worktree task isolation
- **2025-10-10**: Initial hooks setup with UserPromptSubmit, PostToolUse hooks
