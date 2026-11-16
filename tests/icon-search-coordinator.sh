#!/bin/bash
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/iconchanger-coordinator.XXXXXX")"
trap 'rm -rf "$TEST_ROOT"' EXIT
swiftc "$REPO_ROOT/IconChanger/Models/IconRes.swift" \
    "$REPO_ROOT/IconChanger/Services/IconSearchPolicy.swift" \
    "$REPO_ROOT/IconChanger/Services/IconSearchCoordinator.swift" \
    "$REPO_ROOT/tests/icon-search-coordinator.swift" -o "$TEST_ROOT/test"
"$TEST_ROOT/test"
