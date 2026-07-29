#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/iconchanger-diagnostics-test.XXXXXX")"
trap 'rm -rf "$TEST_ROOT"' EXIT

swiftc \
    "$REPO_ROOT/IconChanger/Utilities/AppPaths.swift" \
    "$REPO_ROOT/IconChanger/Utilities/DiagnosticsLogger.swift" \
    "$REPO_ROOT/tests/diagnostics-logging.swift" \
    -o "$TEST_ROOT/diagnostics-logging-tests"

"$TEST_ROOT/diagnostics-logging-tests"
