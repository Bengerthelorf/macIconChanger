#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/iconchanger-setup-health-test.XXXXXX")"
trap 'rm -rf "$TEST_ROOT"' EXIT

swiftc \
    "$REPO_ROOT/IconChanger/Services/SetupHealth.swift" \
    "$REPO_ROOT/tests/setup-health.swift" \
    -o "$TEST_ROOT/setup-health-tests"

"$TEST_ROOT/setup-health-tests"
