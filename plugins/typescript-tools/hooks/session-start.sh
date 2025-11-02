#!/bin/bash
# SessionStart hook - Create worktree for task isolation
# This hook creates an isolated git worktree for each Claude Code session
# to enable parallel development and task-specific branches.

set -e

# Configuration
WORKTREE_BASE="../worktrees"
MAIN_BRANCH="main"

# Create session timestamp for tracking elapsed time (used by compaction-checkpoint hook)
SESSION_START_FILE="${CLAUDE_PROJECT_DIR}/.claude-session-start"
date +%s > "${SESSION_START_FILE}"
echo "📅 Session start time recorded: $(date '+%Y-%m-%d %H:%M:%S')"

# Get main repository path
MAIN_REPO=$(git rev-parse --show-toplevel 2>/dev/null)

# Exit gracefully if not in a git repository
if [ -z "${MAIN_REPO}" ]; then
  echo "Not in a git repository - skipping worktree creation"
  exit 0
fi

# Generate unique task ID from timestamp and random component
TASK_ID=$(date +%s | md5sum | cut -c1-8)

# Extract task name from environment variable or use default
TASK_NAME="${CLAUDE_SESSION_DESCRIPTION:-general-task}"

# Slugify task name: lowercase, spaces to dashes, max 30 chars
TASK_NAME_SLUG=$(echo "${TASK_NAME}" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | cut -c1-30)

# Create branch and worktree names
BRANCH_NAME="task/${TASK_ID}-${TASK_NAME_SLUG}"
WORKTREE_PATH="${MAIN_REPO}/${WORKTREE_BASE}/${TASK_ID}"

echo "🌳 Creating worktree for task: ${TASK_NAME}"
echo "   Branch: ${BRANCH_NAME}"
echo "   Path: ${WORKTREE_PATH}"

# Create worktrees directory if it doesn't exist
mkdir -p "${MAIN_REPO}/${WORKTREE_BASE}"

# Create worktree with new branch
if git worktree add -b "${BRANCH_NAME}" "${WORKTREE_PATH}" "${MAIN_BRANCH}" 2>/dev/null; then
  echo "✅ Worktree created successfully"

  # Store worktree info for session cleanup
  echo "${WORKTREE_PATH}" > "${MAIN_REPO}/.claude-worktree"
  echo "${BRANCH_NAME}" > "${MAIN_REPO}/.claude-branch"

  # Navigate to worktree
  cd "${WORKTREE_PATH}"

  # Optional: Install dependencies if package.json exists
  if [ -f "package.json" ]; then
    echo "📦 Installing dependencies with bun..."
    if bun install 2>/dev/null; then
      echo "✅ Dependencies installed"
    else
      echo "⚠️  Failed to install dependencies - continuing anyway"
    fi
  fi

  echo "🚀 Ready to work in isolated worktree"
  echo "   Current directory: $(pwd)"
  echo "   Branch: $(git branch --show-current)"

  # Success - return 0
  exit 0
else
  echo "❌ Failed to create worktree"
  echo "   This may happen if the branch already exists or the worktree path is in use"

  # Check if branch already exists
  if git show-ref --verify --quiet "refs/heads/${BRANCH_NAME}"; then
    echo "   Branch '${BRANCH_NAME}' already exists"
  fi

  # Check if worktree path already exists
  if [ -d "${WORKTREE_PATH}" ]; then
    echo "   Directory '${WORKTREE_PATH}' already exists"
  fi

  # Non-blocking error - allow session to continue
  exit 1
fi
