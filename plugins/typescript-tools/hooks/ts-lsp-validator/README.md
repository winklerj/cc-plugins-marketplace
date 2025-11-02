# TypeScript LSP Validator Hook

A Claude Code hook that validates TypeScript files using the TypeScript compiler API whenever TypeScript files are modified.

## Features

- Uses TypeScript compiler API directly for accurate type checking
- Automatically finds the appropriate tsconfig.json for each file
- Non-blocking by default (reports errors but allows operations to complete)
- Can be configured to block on errors
- Displays detailed error messages with line numbers and error codes
- Supports warnings display (enabled by default)
- Fast execution with configurable timeout

## Configuration

Configure the hook behavior using environment variables:

### Environment Variables

- `TS_LSP_BLOCK_ON_ERRORS` - Set to `true` to block operations when TypeScript errors are found (default: `false`)
- `TS_LSP_SHOW_WARNINGS` - Set to `false` to hide TypeScript warnings (default: `true`)
- `TS_LSP_DEBUG` - Set to `true` to enable debug logging (default: `false`)
- `TS_LSP_TIMEOUT` - Timeout in milliseconds for validation (default: `10000`)

### Setting Environment Variables

You can set these in your shell profile or pass them when running Claude Code:

```bash
# In your ~/.zshrc or ~/.bashrc
export TS_LSP_BLOCK_ON_ERRORS=true
export TS_LSP_SHOW_WARNINGS=true
export TS_LSP_DEBUG=false

# Or temporarily when running Claude Code
TS_LSP_BLOCK_ON_ERRORS=true claude
```

## Hook Configuration

The hook is configured in `.claude/settings.local.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "bun $CLAUDE_PROJECT_DIR/.claude/hooks/ts-lsp-validator/validate-typescript.ts",
            "timeout": 15000
          }
        ]
      }
    ]
  }
}
```

## How It Works

1. **Trigger**: Hook runs after Write/Edit/MultiEdit operations
2. **File Detection**: Checks if the modified file is a TypeScript file (.ts or .tsx)
3. **Config Discovery**: Walks up the directory tree to find the appropriate tsconfig.json
4. **Type Checking**: Uses TypeScript compiler API to check for errors and warnings
5. **Results Display**: Shows detailed error/warning information with line numbers
6. **Exit Code**: Returns 0 (success) by default, or 2 (blocking error) if `TS_LSP_BLOCK_ON_ERRORS=true` and errors found

## Testing the Hook

### Manual Testing

Test the hook manually with a sample TypeScript file:

```bash
# Create a test file with TypeScript errors
echo 'const x: string = 123;' > test.ts

# Test the hook (simulate Claude Code input)
echo '{"tool_name":"Write","tool_input":{"file_path":"'$(pwd)'/test.ts"}}' | \
  bun /Users/robbwinkle/git/outline-workflows/.claude/hooks/ts-lsp-validator/validate-typescript.ts
```

### Testing with Claude Code

1. Modify a TypeScript file in your project using Claude Code
2. The hook will automatically run after the Write/Edit operation
3. Check the output for validation results

### Enable Debug Mode

```bash
TS_LSP_DEBUG=true claude
```

## Output Examples

### Success (No Errors)

```
🔍 TypeScript LSP Validator
────────────────────────────────────────────────────────────
[INFO] Running TypeScript validation...

════════════════════════════════════════════════════════════
TypeScript LSP Validation Results
════════════════════════════════════════════════════════════
File: src/example.ts

✅ No TypeScript errors or warnings found!

✅ Validation passed
```

### Errors Found (Non-Blocking)

```
🔍 TypeScript LSP Validator
────────────────────────────────────────────────────────────
[INFO] Running TypeScript validation...

════════════════════════════════════════════════════════════
TypeScript LSP Validation Results
════════════════════════════════════════════════════════════
File: src/example.ts

Errors (2):
  ❌ Line 5:15 [TS2322] Type 'number' is not assignable to type 'string'.
  ❌ Line 10:20 [TS2339] Property 'foo' does not exist on type 'Bar'.

⚠️  TypeScript errors found but not blocking
   Set TS_LSP_BLOCK_ON_ERRORS=true to block on errors
```

### Errors Found (Blocking)

```
🔍 TypeScript LSP Validator
────────────────────────────────────────────────────────────
[INFO] Running TypeScript validation...

════════════════════════════════════════════════════════════
TypeScript LSP Validation Results
════════════════════════════════════════════════════════════
File: src/example.ts

Errors (1):
  ❌ Line 5:15 [TS2322] Type 'number' is not assignable to type 'string'.

🛑 Validation failed - TypeScript errors must be fixed!
```

## Troubleshooting

### Hook Not Running

1. Check that the hook is configured in `.claude/settings.local.json`
2. Verify the script is executable: `chmod +x .claude/hooks/ts-lsp-validator/validate-typescript.ts`
3. Run Claude Code with `--debug` flag: `claude --debug`
4. Use `/hooks` command in Claude Code to verify hook is loaded

### No tsconfig.json Found

The hook looks for tsconfig.json starting from the file's directory and walking up to the project root. If no tsconfig.json is found, the hook skips validation.

To fix:
1. Ensure your project has a tsconfig.json in the root or parent directory
2. Check that `CLAUDE_PROJECT_DIR` environment variable is set correctly

### TypeScript Errors Not Blocking

By default, the hook is non-blocking. Set `TS_LSP_BLOCK_ON_ERRORS=true` to block on errors.

### Hook Times Out

Increase the timeout in the hook configuration:

```json
{
  "type": "command",
  "command": "bun $CLAUDE_PROJECT_DIR/.claude/hooks/ts-lsp-validator/validate-typescript.ts",
  "timeout": 30000
}
```

Or set the environment variable:

```bash
export TS_LSP_TIMEOUT=30000
```

## Comparison with Existing Quality Check Hook

This project already has a comprehensive Node.js quality check hook. Here's how they compare:

| Feature | TS LSP Validator | Node.js Quality Check |
|---------|-----------------|----------------------|
| TypeScript Validation | ✅ TypeScript API | ✅ TypeScript Compiler |
| ESLint | ❌ | ✅ |
| Prettier | ❌ | ✅ |
| Auto-fix | ❌ | ✅ |
| Node.js Pattern Checks | ❌ | ✅ |
| Runtime | Bun | Node.js |
| Focus | TypeScript Only | Comprehensive |
| Configuration | Env Variables | JSON + Env Variables |

### When to Use Which Hook

**Use TS LSP Validator** when:
- You only want TypeScript validation
- You prefer Bun runtime
- You want a lightweight, focused validator
- You want to run it in addition to other hooks

**Use Node.js Quality Check** when:
- You want comprehensive code quality checks
- You need ESLint and Prettier integration
- You want auto-fix capabilities
- You need custom rule configurations

**Use Both** when:
- You want TypeScript validation from both tools for extra confidence
- You want the features of both hooks

## Disabling the Hook

To temporarily disable the hook, comment it out in `.claude/settings.local.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
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

Or remove it entirely from the configuration.
