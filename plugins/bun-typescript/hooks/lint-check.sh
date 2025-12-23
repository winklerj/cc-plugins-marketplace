#!/bin/bash

# Adaptive lint/build check hook for TypeScript/JavaScript projects
# Auto-detects package manager, linter, and TypeScript configuration

# Read hook input from stdin and extract file path
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only run for TypeScript/JavaScript files
if [[ ! "$FILE_PATH" =~ \.(ts|tsx|js|jsx)$ ]]; then
  exit 0
fi

# Get project directory (where package.json lives)
PROJECT_DIR="$CLAUDE_PROJECT_DIR"
if [ -z "$PROJECT_DIR" ]; then
  PROJECT_DIR=$(pwd)
fi

cd "$PROJECT_DIR" || exit 0

# Skip if no package.json (not a Node.js project)
if [ ! -f "package.json" ]; then
  exit 0
fi

#############################################
# Detection Functions
#############################################

detect_package_manager() {
  if [ -f "bun.lock" ] || [ -f "bun.lockb" ]; then
    echo "bun"
  elif [ -f "pnpm-lock.yaml" ]; then
    echo "pnpm"
  elif [ -f "yarn.lock" ]; then
    echo "yarn"
  elif [ -f "package-lock.json" ]; then
    echo "npm"
  else
    # Fallback: prefer bun if available, else npm
    if command -v bun &>/dev/null; then
      echo "bun"
    else
      echo "npm"
    fi
  fi
}

has_script() {
  local script_name="$1"
  jq -e ".scripts.\"$script_name\"" package.json &>/dev/null
}

detect_linter() {
  # Check for Biome
  if [ -f "biome.json" ] || [ -f "biome.jsonc" ]; then
    echo "biome"
    return
  fi

  # Check for ESLint (flat config)
  if [ -f "eslint.config.js" ] || [ -f "eslint.config.mjs" ] || [ -f "eslint.config.cjs" ]; then
    echo "eslint"
    return
  fi

  # Check for ESLint (eslintrc format)
  if [ -f ".eslintrc" ] || [ -f ".eslintrc.js" ] || [ -f ".eslintrc.cjs" ] || \
     [ -f ".eslintrc.json" ] || [ -f ".eslintrc.yaml" ] || [ -f ".eslintrc.yml" ]; then
    echo "eslint"
    return
  fi

  echo "none"
}

has_typescript() {
  [ -f "tsconfig.json" ]
}

#############################################
# Main Logic
#############################################

PKG_MANAGER=$(detect_package_manager)
LINTER=$(detect_linter)
ERRORS=""

# Run lint:fix if available (suppress output)
if has_script "lint:fix"; then
  $PKG_MANAGER run lint:fix >/dev/null 2>&1
elif has_script "fix"; then
  $PKG_MANAGER run fix >/dev/null 2>&1
elif [ "$LINTER" = "biome" ] && command -v biome &>/dev/null; then
  biome check --write . >/dev/null 2>&1
elif [ "$LINTER" = "eslint" ] && command -v eslint &>/dev/null; then
  eslint --fix . >/dev/null 2>&1
fi

# Run lint check
if has_script "lint"; then
  LINT_OUTPUT=$($PKG_MANAGER run lint 2>&1)
  LINT_EXIT=$?
  if [ $LINT_EXIT -ne 0 ]; then
    ERRORS="Linting errors:\n$LINT_OUTPUT"
  fi
elif [ "$LINTER" = "biome" ] && command -v biome &>/dev/null; then
  LINT_OUTPUT=$(biome check . 2>&1)
  LINT_EXIT=$?
  if [ $LINT_EXIT -ne 0 ]; then
    ERRORS="Biome errors:\n$LINT_OUTPUT"
  fi
elif [ "$LINTER" = "eslint" ] && command -v eslint &>/dev/null; then
  LINT_OUTPUT=$(eslint . 2>&1)
  LINT_EXIT=$?
  if [ $LINT_EXIT -ne 0 ]; then
    ERRORS="ESLint errors:\n$LINT_OUTPUT"
  fi
fi

# Run build/type check
if has_script "build"; then
  BUILD_OUTPUT=$($PKG_MANAGER run build 2>&1)
  BUILD_EXIT=$?
  if [ $BUILD_EXIT -ne 0 ]; then
    if [ -n "$ERRORS" ]; then
      ERRORS="$ERRORS\n\n"
    fi
    ERRORS="${ERRORS}Build errors:\n$BUILD_OUTPUT"
  fi
elif has_script "typecheck"; then
  BUILD_OUTPUT=$($PKG_MANAGER run typecheck 2>&1)
  BUILD_EXIT=$?
  if [ $BUILD_EXIT -ne 0 ]; then
    if [ -n "$ERRORS" ]; then
      ERRORS="$ERRORS\n\n"
    fi
    ERRORS="${ERRORS}Type check errors:\n$BUILD_OUTPUT"
  fi
elif has_typescript && command -v tsc &>/dev/null; then
  BUILD_OUTPUT=$(tsc --noEmit 2>&1)
  BUILD_EXIT=$?
  if [ $BUILD_EXIT -ne 0 ]; then
    if [ -n "$ERRORS" ]; then
      ERRORS="$ERRORS\n\n"
    fi
    ERRORS="${ERRORS}TypeScript errors:\n$BUILD_OUTPUT"
  fi
fi

# If there are errors, return them as additionalContext
if [ -n "$ERRORS" ]; then
  ERRORS_JSON=$(echo -e "$ERRORS" | jq -Rs .)
  cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": $ERRORS_JSON
  }
}
EOF
fi

exit 0
