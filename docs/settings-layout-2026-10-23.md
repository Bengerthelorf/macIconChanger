# Compact settings verification

Follow-up: the original review missed footer paragraph alignment and localized control truncation. See [the hotfix verification](settings-layout-hotfix-2026-10-23.md) for the corrected 30-language checks and fixes.

The settings window returns to its original 500-point width. Its existing minimum/ideal height stays 540/620 points, and long Form pages keep native vertical scrolling. The Settings scene uses content-size constraints so a previously saved wider frame cannot override the compact width. The main window and all icon reliability fixes are retained.

Long application and alias names keep native single-row editing/list behavior and expose the complete value in a help tooltip.

## Verification

- Built the final isolated UI Review app with the locked package graph and macOS 13 deployment target.
- Inspected all seven settings tabs, including the optional Developer tab, in Simplified Chinese and English. Seven English toolbar labels fit within the compact window.
- Checked alias and folder tables, populated cache rows with Light/Dark slots and all three action buttons, expanded background scheduling/update settings, long Advanced descriptions and bottom controls, and Developer diagnostics controls. Native scrolling keeps the bottom sections reachable.
- Imported disposable icon fixtures through the isolated app's public configuration dialog. No icons were applied to real apps; actual helper, credential, login and Dock mutations remain disabled by UI Review mode.
- Verified Light/Dark rendering. Captured settings screenshots are 1000 physical pixels wide on the 2x display, corresponding to 500 logical points.
- `bash tests/run.sh` passed on the final source. The visual width change is covered by real native-window inspection rather than an implementation-mirroring source-text assertion.

Evidence: sibling directory `macIconChanger-audit-20261023/compact-settings/`, including `screenshots/`, `tests.log`, and `ui-final/build.log`.

Host runtime: macOS 27.0.1. The macOS 13+ deployment target and existing pre-Liquid Glass API fallbacks are retained; this does not claim runtime testing on Ventura or Sequoia.

Release target authorized by the user: GitHub prerelease `v1.5.1-pre.3`, retaining the earlier core reliability fixes. The publish workflow must promote the exact validated candidate; no new copy in Downloads is requested.
