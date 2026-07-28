#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENTITLEMENTS="$REPO_ROOT/IconChanger/IconChanger.ad-hoc.entitlements"
LAUNCH_VALIDATOR="$REPO_ROOT/scripts/validate-launchable-executable.sh"

fail() {
    echo "FAIL: $1" >&2
    exit 1
}

[[ -f "$ENTITLEMENTS" ]] ||
    fail "ad-hoc release entitlements are missing"

library_validation="$(
    /usr/libexec/PlistBuddy \
        -c "Print :com.apple.security.cs.disable-library-validation" \
        "$ENTITLEMENTS"
)"
[[ "$library_validation" == "true" ]] ||
    fail "ad-hoc releases must allow their separately signed Sparkle framework"

if bash "$LAUNCH_VALIDATOR" /usr/bin/true >/dev/null 2>&1; then
    fail "launch validation must reject an executable that exits immediately"
fi

bash "$LAUNCH_VALIDATOR" /usr/bin/yes >/dev/null

echo "PASS: ad-hoc candidates preserve Hardened Runtime and launch validation"
