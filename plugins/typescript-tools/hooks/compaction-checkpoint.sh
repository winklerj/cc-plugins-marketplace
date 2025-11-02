#!/usr/bin/env bash
#
# PreCompact Hook: Compaction Checkpoint
#
# Purpose: Automatically creates a checkpoint commit before Claude Code compacts
# the context window. This preserves work-in-progress state during long sessions.
#
# Triggered: Before context window compaction due to memory limits
#
# Actions:
#   1. Calculate session elapsed time (if available)
#   2. Identify changed files and summarize changes
#   3. Extract feature name from branch or recent commits
#   4. Create checkpoint commit (WIP, no validation)
#   5. Save session context to file for resumption
#
# Security: This hook uses git commands to create commits. It skips pre-commit
# hooks (--no-verify) to ensure fast checkpointing without validation delays.
#
# Exit Codes:
#   0 - Success (checkpoint created)
#   1 - Non-blocking error (logged but doesn't stop compaction)
#

set -euo pipefail

# Absolute paths
PROJECT_DIR="${CLAUDE_PROJECT_DIR}"
SESSION_CONTEXT_DIR="${PROJECT_DIR}/.claude/session-context"
SESSION_START_FILE="${PROJECT_DIR}/.claude-session-start"
HOOKS_DIR="${PROJECT_DIR}/.claude/hooks"

# Ensure we're in the project directory
cd "${PROJECT_DIR}"

# Log function for debugging
log() {
  echo "[PreCompact] $*" >&2
}

log "Starting compaction checkpoint..."

# Check if we're in a git repository
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  log "Not in a git repository - skipping checkpoint"
  exit 0
fi

# Check for uncommitted changes
if git diff --quiet && git diff --cached --quiet; then
  log "No uncommitted changes - skipping checkpoint"
  exit 0
fi

# Calculate session elapsed time
SESSION_ELAPSED_MINUTES="unknown"
if [[ -f "${SESSION_START_FILE}" ]]; then
  SESSION_START_TIME=$(cat "${SESSION_START_FILE}")
  CURRENT_TIME=$(date +%s)
  SESSION_ELAPSED_SECONDS=$((CURRENT_TIME - SESSION_START_TIME))
  SESSION_ELAPSED_MINUTES=$((SESSION_ELAPSED_SECONDS / 60))
  log "Session elapsed time: ${SESSION_ELAPSED_MINUTES} minutes"
else
  log "Session start time not found - creating timestamp for future use"
  date +%s > "${SESSION_START_FILE}"
fi

# Extract feature name from branch or use default
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")
FEATURE_NAME="${CURRENT_BRANCH}"

# Try to extract feature name from branch name (e.g., task/123-feature-name -> feature-name)
if [[ "${CURRENT_BRANCH}" =~ task/[^-]+-(.+)$ ]]; then
  FEATURE_NAME="${BASH_REMATCH[1]}"
elif [[ "${CURRENT_BRANCH}" =~ feature/(.+)$ ]]; then
  FEATURE_NAME="${BASH_REMATCH[1]}"
fi

log "Feature: ${FEATURE_NAME}"

# Get list of changed files
CHANGED_FILES=$(git status --porcelain | wc -l | tr -d ' ')
log "Changed files: ${CHANGED_FILES}"

# Create session context directory if it doesn't exist
mkdir -p "${SESSION_CONTEXT_DIR}"

# Save session context
CONTEXT_FILE="${SESSION_CONTEXT_DIR}/pre-compaction-$(date +%Y%m%d-%H%M%S).md"
log "Saving session context to: ${CONTEXT_FILE}"

cat > "${CONTEXT_FILE}" <<CONTEXT_EOF
# Pre-Compaction Checkpoint Context

**Date**: $(date '+%Y-%m-%d %H:%M:%S')
**Branch**: ${CURRENT_BRANCH}
**Feature**: ${FEATURE_NAME}
**Session Time**: ${SESSION_ELAPSED_MINUTES} minutes
**Changed Files**: ${CHANGED_FILES}

## Git Status

\`\`\`
$(git status)
\`\`\`

## Changed Files Summary

\`\`\`
$(git status --porcelain)
\`\`\`

## Diff Summary (staged changes)

\`\`\`diff
$(git diff --cached --stat || echo "No staged changes")
\`\`\`

## Diff Summary (unstaged changes)

\`\`\`diff
$(git diff --stat || echo "No unstaged changes")
\`\`\`

## Recent Commits

\`\`\`
$(git log --oneline -5 || echo "No commits")
\`\`\`

## Next Steps

Review the changes and continue work after context compaction.
The checkpoint commit was created to preserve work-in-progress state.

CONTEXT_EOF

log "Session context saved to: ${CONTEXT_FILE}"

# Generate change summary for commit message
CHANGE_SUMMARY=$(git status --porcelain | head -10 | sed 's/^/  - /')
if [[ $(git status --porcelain | wc -l) -gt 10 ]]; then
  CHANGE_SUMMARY="${CHANGE_SUMMARY}\n  - ... and $((CHANGED_FILES - 10)) more files"
fi

# Generate commit message
COMMIT_MESSAGE=$(cat <<COMMIT_EOF
chore: Checkpoint before context compaction

Work in progress on ${FEATURE_NAME}.

Changed files: ${CHANGED_FILES}
Session time: ${SESSION_ELAPSED_MINUTES} minutes

Changes:
${CHANGE_SUMMARY}

Status: Pre-compaction checkpoint (WIP)
Next steps: Continue after context compaction and review session context

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
Checkpoint-Reason: pre-compaction
Session-Time: ${SESSION_ELAPSED_MINUTES} minutes
Context-File: ${CONTEXT_FILE#${PROJECT_DIR}/}
COMMIT_EOF
)

# Stage all changes (tracked files only)
log "Staging changes..."
if ! git add -u >/dev/null 2>&1; then
  log "Warning: Failed to stage some changes"
fi

# Check if there are staged changes after staging
if git diff --cached --quiet; then
  log "No staged changes after git add -u (only untracked files present)"
  log "Adding untracked files to stage..."

  # Stage untracked files too
  if ! git add . >/dev/null 2>&1; then
    log "Warning: Failed to stage untracked files"
  fi

  # Check again
  if git diff --cached --quiet; then
    log "Still no staged changes - skipping checkpoint"
    exit 0
  fi
fi

# Create checkpoint commit (skip pre-commit hooks for speed)
log "Creating checkpoint commit..."
if git commit --no-verify -m "${COMMIT_MESSAGE}" >/dev/null 2>&1; then
  log "Checkpoint commit created successfully"

  # Show commit hash
  COMMIT_HASH=$(git rev-parse --short HEAD)
  log "Commit: ${COMMIT_HASH}"

  # Verify commit was created
  if git log -1 --oneline >/dev/null 2>&1; then
    log "Verified: Checkpoint commit exists"
  else
    log "Warning: Could not verify checkpoint commit"
  fi

  # Success
  log "Compaction checkpoint complete"
  echo "✓ Checkpoint created: ${COMMIT_HASH} (${CHANGED_FILES} files, ${SESSION_ELAPSED_MINUTES}m)" >&1
  exit 0
else
  log "Error: Failed to create checkpoint commit"
  log "This is a non-blocking error - compaction will proceed"
  exit 1
fi
