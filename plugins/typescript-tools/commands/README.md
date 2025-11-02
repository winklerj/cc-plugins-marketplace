# Claude Code Custom Commands

This directory contains custom slash commands for Claude Code.

## Git Worktree Commands

These commands help manage git worktrees for parallel development and task isolation.

### `/worktree <task-description>`

Creates a new git worktree for isolated task development.

**Usage:**
```
/worktree add user authentication feature
```

**What it does:**
1. Generates a unique task ID (8-character hash)
2. Creates a branch named `task/{id}-{task-description-slug}`
3. Creates a worktree in `../worktrees/{id}`
4. Installs dependencies automatically (if package.json exists)
5. Changes to the worktree directory

**Example:**
```
/worktree implement password reset flow
```

Creates:
- Branch: `task/abc123de-implement-password-reset-fl`
- Path: `../worktrees/abc123de`
- Auto-runs: `bun install`

## Benefits of Worktrees

1. **Parallel Development**: Work on multiple features simultaneously
2. **Task Isolation**: Each worktree has its own working directory and branch
3. **Quick Context Switching**: Switch between tasks without stashing changes
4. **Shared History**: All worktrees share the same git history and remotes
5. **Independent State**: Each worktree has its own HEAD and working tree state

## Directory Structure

```
project/                    # Main repository
├── .git/                   # Git metadata (shared)
├── src/                    # Main branch files
└── ...

worktrees/                  # Worktree directory (outside main repo)
├── abc123de/               # Worktree 1
│   ├── src/                # Task 1 branch files
│   └── ...
└── def456gh/               # Worktree 2
    ├── src/                # Task 2 branch files
    └── ...
```

## Workflow Example

1. **Create worktree for new feature:**
   ```
   /worktree add OAuth integration
   ```

2. **Work on the feature:**
   ```bash
   # You're now in ../worktrees/{id}
   # Make changes, commit, etc.
   git add .
   git commit -m "Add OAuth provider"
   ```

3. **Switch to another task (without stashing):**
   ```
   /worktree implement email notifications
   ```

4. **List all active worktrees:**
   ```
   /worktree-list
   ```

5. **Finish and clean up:**
   ```bash
   # Merge your branch
   git checkout main
   git merge task/abc123de-add-oauth-integration

   # Remove worktree
   /worktree-remove ../worktrees/abc123de

   # Delete branch
   git branch -d task/abc123de-add-oauth-integration
   ```

## Integration with SessionStart Hook

The SessionStart hook (`.claude/hooks/session-start.sh`) automatically creates a worktree when starting a new Claude Code session. This provides automatic task isolation for each session.

To disable automatic worktree creation, modify `.claude/settings.local.json`:
```json
{
  "hooks": {
    "SessionStart": []
  }
}
```

## Additional Resources

- [Git Worktree Documentation](https://git-scm.com/docs/git-worktree)
- [Claude Code Slash Commands](https://docs.claude.com/en/docs/claude-code/slash-commands)
- [SessionStart Hook README](../.claude/hooks/README-session-start.md)
