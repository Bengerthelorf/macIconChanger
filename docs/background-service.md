---
title: Background Service
section: guide
order: 6
---


The background service keeps your custom icons intact, even after app updates or system changes.

## Enabling

Go to **Settings** > **Background** and toggle **Run in Background**.

When enabled, IconChanger continues running after you close the window. You can access it from the menu bar or Dock.

## Features

### Scheduled Restoration

Automatically restore all cached custom icons at regular intervals.

- Toggle **Restore Icons on Schedule**
- Choose an interval: every hour, 3 hours, 6 hours, 12 hours, daily, or a custom interval
- The settings show when the last and next restoration will occur

### App Update Detection

Detect when apps are updated and automatically reapply their custom icons.

- Toggle **Restore Icons When Apps Update**
- Set how often to check for updates (every 5 minutes to every 2 hours, or custom)

### App Visibility

Control where IconChanger appears when running in the background:

- **Show in Menu Bar** — adds an icon to the menu bar
- **Show in Dock** — keeps the app in the Dock

At least one of these must be enabled.

### Launch at Login

Start IconChanger automatically when you log in to your Mac.

- **Open Main Window** — launches normally with the main window
- **Start Hidden** — launches silently in the background (requires "Run in Background" to be enabled)

::: info
"Start Hidden" only affects login launch. Opening the app manually will always show the main window.
:::

## Service Status

When the background service is active, the settings page shows:
- **Service Status** — whether the service is running
- **Cached Icons** — how many icons are ready for restoration
