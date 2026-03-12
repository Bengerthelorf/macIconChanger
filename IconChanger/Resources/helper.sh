#!/bin/bash
# helper.sh — Root-privileged helper for IconChanger.
# This script is installed to /usr/local/lib/iconchanger/ with root:wheel
# ownership and invoked via NOPASSWD sudo. Input validation is critical
# because it runs with elevated privileges.

set -euo pipefail

FILEICON_PATH="$1"
APP_PATH="$2"
IMAGE_PATH="$3"

# --- Input validation ---

# 1. Verify fileicon lives in the expected install directory.
EXPECTED_DIR="/usr/local/lib/iconchanger"
case "$FILEICON_PATH" in
    "$EXPECTED_DIR"/fileicon) ;;
    *)
        echo "ERROR: fileicon path is not in the expected directory ($EXPECTED_DIR)." >&2
        exit 1
        ;;
esac

# 2. Verify the app path ends with .app and exists.
case "$APP_PATH" in
    *.app) ;;
    *.app/*) ;;  # Allow paths inside .app bundles (e.g., for .icns files passed as image)
    *)
        echo "ERROR: APP_PATH does not appear to be a .app bundle: $APP_PATH" >&2
        exit 1
        ;;
esac

if [ ! -e "$APP_PATH" ]; then
    echo "ERROR: APP_PATH does not exist: $APP_PATH" >&2
    exit 1
fi

# 3. Verify the image file exists and has an expected extension.
if [ ! -f "$IMAGE_PATH" ]; then
    echo "ERROR: IMAGE_PATH does not exist or is not a file: $IMAGE_PATH" >&2
    exit 1
fi

case "$IMAGE_PATH" in
    *.png|*.PNG|*.icns|*.ICNS|*.jpg|*.JPG|*.jpeg|*.JPEG|*.tiff|*.TIFF)
        ;;
    *)
        echo "ERROR: IMAGE_PATH does not have a recognized image extension: $IMAGE_PATH" >&2
        exit 1
        ;;
esac

# 4. Verify fileicon is actually executable.
if [ ! -x "$FILEICON_PATH" ]; then
    echo "ERROR: fileicon is not executable: $FILEICON_PATH" >&2
    exit 1
fi

# --- Execute ---
"$FILEICON_PATH" set "$APP_PATH" "$IMAGE_PATH"
