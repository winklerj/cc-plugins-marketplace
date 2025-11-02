# UserPromptSubmit Hook: Add Guideline Context

## Overview

This hook automatically adds references to project guideline files whenever you submit a prompt to Claude Code. This ensures that Claude always has access to your project's standards and best practices.

## What It Does

The hook adds three guideline files to the context of every user prompt:

1. `docs/orchestrator-agents/GITHUB_CLI_CHECKPOINT_GUIDELINES.md`
2. `docs/orchestrator-agents/LINEAR_MCP_COORDINATION_GUIDELINES.md`
3. `docs/orchestrator-agents/REPOSITORY_GUIDELINES.md`

These files are automatically included in Claude's context, so you don't need to manually reference them in your prompts.

## Configuration

**Location**: `/Users/robbwinkle/git/outline-workflows/.claude/settings.local.json`

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/add-guideline-context.sh",
            "timeout": 5000
          }
        ]
      }
    ]
  }
}
```

## Hook Script

**Location**: `/Users/robbwinkle/git/outline-workflows/.claude/hooks/add-guideline-context.sh`

The script:
- Uses absolute paths via `$CLAUDE_PROJECT_DIR` environment variable
- Validates that each guideline file exists and is readable
- Outputs JSON with `contextAdditions` array containing relative file paths
- Logs warnings to stderr if files are missing (visible with `claude --debug`)
- Always exits with code 0 (non-blocking)

## Testing

### Manual Test

Test the hook script directly:

```bash
echo '{"prompt":"test prompt"}' | CLAUDE_PROJECT_DIR=/Users/robbwinkle/git/outline-workflows /Users/robbwinkle/git/outline-workflows/.claude/hooks/add-guideline-context.sh
```

Expected output:
```json
{
  "contextAdditions": [
    "docs/orchestrator-agents/GITHUB_CLI_CHECKPOINT_GUIDELINES.md",
    "docs/orchestrator-agents/LINEAR_MCP_COORDINATION_GUIDELINES.md",
    "docs/orchestrator-agents/REPOSITORY_GUIDELINES.md"
  ]
}
```

### Verify Hook is Loaded

In a Claude Code session, use the `/hooks` command to see registered hooks:

```
/hooks
```

You should see the `UserPromptSubmit` hook listed with matcher `*`.

### Debug Mode

Run Claude Code with debug logging to see hook execution:

```bash
claude --debug
```

This will show when the hook runs and any warnings/errors.

## How It Works

1. **Trigger**: Every time you submit a prompt (press Enter)
2. **Execution**: The hook script runs before Claude processes your prompt
3. **Context Addition**: The script outputs JSON telling Claude Code to include the guideline files
4. **Processing**: Claude receives your prompt plus the guideline file contents

## Security Considerations

- **Read-Only**: The hook only reads existing guideline files
- **No External Input**: The hook doesn't execute commands with user input
- **Path Validation**: All file paths are validated before reading
- **Non-Blocking**: Exit code 0 ensures prompts are never blocked
- **Timeout Protection**: 5-second timeout prevents hanging

## Modifying the Hook

### Add More Guideline Files

Edit the `GUIDELINE_FILES` array in the hook script:

```bash
GUIDELINE_FILES=(
  "${GUIDELINES_DIR}/GITHUB_CLI_CHECKPOINT_GUIDELINES.md"
  "${GUIDELINES_DIR}/LINEAR_MCP_COORDINATION_GUIDELINES.md"
  "${GUIDELINES_DIR}/REPOSITORY_GUIDELINES.md"
  "${GUIDELINES_DIR}/YOUR_NEW_GUIDELINE.md"  # Add here
)
```

### Change Timeout

Edit `settings.local.json` and adjust the `timeout` value (in milliseconds):

```json
{
  "type": "command",
  "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/add-guideline-context.sh",
  "timeout": 10000  // 10 seconds
}
```

### Disable the Hook

Comment out or remove the `UserPromptSubmit` section in `settings.local.json`:

```json
{
  "hooks": {
    // "UserPromptSubmit": [...],  // Commented out
    "PostToolUse": [...]
  }
}
```

## Troubleshooting

### Hook Not Running

1. Verify hook is registered: `/hooks` command in Claude Code
2. Check script is executable: `ls -l /Users/robbwinkle/git/outline-workflows/.claude/hooks/add-guideline-context.sh`
3. Run with debug mode: `claude --debug`
4. Test script manually (see Testing section above)

### Files Not Being Added to Context

1. Verify files exist:
   ```bash
   ls -l /Users/robbwinkle/git/outline-workflows/docs/orchestrator-agents/GITHUB_CLI_CHECKPOINT_GUIDELINES.md
   ls -l /Users/robbwinkle/git/outline-workflows/docs/orchestrator-agents/LINEAR_MCP_COORDINATION_GUIDELINES.md
   ls -l /Users/robbwinkle/git/outline-workflows/docs/orchestrator-agents/REPOSITORY_GUIDELINES.md
   ```
2. Check JSON output format: Run manual test and verify output is valid JSON
3. Look for stderr warnings: Run with `claude --debug`

### Timeout Errors

If the hook times out:
1. Check if guideline files are very large
2. Increase timeout in `settings.local.json`
3. Consider optimizing the script or reducing number of files

## Benefits

- **Consistent Context**: Guidelines are always available without manual referencing
- **Reduced Typing**: No need to type file paths in prompts
- **Better Adherence**: Claude is more likely to follow guidelines when they're always present
- **Automatic Updates**: When guideline files are updated, changes are automatically included

## Performance Impact

- **Minimal**: Hook executes in milliseconds
- **Efficient**: Only reads file paths, not contents (Claude Code handles reading)
- **Non-Blocking**: Never delays prompt submission
- **Cached**: Claude Code may cache guideline content for performance
