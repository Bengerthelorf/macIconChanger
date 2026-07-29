#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CI_WORKFLOW="$REPO_ROOT/.github/workflows/build.yml"
CANDIDATE_WORKFLOW="$REPO_ROOT/.github/workflows/release-candidate.yml"
PUBLISH_WORKFLOW="$REPO_ROOT/.github/workflows/publish-release.yml"
SPARKLE_PAGES_WORKFLOW="$REPO_ROOT/.github/workflows/sparkle-pages.yml"
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
[[ -f "$SPARKLE_PAGES_WORKFLOW" ]] ||
    fail "public Sparkle feed deployment workflow is missing"
[[ -f "$DMG_SETTINGS" ]] || fail "deterministic DMG settings are missing"
[[ -f "$DMG_BACKGROUND" ]] || fail "DMG background asset is missing"
[[ -f "$DMG_BACKGROUND_RETINA" ]] || fail "Retina DMG background asset is missing"

if /usr/bin/grep -Fq "tags:" "$CI_WORKFLOW" ||
   /usr/bin/grep -Fq "action-gh-release" "$CI_WORKFLOW"; then
    fail "ordinary CI must not publish releases from a pushed tag"
fi
/usr/bin/grep -Fq "Repository Apple Development signing check" "$CI_WORKFLOW" ||
    fail "manual CI must test the repository signing certificate"
/usr/bin/grep -Fq 'CERTIFICATE_P12: ${{ secrets.CERTIFICATE_P12 }}' \
    "$CI_WORKFLOW" ||
    fail "manual CI signing check must use the repository certificate secret"
/usr/bin/grep -Fq "github.event_name == 'workflow_dispatch'" "$CI_WORKFLOW" ||
    fail "repository signing certificate checks must be manually triggered"

/usr/bin/grep -Fq "workflow_dispatch:" "$CANDIDATE_WORKFLOW" ||
    fail "candidate builds must be manually dispatched"
/usr/bin/grep -Fq "signing_mode:" "$CANDIDATE_WORKFLOW" ||
    fail "candidate workflow must expose an explicit signing mode"
/usr/bin/grep -Fq "default: auto" "$CANDIDATE_WORKFLOW" ||
    fail "candidate workflow must safely select signing automatically"
/usr/bin/grep -Fq 'CERTIFICATE_P12: ${{ secrets.CERTIFICATE_P12 }}' \
    "$CANDIDATE_WORKFLOW" ||
    fail "candidate workflow must import the existing Apple Development certificate"
/usr/bin/grep -Fq 'CERTIFICATE_PASSWORD: ${{ secrets.CERTIFICATE_PASSWORD }}' \
    "$CANDIDATE_WORKFLOW" ||
    fail "candidate workflow must unlock the existing signing certificate"
/usr/bin/grep -Fq "openssl x509 -checkend 0" "$CANDIDATE_WORKFLOW" ||
    fail "candidate workflow must reject an expired signing certificate"
/usr/bin/grep -Fq 'codesign --verify --strict "$SIGNING_PROBE"' \
    "$CANDIDATE_WORKFLOW" ||
    fail "candidate workflow must prove the certificate can sign executable code"
/usr/bin/grep -Fq 'bash scripts/create-signing-probe.sh "$SIGNING_PROBE"' \
    "$CI_WORKFLOW" ||
    fail "manual CI must build its own signing probe"
/usr/bin/grep -Fq 'bash scripts/create-signing-probe.sh "$SIGNING_PROBE"' \
    "$CANDIDATE_WORKFLOW" ||
    fail "candidate workflow must build its own signing probe"
/usr/bin/grep -Fq "security verify-cert" "$CI_WORKFLOW" ||
    fail "manual CI must validate the certificate trust chain"
/usr/bin/grep -Fq "security verify-cert" "$CANDIDATE_WORKFLOW" ||
    fail "candidate workflow must validate the certificate trust chain"
/usr/bin/grep -Fq -- "-R ocsp" "$CI_WORKFLOW" ||
    fail "manual CI must check Apple certificate revocation status"
/usr/bin/grep -Fq -- "-R ocsp" "$CANDIDATE_WORKFLOW" ||
    fail "candidate workflow must check Apple certificate revocation status"
if /usr/bin/grep -Fq "ditto /usr/bin/true" "$CI_WORKFLOW" ||
   /usr/bin/grep -Fq "ditto /usr/bin/true" "$CANDIDATE_WORKFLOW"; then
    fail "signing checks must not copy a SIP-protected system executable"
fi
/usr/bin/grep -Fq "select-signing-identity.py" "$CANDIDATE_WORKFLOW" ||
    fail "candidate workflow must reject revoked Apple Development identities"
/usr/bin/grep -Fq 'CODE_SIGN_IDENTITY="$SIGNING_IDENTITY"' \
    "$CANDIDATE_WORKFLOW" ||
    fail "candidate workflow must build with the imported Apple Development identity"
/usr/bin/grep -Fq -- '--entitlements "$SIGNING_ENTITLEMENTS"' \
    "$CANDIDATE_WORKFLOW" ||
    fail "candidate workflow must re-sign the ad-hoc app with release entitlements"
/usr/bin/grep -Fq "validate-launchable-executable.sh" "$CANDIDATE_WORKFLOW" ||
    fail "candidate workflow must prove the built application can launch"
/usr/bin/grep -Fq "codesign --verify" "$CANDIDATE_WORKFLOW" ||
    fail "candidate workflow must verify its app signature"
/usr/bin/grep -Fq "actions/upload-artifact@" "$CANDIDATE_WORKFLOW" ||
    fail "candidate workflow must upload testable artifacts"

if /usr/bin/grep -Fq "hide_extensions" "$DMG_SETTINGS"; then
    fail "DMG layout must not add FinderInfo metadata to the signed app"
fi

if /usr/bin/grep -Eq \
    'notarytool|stapler|APPLE_ID|APPLE_TEAM_ID|Developer ID|spctl' \
    "$CANDIDATE_WORKFLOW"; then
    fail "candidate workflow must not require a paid Apple developer account"
fi

/usr/bin/grep -Fq "workflow_dispatch:" "$PUBLISH_WORKFLOW" ||
    fail "publishing must require a manual dispatch"
/usr/bin/grep -Fq "actions: write" "$PUBLISH_WORKFLOW" ||
    fail "publishing must be allowed to dispatch the docs workflow"
/usr/bin/grep -Fq "workflow run sparkle-pages.yml" "$PUBLISH_WORKFLOW" ||
    fail "publishing must dispatch the public Sparkle feed deployment"
if /usr/bin/grep -Fq "pages/builds" "$PUBLISH_WORKFLOW"; then
    fail "workflow-based Pages sites must not use the legacy Pages build API"
fi
/usr/bin/grep -Fq "candidate_run_id" "$PUBLISH_WORKFLOW" ||
    fail "publishing must promote a specific tested candidate"
/usr/bin/grep -Fq "I_APPROVE_RELEASE" "$PUBLISH_WORKFLOW" ||
    fail "publishing must require explicit confirmation"
/usr/bin/grep -Fq "actions/download-artifact@" "$PUBLISH_WORKFLOW" ||
    fail "publishing must download the exact candidate artifact"
/usr/bin/grep -Fq "jq -er '.prerelease | tostring'" "$PUBLISH_WORKFLOW" ||
    fail "publishing must accept a stable candidate with prerelease=false"
/usr/bin/grep -Fq 'releases/download/${TAG}/IconChanger.dmg' "$PUBLISH_WORKFLOW" ||
    fail "appcast validation must check the published download URL"

/usr/bin/grep -Fq "workflow_dispatch:" "$SPARKLE_PAGES_WORKFLOW" ||
    fail "the public Sparkle feed deployment must support explicit dispatch"
/usr/bin/grep -Fq "pages: write" "$SPARKLE_PAGES_WORKFLOW" ||
    fail "the Sparkle Pages deployment needs Pages write permission"
/usr/bin/grep -Fq "id-token: write" "$SPARKLE_PAGES_WORKFLOW" ||
    fail "the Sparkle Pages deployment needs OIDC permission"
/usr/bin/grep -Fq "actions/upload-pages-artifact@" "$SPARKLE_PAGES_WORKFLOW" ||
    fail "the Sparkle Pages deployment must upload a Pages artifact"
/usr/bin/grep -Fq "actions/deploy-pages@" "$SPARKLE_PAGES_WORKFLOW" ||
    fail "the Sparkle Pages deployment must deploy the Pages artifact"

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
