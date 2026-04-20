---
title: Import & Export
section: guide
order: 8
---


Back up your icon configurations or transfer them to another Mac.

## What Gets Exported

An export file (JSON) includes:
- **App aliases** — your custom search name mappings
- **Cached icon references** — which apps have custom icons and the cached icon files

## Exporting

### From the GUI

Go to **Settings** > **Advanced** > **Configuration**, and click **Export**.

### From the CLI

```bash
iconchanger export ~/Desktop/my-icons.json
```

## Importing

### From the GUI

Go to **Settings** > **Advanced** > **Configuration**, and click **Import**.

### From the CLI

```bash
iconchanger import ~/Desktop/my-icons.json
```

:::callout[tip]{kind="info"}
Import only **adds** new items. It never replaces or removes your existing aliases or cached icons.
:::

## Validating

Before importing, you can validate a configuration file:

```bash
iconchanger validate ~/Desktop/my-icons.json
```

This checks the file structure without making any changes.

## Automation with Dotfiles

You can automate IconChanger setup as part of your dotfiles:

```bash
#!/bin/bash
DMG_URL="https://github.com/Bengerthelorf/macIconChanger/releases/latest/download/IconChanger.dmg"
DMG_PATH="/tmp/IconChanger.dmg"

# Install the app
curl -L "$DMG_URL" -o "$DMG_PATH"
hdiutil attach "$DMG_PATH" -mountpoint /Volumes/IconChanger
cp -R /Volumes/IconChanger/IconChanger.app /Applications/
hdiutil detach /Volumes/IconChanger

# Install CLI (from the app bundle)
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger

# Import your icon configuration
iconchanger import ~/dotfiles/iconchanger/config.json
```
