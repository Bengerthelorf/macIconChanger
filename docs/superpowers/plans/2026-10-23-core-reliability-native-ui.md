# Core reliability and native macOS controls

The product helps people choose, apply, and preserve icons for individual apps and folders. This pass prioritizes failures in that workflow and keeps macOS 13 as the deployment target. The user delegated scope decisions and requested a local DMG in Downloads; no public release is part of this pass.

1. Inspect live issues and comments, distinguish shipped fixes, reproducible defects, platform limits, and requests outside the product. Record decisions in `docs/issue-audit-2026-10-23.md`.
2. Reproduce app-update metadata staleness in one process. Read version metadata from disk and cover in-place updates and bundle replacement.
3. Correct folder icon operations to use the public `NSWorkspace.setIcon` API. Preserve app helper restrictions. Reject unsuccessful postconditions before committing cache/history, and improve relevant failure messages.
4. Centralize menu-bar/Dock visibility changes and keep one entry point available. Validate custom intervals and avoid integer overflow. Replace gesture-only controls with native Buttons/SecureFields.
5. Run behavioral regression tests and a Release build with locked dependencies and macOS 13 deployment. Review changes independently. Build the isolated UI Review app and inspect key screens and interactions in light/dark appearances.
6. Package a clearly labeled local candidate, verify signatures/version/mount contents, and save its DMG to `~/Downloads`. Keep the installed app and real user icon/settings data untouched during QA.

Older macOS runtime coverage is limited by the local host; availability and deployment-target builds provide compatibility checks, not a claim of execution on Sequoia.
