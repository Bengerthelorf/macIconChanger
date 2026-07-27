#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

bash "$REPO_ROOT/tests/security-fileicon.sh"
bash "$REPO_ROOT/tests/security-helper.sh"
bash "$REPO_ROOT/tests/background-schedule.sh"
bash "$REPO_ROOT/tests/setup-health.sh"
