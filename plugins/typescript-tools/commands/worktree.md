---
description: Create a git worktree for task isolation
allowed-tools: Bash(git:*), Bash(mkdir:*), Bash(cd:*), Bash(bun install:*)
---

Create a new git worktree for isolated task development.

You should use the following steps to create the worktree:

## Configuration
- Worktree base directory: `../worktrees`
- Main branch: `main` (or current branch if not on main)
- Task description: $ARGUMENTS

## Steps

1. **Generate unique task ID** from timestamp and random component:
   ```bash
   TASK_ID=$(date +%s | md5sum | cut -c1-8)
   ```

2. **Extract and slugify task name**:
   - Convert to lowercase
   - Replace spaces with dashes
   - Truncate to 30 characters max
   - Use "general-task" if no description provided

3. **Create branch and worktree names**:
   - Branch: `task/${TASK_ID}-${TASK_NAME_SLUG}`
   - Path: `../worktrees/${TASK_ID}`

4. **Create worktree** with new branch:
   ```bash
   git worktree add -b "${BRANCH_NAME}" "${WORKTREE_PATH}" "${MAIN_BRANCH}"
   ```

5. **Navigate to worktree**:
   ```bash
   cd "${WORKTREE_PATH}"
   ```

6. **Install dependencies** if package.json exists:
   ```bash
   if [ -f "package.json" ]; then
     bun install
   fi
   ```

7. **Report status**:
   - Current directory
   - Branch name
   - Worktree path

## Error Handling

If worktree creation fails:
- Check if branch already exists: `git show-ref --verify --quiet "refs/heads/${BRANCH_NAME}"`
- Check if worktree path already exists: `[ -d "${WORKTREE_PATH}" ]`
- Provide clear error message to user

## Example Usage

```
/worktree add user authentication feature
```

This creates:
- Branch: `task/abc123de-add-user-authentication-feat`
- Path: `../worktrees/abc123de`
- Installs dependencies automatically
- Changes directory to worktree

## Notes

- Worktrees enable parallel development on multiple features
- Each worktree is isolated with its own branch
- Dependencies are installed automatically
- Original repository remains unchanged
- Clean up worktrees with: `git worktree remove <path>`
