# IconChanger

[中文版](./README-zh.md) | [Version française](./README-fr.md)

A macOS app to customize application icons with a clean GUI and a powerful CLI.

![preview](./Github/Github-Iconchanger.jpeg)

## Features

- **Custom Icons** — Change the icon of any app on your Mac via GUI or command line
- **Icon Cache** — Automatically caches custom icons for easy restoration
- **Background Service** — Keeps custom icons persistent across app updates with scheduled restoration and update detection
- **Launch at Login** — Start at login with configurable behavior (open window or stay hidden)
- **App Aliases** — Map alternative search names for better icon search results
- **Import/Export** — Save, share, and restore your icon configurations
- **CLI Tool** — Full-featured command-line interface with 8 commands
- **Localization** — Available in 30 languages

## Installation

### Homebrew

```bash
brew install Bengerthelorf/tap/iconchanger
```

### Manual

1. Download the latest DMG from [Releases](https://github.com/Bengerthelorf/macIconChanger/releases/latest).
2. Drag IconChanger to your Applications folder.
3. Launch and follow the one-time setup prompt (grants permission to change icons).

### CLI Tool

1. Open IconChanger → `Settings` → `Advanced`.
2. Click **Install** under Command Line Tool (requires admin password).
3. The `iconchanger` command is now available in your terminal.

## Usage

### Changing Icons (GUI)

1. Select an app from the sidebar.
2. Search for icons or choose a local image.
3. Click to apply.

### Changing Icons (CLI)

```bash
# Set a custom icon
iconchanger set-icon /Applications/Safari.app ~/icons/safari.png

# Remove a custom icon (restore default)
iconchanger remove-icon /Applications/Safari.app

# Restore all cached custom icons (e.g., after system update)
iconchanger restore

# Restore with preview
iconchanger restore --dry-run --verbose
```

### App Aliases

If icon search returns no results for an app:

1. Right-click the app in the sidebar → **Set the Alias**.
2. Enter a search-friendly name (e.g., `Adobe Illustrator 2023` → `Illustrator`).

### Configuration Management

```bash
# Export configuration (aliases + cached icons)
iconchanger export ~/Desktop/my-icons.json

# Import a configuration
iconchanger import ~/Desktop/my-icons.json

# Validate a config file before importing
iconchanger validate ~/Desktop/my-icons.json

# Check setup status
iconchanger status

# List all aliases and cached icons
iconchanger list
```

### Background Service

Go to `Settings` → `Background` to configure:

- **Run in Background** — Keep the app running after closing the window
- **Restore Icons on Schedule** — Automatically restore icons at set intervals
- **Restore Icons When Apps Update** — Detect app updates and re-apply custom icons
- **Show in Menu Bar / Dock** — Choose how the app appears when running in background
- **Launch at Login** — Start automatically with configurable behavior

## Initial Setup

On first launch, IconChanger will prompt you to complete setup. This configures the necessary permissions to change app icons (writes a sudoers rule for the helper script). Just click the setup button and enter your admin password once.

If you prefer manual setup, add this line via `sudo visudo`:

```
ALL ALL=(ALL) NOPASSWD: /Users/<your-username>/.iconchanger/helper.sh
```

## API Key

An API key from [macosicons.com](https://macosicons.com/) is required to search for icons online.

1. Visit [macosicons.com](https://macosicons.com/) and create an account.
2. Request an API key.
3. Enter it in `Settings` → `Advanced` → `API Key`.

You can also use local icon files without an API key.

![How to get API key](./Github/Api.png)

## Automation with dotfiles

```bash
#!/bin/bash
DMG_URL="https://github.com/Bengerthelorf/macIconChanger/releases/latest/download/IconChanger.dmg"
DMG_PATH="/tmp/IconChanger.dmg"

# Install app
curl -L "$DMG_URL" -o "$DMG_PATH"
hdiutil attach "$DMG_PATH" -mountpoint /Volumes/IconChanger
cp -R /Volumes/IconChanger/IconChanger.app /Applications/
hdiutil detach /Volumes/IconChanger

# Install CLI (from app bundle)
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger

# Import your icon configuration
iconchanger import ~/dotfiles/iconchanger/config.json
```

## System Requirements

- macOS 13.0 or later
- Administrator privileges (for initial setup and icon changes)

## Limitations

System apps protected by SIP (System Integrity Protection) cannot have their icons changed. This is a macOS restriction.

## Contributing

1. Fork the project.
2. Clone and open in Xcode 15+.
3. Start contributing!

Report bugs via [GitHub Issues](https://github.com/Bengerthelorf/macIconChanger/issues).

## Acknowledgements

- [underthestars-zhy/IconChanger](https://github.com/underthestars-zhy/IconChanger) — Original project
- [lcandy2](https://github.com/lcandy2) — Fork that this project is based on
- [macOSicons.com](https://macosicons.com/#/) — Icon database
- [fileicon](https://github.com/mklement0/fileicon) — Icon manipulation tool
- [Atom](https://github.com/atomtoto) — Contributor

## License

MIT License. See [LICENSE](LICENSE) for details.

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=Bengerthelorf/macIconChanger&type=Timeline)](https://www.star-history.com/#Bengerthelorf/macIconChanger&Timeline)
