#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/iconchanger-schedule-test.XXXXXX")"
trap 'rm -rf "$TEST_ROOT"' EXIT

swiftc \
    "$REPO_ROOT/IconChanger/Services/BackgroundSchedulePolicy.swift" \
    "$REPO_ROOT/tests/background-schedule.swift" \
    -o "$TEST_ROOT/background-schedule-tests"

"$TEST_ROOT/background-schedule-tests"
