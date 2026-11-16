#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/iconchanger-icon-fetch-cache-test.XXXXXX")"
trap 'rm -rf "$TEST_ROOT"' EXIT

swiftc \
    "$REPO_ROOT/IconChanger/Models/IconRes.swift" \
    "$REPO_ROOT/IconChanger/Services/IconFetchCache.swift" \
    "$REPO_ROOT/tests/icon-fetch-cache.swift" \
    -o "$TEST_ROOT/icon-fetch-cache-tests"

"$TEST_ROOT/icon-fetch-cache-tests" "$TEST_ROOT"
