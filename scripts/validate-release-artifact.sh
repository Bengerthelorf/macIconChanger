#!/bin/bash
set -euo pipefail

DMG_PATH="${1:-}"
EXPECTED_VERSION="${2:-}"
EXPECTED_BUILD="${3:-}"

if [[ -z "$DMG_PATH" || -z "$EXPECTED_VERSION" || -z "$EXPECTED_BUILD" ]]; then
    echo "Usage: $0 <IconChanger.dmg> <version> <build>" >&2
    exit 1
fi

[[ -f "$DMG_PATH" ]] || {
    echo "DMG does not exist: $DMG_PATH" >&2
    exit 1
}

hdiutil verify "$DMG_PATH"
codesign --verify --strict --verbose=4 "$DMG_PATH"

MOUNT_INFO="$(mktemp "${TMPDIR:-/tmp}/iconchanger-mount.XXXXXX.plist")"
MOUNT_POINT=""

cleanup() {
    if [[ -n "$MOUNT_POINT" ]]; then
        hdiutil detach "$MOUNT_POINT" >/dev/null 2>&1 || true
    fi
    rm -f "$MOUNT_INFO"
}
trap cleanup EXIT

hdiutil attach -readonly -nobrowse -plist "$DMG_PATH" > "$MOUNT_INFO"
MOUNT_POINT="$(
    python3 - "$MOUNT_INFO" <<'PY'
import plistlib
import sys

with open(sys.argv[1], "rb") as handle:
    payload = plistlib.load(handle)

for entity in payload.get("system-entities", []):
    mount_point = entity.get("mount-point")
    if mount_point:
        print(mount_point)
        break
PY
)"

[[ -n "$MOUNT_POINT" ]] || {
    echo "Could not determine DMG mount point." >&2
    exit 1
}

APP_PATH="$MOUNT_POINT/IconChanger.app"
[[ -d "$APP_PATH" ]] || {
    echo "IconChanger.app is missing from the DMG." >&2
    exit 1
}
[[ -L "$MOUNT_POINT/Applications" ]] || {
    echo "Applications drop link is missing from the DMG." >&2
    exit 1
}

codesign --verify --deep --strict --verbose=4 "$APP_PATH"

ACTUAL_VERSION=$(
    /usr/libexec/PlistBuddy \
        -c "Print :CFBundleShortVersionString" \
        "$APP_PATH/Contents/Info.plist"
)
ACTUAL_BUILD=$(
    /usr/libexec/PlistBuddy \
        -c "Print :CFBundleVersion" \
        "$APP_PATH/Contents/Info.plist"
)

[[ "$ACTUAL_VERSION" == "$EXPECTED_VERSION" ]] || {
    echo "Expected version $EXPECTED_VERSION, found $ACTUAL_VERSION." >&2
    exit 1
}
[[ "$ACTUAL_BUILD" == "$EXPECTED_BUILD" ]] || {
    echo "Expected build $EXPECTED_BUILD, found $ACTUAL_BUILD." >&2
    exit 1
}

echo "Release artifact passed signature, layout, and version checks."
