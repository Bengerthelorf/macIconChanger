# IconChanger

[中文版](./README-zh.md) | [Version française](./README-fr.md) | [Documentation](https://bengerthelorf.github.io/macIconChanger/)

A macOS app to customize application icons with a clean GUI and a powerful CLI.

![preview](./Github/Github-Iconchanger.jpeg)

## Features

- **Custom Icons** — Change the icon of any app via GUI or command line
- **Dock Preview** — Live preview of your Dock with custom icons
- **Icon Cache** — Automatically caches custom icons for easy restoration
- **Background Service** — Keeps custom icons persistent across app updates
- **Squircle Jail Escape** — Fix macOS Tahoe's forced squircle icons with one click
- **CLI Tool** — Full-featured command-line interface
- **Localization** — Available in 30 languages

## Installation

### Homebrew

```bash
brew install Bengerthelorf/tap/iconchanger
```

### Manual

1. Download the latest DMG from [Releases](https://github.com/Bengerthelorf/macIconChanger/releases/latest).
2. Drag IconChanger to your Applications folder.
3. Launch and follow the one-time setup prompt.

## Quick Start

1. Select an app from the sidebar.
2. Browse icons from [macosicons.com](https://macosicons.com/) or choose a local image.
3. Click to apply.

> An API key is required to search icons online. See the [API Key guide](https://bengerthelorf.github.io/macIconChanger/guide/api-key) in the documentation.

For detailed usage including CLI commands, background service, app aliases, and configuration management, visit the **[Documentation](https://bengerthelorf.github.io/macIconChanger/)**.

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
- [macOSicons.com](https://macosicons.com/) — Icon database
- [fileicon](https://github.com/mklement0/fileicon) — Icon manipulation tool
- [Atom](https://github.com/atomtoto) — Contributor

## License

MIT License. See [LICENSE](LICENSE) for details.

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=Bengerthelorf/macIconChanger&type=Timeline)](https://www.star-history.com/#Bengerthelorf/macIconChanger&Timeline)
