#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$(mktemp -d "${TMPDIR:-/tmp}/iconchanger-search-test.XXXXXX")"
trap 'rm -rf "$BUILD_DIR"' EXIT

swiftc -swift-version 5 \
    "$REPO_ROOT/IconChanger/Services/Request.swift" \
    "$REPO_ROOT/IconChanger/Services/IconSearchPolicy.swift" \
    "$REPO_ROOT/IconChanger/Services/IconInteractionPolicy.swift" \
    "$REPO_ROOT/IconChanger/Utilities/APIKeyManager.swift" \
    "$REPO_ROOT/IconChanger/Utilities/DiagnosticsLogger.swift" \
    "$REPO_ROOT/IconChanger/Models/IconRes.swift" \
    "$REPO_ROOT/IconChanger/Models/IconStyle.swift" \
    "$REPO_ROOT/tests/icon-search.swift" \
    -o "$BUILD_DIR/${BUILD_DIR##*/}"

CFFIXED_USER_HOME="$BUILD_DIR" "$BUILD_DIR/${BUILD_DIR##*/}"
