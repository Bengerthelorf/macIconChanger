#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/iconchanger-interval-observers-test.XXXXXX")"
trap 'rm -rf "$TEST_ROOT"' EXIT

python3 - "$REPO_ROOT/IconChanger/Services/BackgroundService.swift" "$TEST_ROOT/BackgroundIntervalHarness.swift" <<'PY'
from pathlib import Path
import sys

source = Path(sys.argv[1]).read_text()
properties = []
for name in ("scheduledRestoreInterval", "customScheduledRestoreInterval", "autoRestoreCheckInterval"):
    start = source.index(f"    @Published var {name}: Int {{")
    end = source.index("\n    @Published ", start + 1)
    properties.append(source[start:end])

# Keep the real Combine wrappers and observers; replace only their external
# effects with in-memory persistence and scheduling spies in the test module.
Path(sys.argv[2]).write_text("""import Foundation
import Combine
@MainActor
final class BackgroundIntervalHarness: ObservableObject {
""" + "\n".join(properties) + """
    var rescheduleRequests: [Bool] = []

    init() {
        scheduledRestoreInterval = 24
        customScheduledRestoreInterval = 36
        autoRestoreCheckInterval = 15
    }

    private func rescheduleIfRunning(changed: Bool) {
        rescheduleRequests.append(changed)
    }
}
""")
PY

swiftc \
    "$REPO_ROOT/IconChanger/Services/BackgroundSchedulePolicy.swift" \
    "$TEST_ROOT/BackgroundIntervalHarness.swift" \
    "$REPO_ROOT/tests/background-interval-observers.swift" \
    -o "$TEST_ROOT/background-interval-observer-tests"

"$TEST_ROOT/background-interval-observer-tests"
