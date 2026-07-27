#!/bin/bash
set -euo pipefail

HELPER_UNDER_TEST="${1:-IconChanger/Resources/helper.sh}"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

case "$HELPER_UNDER_TEST" in
    /*) ;;
    *) HELPER_UNDER_TEST="$REPO_ROOT/$HELPER_UNDER_TEST" ;;
esac

SELF_TEST_OUTPUT="$(bash "$HELPER_UNDER_TEST" --self-test 2>&1)" || {
    echo "FAIL: helper self-test must succeed without privileged side effects" >&2
    printf '%s\n' "$SELF_TEST_OUTPUT" >&2
    exit 1
}

if [[ "$SELF_TEST_OUTPUT" != "IconChanger helper ready" ]]; then
    echo "FAIL: helper self-test returned an unexpected response" >&2
    printf '%s\n' "$SELF_TEST_OUTPUT" >&2
    exit 1
fi

set +e
OUTPUT="$(
    bash "$HELPER_UNDER_TEST" \
        "/usr/local/lib/iconchanger/fileicon" \
        $'/Applications/Example.app\nmalicious' \
        "/tmp/icon.png" 2>&1
)"
STATUS=$?
set -e

if [[ $STATUS -eq 0 ]]; then
    echo "FAIL: helper accepted a path containing control characters" >&2
    exit 1
fi

if [[ "$OUTPUT" != *"path contains control characters"* ]]; then
    echo "FAIL: helper did not reject the control character at its trust boundary" >&2
    printf '%s\n' "$OUTPUT" >&2
    exit 1
fi

echo "PASS: helper self-test is explicit and paths are validated before privileged execution"
