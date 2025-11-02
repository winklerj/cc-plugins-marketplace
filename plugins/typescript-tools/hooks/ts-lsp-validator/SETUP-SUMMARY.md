# TypeScript LSP Validator Hook - Setup Summary

## What Was Created

A TypeScript validation hook for Claude Code that uses the TypeScript compiler API to validate TypeScript files whenever they are modified.

### Files Created

1. **`.claude/hooks/ts-lsp-validator/validate-typescript.ts`**
   - Main validation script written in TypeScript
   - Uses Bun runtime for fast execution
   - Implements TypeScript compiler API for accurate type checking
   - Configurable via environment variables

2. **`.claude/hooks/ts-lsp-validator/README.md`**
   - Comprehensive documentation
   - Configuration guide
   - Testing instructions
   - Troubleshooting tips

3. **`.claude/hooks/tsconfig.json`**
   - TypeScript configuration for hook scripts
   - Excludes hooks directory from project linting

4. **`.claude/hooks/ts-lsp-validator/SETUP-SUMMARY.md`** (this file)
   - Quick reference guide
   - Setup verification steps

### Files Modified

1. **`.claude/settings.local.json`**
   - Added TypeScript LSP validator hook to PostToolUse event
   - Configured to run after Write/Edit/MultiEdit operations
   - Set timeout to 15 seconds

2. **`eslint.config.js`**
   - Added `.claude/hooks/**` to ignore patterns
   - Prevents ESLint errors for hook scripts

## How It Works

```
┌─────────────────────────────────────────────────────────────┐
│                    Claude Code Operation                     │
│              (Write/Edit/MultiEdit TypeScript file)         │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│              Existing Node.js Quality Check Hook            │
│  • TypeScript compilation check                             │
│  • ESLint validation (with auto-fix)                        │
│  • Prettier formatting (with auto-fix)                      │
│  • Common code issues check                                 │
│  • Node.js pattern checks                                   │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│            NEW: TypeScript LSP Validator Hook               │
│  • TypeScript compiler API validation                       │
│  • Finds appropriate tsconfig.json                          │
│  • Detailed error/warning reporting                         │
│  • Non-blocking by default                                  │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    Operation Completes                       │
│           (User sees validation results in console)         │
└─────────────────────────────────────────────────────────────┘
```

## Quick Start

### 1. Verify Installation

The hook is already installed and configured. Verify it's working:

```bash
# Check hook configuration
cat .claude/settings.local.json

# Manually test the hook
printf '{"tool_name":"Write","tool_input":{"file_path":"%s"}}' \
  "$(pwd)/index.ts" | \
  bun .claude/hooks/ts-lsp-validator/validate-typescript.ts
```

### 2. Configuration Options

Set environment variables to customize behavior:

```bash
# Block operations when TypeScript errors are found
export TS_LSP_BLOCK_ON_ERRORS=true

# Hide warnings (show errors only)
export TS_LSP_SHOW_WARNINGS=false

# Enable debug logging
export TS_LSP_DEBUG=true

# Increase timeout (in milliseconds)
export TS_LSP_TIMEOUT=20000
```

### 3. Test the Hook

Modify a TypeScript file using Claude Code and observe the validation output.

## Verification Steps

### ✅ Step 1: Hook Configuration

Verify the hook is configured in `.claude/settings.local.json`:

```bash
grep -A 5 "ts-lsp-validator" .claude/settings.local.json
```

Expected output:
```json
{
  "type": "command",
  "command": "bun $CLAUDE_PROJECT_DIR/.claude/hooks/ts-lsp-validator/validate-typescript.ts",
  "timeout": 15000
}
```

### ✅ Step 2: Script Permissions

Verify the script is executable:

```bash
ls -la .claude/hooks/ts-lsp-validator/validate-typescript.ts
```

Expected output should show executable permissions (e.g., `-rwxr-xr-x`).

### ✅ Step 3: Manual Test

Test the hook manually with a real TypeScript file:

```bash
printf '{"tool_name":"Write","tool_input":{"file_path":"'"$(pwd)/index.ts"'"}}' | \
  bun .claude/hooks/ts-lsp-validator/validate-typescript.ts
```

Expected output:
```
🔍 TypeScript LSP Validator
────────────────────────────────────────────────────────────
[INFO] Running TypeScript validation...

════════════════════════════════════════════════════════════
TypeScript LSP Validation Results
════════════════════════════════════════════════════════════
File: index.ts

✅ No TypeScript errors or warnings found!

✅ Validation passed
```

### ✅ Step 4: Test with Claude Code

1. Start Claude Code: `claude`
2. Ask Claude to modify a TypeScript file
3. Observe the hook output in the console after the modification
4. You should see output from both hooks:
   - Node.js Quality Check Hook
   - TypeScript LSP Validator Hook

## Default Behavior

- **Non-blocking**: By default, the hook reports errors but does not block operations
- **Shows warnings**: TypeScript warnings are displayed along with errors
- **15-second timeout**: Hook will timeout if validation takes longer than 15 seconds
- **Automatic tsconfig discovery**: Finds the appropriate tsconfig.json for each file

## Customization Examples

### Make Hook Blocking on Errors

Add to your shell profile (`~/.zshrc` or `~/.bashrc`):

```bash
export TS_LSP_BLOCK_ON_ERRORS=true
```

Then restart your terminal or run `source ~/.zshrc`.

### Disable Warnings

```bash
export TS_LSP_SHOW_WARNINGS=false
```

### Enable Debug Mode

```bash
export TS_LSP_DEBUG=true
```

### Temporary Configuration

Set variables only for the current Claude Code session:

```bash
TS_LSP_BLOCK_ON_ERRORS=true TS_LSP_DEBUG=true claude
```

## Disabling the Hook

### Temporarily Disable

Comment out the hook in `.claude/settings.local.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "node $CLAUDE_PROJECT_DIR/.claude/hooks/node-typescript/quality-check.js"
          }
          // Commented out - temporarily disabled
          // {
          //   "type": "command",
          //   "command": "bun $CLAUDE_PROJECT_DIR/.claude/hooks/ts-lsp-validator/validate-typescript.ts",
          //   "timeout": 15000
          // }
        ]
      }
    ]
  }
}
```

### Permanently Remove

Remove the hook entry entirely from `.claude/settings.local.json`.

## Comparison: Two Validation Approaches

Your project now has **two TypeScript validation hooks** running in sequence:

### Node.js Quality Check Hook (Existing)

- **Scope**: Comprehensive code quality
- **Tools**: TypeScript compiler, ESLint, Prettier
- **Features**: Auto-fix, custom rules, multiple checks
- **Runtime**: Node.js
- **Best for**: Complete code quality enforcement

### TypeScript LSP Validator Hook (New)

- **Scope**: TypeScript validation only
- **Tools**: TypeScript compiler API
- **Features**: Detailed error reporting, fast execution
- **Runtime**: Bun
- **Best for**: Focused TypeScript type checking

### Recommended Usage

**Keep both hooks** for:
- Maximum validation coverage
- ESLint and Prettier enforcement (from Node.js hook)
- TypeScript validation from both tools (extra confidence)

**Use only Node.js Quality Check** if:
- You want comprehensive validation in one hook
- You don't need Bun-specific features
- You prefer auto-fix capabilities

**Use only TypeScript LSP Validator** if:
- You only care about TypeScript errors
- You want lightweight, fast validation
- You use other tools for ESLint/Prettier

## Troubleshooting

### Hook Not Running

```bash
# Check if hook is loaded
claude --debug

# Then in Claude Code, run:
/hooks
```

### ESLint Errors for Hook Files

Verify `.claude/hooks/**` is in `eslint.config.js` ignores:

```bash
grep ".claude/hooks" eslint.config.js
```

### TypeScript Errors Not Showing

Enable debug mode and check for issues:

```bash
TS_LSP_DEBUG=true claude
```

### Hook Times Out

Increase timeout in `.claude/settings.local.json`:

```json
{
  "type": "command",
  "command": "bun $CLAUDE_PROJECT_DIR/.claude/hooks/ts-lsp-validator/validate-typescript.ts",
  "timeout": 30000
}
```

## Testing the Hook

### Test 1: Valid TypeScript

```bash
# Create a valid TypeScript file
cat > test-valid.ts << 'EOF'
interface User {
  name: string;
  age: number;
}

function greet(user: User): string {
  return `Hello, ${user.name}!`;
}
EOF

# Test the hook
printf '{"tool_name":"Write","tool_input":{"file_path":"'"$(pwd)/test-valid.ts"'"}}' | \
  bun .claude/hooks/ts-lsp-validator/validate-typescript.ts

# Clean up
rm test-valid.ts
```

Expected: ✅ No errors or warnings

### Test 2: TypeScript with Errors

```bash
# Create a TypeScript file with errors
cat > test-errors.ts << 'EOF'
interface User {
  name: string;
  age: number;
}

function greet(user: User): string {
  return `Hello, ${user.name}!`;
}

// This has type errors
const badUser: User = {
  name: 'Alice',
  age: 'thirty' // Error: Type 'string' is not assignable to type 'number'
};

greet(badUser);
EOF

# Test the hook
printf '{"tool_name":"Write","tool_input":{"file_path":"'"$(pwd)/test-errors.ts"'"}}' | \
  bun .claude/hooks/ts-lsp-validator/validate-typescript.ts

# Clean up
rm test-errors.ts
```

Expected: ❌ TypeScript error reported (but non-blocking by default)

### Test 3: Non-TypeScript File

```bash
# Test with a JavaScript file
printf '{"tool_name":"Write","tool_input":{"file_path":"'"$(pwd)/package.json"'"}}' | \
  bun .claude/hooks/ts-lsp-validator/validate-typescript.ts
```

Expected: ⏭️ Skipped - not a TypeScript file

## Next Steps

1. **Test the hook** by modifying a TypeScript file in Claude Code
2. **Configure behavior** using environment variables if needed
3. **Read the README** in `.claude/hooks/ts-lsp-validator/README.md` for detailed documentation
4. **Customize as needed** based on your workflow

## Support

For issues or questions:

1. Check the README: `.claude/hooks/ts-lsp-validator/README.md`
2. Enable debug mode: `TS_LSP_DEBUG=true`
3. Run Claude Code with debug flag: `claude --debug`
4. Check hook output in the console after file modifications

## Summary

✅ TypeScript LSP Validator Hook is installed and configured
✅ Hook runs automatically after TypeScript file modifications
✅ Non-blocking by default (reports errors but allows operations)
✅ Configurable via environment variables
✅ Works alongside existing Node.js Quality Check Hook
✅ Ready to use!

**Current Configuration**: Both hooks are enabled and run in sequence.
