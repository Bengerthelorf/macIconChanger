#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_NUMBER="$REPO_ROOT/scripts/build-number.py"

fail() {
    echo "FAIL: $1" >&2
    exit 1
}

build() {
    python3 "$BUILD_NUMBER" "$1"
}

[[ "$(build 1.5.0-alpha.1)" == "40105001001" ]] ||
    fail "alpha build number is not encoded in the expected stage"
[[ "$(build 1.5.0-beta.1)" == "40105003001" ]] ||
    fail "beta build number is not encoded in the expected stage"
[[ "$(build 1.5.0-pre.1)" == "40105005001" ]] ||
    fail "pre build number is not encoded in the expected stage"
[[ "$(build 1.5.1-pre.1.fix.1)" == "40105016101" ]] ||
    fail "preview hotfix build number is not encoded after the preview stage"
[[ "$(build 1.5.0-rc.1)" == "40105007001" ]] ||
    fail "release candidate build number is not encoded in the expected stage"
[[ "$(build 1.5.0)" == "40105009000" ]] ||
    fail "stable build number is not encoded in the expected stage"

alpha="$(build 1.5.0-alpha.1)"
beta="$(build 1.5.0-beta.1)"
pre="$(build 1.5.0-pre.1)"
rc="$(build 1.5.0-rc.1)"
stable="$(build 1.5.0)"
next_patch="$(build 1.5.1-alpha.1)"

(( alpha < beta )) || fail "alpha must sort before beta"
(( beta < pre )) || fail "beta must sort before pre"
(( pre < rc )) || fail "pre must sort before release candidate"
(( rc < stable )) || fail "release candidate must sort before stable"
(( stable < next_patch )) || fail "stable must sort before the next patch prerelease"
(( 3014470009 < alpha )) || fail "new scheme must migrate above the current public build"

preview_fix="$(build 1.5.1-pre.1.fix.1)"
preview_base="$(build 1.5.1-pre.1)"
preview_rc="$(build 1.5.1-rc.1)"
(( preview_base < preview_fix )) ||
    fail "preview hotfix must sort after its published preview"
(( preview_fix < preview_rc )) ||
    fail "preview hotfix must sort before the release candidate"

[[ "$(build 1.5.0-pre-1)" == "$pre" ]] ||
    fail "legacy pre separator must remain accepted"
[[ "$(build 1.5.0-8)" == "40105009008" ]] ||
    fail "legacy stable revision must remain accepted"
[[ "$(build 1.10.0)" == "40110009000" ]] ||
    fail "multi-digit minor versions must not collide with major versions"

if build 1.5.0-pre.1000 >/dev/null 2>&1; then
    fail "prerelease sequences above 999 must be rejected"
fi
if build 1.100.0 >/dev/null 2>&1; then
    fail "version components above 99 must be rejected"
fi
if build 1.5 >/dev/null 2>&1; then
    fail "malformed versions must be rejected"
fi

echo "PASS: build numbers preserve Sparkle release ordering"
