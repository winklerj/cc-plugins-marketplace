# Installing Overpowered for Codex

Enable overpowered skills in Codex via native skill discovery. Just clone and symlink.

## Prerequisites

- Git

## Installation

1. **Clone the overpowered repository:**
   ```bash
   git clone https://github.com/winklerj/cc-plugins-marketplace.git ~/.codex/overpowered
   ```

2. **Create the skills symlink:**
   ```bash
   mkdir -p ~/.agents/skills
   ln -s ~/.codex/overpowered/plugins/overpowered/skills ~/.agents/skills/overpowered
   ```

   **Windows (PowerShell):**
   ```powershell
   New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.agents\skills"
   cmd /c mklink /J "$env:USERPROFILE\.agents\skills\overpowered" "$env:USERPROFILE\.codex\plugins\overpowered\skills"
   ```

3. **Restart Codex** (quit and relaunch the CLI) to discover the skills.

## Migrating from old bootstrap

If you installed overpowered before native skill discovery, you need to:

1. **Update the repo:**
   ```bash
   cd ~/.codex/overpowered && git pull
   ```

2. **Create the skills symlink** (step 2 above) — this is the new discovery mechanism.

3. **Remove the old bootstrap block** from `~/.codex/AGENTS.md` — any block referencing `overpowered-codex bootstrap` is no longer needed.

4. **Restart Codex.**

## Verify

```bash
ls -la ~/.agents/skills/overpowered
```

You should see a symlink (or junction on Windows) pointing to your overpowered skills directory.

## Updating

```bash
cd ~/.codex/overpowered && git pull
```

Skills update instantly through the symlink.

## Uninstalling

```bash
rm ~/.agents/skills/overpowered
```

Optionally delete the clone: `rm -rf ~/.codex/overpowered`.
