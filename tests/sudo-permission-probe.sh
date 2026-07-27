#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/iconchanger-sudo-test.XXXXXX")"
trap 'rm -rf "$TEST_ROOT"' EXIT

swiftc \
    "$REPO_ROOT/IconChanger/Services/SudoPermissionProbePolicy.swift" \
    "$REPO_ROOT/tests/sudo-permission-probe.swift" \
    -o "$TEST_ROOT/sudo-permission-probe-tests"

"$TEST_ROOT/sudo-permission-probe-tests"
