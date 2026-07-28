#!/bin/bash
set -euo pipefail

if [[ "${1:-}" == "--self-test" ]]; then
    if [[ "$#" -ne 1 ]]; then
        echo "ERROR: --self-test does not accept additional arguments." >&2
        exit 64
    fi
    echo "IconChanger helper ready"
    exit 0
fi

MODE="set"
if [[ "${1:-}" == "--remove" ]]; then
    MODE="remove"
    shift
fi

if [[ "$MODE" == "set" && "$#" -ne 3 ]]; then
    echo "Usage: helper.sh FILEICON_PATH APP_PATH IMAGE_PATH" >&2
    exit 64
fi
if [[ "$MODE" == "remove" && "$#" -ne 2 ]]; then
    echo "Usage: helper.sh --remove FILEICON_PATH APP_PATH" >&2
    exit 64
fi

FILEICON_PATH="$1"
APP_PATH="$2"
IMAGE_PATH="${3:-}"

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

if [ ! -d "$APP_PATH" ]; then
    echo "ERROR: APP_PATH does not exist: $APP_PATH" >&2
    exit 1
fi

if [ -L "$APP_PATH" ]; then
    echo "ERROR: APP_PATH must not be a symbolic link." >&2
    exit 1
fi

APP_PATH="$(/bin/realpath "$APP_PATH")"
case "$APP_PATH" in
    *.app) ;;
    *)
        echo "ERROR: APP_PATH is not a .app bundle: $APP_PATH" >&2
        exit 1
        ;;
esac

# User-owned apps can live in custom folders. Root-owned targets are restricted
# to standard application roots so the NOPASSWD helper cannot mutate arbitrary
# privileged directories merely named with an .app suffix.
CALLER_UID="${SUDO_UID:-$(/usr/bin/id -u)}"
APP_OWNER_UID="$(/usr/bin/stat -f '%u' "$APP_PATH")"
if [[ "$APP_OWNER_UID" != "$CALLER_UID" ]]; then
    case "$APP_PATH" in
        /Applications/*.app|/System/Applications/*.app|/System/Applications/Utilities/*.app) ;;
        *)
            echo "ERROR: privileged app target is outside an approved application directory." >&2
            exit 1
            ;;
    esac
fi

if [[ "$MODE" == "set" ]]; then
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
fi

if [ ! -x "$FILEICON_PATH" ]; then
    echo "ERROR: fileicon is not executable: $FILEICON_PATH" >&2
    exit 1
fi

if [[ "$MODE" == "remove" ]]; then
    "$FILEICON_PATH" rm "$APP_PATH"
else
    "$FILEICON_PATH" set "$APP_PATH" "$IMAGE_PATH"
fi
