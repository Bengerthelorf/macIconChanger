#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CI_WORKFLOW="$REPO_ROOT/.github/workflows/build.yml"
CANDIDATE_WORKFLOW="$REPO_ROOT/.github/workflows/release-candidate.yml"
PUBLISH_WORKFLOW="$REPO_ROOT/.github/workflows/publish-release.yml"
RELEASE_SCRIPT="$REPO_ROOT/scripts/release.sh"
DMG_SETTINGS="$REPO_ROOT/scripts/dmg-settings.py"
DMG_BACKGROUND="$REPO_ROOT/assets/dmg/background.png"
DMG_BACKGROUND_RETINA="$REPO_ROOT/assets/dmg/background@2x.png"

fail() {
    echo "FAIL: $1" >&2
    exit 1
}

[[ -f "$CANDIDATE_WORKFLOW" ]] || fail "release candidate workflow is missing"
[[ -f "$PUBLISH_WORKFLOW" ]] || fail "manual publish workflow is missing"
[[ -f "$DMG_SETTINGS" ]] || fail "deterministic DMG settings are missing"
[[ -f "$DMG_BACKGROUND" ]] || fail "DMG background asset is missing"
[[ -f "$DMG_BACKGROUND_RETINA" ]] || fail "Retina DMG background asset is missing"

if /usr/bin/grep -Fq "tags:" "$CI_WORKFLOW" ||
   /usr/bin/grep -Fq "action-gh-release" "$CI_WORKFLOW"; then
    fail "ordinary CI must not publish releases from a pushed tag"
fi

/usr/bin/grep -Fq "workflow_dispatch:" "$CANDIDATE_WORKFLOW" ||
    fail "candidate builds must be manually dispatched"
/usr/bin/grep -Fq 'CODE_SIGN_IDENTITY="-"' "$CANDIDATE_WORKFLOW" ||
    fail "candidate workflow must use repeatable local signing"
/usr/bin/grep -Fq "codesign --verify" "$CANDIDATE_WORKFLOW" ||
    fail "candidate workflow must verify its app signature"
/usr/bin/grep -Fq "actions/upload-artifact@" "$CANDIDATE_WORKFLOW" ||
    fail "candidate workflow must upload testable artifacts"

if /usr/bin/grep -Fq "hide_extensions" "$DMG_SETTINGS"; then
    fail "DMG layout must not add FinderInfo metadata to the signed app"
fi

if /usr/bin/grep -Eq \
    'notarytool|stapler|APPLE_ID|APPLE_TEAM_ID|CERTIFICATE_P12|Developer ID|spctl' \
    "$CANDIDATE_WORKFLOW"; then
    fail "candidate workflow must not require a paid Apple developer account"
fi

/usr/bin/grep -Fq "workflow_dispatch:" "$PUBLISH_WORKFLOW" ||
    fail "publishing must require a manual dispatch"
/usr/bin/grep -Fq "candidate_run_id" "$PUBLISH_WORKFLOW" ||
    fail "publishing must promote a specific tested candidate"
/usr/bin/grep -Fq "I_APPROVE_RELEASE" "$PUBLISH_WORKFLOW" ||
    fail "publishing must require explicit confirmation"
/usr/bin/grep -Fq "actions/download-artifact@" "$PUBLISH_WORKFLOW" ||
    fail "publishing must download the exact candidate artifact"
/usr/bin/grep -Fq 'releases/download/${TAG}/IconChanger.dmg' "$PUBLISH_WORKFLOW" ||
    fail "appcast validation must check the published download URL"

if /usr/bin/grep -Eq 'git (tag|push)|gh release create' "$RELEASE_SCRIPT"; then
    fail "local candidate preparation must not tag, push, or publish"
fi

dimensions="$(sips -g pixelWidth -g pixelHeight "$DMG_BACKGROUND" 2>/dev/null)"
[[ "$dimensions" == *"pixelWidth: 660"* &&
   "$dimensions" == *"pixelHeight: 420"* ]] ||
    fail "DMG background must be 660x420"

retina_dimensions="$(
    sips -g pixelWidth -g pixelHeight "$DMG_BACKGROUND_RETINA" 2>/dev/null
)"
[[ "$retina_dimensions" == *"pixelWidth: 1320"* &&
   "$retina_dimensions" == *"pixelHeight: 840"* ]] ||
    fail "Retina DMG background must be 1320x840"

echo "PASS: release automation separates tested candidates from manual publishing"
