#!/bin/bash
set -euo pipefail

EXECUTABLE="${1:-}"

if [[ -z "$EXECUTABLE" || ! -x "$EXECUTABLE" ]]; then
    echo "Usage: $0 <executable>" >&2
    exit 1
fi

LOG_PATH="$(mktemp "${TMPDIR:-/tmp}/iconchanger-launch.XXXXXX.log")"
PROCESS_ID=""

cleanup() {
    if [[ -n "$PROCESS_ID" ]] && kill -0 "$PROCESS_ID" 2>/dev/null; then
        kill -TERM "$PROCESS_ID" 2>/dev/null || true
        wait "$PROCESS_ID" 2>/dev/null || true
    fi
    rm -f "$LOG_PATH"
}
trap cleanup EXIT

"$EXECUTABLE" > "$LOG_PATH" 2>&1 &
PROCESS_ID=$!

for _ in {1..20}; do
    if ! kill -0 "$PROCESS_ID" 2>/dev/null; then
        wait "$PROCESS_ID" 2>/dev/null || true
        echo "Executable exited before launch validation completed." >&2
        sed -n '1,120p' "$LOG_PATH" >&2
        exit 1
    fi
    sleep 0.1
done

echo "Executable remained running through launch validation."
