#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/iconchanger-background-restore-test.XXXXXX")"
trap 'rm -rf "$TEST_ROOT"' EXIT

# Exercise the production loop without starting timers, notifications, or helpers.
python3 - "$REPO_ROOT/IconChanger/Services/BackgroundService.swift" "$TEST_ROOT/BackgroundRestoreHarness.swift" <<'PY'
from pathlib import Path
import sys

source = Path(sys.argv[1]).read_text()
start = source.index("    private func restoreUpdatedApps(")
end = source.index("\n    func formatInterval", start)
methods = source[start:end].replace("private func ", "func ")
Path(sys.argv[2]).write_text("""import Foundation
@MainActor
final class BackgroundRestoreHarness {
    let iconManager = IconManager()
    let logger = TestLogger()
""" + methods + "\n}\n")
PY

swiftc \
    "$TEST_ROOT/BackgroundRestoreHarness.swift" \
    "$REPO_ROOT/tests/background-restore.swift" \
    -o "$TEST_ROOT/background-restore-tests"

"$TEST_ROOT/background-restore-tests"
