#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

bash "$REPO_ROOT/tests/security-fileicon.sh"
bash "$REPO_ROOT/tests/security-helper.sh"
