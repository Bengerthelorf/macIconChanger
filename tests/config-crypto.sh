#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEST_BIN="$(mktemp "${TMPDIR:-/tmp}/iconchanger-config-crypto.XXXXXX")"
trap 'rm -f "$TEST_BIN"' EXIT

xcrun swiftc \
    "$REPO_ROOT/IconChanger/Utilities/ConfigCrypto.swift" \
    "$REPO_ROOT/tests/config-crypto.swift" \
    -o "$TEST_BIN"

"$TEST_BIN"
echo "PASS: encrypted configuration round-trips and rejects wrong passwords"
