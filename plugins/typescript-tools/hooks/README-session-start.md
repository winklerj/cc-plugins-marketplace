# SessionStart Hook - Git Worktree Task Isolation

## Overview

This SessionStart hook automatically creates an isolated git worktree for each Claude Code session, enabling parallel development and task-specific branches without conflicts.

## What It Does

When a new Claude Code session starts, this hook:

1. Generates a unique task ID from timestamp and random component (8 character hash)
2. Extracts task name from `CLAUDE_SESSION_DESCRIPTION` environment variable (default: "general-task")
3. Slugifies the task name (lowercase, spaces to dashes, max 30 chars)
4. Creates branch name as: `task/${TASK_ID}-${TASK_NAME_SLUG}`
5. Creates worktree in `../worktrees/${TASK_ID}` relative to main repo
6. Navigates to the worktree directory
7. Runs `bun install` if package.json exists
8. Stores worktree path in `${MAIN_REPO}/.claude-worktree` for cleanup
9. Stores branch name in `${MAIN_REPO}/.claude-branch` for reference
10. Provides clear progress messages with emojis

## Benefits

- **Task Isolation**: Each session works in its own directory with its own branch
- **Parallel Development**: Multiple sessions can run simultaneously without conflicts
- **Clean Separation**: Main worktree remains untouched during development
- **Easy Context Switching**: Switch between tasks without stashing or committing
- **Automatic Setup**: No manual branch or worktree management needed

## Configuration

The hook is configured in `.claude/settings.local.json`:

```json
{
  "hooks": {
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
    ]
  }
}
```

### Hook Parameters

- **WORKTREE_BASE**: `../worktrees` - Directory where worktrees are created
- **MAIN_BRANCH**: `main` - Base branch for new task branches
- **timeout**: 30000ms (30 seconds) - Maximum time for hook execution
- **blocking**: false - Session continues even if hook fails

## Environment Variables

- **CLAUDE_SESSION_DESCRIPTION**: Optional description for the task/session
  - Used to generate meaningful branch names
  - Example: "add user authentication" -> `task/abc123-add-user-authentication`
  - If not set, defaults to "general-task"

## File Structure

After hook execution:

```
outline-workflows/                    # Main repository
├── .claude-worktree                  # Stores current worktree path
├── .claude-branch                    # Stores current branch name
└── ...

worktrees/                            # Created by hook
└── 3ceafa3f/                         # Task-specific worktree
    ├── .git -> main repo            # Linked to main repository
    ├── package.json                  # Full copy of project
    ├── node_modules/                 # Fresh dependencies
    └── ...                           # All project files
```

## Usage Examples

### Example 1: Feature Development

```bash
# Set task description before starting session
export CLAUDE_SESSION_DESCRIPTION="add real-time notifications"
claude

# Hook creates:
# - Branch: task/a1b2c3d4-add-real-time-notifications
# - Worktree: ../worktrees/a1b2c3d4
# - Auto-installs dependencies
```

### Example 2: Bug Fix

```bash
export CLAUDE_SESSION_DESCRIPTION="fix session race condition"
claude

# Hook creates:
# - Branch: task/e5f6g7h8-fix-session-race-condition
# - Worktree: ../worktrees/e5f6g7h8
```

### Example 3: Default Task

```bash
# Without CLAUDE_SESSION_DESCRIPTION
claude

# Hook creates:
# - Branch: task/i9j0k1l2-general-task
# - Worktree: ../worktrees/i9j0k1l2
```

## Testing the Hook

Test the hook manually before relying on it:

```bash
# Test with custom task description
CLAUDE_SESSION_DESCRIPTION="test hook functionality" ./.claude/hooks/session-start.sh

# Verify worktree was created
git worktree list

# Verify branch was created
git branch --list 'task/*'

# Clean up test worktree
WORKTREE_PATH=$(cat .claude-worktree)
BRANCH_NAME=$(cat .claude-branch)
git worktree remove "${WORKTREE_PATH}"
git branch -D "${BRANCH_NAME}"
rm -f .claude-worktree .claude-branch
```

## Cleanup

To remove a worktree after completing work:

```bash
# Get worktree info from tracking files
WORKTREE_PATH=$(cat .claude-worktree)
BRANCH_NAME=$(cat .claude-branch)

# Navigate back to main repo
cd /Users/robbwinkle/git/outline-workflows

# Remove worktree
git worktree remove "${WORKTREE_PATH}"

# Remove branch (after PR is merged)
git branch -d "${BRANCH_NAME}"

# Clean up tracking files
rm -f .claude-worktree .claude-branch
```

### Bulk Cleanup

Clean up all stale worktrees:

```bash
# List all worktrees
git worktree list

# Prune stale worktree references
git worktree prune

# Remove gone remote branches
git fetch --prune
git branch -vv | grep ': gone]' | awk '{print $1}' | xargs git branch -D
```

## Error Handling

The hook handles errors gracefully:

### Not in Git Repository
- Hook exits with code 0 (success) without creating worktree
- Session continues normally

### Branch Already Exists
- Hook reports error and exits with code 1
- Session continues in current directory
- User can manually resolve conflict

### Worktree Path Exists
- Hook reports error and exits with code 1
- User can remove existing directory or use different task name

### Dependency Installation Fails
- Hook continues with warning
- User may need to run `bun install` manually

## Troubleshooting

### Issue: Hook doesn't run

**Check hook is registered:**
```bash
# View hooks configuration
cat .claude/settings.local.json | grep -A 10 SessionStart
```

**Verify hook is executable:**
```bash
ls -l .claude/hooks/session-start.sh
# Should show: -rwxr-xr-x (executable)
```

**Test hook manually:**
```bash
./.claude/hooks/session-start.sh
```

### Issue: Branch name already exists

**Solution 1: Remove old worktree**
```bash
git worktree list
git worktree remove /path/to/worktree
git branch -D task/abc123-task-name
```

**Solution 2: Use different task description**
```bash
export CLAUDE_SESSION_DESCRIPTION="add auth v2"  # Add version or variation
```

### Issue: Worktree directory exists but not tracked

**Clean up stale worktrees:**
```bash
git worktree prune
rm -rf ../worktrees/*  # CAUTION: Only if you're sure they're unused
```

### Issue: Dependencies not installed

**Manually install in worktree:**
```bash
cd $(cat .claude-worktree)
bun install
```

## Security Considerations

- **Input Validation**: Task name is sanitized (lowercase, dashes only, length limit)
- **Path Safety**: Worktrees created in controlled location (../worktrees/)
- **Non-Blocking**: Hook failures don't prevent session from starting
- **Minimal Permissions**: Only requires git and bun permissions
- **No Secret Exposure**: No sensitive data logged or stored

## Best Practices

1. **Set Meaningful Task Descriptions**: Use `CLAUDE_SESSION_DESCRIPTION` for clear branch names
2. **Clean Up Regularly**: Remove worktrees after PR merges to avoid clutter
3. **Monitor Disk Usage**: Each worktree duplicates the repository (including node_modules)
4. **Use Worktree for Complex Tasks**: For simple edits, traditional branches may be sufficient
5. **Coordinate with Team**: Ensure team members understand worktree workflow

## Integration with Other Hooks

This hook works well with:

- **SessionEnd Hook**: Automatically clean up worktree when session ends
- **Stop Hook**: Create checkpoint commit before session stops
- **PostToolUse Hooks**: Quality checks run normally in worktree context

## Advanced Configuration

### Change Worktree Location

Edit the hook script:
```bash
# Change from:
WORKTREE_BASE="../worktrees"

# To:
WORKTREE_BASE="/path/to/custom/location"
```

### Change Branch Prefix

Edit the hook script:
```bash
# Change from:
BRANCH_NAME="task/${TASK_ID}-${TASK_NAME_SLUG}"

# To:
BRANCH_NAME="feature/${TASK_ID}-${TASK_NAME_SLUG}"
```

### Disable Dependency Installation

Edit the hook script and comment out:
```bash
# Optional: Install dependencies if package.json exists
# if [ -f "package.json" ]; then
#   echo "📦 Installing dependencies with bun..."
#   if bun install 2>/dev/null; then
#     echo "✅ Dependencies installed"
#   else
#     echo "⚠️  Failed to install dependencies - continuing anyway"
#   fi
# fi
```

## Related Documentation

- [Git Worktree Integration](../../docs/orchestrator-agents/GITHUB_CLI_CHECKPOINT_GUIDELINES.md#git-worktree-integration)
- [Claude Code Hooks Guide](https://docs.claude.com/en/docs/claude-code/hooks-guide)
- [Claude Code Hooks Reference](https://docs.claude.com/en/docs/claude-code/hooks)

## Debugging

Run hook with debug output:

```bash
# Enable bash debugging
bash -x ./.claude/hooks/session-start.sh

# Or add to hook script temporarily:
set -x  # Add after set -e
```

Run Claude Code with debug mode:

```bash
claude --debug
```

This will show detailed hook execution logs including:
- When hook is triggered
- Hook command being executed
- Hook stdout/stderr output
- Hook exit code
- Time taken to execute

## Version History

- **v1.0.0** (2025-10-10): Initial implementation
  - Automatic worktree creation on SessionStart
  - Task ID generation with md5sum
  - Task name slugification
  - Automatic dependency installation
  - Progress feedback with emojis
