#!/bin/bash
set -euo pipefail

FILEICON_UNDER_TEST="${1:-IconChanger/Resources/fileicon}"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

case "$FILEICON_UNDER_TEST" in
    /*) ;;
    *) FILEICON_UNDER_TEST="$REPO_ROOT/$FILEICON_UNDER_TEST" ;;
esac

TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/iconchanger-fileicon-test.XXXXXX")"
trap 'rm -rf "$TEST_ROOT"' EXIT

FAKE_BIN="$TEST_ROOT/bin"
CAPTURE_DIR="$TEST_ROOT/capture"
mkdir -p "$FAKE_BIN" "$CAPTURE_DIR"

cat > "$FAKE_BIN/osascript" <<'EOF'
#!/bin/bash
set -euo pipefail
printf '%s\n' "$@" > "$FILEICON_TEST_CAPTURE/osascript-args"
cat > "$FILEICON_TEST_CAPTURE/osascript-source"
EOF
chmod +x "$FAKE_BIN/osascript"

cat > "$FAKE_BIN/xxd" <<'EOF'
#!/bin/bash
printf '69636e73'
EOF
chmod +x "$FAKE_BIN/xxd"

TARGET="$TEST_ROOT/Target \"quoted\"; touch SHOULD_NOT_EXIST.app"
IMAGE="$TEST_ROOT/Icon \"quoted\"; touch SHOULD_NOT_EXIST.png"
touch "$TARGET" "$IMAGE"

PATH="$FAKE_BIN:$PATH" \
FILEICON_TEST_CAPTURE="$CAPTURE_DIR" \
bash "$FILEICON_UNDER_TEST" set "$TARGET" "$IMAGE" >/dev/null

ARG_COUNT="$(wc -l < "$CAPTURE_DIR/osascript-args" | tr -d ' ')"
ARG_ONE="$(sed -n '1p' "$CAPTURE_DIR/osascript-args")"
ARG_TWO="$(sed -n '2p' "$CAPTURE_DIR/osascript-args")"
ARG_THREE="$(sed -n '3p' "$CAPTURE_DIR/osascript-args")"
if [[ "$ARG_COUNT" -ne 3 ||
      "$ARG_ONE" != "-" ||
      "$ARG_TWO" != "$IMAGE" ||
      "$ARG_THREE" != "$TARGET" ]]; then
    echo "FAIL: fileicon must pass image and target paths as osascript argv" >&2
    sed 's/^/Captured argv: </; s/$/>/' "$CAPTURE_DIR/osascript-args" >&2
    exit 1
fi

if /usr/bin/grep -Fq "$TARGET" "$CAPTURE_DIR/osascript-source" ||
   /usr/bin/grep -Fq "$IMAGE" "$CAPTURE_DIR/osascript-source"; then
    echo "FAIL: caller-controlled paths were interpolated into AppleScript source" >&2
    exit 1
fi

if [[ -e "$TEST_ROOT/SHOULD_NOT_EXIST.app" ||
      -e "$TEST_ROOT/SHOULD_NOT_EXIST.png" ]]; then
    echo "FAIL: path content was executed as a command" >&2
    exit 1
fi

echo "PASS: fileicon treats caller-controlled paths as data"
