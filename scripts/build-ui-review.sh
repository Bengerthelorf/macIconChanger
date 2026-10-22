#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUTPUT_DIR="${1:-${TMPDIR:-/tmp}/iconchanger-ui-review}"
mkdir -p "$OUTPUT_DIR"
OUTPUT_DIR="$(cd "$OUTPUT_DIR" && pwd)"
APP="$OUTPUT_DIR/IconChanger UI Review.app"
BUILD_DIR="${ICONCHANGER_REVIEW_DERIVED_DATA:-$OUTPUT_DIR/Build}"

xcodebuild -project "$REPO_ROOT/IconChanger.xcodeproj" -scheme IconChanger \
    -configuration Debug -derivedDataPath "$BUILD_DIR" \
    CODE_SIGNING_ALLOWED=NO ENABLE_DEBUG_DYLIB=NO build > "$OUTPUT_DIR/build.log" 2>&1 || {
    tail -n 60 "$OUTPUT_DIR/build.log"
    exit 1
}
ditto "$BUILD_DIR/Build/Products/Debug/IconChanger.app" "$APP"
/usr/bin/plutil -replace CFBundleIdentifier -string com.zhuhaoyu.IconChanger.UIReview "$APP/Contents/Info.plist"
/usr/bin/plutil -replace CFBundleName -string 'IconChanger UI Review' "$APP/Contents/Info.plist"
/usr/bin/plutil -replace CFBundleDisplayName -string 'IconChanger UI Review' "$APP/Contents/Info.plist"
BASE_VERSION="$(git -C "$REPO_ROOT" describe --tags --abbrev=0 | sed 's/^v//')"
/usr/bin/plutil -replace CFBundleShortVersionString -string "$BASE_VERSION.ui-review" "$APP/Contents/Info.plist"
/usr/bin/codesign --force --deep --sign - --options runtime \
    --entitlements "$REPO_ROOT/IconChanger/IconChanger.ad-hoc.entitlements" "$APP"
/usr/bin/codesign --verify --deep --strict "$APP"
printf 'UI review app: %s\n' "$APP"
