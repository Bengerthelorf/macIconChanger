#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/iconchanger-interaction-test.XXXXXX")"
trap 'rm -rf "$TEST_ROOT"' EXIT

swiftc \
    "$REPO_ROOT/IconChanger/Services/IconInteractionPolicy.swift" \
    "$REPO_ROOT/tests/icon-interactions.swift" \
    -o "$TEST_ROOT/icon-interaction-tests"

"$TEST_ROOT/icon-interaction-tests"

grep -Fq \
    'key: IconFetchInteractionPolicy.automaticallyLoadIconsKey' \
    "$REPO_ROOT/IconChanger/Utilities/AppSettings.swift"
grep -Fq \
    '"extendedSearch", "automaticallyLoadIcons", "appAppearance"' \
    "$REPO_ROOT/IconChangerCLI/IconChangerCLI.swift"
grep -Fq \
    'exportedSettings["automaticallyLoadIcons"] = .bool(true)' \
    "$REPO_ROOT/IconChangerCLI/IconChangerCLI.swift"
grep -Fq \
    'guard let resolvedKey = IconRemoteRequestPolicy.normalizedAPIKey(' \
    "$REPO_ROOT/IconChanger/Services/Request.swift"

echo "PASS: automatic loading is backed up consistently and missing API keys do not consume usage"
