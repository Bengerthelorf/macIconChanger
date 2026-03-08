# Initial Setup

IconChanger needs administrator privileges to change application icons. On first launch, the app offers to set this up automatically.

## Automatic Setup (Recommended)

1. Launch IconChanger.
2. Click the **Setup** button when prompted.
3. Enter your administrator password.

The app will create a helper script at `~/.iconchanger/helper.sh` and configure a sudoers rule so it can run without a password prompt each time.

## Manual Setup

If automatic setup fails, you can configure it manually:

1. Open Terminal.
2. Run:

```bash
sudo visudo
```

3. Add the following line at the end:

```
ALL ALL=(ALL) NOPASSWD: /Users/<your-username>/.iconchanger/helper.sh
```

Replace `<your-username>` with your actual macOS username.

## Verifying Setup

After setup, the app should show the application list in the sidebar. If you see the setup prompt again, the configuration may not have been applied correctly.

You can verify the setup from the menu bar: click the **...** menu and select **Check Setup Status**.

## Limitations

Applications protected by macOS System Integrity Protection (SIP) cannot have their icons changed. This is a macOS restriction and cannot be bypassed.

Common SIP-protected apps include:
- Finder
- Safari (on some macOS versions)
- Other system applications in `/System/Applications/`
