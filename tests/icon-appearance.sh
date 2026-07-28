#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEST_BINARY="$(mktemp "${TMPDIR:-/tmp}/icon-appearance.XXXXXX")"
trap 'rm -f "$TEST_BINARY"' EXIT

swiftc \
    "$REPO_ROOT/IconChanger/Services/IconAppearancePolicy.swift" \
    "$REPO_ROOT/tests/icon-appearance.swift" \
    -o "$TEST_BINARY"

"$TEST_BINARY"
