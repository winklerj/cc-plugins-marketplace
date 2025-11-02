#!/usr/bin/env bash
#
# UserPromptSubmit Hook: Add Guideline Context
#
# Purpose: Automatically adds references to guideline files whenever the user submits a prompt.
# This ensures Claude has access to project guidelines for all tasks.
#
# Security: This hook only reads project guideline files and adds them to context.
# No external commands are executed with user input.
#
# Exit Codes:
#   0 - Success (hook executed successfully)
#   1 - Non-blocking error (logged but doesn't stop execution)

set -euo pipefail

# Define absolute paths to guideline files
PROJECT_DIR="${CLAUDE_PROJECT_DIR}"
GUIDELINES_DIR="${PROJECT_DIR}/docs/orchestrator-agents"

# Array of guideline files to add to context
GUIDELINE_FILES=(
  "${GUIDELINES_DIR}/GITHUB_CLI_CHECKPOINT_GUIDELINES.md"
  "${GUIDELINES_DIR}/LINEAR_MCP_COORDINATION_GUIDELINES.md"
  "${GUIDELINES_DIR}/REPOSITORY_GUIDELINES.md"
)

# Read input from stdin (contains the user's prompt)
INPUT=$(cat)

# Initialize context array
CONTEXT_ADDITIONS=()

# Validate and add each guideline file
for guideline_file in "${GUIDELINE_FILES[@]}"; do
  # Validate file exists and is readable
  if [[ -f "${guideline_file}" && -r "${guideline_file}" ]]; then
    # Get relative path for cleaner display
    RELATIVE_PATH="${guideline_file#${PROJECT_DIR}/}"
    CONTEXT_ADDITIONS+=("${RELATIVE_PATH}")
  else
    # Log warning to stderr (visible in debug mode)
    echo "Warning: Guideline file not found or not readable: ${guideline_file}" >&2
  fi
done

# Build JSON output to add context
# The contextAdditions field tells Claude Code to include these files
if [[ ${#CONTEXT_ADDITIONS[@]} -gt 0 ]]; then
  # Start JSON array
  JSON_ARRAY="["

  # Add each file path as a JSON string
  for i in "${!CONTEXT_ADDITIONS[@]}"; do
    if [[ $i -gt 0 ]]; then
      JSON_ARRAY+=","
    fi
    # Escape any special characters in the path
    ESCAPED_PATH=$(printf '%s' "${CONTEXT_ADDITIONS[$i]}" | sed 's/\\/\\\\/g; s/"/\\"/g')
    JSON_ARRAY+="\"${ESCAPED_PATH}\""
  done

  JSON_ARRAY+="]"

  # Output JSON with context additions
  cat <<EOF
{
  "contextAdditions": ${JSON_ARRAY}
}
EOF
else
  # No files to add, output empty JSON
  echo "{}"
fi

exit 0
