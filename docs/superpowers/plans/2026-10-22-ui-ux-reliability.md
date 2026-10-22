# IconChanger reliability and UI repair plan

**Goal:** Implement the issues accepted in the 2026-10-22 audit, then compile and inspect the actual macOS UI.

**Scope:** Existing SwiftUI app; retain macOS 13 compatibility and existing translations. No system-wide icon modification, privilege changes, publishing, or replacement of the installed app during QA.

**Approach:** Work on `fix/ui-ux-reliability`. Use a separately identified Debug application with isolated data and a write-blocked UI review mode. The user authorized direct implementation of the preceding audit.

- [x] Task 1: Fix sudoers candidate validation order and give explicit diagnostics for unrecognized legacy rules. Test cleanup/probe behavior with isolated fixtures; never edit the host sudoers.
- [x] Task 2: Keep usable setup health during rechecks, coalesce concurrent checks, preserve browsing state, and derive settings status from SetupHealth. Regression tests for non-ready states.
- [x] Task 3: Make icon cards preview before application, stage cache records until successful application, remove misleading cancellation, and provide recovery/undo for changes. Test failure preservation.
- [x] Task 4: Fix blank filter text, empty/search states, Dock size and contrast, settings layout, API quota clarity, and accessibility labels. Inspect Light/Dark and the minimum-width window layout.
- [x] Task 5: Compile GUI and CLI, run regression checks, launch the isolated app, capture every settings tab and key flows, correct observed display bugs, then obtain an independent code review.

**Review focus:** Managed sudoers without includedir; damaged/unrecognized legacy rules; configuration health changes during active browsing; failed helper calls preserving previous cache; preview dismissal never applying an icon; macOS 13 fallback and macOS 26 toolbar layout; isolated QA must not touch real app icons or user credentials.

**Evidence:** Build logs, screenshots, and the verification ledger are saved outside the source checkout. The isolated UI build can be reproduced with `bash scripts/build-ui-review.sh /tmp/iconchanger-ui-review`.
