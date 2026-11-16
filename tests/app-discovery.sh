#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/iconchanger-discovery-test.XXXXXX")"
trap 'rm -rf "$TEST_ROOT"' EXIT

swiftc \
    "$REPO_ROOT/IconChanger/Services/AppDiscoveryPolicy.swift" \
    "$REPO_ROOT/tests/app-discovery.swift" \
    -o "$TEST_ROOT/app-discovery-tests"

"$TEST_ROOT/app-discovery-tests" "$TEST_ROOT"
