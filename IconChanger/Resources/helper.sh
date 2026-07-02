#!/bin/bash
set -euo pipefail

FILEICON_PATH="$1"
APP_PATH="$2"
IMAGE_PATH="$3"

# Reject control chars in caller paths (defense-in-depth; real paths never have them).
control_chars=$'\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a\x1b\x1c\x1d\x1e\x1f\x7f'
for p in "$APP_PATH" "$IMAGE_PATH"; do
    case "$p" in
        *["$control_chars"]*)
            echo "ERROR: path contains control characters, refusing: $p" >&2
            exit 1
            ;;
    esac
done

EXPECTED_DIR="/usr/local/lib/iconchanger"
case "$FILEICON_PATH" in
    "$EXPECTED_DIR"/fileicon) ;;
    *)
        echo "ERROR: fileicon path is not in the expected directory ($EXPECTED_DIR)." >&2
        exit 1
        ;;
esac

if [ ! -e "$APP_PATH" ]; then
    echo "ERROR: APP_PATH does not exist: $APP_PATH" >&2
    exit 1
fi

case "$APP_PATH" in
    *.app|*.app/*) ;;
    *)
        if [ ! -d "$APP_PATH" ]; then
            echo "ERROR: APP_PATH is not a .app bundle or directory: $APP_PATH" >&2
            exit 1
        fi
        ;;
esac

if [ ! -f "$IMAGE_PATH" ]; then
    echo "ERROR: IMAGE_PATH does not exist or is not a file: $IMAGE_PATH" >&2
    exit 1
fi

case "$IMAGE_PATH" in
    *.png|*.PNG|*.icns|*.ICNS|*.jpg|*.JPG|*.jpeg|*.JPEG|*.tiff|*.TIFF) ;;
    *)
        echo "ERROR: IMAGE_PATH does not have a recognized image extension: $IMAGE_PATH" >&2
        exit 1
        ;;
esac

if [ ! -x "$FILEICON_PATH" ]; then
    echo "ERROR: fileicon is not executable: $FILEICON_PATH" >&2
    exit 1
fi

"$FILEICON_PATH" set "$APP_PATH" "$IMAGE_PATH"
