#!/bin/bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="${1:-}"
SOURCE_REF="${2:-$(git -C "$PROJECT_DIR" branch --show-current)}"

if [[ -z "$VERSION" || -z "$SOURCE_REF" ]]; then
    echo "Usage: $0 <version> [branch-or-commit]" >&2
    exit 1
fi

python3 "$PROJECT_DIR/scripts/build-number.py" "$VERSION" >/dev/null

if ! git -C "$PROJECT_DIR" diff --quiet ||
   ! git -C "$PROJECT_DIR" diff --cached --quiet; then
    echo "Working tree must be clean before building a release candidate." >&2
    exit 1
fi

gh auth status >/dev/null
gh workflow run release-candidate.yml \
    --repo Bengerthelorf/macIconChanger \
    -f "version=$VERSION" \
    -f "ref=$SOURCE_REF"

echo "Release candidate requested for $VERSION from $SOURCE_REF."
echo "This does not create a tag or publish a release."
echo "After testing the downloaded candidate, run Publish Tested Release manually."
