#!/bin/bash
set -euo pipefail

# ==============================================================================
# IconChanger Release Script (local steps only)
# Usage: ./scripts/release.sh <version>
# Example: ./scripts/release.sh 1.4.0
#
# This script bumps the version, commits, tags, and pushes.
# GitHub Actions handles the rest: build, DMG, Sparkle sign, release.
# ==============================================================================

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_FILE="$PROJECT_DIR/IconChanger.xcodeproj/project.pbxproj"
SCHEME="IconChanger"

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
    error "Usage: $0 <version>  (e.g. 1.4.0)"
fi

if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    error "Version must be in format X.Y.Z (e.g. 1.4.0)"
fi

BUILD_NUMBER=$(python3 "$PROJECT_DIR/scripts/build-number.py" "$VERSION")
TAG="v$VERSION"

info "Preparing release: $VERSION (build $BUILD_NUMBER, tag $TAG)"

# ==============================================================================
# Pre-flight checks
# ==============================================================================

cd "$PROJECT_DIR"

if ! git diff --quiet || ! git diff --cached --quiet; then
    error "Working directory has uncommitted changes. Commit or stash first."
fi

if git rev-parse "$TAG" >/dev/null 2>&1; then
    error "Tag $TAG already exists."
fi

# ==============================================================================
# Step 1: Bump version in Xcode project
# ==============================================================================

info "Bumping version to $VERSION (build $BUILD_NUMBER)..."

sed -i '' "s/MARKETING_VERSION = [0-9]*\.[0-9]*\.[0-9]*;/MARKETING_VERSION = $VERSION;/g" "$PROJECT_FILE"

# Update CURRENT_PROJECT_VERSION for the main target (skip CLI target which is 110)
sed -i '' "/CURRENT_PROJECT_VERSION = 110;/!s/CURRENT_PROJECT_VERSION = [0-9]*;/CURRENT_PROJECT_VERSION = $BUILD_NUMBER;/g" "$PROJECT_FILE"

info "Version bumped in project file."

# ==============================================================================
# Step 2: Commit, tag, and push
# ==============================================================================

info "Committing version bump..."
git add -f "$PROJECT_FILE"
git commit -m "release: v$VERSION"

git tag -a "$TAG" -m "IconChanger v$VERSION"

info "Pushing to remote..."
git push origin main
git push origin "$TAG"

info "============================================"
info "Tag $TAG pushed!"
info "GitHub Actions will now build, sign, and publish the release."
info "Monitor at: https://github.com/Bengerthelorf/macIconChanger/actions"
info "============================================"
