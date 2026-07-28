#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEST_BINARY="$(mktemp "${TMPDIR:-/tmp}/configuration-archive.XXXXXX")"
trap 'rm -f "$TEST_BINARY"' EXIT

swiftc \
    "$REPO_ROOT/IconChanger/Config/ConfigurationArchive.swift" \
    "$REPO_ROOT/tests/configuration-archive.swift" \
    -o "$TEST_BINARY"

"$TEST_BINARY"
