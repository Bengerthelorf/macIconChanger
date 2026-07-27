#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$(mktemp -d "${TMPDIR:-/tmp}/iconchanger-remote-image-test.XXXXXX")"
trap 'rm -rf "$BUILD_DIR"' EXIT

swiftc \
    "$REPO_ROOT/IconChanger/Models/IconRes.swift" \
    "$REPO_ROOT/tests/remote-image-policy.swift" \
    -o "$BUILD_DIR/remote-image-policy-tests"

"$BUILD_DIR/remote-image-policy-tests"
