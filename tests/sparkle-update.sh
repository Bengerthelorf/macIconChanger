#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEST_DIR="$(mktemp -d "${TMPDIR:-/tmp}/iconchanger-sparkle-test.XXXXXX")"
trap 'rm -rf "$TEST_DIR"' EXIT

mkdir -p "$TEST_DIR/IconChanger/Resources"
cp "$REPO_ROOT/scripts/update-sparkle.py" "$TEST_DIR/update-sparkle.py"

cat > "$TEST_DIR/IconChanger/Resources/sparkle.xml" <<'XML'
<?xml version="1.0" encoding="UTF-8"?>
<rss xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" version="2.0">
    <channel>
        <title>IconChanger</title>
    </channel>
</rss>
XML

cat > "$TEST_DIR/CHANGELOG.md" <<'MARKDOWN'
## What's Changed

- fix: escape <script>alert("unsafe")</script> & keep release notes readable
MARKDOWN

(
    cd "$TEST_DIR"
    SPARKLE_VERSION="2.0.0" \
    SPARKLE_BUILD="4000000000" \
    SPARKLE_PUBDATE="Mon, 27 Jul 2026 00:00:00 +0000" \
    SPARKLE_DOWNLOAD_URL="https://example.com/IconChanger.dmg" \
    SPARKLE_ED_SIG="test-signature" \
    SPARKLE_DMG_SIZE="1234" \
    SPARKLE_REPO="Bengerthelorf/macIconChanger" \
    python3 update-sparkle.py >/dev/null
)

python3 "$REPO_ROOT/scripts/validate-appcast.py" \
    "$TEST_DIR/IconChanger/Resources/sparkle.xml" \
    "2.0.0" \
    "4000000000" \
    "test-signature" \
    "1234" \
    "https://example.com/IconChanger.dmg" >/dev/null

if grep -Fq '<script>' "$TEST_DIR/IconChanger/Resources/sparkle.xml"; then
    echo "FAIL: release notes were inserted as executable markup" >&2
    exit 1
fi

grep -Fq '&lt;script&gt;alert(&quot;unsafe&quot;)&lt;/script&gt; &amp;' \
    "$TEST_DIR/IconChanger/Resources/sparkle.xml"

echo "PASS: Sparkle metadata is validated and release notes are escaped"
