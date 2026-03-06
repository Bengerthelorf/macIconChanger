#!/bin/bash
set -euo pipefail

# ==============================================================================
# IconChanger Release Script
# Usage: ./scripts/release.sh <version>
# Example: ./scripts/release.sh 1.3.0
# ==============================================================================

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_FILE="$PROJECT_DIR/IconChanger.xcodeproj/project.pbxproj"
SPARKLE_DIR="$HOME/development/Sparkle-2.8.0"
SPARKLE_XML="$PROJECT_DIR/IconChanger/Resources/sparkle.xml"
SCHEME="IconChanger"
BUILD_DIR="$PROJECT_DIR/build/release"
ARCHIVE_PATH="$BUILD_DIR/IconChanger.xcarchive"
EXPORT_DIR="$BUILD_DIR/export"
DMG_PATH="$BUILD_DIR/IconChanger.dmg"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# ==============================================================================
# Validate arguments
# ==============================================================================

VERSION="${1:-}"
if [[ -z "$VERSION" ]]; then
    error "Usage: $0 <version>  (e.g. 1.3.0)"
fi

# Validate version format
if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    error "Version must be in format X.Y.Z (e.g. 1.3.0)"
fi

# Calculate build number (remove dots: 1.3.0 -> 130)
BUILD_NUMBER=$(echo "$VERSION" | tr -d '.')

TAG="v$VERSION"

info "Preparing release: $VERSION (build $BUILD_NUMBER, tag $TAG)"

# ==============================================================================
# Pre-flight checks
# ==============================================================================

cd "$PROJECT_DIR"

# Check for uncommitted changes
if ! git diff --quiet || ! git diff --cached --quiet; then
    error "Working directory has uncommitted changes. Commit or stash first."
fi

# Check Sparkle tools
[[ -x "$SPARKLE_DIR/bin/sign_update" ]] || error "Sparkle sign_update not found at $SPARKLE_DIR/bin/sign_update"

# Check for existing tag
if git rev-parse "$TAG" >/dev/null 2>&1; then
    error "Tag $TAG already exists."
fi

# hdiutil is always available on macOS

# ==============================================================================
# Step 1: Bump version in Xcode project
# ==============================================================================

info "Bumping version to $VERSION (build $BUILD_NUMBER)..."

# Update MARKETING_VERSION (both Debug and Release configs for IconChanger target)
sed -i '' "s/MARKETING_VERSION = [0-9]*\.[0-9]*\.[0-9]*;/MARKETING_VERSION = $VERSION;/g" "$PROJECT_FILE"

# Update CURRENT_PROJECT_VERSION for the main target (skip CLI target which is 110)
# Match any build number that isn't 110
sed -i '' "/CURRENT_PROJECT_VERSION = 110;/!s/CURRENT_PROJECT_VERSION = [0-9]*;/CURRENT_PROJECT_VERSION = $BUILD_NUMBER;/g" "$PROJECT_FILE"

info "Version bumped in project file."

# ==============================================================================
# Step 2: Build and Archive
# ==============================================================================

info "Cleaning build directory..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

info "Archiving (this may take a minute)..."
xcodebuild archive \
    -project "$PROJECT_DIR/IconChanger.xcodeproj" \
    -scheme "$SCHEME" \
    -configuration Release \
    -archivePath "$ARCHIVE_PATH" \
    -quiet \
    CODE_SIGN_IDENTITY="Apple Development" \
    DEVELOPMENT_TEAM="2T53C3HYGK" \
    2>&1 | grep -E "error:|warning:" || true

if [[ ! -d "$ARCHIVE_PATH" ]]; then
    error "Archive failed. Check Xcode build logs."
fi

info "Archive succeeded."

# ==============================================================================
# Step 3: Export .app from archive
# ==============================================================================

info "Exporting .app from archive..."
mkdir -p "$EXPORT_DIR"

# Create export options plist for Development signing (no notarization needed)
cat > "$BUILD_DIR/ExportOptions.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>development</string>
    <key>teamID</key>
    <string>2T53C3HYGK</string>
</dict>
</plist>
PLIST

xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportOptionsPlist "$BUILD_DIR/ExportOptions.plist" \
    -exportPath "$EXPORT_DIR" \
    -quiet 2>&1 | grep -E "error:" || true

APP_PATH="$EXPORT_DIR/IconChanger.app"
if [[ ! -d "$APP_PATH" ]]; then
    # Fallback: extract from archive directly
    warn "exportArchive failed, extracting from archive directly..."
    cp -R "$ARCHIVE_PATH/Products/Applications/IconChanger.app" "$EXPORT_DIR/"
fi

[[ -d "$APP_PATH" ]] || error "Could not find IconChanger.app"

info "Exported: $APP_PATH"

# ==============================================================================
# Step 4: Create DMG
# ==============================================================================

info "Creating DMG..."
rm -f "$DMG_PATH"

DMG_STAGING="$BUILD_DIR/dmg_staging"
rm -rf "$DMG_STAGING"
mkdir -p "$DMG_STAGING"
cp -R "$APP_PATH" "$DMG_STAGING/"
ln -s /Applications "$DMG_STAGING/Applications"

hdiutil create \
    -volname "IconChanger" \
    -srcfolder "$DMG_STAGING" \
    -ov \
    -format UDZO \
    "$DMG_PATH" 2>&1

[[ -f "$DMG_PATH" ]] || error "DMG creation failed."
rm -rf "$DMG_STAGING"

DMG_SIZE=$(stat -f%z "$DMG_PATH")
info "DMG created: $DMG_PATH ($DMG_SIZE bytes)"

# ==============================================================================
# Step 5: Sign DMG with Sparkle EdDSA
# ==============================================================================

info "Signing DMG with Sparkle EdDSA..."
SIGNATURE=$("$SPARKLE_DIR/bin/sign_update" "$DMG_PATH" 2>&1)

# sign_update outputs: sparkle:edSignature="..." length="..."
# Extract just the signature
ED_SIGNATURE=$(echo "$SIGNATURE" | grep -o 'sparkle:edSignature="[^"]*"' | sed 's/sparkle:edSignature="//;s/"//')

if [[ -z "$ED_SIGNATURE" ]]; then
    error "Failed to get EdDSA signature. Output: $SIGNATURE"
fi

info "EdDSA signature: $ED_SIGNATURE"

# ==============================================================================
# Step 6: Update sparkle.xml appcast
# ==============================================================================

info "Updating sparkle.xml..."

PUBDATE=$(date -u "+%a, %d %b %Y %H:%M:%S +0000")
DOWNLOAD_URL="https://github.com/Bengerthelorf/macIconChanger/releases/download/$TAG/IconChanger.dmg"

# Read existing sparkle.xml and insert new item after <channel>
NEW_ITEM="        <item>
            <title>Version $VERSION</title>
            <link>https://github.com/Bengerthelorf/macIconChanger</link>
            <sparkle:version>$BUILD_NUMBER</sparkle:version>
            <sparkle:shortVersionString>$VERSION</sparkle:shortVersionString>
            <pubDate>$PUBDATE</pubDate>
            <enclosure url=\"$DOWNLOAD_URL\"
            sparkle:edSignature=\"$ED_SIGNATURE\" length=\"$DMG_SIZE\"
            type=\"application/octet-stream\"/>
            <description>
                <![CDATA[
                <h2>Version $VERSION</h2>
                <ul>
                    <li><strong>New:</strong> One-click permission setup — no more manual sudoers editing.</li>
                    <li><strong>New:</strong> Restore default app icons (fully restores macOS 26 icon features).</li>
                    <li><strong>Fix:</strong> Icons not loading when scrolling sidebar quickly.</li>
                    <li><strong>Fix:</strong> Shell injection prevention and security hardening.</li>
                    <li><strong>Fix:</strong> Thread safety and performance improvements.</li>
                    <li><strong>Perf:</strong> Replaced debug print() with os.Logger for better release performance.</li>
                </ul>
                ]]>
            </description>
        </item>"

# Insert after the <channel> + <title> line
python3 -c "
import re
with open('$SPARKLE_XML', 'r') as f:
    content = f.read()
# Insert new item after <title>IconChanger</title>
marker = '<title>IconChanger</title>'
idx = content.find(marker)
if idx == -1:
    raise Exception('Could not find channel title in sparkle.xml')
insert_pos = content.find('\n', idx) + 1
new_content = content[:insert_pos] + '''$NEW_ITEM
''' + content[insert_pos:]
with open('$SPARKLE_XML', 'w') as f:
    f.write(new_content)
print('sparkle.xml updated')
"

info "sparkle.xml updated with new release entry."

# ==============================================================================
# Step 7: Commit, tag, and push
# ==============================================================================

info "Committing version bump and appcast update..."
git add -f "$PROJECT_FILE" "$SPARKLE_XML" "$PROJECT_DIR/IconChanger/Info.plist" "$PROJECT_DIR/IconChanger/sparkle.xml"
git commit -m "release: v$VERSION

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"

git tag -a "$TAG" -m "IconChanger v$VERSION"

info "Pushing to remote..."
git push
git push origin "$TAG"

# ==============================================================================
# Step 8: Create GitHub Release
# ==============================================================================

info "Creating GitHub Release..."
gh release create "$TAG" \
    --title "IconChanger v$VERSION" \
    --notes "$(cat <<NOTES
- **New:** One-click permission setup — no more manual sudoers editing
- **New:** Restore default app icons (fully restores macOS 26 icon features)
- **Fix:** Icons not loading when scrolling sidebar quickly
- **Fix:** Shell injection prevention and security hardening
- **Fix:** Thread safety and performance improvements
- **Perf:** Replaced debug print() with os.Logger for better release performance
NOTES
)" \
    "$DMG_PATH"

RELEASE_URL="https://github.com/Bengerthelorf/macIconChanger/releases/tag/$TAG"
info "============================================"
info "Release $VERSION published!"
info "$RELEASE_URL"
info "============================================"
info ""
info "Sparkle appcast has been pushed. Existing users"
info "will receive the update automatically."
