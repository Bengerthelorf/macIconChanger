#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ICON_LIST="$REPO_ROOT/IconChanger/Views/IconList.swift"

if /usr/bin/grep -Fq "removeApp(" "$ICON_LIST" ||
   /usr/bin/grep -Fq "Remove the Icon from the Launchpad" "$ICON_LIST"; then
    echo "FAIL: the app still exposes an irreversible Launchpad database deletion" >&2
    exit 1
fi

echo "PASS: IconChanger no longer exposes irreversible Launchpad deletion"
