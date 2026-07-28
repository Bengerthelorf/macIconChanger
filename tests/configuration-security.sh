#!/bin/bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"

if grep -Eq 'exportConfigurationForCLI' \
    "$repo_root/IconChanger/Views/SettingsView/AdvancedSettingsView.swift" \
    "$repo_root/IconChanger/Config/ConfigManager+CLI.swift"; then
    echo "FAIL: GUI export still creates a secondary plaintext CLI export" >&2
    exit 1
fi

if grep -Eq 'latest_export\.json' "$repo_root/IconChangerCLI/IconChangerCLI.swift"; then
    echo "FAIL: CLI export still relies on a stale plaintext handoff" >&2
    exit 1
fi

grep -Eq 'includeSensitive: isEncrypted' \
    "$repo_root/IconChanger/Config/ConfigManager.swift"
grep -Eq 'def\.flags\.contains\(\.secured\) && !includeSensitive' \
    "$repo_root/IconChanger/Utilities/AppSettings.swift"
grep -Eq '\[\.posixPermissions: 0o600\]' \
    "$repo_root/IconChanger/Config/ConfigManager.swift"
grep -Eq 'removeLegacyPlaintextCLIExport\(\)' \
    "$repo_root/IconChanger/Config/ConfigManager.swift"

echo "PASS: configuration export keeps secrets encrypted and files owner-only"
