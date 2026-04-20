---
title: Command Reference
section: cli
order: 2
---


## Overview

```
iconchanger <command> [options]
```

## Commands

### `status`

Show current configuration status.

```bash
iconchanger status
```

Displays:
- Number of app aliases configured
- Number of cached icons
- Helper script status

---

### `list`

List all aliases and cached icons.

```bash
iconchanger list
```

Shows a table of all configured aliases and all cached icon entries.

---

### `set-icon`

Set a custom icon for an application.

```bash
iconchanger set-icon <app-path> <image-path>
```

**Arguments:**
- `app-path` — Path to the application (e.g., `/Applications/Safari.app`)
- `image-path` — Path to the icon image (PNG, JPEG, ICNS, etc.)

**Examples:**

```bash
# Set a custom Safari icon
iconchanger set-icon /Applications/Safari.app ~/icons/safari.png

# Relative paths work too
iconchanger set-icon /Applications/Slack.app ./slack-icon.icns
```

---

### `remove-icon`

Remove a custom icon and restore the original.

```bash
iconchanger remove-icon <app-path>
```

**Example:**

```bash
iconchanger remove-icon /Applications/Safari.app
```

---

### `restore`

Restore all cached custom icons. Useful after a system update or when apps reset their icons.

```bash
iconchanger restore [options]
```

**Options:**
- `--dry-run` — Preview what would be restored without making changes
- `--verbose` — Show detailed output for each icon
- `--force` — Restore even if the icon appears unchanged

**Examples:**

```bash
# Restore all cached icons
iconchanger restore

# Preview what would happen
iconchanger restore --dry-run --verbose

# Force restore everything
iconchanger restore --force
```

---

### `export`

Export aliases and cached icon configuration to a JSON file.

```bash
iconchanger export <output-path>
```

**Example:**

```bash
iconchanger export ~/Desktop/my-icons.json
```

---

### `import`

Import a configuration file.

```bash
iconchanger import <input-path>
```

Import only adds new items — it never replaces or removes existing entries.

**Example:**

```bash
iconchanger import ~/Desktop/my-icons.json
```

---

### `validate`

Validate a configuration file before importing.

```bash
iconchanger validate <file-path>
```

Checks JSON structure, required fields, and data integrity without making changes.

**Example:**

```bash
iconchanger validate ~/Desktop/my-icons.json
```

---

### `escape-jail`

Escape macOS Tahoe's squircle jail by re-applying bundled icons as custom icons. Custom icons bypass squircle enforcement, preserving the original icon shape.

```bash
iconchanger escape-jail [app-path] [options]
```

**Arguments:**
- `app-path` — (Optional) Path to a specific `.app` bundle. If omitted, processes all apps in `/Applications`.

**Options:**
- `--dry-run` — Preview what would be done without making changes
- `--verbose` — Show detailed output

**Examples:**

```bash
# Escape jail for all apps in /Applications
iconchanger escape-jail

# Preview what would happen
iconchanger escape-jail --dry-run --verbose

# Escape jail for a specific app
iconchanger escape-jail /Applications/Safari.app
```

:::callout[warning]{kind="warn"}
Custom icons do not support macOS Tahoe's Clear, Tinted, or Dark icon modes. They remain as static bitmaps.
:::

---

### `completions`

Generate shell completion scripts for tab completion.

```bash
iconchanger completions <shell>
```

**Arguments:**
- `shell` — Shell type: `zsh`, `bash`, or `fish`

**Examples:**

```bash
# Zsh (add to ~/.zshrc)
source <(iconchanger completions zsh)

# Bash (add to ~/.bashrc)
source <(iconchanger completions bash)

# Fish
iconchanger completions fish > ~/.config/fish/completions/iconchanger.fish
```
