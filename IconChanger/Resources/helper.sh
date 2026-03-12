#!/bin/bash
set -euo pipefail

FILEICON_PATH="$1"
APP_PATH="$2"
IMAGE_PATH="$3"

EXPECTED_DIR="/usr/local/lib/iconchanger"
case "$FILEICON_PATH" in
    "$EXPECTED_DIR"/fileicon) ;;
    *)
        echo "ERROR: fileicon path is not in the expected directory ($EXPECTED_DIR)." >&2
        exit 1
        ;;
esac

case "$APP_PATH" in
    *.app|*.app/*) ;;
    *)
        echo "ERROR: APP_PATH does not appear to be a .app bundle: $APP_PATH" >&2
        exit 1
        ;;
esac

if [ ! -e "$APP_PATH" ]; then
    echo "ERROR: APP_PATH does not exist: $APP_PATH" >&2
    exit 1
fi

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
