#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/iconchanger-version-metadata-test.XXXXXX")"
trap 'rm -rf "$TEST_ROOT"' EXIT

# Compile the real metadata model without instantiating app/helper singletons.
sed '/^struct IconUndoSnapshot/,$d' \
    "$REPO_ROOT/IconChanger/Services/IconCache.swift" > "$TEST_ROOT/IconCache.swift"

swiftc \
    "$REPO_ROOT/IconChanger/Services/BackgroundSchedulePolicy.swift" \
    "$TEST_ROOT/IconCache.swift" \
    "$REPO_ROOT/tests/app-version-metadata.swift" \
    -o "$TEST_ROOT/app-version-metadata-tests"

"$TEST_ROOT/app-version-metadata-tests"
