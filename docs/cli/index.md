---
title: CLI Installation
section: cli
order: 1
---


IconChanger includes a command-line interface for scripting and automation.

## Install from the App

1. Open IconChanger > **Settings** > **Advanced**.
2. Under **Command Line Tool**, click **Install**.
3. Enter your administrator password.

The `iconchanger` command is now available in your terminal.

## Install Manually

If you prefer to install manually (e.g., in a dotfiles script):

```bash
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger
```

## Verify Installation

```bash
iconchanger --version
```

## Uninstall

From the app: **Settings** > **Advanced** > **Uninstall**.

Or manually:

```bash
sudo rm /usr/local/bin/iconchanger
```

## Next Steps

See the [Command Reference](./commands) for all available commands.
