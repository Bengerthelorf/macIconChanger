#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SELECTOR="$REPO_ROOT/scripts/select-signing-identity.py"
VALID_HASH="0123456789ABCDEF0123456789ABCDEF01234567"

fail() {
    echo "FAIL: $1" >&2
    exit 1
}

valid_report="  1) $VALID_HASH \"Apple Development: Example Developer (ABCDEFGHIJ)\""$'\n'
valid_report+="     1 valid identities found"
revoked_report="  1) $VALID_HASH \"Apple Development: Example Developer (ABCDEFGHIJ)\" (CSSMERR_TP_CERT_REVOKED)"$'\n'
revoked_report+="     1 valid identities found"

actual="$(
    printf '%s\n' "$valid_report" |
        python3 "$SELECTOR" --mode auto
)"
[[ "$actual" == "$VALID_HASH" ]] ||
    fail "auto mode must use a valid Apple Development identity"

actual="$(
    printf '%s\n' "$revoked_report" |
        python3 "$SELECTOR" --mode auto
)"
[[ "$actual" == "-" ]] ||
    fail "auto mode must fall back to ad-hoc for a revoked identity"

actual="$(
    printf '%s\n' "$valid_report" |
        python3 "$SELECTOR" --mode adhoc
)"
[[ "$actual" == "-" ]] ||
    fail "explicit ad-hoc mode must ignore available identities"

if printf '%s\n' "$revoked_report" |
    python3 "$SELECTOR" --mode apple-development >/dev/null 2>&1; then
    fail "explicit Apple Development mode must reject a revoked identity"
fi

echo "PASS: signing selection rejects revoked Apple Development identities"
