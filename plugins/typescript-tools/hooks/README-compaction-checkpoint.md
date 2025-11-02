# PreCompact Hook: Compaction Checkpoint

Automatically creates a checkpoint commit before Claude Code compacts the context window due to memory limits. This preserves work-in-progress state during long-running sessions and provides context for resumption.

## Overview

**Hook Name**: `compaction-checkpoint`
**Event**: PreCompact
**Trigger**: Before Claude Code compacts context due to memory limits
**Blocking**: No (non-blocking, exit code 0/1)
**Timeout**: 30 seconds

## Purpose

Long Claude Code sessions eventually trigger context window compaction when memory limits are reached. This hook ensures that:

1. Work-in-progress is automatically checkpointed via git commit
2. Session elapsed time is tracked and recorded
3. Conversation context is saved to a file for easy resumption
4. All changes are preserved before potential data loss
5. Fast checkpointing without validation delays (WIP commits)

## Hook Actions

When Claude Code triggers compaction, this hook:

1. **Checks for changes**: Verifies there are uncommitted changes to checkpoint
2. **Calculates session time**: Reads session start timestamp and calculates elapsed minutes
3. **Extracts feature name**: Identifies feature from branch name or uses branch name
4. **Generates change summary**: Lists changed files and diff statistics
5. **Saves session context**: Creates markdown file with full session state
6. **Creates checkpoint commit**: Commits all changes with descriptive message
7. **Skips validation**: Uses `--no-verify` to bypass pre-commit hooks for speed

## Commit Message Format

```
chore: Checkpoint before context compaction

Work in progress on ${FEATURE_NAME}.

Changed files: ${COUNT}
Session time: ${ELAPSED_MINUTES} minutes

Changes:
  - path/to/file1.ts
  - path/to/file2.tsx
  - ... and N more files

Status: Pre-compaction checkpoint (WIP)
Next steps: Continue after context compaction and review session context

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
Checkpoint-Reason: pre-compaction
Session-Time: ${ELAPSED_MINUTES} minutes
Context-File: .claude/session-context/pre-compaction-YYYYMMDD-HHMMSS.md
```

## Session Context File

The hook creates a detailed session context file at:

```
.claude/session-context/pre-compaction-YYYYMMDD-HHMMSS.md
```

This file contains:

- **Session metadata**: Date, branch, feature name, elapsed time
- **Git status**: Full output of `git status`
- **Changed files**: List of modified, added, deleted files
- **Diff summary**: Statistics for staged and unstaged changes
- **Recent commits**: Last 5 commits for context
- **Next steps**: Guidance for resuming work

Example:

```markdown
# Pre-Compaction Checkpoint Context

**Date**: 2025-10-10 14:32:15
**Branch**: task/abc123-add-authentication
**Feature**: add-authentication
**Session Time**: 47 minutes
**Changed Files**: 12

## Git Status

```
On branch task/abc123-add-authentication
Changes to be committed:
  modified:   src/auth/login.ts
  modified:   src/auth/types.ts
...
```

## Changed Files Summary

```
 M src/auth/login.ts
 M src/auth/types.ts
...
```

## Next Steps

Review the changes and continue work after context compaction.
The checkpoint commit was created to preserve work-in-progress state.
```

## Session Time Tracking

The hook integrates with the SessionStart hook to track session elapsed time:

1. **SessionStart hook** creates `.claude-session-start` with Unix timestamp
2. **PreCompact hook** reads timestamp and calculates elapsed minutes
3. Elapsed time is included in commit message and context file

If the session start file doesn't exist, the PreCompact hook creates it for future use and reports "unknown" for elapsed time.

## Feature Name Extraction

The hook intelligently extracts feature names from branch names:

- `task/123-add-authentication` → `add-authentication`
- `feature/user-profiles` → `user-profiles`
- `main` → `main` (uses branch name as-is)

This provides meaningful commit messages even when branch naming varies.

## Configuration

### Settings File

Located in: `.claude/settings.local.json`

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
    ]
  }
}
```

### Hook Script

Located in: `.claude/hooks/compaction-checkpoint.sh`

**Permissions**: Must be executable (`chmod +x`)

**Dependencies**:
- Git (for repository operations)
- Bash (shell script)
- Standard Unix utilities (date, cat, etc.)

## Installation

### 1. Verify Hook File

The hook script should already exist at:

```bash
/Users/robbwinkle/git/outline-workflows/.claude/hooks/compaction-checkpoint.sh
```

Verify it's executable:

```bash
ls -l /Users/robbwinkle/git/outline-workflows/.claude/hooks/compaction-checkpoint.sh
```

If not executable, make it executable:

```bash
chmod +x /Users/robbwinkle/git/outline-workflows/.claude/hooks/compaction-checkpoint.sh
```

### 2. Verify Configuration

Check that the hook is registered in settings:

```bash
cat /Users/robbwinkle/git/outline-workflows/.claude/settings.local.json | grep -A 10 PreCompact
```

Expected output:

```json
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
```

### 3. Create Session Context Directory

Create the directory for session context files:

```bash
mkdir -p /Users/robbwinkle/git/outline-workflows/.claude/session-context
```

### 4. Verify Session Start Tracking

The SessionStart hook should create the timestamp file. Verify it's configured:

```bash
cat /Users/robbwinkle/git/outline-workflows/.claude/hooks/session-start.sh | grep -A 3 "SESSION_START_FILE"
```

Expected output:

```bash
# Create session timestamp for tracking elapsed time (used by compaction-checkpoint hook)
SESSION_START_FILE="${CLAUDE_PROJECT_DIR}/.claude-session-start"
date +%s > "${SESSION_START_FILE}"
echo "📅 Session start time recorded: $(date '+%Y-%m-%d %H:%M:%S')"
```

## Testing

### Manual Test

Test the hook script manually with a simulated compaction event:

```bash
cd /Users/robbwinkle/git/outline-workflows

# Create test changes
echo "test" >> test-file.txt

# Set required environment variable
export CLAUDE_PROJECT_DIR=/Users/robbwinkle/git/outline-workflows

# Create session start timestamp
date +%s > .claude-session-start

# Run the hook
./.claude/hooks/compaction-checkpoint.sh
```

Expected output:

```
[PreCompact] Starting compaction checkpoint...
[PreCompact] Session elapsed time: 0 minutes
[PreCompact] Feature: main
[PreCompact] Changed files: 1
[PreCompact] Saving session context to: .claude/session-context/pre-compaction-20251010-143215.md
[PreCompact] Session context saved to: .claude/session-context/pre-compaction-20251010-143215.md
[PreCompact] Staging changes...
[PreCompact] Creating checkpoint commit...
[PreCompact] Checkpoint commit created successfully
[PreCompact] Commit: abc1234
[PreCompact] Verified: Checkpoint commit exists
[PreCompact] Compaction checkpoint complete
✓ Checkpoint created: abc1234 (1 files, 0m)
```

### Verify Checkpoint Commit

Check that the commit was created:

```bash
git log -1 --format="%H %s"
```

Expected output:

```
abc1234 chore: Checkpoint before context compaction
```

View full commit message:

```bash
git log -1
```

### Verify Session Context File

Check that the session context file was created:

```bash
ls -lh /Users/robbwinkle/git/outline-workflows/.claude/session-context/
```

View the contents:

```bash
cat /Users/robbwinkle/git/outline-workflows/.claude/session-context/pre-compaction-*.md
```

### Integration Test

To test the hook in a real Claude Code session:

1. Start Claude Code with debug logging:
   ```bash
   claude --debug
   ```

2. Work on a long task that triggers compaction (typically after extended conversation)

3. Watch debug logs for PreCompact hook execution:
   ```
   [Hooks] Triggering PreCompact hooks...
   [Hooks] Running hook: compaction-checkpoint.sh
   [PreCompact] Starting compaction checkpoint...
   ...
   [Hooks] Hook completed with exit code 0
   ```

4. Verify checkpoint commit was created:
   ```bash
   git log -1
   ```

5. Verify session context file exists:
   ```bash
   ls -lh .claude/session-context/
   ```

### Debug Mode

Run Claude Code with debug logging to see hook execution:

```bash
claude --debug
```

Debug logs show:

- Hook trigger events
- Hook command being executed
- Hook stdout/stderr output
- Hook exit codes
- Execution time

## Use Cases

### 1. Long Development Sessions

When working on complex features over extended periods:

- Hook automatically checkpoints work before compaction
- Session time tracking shows how long you've been working
- Context file preserves conversation state
- Easy to resume work after compaction

### 2. Multi-File Refactoring

When refactoring across many files:

- All changes are committed before compaction
- Change summary shows affected files
- Diff statistics help understand scope
- Safe to continue after compaction

### 3. Exploratory Development

When experimenting with different approaches:

- Frequent checkpoints preserve experimental work
- Context files document thought process
- Easy to review what was tried
- Can backtrack if needed

### 4. Context Preservation

When important context is at risk of being lost:

- Session context file captures current state
- Git commit preserves code changes
- Metadata helps resume work later
- Reduces context switching overhead

## Best Practices

### 1. Review Checkpoints Periodically

Checkpoint commits use `--no-verify` to skip validation for speed:

```bash
# Review recent checkpoint commits
git log --grep="Checkpoint-Reason: pre-compaction" --oneline

# Review changes in checkpoint
git show HEAD

# Amend checkpoint if needed (ensure it's safe to amend)
git commit --amend
```

### 2. Clean Up Session Context Files

Session context files accumulate over time:

```bash
# List session context files
ls -lh .claude/session-context/

# Remove old session context files (older than 30 days)
find .claude/session-context/ -name "*.md" -mtime +30 -delete
```

### 3. Track Session Time

Monitor session elapsed time to identify when breaks are needed:

```bash
# Check current session start time
cat .claude-session-start

# Calculate elapsed time manually
echo "$((($(date +%s) - $(cat .claude-session-start)) / 60)) minutes"
```

### 4. Use Feature Branches

Use descriptive branch names for better checkpoint commits:

```bash
# Good branch names
git checkout -b task/123-add-authentication
git checkout -b feature/user-profiles

# Results in clear commit messages
# "Work in progress on add-authentication"
# "Work in progress on user-profiles"
```

### 5. Gitignore Session Files

Add session tracking files to `.gitignore`:

```gitignore
# Claude Code session tracking
.claude-session-start
.claude-worktree
.claude-branch
.claude/session-context/
```

## Troubleshooting

### Hook Not Running

**Symptom**: Compaction occurs but no checkpoint commit is created

**Solutions**:

1. Verify hook is registered:
   ```bash
   cat .claude/settings.local.json | grep -A 10 PreCompact
   ```

2. Check hook script exists and is executable:
   ```bash
   ls -l .claude/hooks/compaction-checkpoint.sh
   chmod +x .claude/hooks/compaction-checkpoint.sh
   ```

3. Run with debug logging:
   ```bash
   claude --debug
   ```

4. Test hook manually:
   ```bash
   export CLAUDE_PROJECT_DIR=$(pwd)
   ./.claude/hooks/compaction-checkpoint.sh
   ```

### No Staged Changes

**Symptom**: Hook runs but reports "No staged changes"

**Cause**: Only untracked files exist, no modified tracked files

**Solution**: The hook now stages untracked files automatically. If this still occurs, manually stage files:

```bash
git add .
```

### Session Time Unknown

**Symptom**: Commit message shows "Session-Time: unknown minutes"

**Cause**: SessionStart hook didn't create timestamp file

**Solutions**:

1. Manually create timestamp file:
   ```bash
   date +%s > .claude-session-start
   ```

2. Verify SessionStart hook is configured:
   ```bash
   cat .claude/settings.local.json | grep -A 10 SessionStart
   ```

3. Check SessionStart hook creates timestamp:
   ```bash
   cat .claude/hooks/session-start.sh | grep SESSION_START_FILE
   ```

### Hook Timeout

**Symptom**: Hook execution is interrupted after 30 seconds

**Cause**: Large repository with many changes

**Solutions**:

1. Increase timeout in settings:
   ```json
   {
     "timeout": 60000
   }
   ```

2. Reduce scope of diff operations in hook script

3. Use `git add -u` instead of `git add .` (tracked files only)

### Permission Denied

**Symptom**: Hook fails with "Permission denied" error

**Cause**: Hook script is not executable

**Solution**: Make script executable:

```bash
chmod +x /Users/robbwinkle/git/outline-workflows/.claude/hooks/compaction-checkpoint.sh
```

### Git Repository Not Found

**Symptom**: Hook reports "Not in a git repository"

**Cause**: Working directory is not in a git repository

**Solution**: Initialize git repository or work in an existing repository:

```bash
git init
```

## Security Considerations

### Input Validation

The hook validates all inputs before processing:

- Checks for git repository existence
- Validates file paths stay within project directory
- Uses absolute paths throughout
- No user input is executed as shell commands

### Command Injection Prevention

The hook prevents command injection:

- All git commands use fixed arguments
- No string interpolation in git commands
- File paths are validated before use
- Uses `set -euo pipefail` for error handling

### Skip Pre-Commit Hooks

The hook uses `--no-verify` to skip pre-commit hooks:

- **Rationale**: Fast checkpointing is critical before compaction
- **Risk**: Validation is skipped (linting, tests, etc.)
- **Mitigation**: Checkpoint commits are clearly marked as WIP
- **Recommendation**: Review and amend checkpoint commits later

### Credential Safety

The hook does not expose credentials:

- No environment variables are logged
- No sensitive data in commit messages
- Session context files contain only git state
- No API keys or secrets are included

### Exit Code Safety

The hook uses appropriate exit codes:

- **Exit 0**: Checkpoint created successfully (allow compaction)
- **Exit 1**: Non-blocking error (log but allow compaction)
- **Never exits 2**: Blocking compaction would be harmful

## Integration with Other Hooks

### SessionStart Hook

**Integration**: Session start time tracking

The SessionStart hook creates `.claude-session-start` timestamp file:

```bash
SESSION_START_FILE="${CLAUDE_PROJECT_DIR}/.claude-session-start"
date +%s > "${SESSION_START_FILE}"
```

The PreCompact hook reads this file to calculate elapsed time:

```bash
if [[ -f "${SESSION_START_FILE}" ]]; then
  SESSION_START_TIME=$(cat "${SESSION_START_FILE}")
  CURRENT_TIME=$(date +%s)
  SESSION_ELAPSED_MINUTES=$(((CURRENT_TIME - SESSION_START_TIME) / 60))
fi
```

### PostToolUse Hooks

**Integration**: Quality checks are skipped in checkpoint commits

The checkpoint commit uses `--no-verify` to bypass:

- Quality check hook (file length, naming conventions)
- TypeScript LSP validator (type checking)

This ensures fast checkpointing without validation delays.

**Recommendation**: Review checkpoint commits later and run validation manually:

```bash
# Review checkpoint
git show HEAD

# Run validation manually
bun run typecheck
npm run lint
```

### UserPromptSubmit Hook

**Integration**: Guideline context is preserved in session context file

The UserPromptSubmit hook adds guideline files to context. These guidelines are captured in the session context file's recent commits section.

## Files Created/Modified

### Created Files

1. **Hook script**: `.claude/hooks/compaction-checkpoint.sh`
   - Executable bash script
   - Creates checkpoint commits
   - Saves session context

2. **Session context files**: `.claude/session-context/pre-compaction-YYYYMMDD-HHMMSS.md`
   - Created on each compaction
   - Contains session state
   - Markdown format for easy reading

3. **Session timestamp**: `.claude-session-start`
   - Created by SessionStart hook
   - Unix timestamp
   - Used to calculate elapsed time

### Modified Files

1. **Settings**: `.claude/settings.local.json`
   - Added PreCompact hook configuration
   - 30-second timeout
   - Non-blocking execution

2. **SessionStart hook**: `.claude/hooks/session-start.sh`
   - Added session timestamp creation
   - Integrates with PreCompact hook
   - Preserves existing functionality

## Performance

### Hook Execution Time

Typical execution time: **1-5 seconds**

- Git status: ~100ms
- Git diff: ~200ms
- File I/O: ~50ms
- Git commit: ~500ms
- Total: ~1-5 seconds (depends on repository size)

### Timeout

Default timeout: **30 seconds**

- Allows for large repositories
- Prevents indefinite hanging
- Can be increased if needed

### Impact on Compaction

The hook adds minimal delay to compaction:

- **Before hook**: Compaction happens immediately
- **With hook**: 1-5 second delay for checkpoint
- **Trade-off**: Preservation of work vs. slight delay
- **Recommendation**: Keep hook enabled (benefits outweigh cost)

## Future Enhancements

Potential improvements for future versions:

1. **Smart Change Detection**: Only checkpoint if significant changes exist
2. **Compression**: Compress old session context files
3. **Metrics**: Track compaction frequency and session duration
4. **Notifications**: Desktop notification when checkpoint is created
5. **Auto-Push**: Optionally push checkpoint to remote
6. **Context Restoration**: Helper script to restore session context
7. **Integration**: Link to Linear issues or GitHub PRs in context file

## References

- [Claude Code Hooks Guide](https://docs.claude.com/en/docs/claude-code/hooks-guide)
- [Claude Code Hooks Reference](https://docs.claude.com/en/docs/claude-code/hooks)
- [PreCompact Event Documentation](https://docs.claude.com/en/docs/claude-code/hooks#precompact)
- [Git Worktree Integration](../../docs/orchestrator-agents/GITHUB_CLI_CHECKPOINT_GUIDELINES.md)
- [Repository Guidelines](../../docs/orchestrator-agents/REPOSITORY_GUIDELINES.md)

## Version History

- **2025-10-10**: Initial PreCompact hook implementation
  - Automatic checkpoint commits before compaction
  - Session time tracking integration
  - Session context file generation
  - Feature name extraction from branches
  - Fast checkpointing with --no-verify
