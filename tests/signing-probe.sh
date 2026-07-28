#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROBE_BUILDER="$REPO_ROOT/scripts/create-signing-probe.sh"
TEST_DIR="$(mktemp -d)"
PROBE_PATH="$TEST_DIR/signing-probe"

cleanup() {
    rm -rf "$TEST_DIR"
}
trap cleanup EXIT

[[ -x "$PROBE_BUILDER" ]] || {
    echo "FAIL: signing probe builder is missing or not executable" >&2
    exit 1
}

bash "$PROBE_BUILDER" "$PROBE_PATH"

[[ -x "$PROBE_PATH" ]] || {
    echo "FAIL: signing probe builder did not create an executable" >&2
    exit 1
}

file "$PROBE_PATH" | /usr/bin/grep -Fq "Mach-O" || {
    echo "FAIL: signing probe is not a Mach-O executable" >&2
    exit 1
}

"$PROBE_PATH" || {
    echo "FAIL: signing probe did not execute successfully" >&2
    exit 1
}

echo "PASS: signing probe builder creates a working Mach-O executable"
