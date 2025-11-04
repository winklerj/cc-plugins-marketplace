---
description: Install the beads bd cli tool
allowed-tools: Bash(curl:*), Bash(bash:*), Bash(brew:*), Bash(bd:*)
---

Install the beads bd cli tool for git-backed issue tracking.

## Installation Methods

Choose one of the following installation methods based on the system:

### Method 1: Quick Install (All Platforms)
```bash
curl -fsSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash
```

### Method 2: Homebrew (macOS/Linux)
```bash
brew tap steveyegge/beads && brew install bd
```

### Method 3: npm (Node.js environments)
```bash
npm install -g @beads/bd
```

## Post-Installation

1. **Verify installation**:
   ```bash
   bd --version
   ```

2. **Check if already initialized in current project**:
   ```bash
   bd list 2>/dev/null || echo "Not initialized in this project"
   ```

3. **Provide next steps**:
   - If not initialized: Suggest running `/beads:init` to initialize beads in the current project
   - If initialized: Show project statistics with `bd stats`

## Error Handling

If installation fails:
- Check internet connection
- Verify required dependencies (git, sqlite3)
- For Homebrew: Ensure Homebrew is installed and updated
- For npm: Ensure Node.js and npm are installed
- Try alternative installation method

## Notes

- Beads requires git to be installed and configured
- SQLite3 is required for local caching
- The bd cli is the primary interface for beads
- Installation is system-wide and available in all projects
