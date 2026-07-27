#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/iconchanger-interaction-test.XXXXXX")"
trap 'rm -rf "$TEST_ROOT"' EXIT

swiftc \
    "$REPO_ROOT/IconChanger/Services/IconInteractionPolicy.swift" \
    "$REPO_ROOT/tests/icon-interactions.swift" \
    -o "$TEST_ROOT/icon-interaction-tests"

"$TEST_ROOT/icon-interaction-tests"
