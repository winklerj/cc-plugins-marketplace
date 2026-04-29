# Installing Overpowered for OpenCode

## Prerequisites

- [OpenCode.ai](https://opencode.ai) installed

## Installation

Add overpowered to the `plugin` array in your `opencode.json` (global or project-level):

```json
{
  "plugin": ["overpowered@git+https://github.com/winklerj/cc-plugins-marketplace.git"]
}
```

Restart OpenCode. That's it — the plugin auto-installs and registers all skills.

Verify by asking: "Tell me about your overpowered skills"

## Migrating from the old symlink-based install

If you previously installed overpowered using `git clone` and symlinks, remove the old setup:

```bash
# Remove old symlinks
rm -f ~/.config/opencode/plugins/overpowered.js
rm -rf ~/.config/opencode/skills/overpowered

# Optionally remove the cloned repo
rm -rf ~/.config/opencode/overpowered

# Remove skills.paths from opencode.json if you added one for overpowered
```

Then follow the installation steps above.

## Usage

Use OpenCode's native `skill` tool:

```
use skill tool to list skills
use skill tool to load overpowered/brainstorming
```

## Updating

overpowered updates automatically when you restart OpenCode.

To pin a specific version:

```json
{
  "plugin": ["overpowered@git+https://github.com/winklerj/cc-plugins-marketplace.git"]
}
```

## Troubleshooting

### Plugin not loading

1. Check logs: `opencode run --print-logs "hello" 2>&1 | grep -i overpowered`
2. Verify the plugin line in your `opencode.json`
3. Make sure you're running a recent version of OpenCode

### Skills not found

1. Use `skill` tool to list what's discovered
2. Check that the plugin is loading (see above)

### Tool mapping

When skills reference Claude Code tools:
- `TodoWrite` → `todowrite`
- `Task` with subagents → `@mention` syntax
- `Skill` tool → OpenCode's native `skill` tool
- File operations → your native tools
