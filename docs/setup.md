---
title: Initial Setup
section: guide
order: 2
---


IconChanger needs administrator privileges to change application icons. On first launch, the app offers to set this up automatically.

## Automatic Setup (Recommended)

1. Launch IconChanger.
2. Click the **Setup** button when prompted.
3. Enter your administrator password.

The app will install a helper script to `/usr/local/lib/iconchanger/` (owned by `root:wheel`) and configure a scoped sudoers rule so it can run without a password prompt each time.

## Security

IconChanger uses several security measures to protect the helper pipeline:

- **Root-owned helper directory** — The helper files live in `/usr/local/lib/iconchanger/` with `root:wheel` ownership, preventing unprivileged modification.
- **SHA-256 integrity verification** — The helper script is verified against a known hash before every execution.
- **Scoped sudoers rule** — The sudoers entry only grants passwordless access to the specific helper script, not arbitrary commands.
- **Audit logging** — All icon operations are logged with timestamps for traceability.

## Manual Setup

If automatic setup fails, you can configure it manually:

1. Open Terminal.
2. Run:

```bash
sudo visudo -f /etc/sudoers.d/iconchanger
```

3. Add the following line:

```
ALL ALL=(ALL) NOPASSWD: /usr/local/lib/iconchanger/helper.sh
```

## Verifying Setup

After setup, the app should show the application list in the sidebar. If you see the setup prompt again, the configuration may not have been applied correctly.

You can verify the setup from the menu bar: click the **...** menu and select **Check Setup Status**.

## Limitations

Applications protected by macOS System Integrity Protection (SIP) cannot have their icons changed. This is a macOS restriction and cannot be bypassed.

Common SIP-protected apps include:
- Finder
- Safari (on some macOS versions)
- Other system applications in `/System/Applications/`
