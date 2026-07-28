#!/bin/bash
set -euo pipefail

if [[ "$#" -ne 1 || -z "$1" ]]; then
    echo "Usage: $0 OUTPUT_PATH" >&2
    exit 64
fi

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE_PATH="$REPO_ROOT/tests/fixtures/signing-probe.c"
OUTPUT_PATH="$1"

[[ -f "$SOURCE_PATH" ]] || {
    echo "Signing probe source is missing: $SOURCE_PATH" >&2
    exit 1
}

mkdir -p "$(dirname "$OUTPUT_PATH")"
xcrun clang \
    -Os \
    -Wall \
    -Wextra \
    -Werror \
    "$SOURCE_PATH" \
    -o "$OUTPUT_PATH"
