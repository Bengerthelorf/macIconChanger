#!/bin/bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"

if rg -q 'exportConfigurationForCLI' \
    "$repo_root/IconChanger/Views/SettingsView/AdvancedSettingsView.swift" \
    "$repo_root/IconChanger/Config/ConfigManager+CLI.swift"; then
    echo "FAIL: GUI export still creates a secondary plaintext CLI export" >&2
    exit 1
fi

if rg -q 'latest_export\.json' "$repo_root/IconChangerCLI/IconChangerCLI.swift"; then
    echo "FAIL: CLI export still relies on a stale plaintext handoff" >&2
    exit 1
fi

rg -q 'includeSensitive: isEncrypted' \
    "$repo_root/IconChanger/Config/ConfigManager.swift"
rg -q 'def\.flags\.contains\(\.secured\) && !includeSensitive' \
    "$repo_root/IconChanger/Utilities/AppSettings.swift"
rg -q '\[\.posixPermissions: 0o600\]' \
    "$repo_root/IconChanger/Config/ConfigManager.swift"

echo "PASS: configuration export keeps secrets encrypted and files owner-only"
