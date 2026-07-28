#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

bash "$REPO_ROOT/tests/security-fileicon.sh"
bash "$REPO_ROOT/tests/security-helper.sh"
bash "$REPO_ROOT/tests/background-schedule.sh"
bash "$REPO_ROOT/tests/setup-health.sh"
bash "$REPO_ROOT/tests/icon-interactions.sh"
bash "$REPO_ROOT/tests/sudo-permission-probe.sh"
bash "$REPO_ROOT/tests/no-launchpad-mutation.sh"
bash "$REPO_ROOT/tests/build-number.sh"
bash "$REPO_ROOT/tests/signing-selection.sh"
bash "$REPO_ROOT/tests/adhoc-release.sh"
bash "$REPO_ROOT/tests/release-automation.sh"
bash "$REPO_ROOT/tests/sparkle-update.sh"
bash "$REPO_ROOT/tests/remote-image-policy.sh"
