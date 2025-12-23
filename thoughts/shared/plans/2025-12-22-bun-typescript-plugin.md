# Bun TypeScript Plugin Implementation Plan

## Overview

Create a minimal, portable Claude Code plugin that provides an adaptive lint/build check hook for TypeScript/JavaScript projects. The hook auto-detects the project's tooling (package manager, linter, TypeScript) and runs appropriate checks after file edits.

## Current State Analysis

### Existing Implementation
- `plugins/typescript-tools/hooks/lint-check.sh` - Hardcoded to use `bun run lint:fix`, `bun run lint`, `bun run build`
- Current `hooks.json` references `$CLAUDE_PROJECT_DIR/.claude/hooks/lint-check.sh` (not portable)
- The `typescript-tools` plugin.json has no `"hooks"` field

### Key Discoveries
- Hook scripts can use `${CLAUDE_PLUGIN_ROOT}` for portable paths
- Package manager detection via lockfiles is reliable and widely used
- ESLint has two config formats (flat config and eslintrc)
- Biome uses `biome.json` or `biome.jsonc`
- TypeScript detection via `tsconfig.json`

## Desired End State

A new `bun-typescript` plugin that:
1. Installs portably via Claude Code plugin system
2. Auto-detects project tooling (package manager, linter, TypeScript)
3. Runs lint fixes, lint checks, and type checks after TS/JS file edits
4. Works with any package manager (bun, pnpm, yarn, npm)
5. Works with any linter (ESLint, Biome) or none
6. Gracefully degrades when tools aren't available

### Verification
- Plugin installs successfully: `claude plugins install ./plugins/bun-typescript`
- Hook triggers on Write/Edit/MultiEdit of .ts/.tsx/.js/.jsx files
- Errors are returned as `additionalContext` for Claude to see

## What We're NOT Doing

- Moving other typescript-tools content (agents, commands, etc.)
- Creating MCP servers or complex integrations
- Supporting TSLint (deprecated since 2019)
- Adding configuration options to the plugin itself

## Implementation Approach

Create the plugin with a single adaptive shell script that:
1. Detects package manager from lockfiles
2. Detects linter from config files
3. Checks for lint/build scripts in package.json
4. Runs appropriate commands with proper fallbacks
5. Returns errors as JSON for Claude's context

---

## Phase 1: Create Plugin Structure

### Overview
Set up the basic plugin directory structure and configuration.

### Changes Required:

#### 1.1 Create Plugin Directory Structure

**Directory**: `plugins/bun-typescript/`

Create the following structure:
```
plugins/bun-typescript/
├── .claude-plugin/
│   └── plugin.json
└── hooks/
    ├── hooks.json
    └── lint-check.sh
```

#### 1.2 Create Plugin Manifest

**File**: `plugins/bun-typescript/.claude-plugin/plugin.json`

```json
{
  "name": "bun-typescript",
  "version": "1.0.0",
  "description": "Adaptive lint and type-check hook for TypeScript/JavaScript projects. Auto-detects package manager and linting tools.",
  "author": {
    "name": "Robb Winkle",
    "email": "robb@devfit.com",
    "url": "https://github.com/winklerj"
  },
  "repository": "https://github.com/winklerj/cc-plugins-marketplace",
  "license": "Apache-2.0",
  "keywords": ["claude code", "typescript", "javascript", "lint", "eslint", "biome", "bun", "hooks"]
}
```

#### 1.3 Create Hooks Configuration

**File**: `plugins/bun-typescript/hooks/hooks.json`

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/lint-check.sh",
            "timeout": 60000
          }
        ]
      }
    ]
  }
}
```

### Success Criteria:

#### Automated Verification:
- [x] Directory structure exists: `ls -la plugins/bun-typescript/`
- [x] Plugin JSON is valid: `jq . plugins/bun-typescript/.claude-plugin/plugin.json`
- [x] Hooks JSON is valid: `jq . plugins/bun-typescript/hooks/hooks.json`

#### Manual Verification:
- [ ] Plugin can be installed locally for testing

---

## Phase 2: Create Adaptive Lint-Check Script

### Overview
Create the intelligent lint-check.sh that auto-detects project tooling.

### Changes Required:

#### 2.1 Create Lint-Check Script

**File**: `plugins/bun-typescript/hooks/lint-check.sh`

```bash
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
```

### Success Criteria:

#### Automated Verification:
- [x] Script is executable: `test -x plugins/bun-typescript/hooks/lint-check.sh`
- [x] Script has valid bash syntax: `bash -n plugins/bun-typescript/hooks/lint-check.sh`
- [x] Script uses jq correctly (required dependency)

#### Manual Verification:
- [ ] Test in a Bun project - detects bun.lock and uses `bun run`
- [ ] Test in an npm project - detects package-lock.json and uses `npm run`
- [ ] Test in a project with ESLint - detects and runs ESLint
- [ ] Test in a project with Biome - detects and runs Biome
- [ ] Test in a project without linting - gracefully skips
- [ ] Errors are properly returned as JSON

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation from the human that the manual testing was successful before proceeding to the next phase.

---

## Phase 3: Remove Hook from typescript-tools

### Overview
Clean up the typescript-tools plugin by removing the lint-check hook (now in bun-typescript).

### Changes Required:

#### 3.1 Update typescript-tools hooks.json

**File**: `plugins/typescript-tools/hooks/hooks.json`

Remove the PostToolUse hook for lint-check, keeping only the PreCompact hook:

```json
{
    "hooks": {
        "PreCompact": [
            {
                "matcher": "*",
                "hooks": [
                    {
                        "type": "command",
                        "command": "${CLAUDE_PLUGIN_ROOT}/hooks/compaction-checkpoint.sh",
                        "timeout": 30000
                    }
                ]
            }
        ]
    }
}
```

#### 3.2 Delete lint-check.sh from typescript-tools

**File to delete**: `plugins/typescript-tools/hooks/lint-check.sh`

### Success Criteria:

#### Automated Verification:
- [x] Updated hooks.json is valid: `jq . plugins/typescript-tools/hooks/hooks.json`
- [x] lint-check.sh no longer exists: `test ! -f plugins/typescript-tools/hooks/lint-check.sh`

#### Manual Verification:
- [ ] typescript-tools plugin still works without the hook
- [ ] PreCompact hook still functions correctly

---

## Testing Strategy

### Unit Tests:
- Validate JSON files with `jq`
- Validate bash syntax with `bash -n`

### Integration Tests:
1. Create test projects with different configurations:
   - Bun + ESLint
   - npm + Biome
   - pnpm + TypeScript only
   - yarn + no linting
2. Install plugin and trigger hook via file edit
3. Verify correct package manager and tools are detected

### Manual Testing Steps:
1. Install plugin: `claude plugins install ./plugins/bun-typescript`
2. Open a TypeScript project
3. Edit a .ts file with an intentional lint error
4. Verify hook runs and returns error in context
5. Fix the error and verify hook passes silently

## Performance Considerations

- Script exits early for non-TS/JS files (no overhead)
- Script exits early if no package.json (not a Node.js project)
- Detection uses simple file existence checks (fast)
- Timeout set to 60 seconds to allow for slower builds

## Migration Notes

Users currently using `typescript-tools` with the lint hook will need to:
1. Install `bun-typescript` plugin
2. The new hook will auto-detect their tooling

## References

- Research document: `thoughts/shared/research/2025-12-22-bun-typescript-plugin-creation.md`
- Original hook: `plugins/typescript-tools/hooks/lint-check.sh`
- ESLint config docs: https://eslint.org/docs/latest/use/configure/configuration-files
- Biome config docs: https://biomejs.dev/guides/configure-biome/
