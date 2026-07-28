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

TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/iconchanger-helper-test.XXXXXX")"
trap 'rm -rf "$TEST_ROOT"' EXIT

FAKE_FILEICON="$TEST_ROOT/fileicon"
TARGET_APP="$TEST_ROOT/Example.app"
CAPTURE_FILE="$TEST_ROOT/fileicon-arguments"
TEST_HELPER="$TEST_ROOT/helper.sh"
mkdir -p "$TARGET_APP"
sed "s|EXPECTED_DIR=\"/usr/local/lib/iconchanger\"|EXPECTED_DIR=\"$TEST_ROOT\"|" \
    "$HELPER_UNDER_TEST" > "$TEST_HELPER"
cat > "$FAKE_FILEICON" <<'EOF'
#!/bin/bash
printf '%s\n' "$@" > "$HELPER_TEST_CAPTURE"
EOF
chmod +x "$FAKE_FILEICON"

ln -s "$TARGET_APP" "$TEST_ROOT/Symlink.app"
set +e
SYMLINK_OUTPUT="$(
    HELPER_TEST_CAPTURE="$CAPTURE_FILE" \
    bash "$TEST_HELPER" --remove "$FAKE_FILEICON" "$TEST_ROOT/Symlink.app" 2>&1
)"
SYMLINK_STATUS=$?
set -e
if [[ $SYMLINK_STATUS -eq 0 || "$SYMLINK_OUTPUT" != *"must not be a symbolic link"* ]]; then
    echo "FAIL: helper accepted a symbolic-link app target" >&2
    exit 1
fi

HELPER_TEST_CAPTURE="$CAPTURE_FILE" \
bash "$TEST_HELPER" --remove "$FAKE_FILEICON" "$TARGET_APP"

EXPECTED_TARGET_APP="$(/bin/realpath "$TARGET_APP")"
if [[ "$(sed -n '1p' "$CAPTURE_FILE")" != "rm" ||
      "$(sed -n '2p' "$CAPTURE_FILE")" != "$EXPECTED_TARGET_APP" ||
      "$(wc -l < "$CAPTURE_FILE" | tr -d ' ')" -ne 2 ]]; then
    echo "FAIL: helper remove mode must pass an exact rm command and app path" >&2
    exit 1
fi

echo "PASS: helper self-test is explicit and paths are validated before privileged execution"
