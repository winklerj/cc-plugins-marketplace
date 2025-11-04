---
description: Initialize beads in the current project
allowed-tools: Bash(bd:*)
argument-hint: [--branch <branch-name>]
---

Initialize beads issue tracking in the current project.

## Arguments

- `$ARGUMENTS` - Optional: `--branch <branch-name>` for protected branches

## Steps

1. **Check if already initialized**:
   ```bash
   if bd list 2>/dev/null; then
     echo "Beads is already initialized in this project"
     bd stats
     exit 0
   fi
   ```

2. **Verify git repository**:
   ```bash
   if ! git rev-parse --git-dir > /dev/null 2>&1; then
     echo "Error: Not a git repository. Please run 'git init' first."
     exit 1
   fi
   ```

3. **Initialize beads**:
   - If arguments provided (for protected branch):
     ```bash
     bd init $ARGUMENTS
     ```
   - Otherwise (default):
     ```bash
     bd init
     ```

4. **Verify initialization**:
   ```bash
   bd stats
   ```

5. **Display next steps**:
   - Run `bd onboard` for integration instructions
   - Run `bd create "First issue" -d "Description"` to create your first issue
   - Run `bd ready` to see ready work
   - Run `bd doctor` to verify setup

## Protected Branches

If your repository has protected branches (like main/master), use:
```bash
bd init --branch beads-metadata
```

This creates a separate branch for beads metadata to avoid conflicts with branch protection rules.

## What Gets Created

- `.beads/` directory for local SQLite cache
- `.beads/issues.jsonl` file for git-backed issue storage
- SQLite database for fast queries
- Auto-sync configuration

## Error Handling

If initialization fails:
- Ensure you're in a git repository
- Check git configuration (user.name and user.email)
- Verify write permissions in the directory
- Check if .beads/ directory already exists

## Example Usage

```
/beads:init
/beads:init --branch beads-metadata
```
