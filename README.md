# 🎨 IconChanger

[📖 中文版](./README-zh.md) | [🇫🇷 Version française](./README-fr.md)

IconChanger is a macOS application that empowers you to customize application icons on your Mac effortlessly. With a sleek graphical interface and powerful command-line tools, IconChanger gives you complete control over your app icons.

![preview](./Github/Github-Iconchanger.png)

## ✨ Why IconChanger?

Tired of the same old app icons? IconChanger is here to help you:

- 🎭 **Personalize** your Mac with custom icons that reflect your style.
- 🛠️ **Restore** original icons with ease, thanks to built-in caching.
- 🔄 **Keep consistent** icons across app updates with a background service.
- ⚡ **Automate** icon setups across multiple Macs using dotfiles.

Whether you're a casual user or a power user, IconChanger has something for everyone.

## 🚀 Features

### 🌟 Core Features

- **Custom Icons**: Change the icons of any application on your Mac.
- **Icon Cache**: Automatically cache original icons for easy restoration.
- **Smart Restoration**: Restore icons individually or all at once.
- **App Aliases**: Create custom names for your favorite applications.
- **Background Service**: Keep your custom icons persistent across app updates.

### 🧰 Advanced Features

- **Import/Export**: Save and share your icon configurations.
- **API Support**: Integrate with external tools and scripts.
- **Command Line Interface**: Manage icons through terminal commands.
- **dotfiles Integration**: Automate icon setup across multiple Macs.

## 📥 Installation

### 🖥️ App Installation

1. Download the latest DMG from [Releases](https://github.com/Bengerthelorf/macIconChanger/releases/latest).
2. Mount the DMG and drag IconChanger to your Applications folder.
3. Launch IconChanger from your Applications folder.

### 💻 CLI Tool Installation (GUI)

The command-line tool can be installed in two ways:

**Method 1: From the app (recommended)**

1. Open IconChanger.
2. Go to `Settings → Command Line`.
3. Click "Install CLI Tool" (requires admin password).

**Method 2: From the menu**

1. Open IconChanger.
2. From the menu bar, select `IconChanger → Command Line Tool → Install CLI Tool`.

## 🛠️ Usage

### 🎨 Changing App Icons

1. Launch IconChanger.
2. Browse or drag applications to the app window.
3. Select an application and click "Change Icon."
4. Choose a new icon image.
5. Click "Apply."

### ♻️ Restoring Icons

- Select an application with a custom icon and click "Restore."
- Or use "Restore All" to revert all applications to their original icons.

### 🏷️ App Aliases

> If IconChanger doesn't show any icon for a certain app:

1. Right-click the app's icon.
2. Choose `Set the Alias Name`.
3. Set an alias name for it (e.g., Adobe Illustrator → Illustrator).

### 📂 Configuration Management

#### 🖱️ GUI Method

1. Go to `Settings → Configuration`.
2. Use "Export Configuration" to save your settings.
3. Use "Import Configuration" to load a saved configuration.

#### 💻 Command Line Method

```bash
# Export your configuration
iconchanger export ~/Desktop/my-icons.json

# Import a configuration
iconchanger import ~/path/to/config.json
```

**Important Notes:**

- You must first export a configuration from the app before using the CLI export command.
- After importing with CLI, restart the app to see the changes take effect.

### 🔧 Background Service

IconChanger includes a background service that can:

- Maintain your custom icons when applications update.
- Run silently in the background or appear in the menu bar.
- Start automatically at login (optional).

To configure the background service:

1. Go to `Settings → Background`.
2. Enable "Run in Background."
3. Choose visibility options (Menu Bar, Dock, or both).

## 🔑 How to sudo permission (Required)

<iframe width="560" height="315" src="https://www.youtube.com/embed/f9TmrEY6GI0?si=cjKWk1y4K8evrKvh" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

IconChanger needs permission to change icons using its helper script. Please grant this permission by editing the sudoers file carefully:

1. Open Terminal (in /Applications/Utilities).
2. Type `sudo visudo` and press Enter. Enter your administrator password when prompted.
3. Navigate to the end of the file using arrow keys. Press 'i' to enter INSERT mode.
4. Add ONE of the following lines EXACTLY as shown (using your username is generally preferred):
    `ALL ALL=(ALL) NOPASSWD: /Users/username/.iconchanger/helper.sh`
    > (Note: This grants permission to all users. While less specific, it seems necessary for reliable operation in some environments.)
5. Press 'Esc' to exit INSERT mode.
6. Type `:wq` and press Enter to save and quit. (Use `:q!` to quit without saving if you make a mistake).
7. Restart IconChanger after saving the file.

WARNING: Incorrectly editing sudoers can damage your system. Proceed with caution.

## 🔑 How to Get an API Key (Required)

![HOW_TO_GET_API_KEY](./Github/Api.png)

1. Open your browser.
2. Go to [macosicons.com](https://macosicons.com/).
3. Create an account or log in.
4. Request an API key for use with IconChanger.
5. Copy the API key.
6. Open the IconChanger Settings.
7. Input the API key.

## ⚙️ Integration with dotfiles

IconChanger is perfect for managing consistent app appearances across multiple Macs using dotfiles:

```bash
#!/bin/bash
# Example dotfiles script

# Parameters
DMG_URL="https://github.com/Bengerthelorf/macIconChanger/releases/latest/download/IconChanger.dmg"
CLI_URL="https://github.com/Bengerthelorf/macIconChanger/releases/latest/download/IconChangerCLI"
DMG_PATH="/tmp/IconChanger.dmg"
MOUNT_POINT="/Volumes/IconChanger"

# Download IconChanger DMG
echo "Downloading IconChanger DMG..."
curl -L "$DMG_URL" -o "$DMG_PATH"

# Mount IconChanger DMG
echo "Mounting DMG..."
hdiutil attach "$DMG_PATH" -mountpoint "$MOUNT_POINT"

# Install IconChanger
echo "Installing IconChanger..."
cp -R "$MOUNT_POINT/IconChanger.app" "/Applications/"

# Unmount IconChanger DMG
echo "Unmounting DMG..."
hdiutil detach "$MOUNT_POINT"

# Install IconChanger and CLI tool
echo "Installing CLI tool..."
# open -a IconChanger --args --install-cli          # Method 1
# echo "Waiting for Password Dialog..."
# sleep 5
curl -L "$CLI_URL" -o "/usr/local/bin/iconchanger"  # Method 2

# Import your icon configuration
iconchanger import ~/dotfiles/iconchanger/config.json

echo "IconChanger setup complete!"
```

## 🖥️ System Requirements

- macOS 12.0 or later.
- Administrator privileges (for icon changes and CLI installation).

## 🚫 About System Apps

Unfortunately, IconChanger cannot change the icons of System Apps due to macOS's System Integrity Protection (SIP). Modifying `Info.plist` files is restricted, so this feature is currently unavailable.

## 🤝 How to Contribute

1. Fork the project.
2. Clone your forked repository.
3. Open it in Xcode (13.3 or later).
4. Start contributing!

If you encounter any issues or have questions, please:

- Report bugs through [GitHub Issues](https://github.com/Bengerthelorf/macIconChanger/issues).

## 🌟 Acknowledgements

Special thanks to the following projects and resources:

- [macOSIcon](https://macosicons.com/#/)
- [fileicon](https://github.com/mklement0/fileicon)
- [Atom](https://github.com/atomtoto)

## 📜 License

IconChanger is licensed under the MIT License. See [LICENSE](LICENSE) for details.

## ⭐ Star History

[![Star History Chart](https://api.star-history.com/svg?repos=Bengerthelorf/macIconChanger&type=Timeline)](https://www.star-history.com/#Bengerthelorf/macIconChanger&Timeline)
