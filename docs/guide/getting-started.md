# Quick Start

## Requirements

- macOS 13.0 (Ventura) or later
- Administrator privileges (for initial setup and changing icons)

## Installation

### Homebrew (Recommended)

```bash
brew install Bengerthelorf/tap/iconchanger
```

### Manual Download

1. Download the latest DMG from [GitHub Releases](https://github.com/Bengerthelorf/macIconChanger/releases/latest).
2. Open the DMG and drag **IconChanger** into your Applications folder.
3. Launch IconChanger.

## First Launch

On the first launch, IconChanger will prompt you to complete a one-time permission setup. This is required for the app to change application icons.

![First launch setup screen](/images/setup-prompt.png)

Click the setup button and enter your administrator password. IconChanger will automatically configure the necessary permissions (a sudoers rule for the helper script).

::: tip
If the automatic setup fails, see [Initial Setup](./setup) for manual instructions.
:::

## Changing Your First Icon

1. Select an application from the sidebar.
2. Browse icons from [macOSicons.com](https://macosicons.com/) or choose a local image file.
3. Click on an icon to apply it.

![Main interface](/images/main-interface.png)

That's it! The app icon will be changed immediately.

## Next Steps

- [Set up an API key](./api-key) for online icon search
- [Learn about app aliases](./aliases) for better search results
- [Configure the background service](./background-service) for automatic icon restoration
- [Install the CLI tool](/cli/) for command-line access
