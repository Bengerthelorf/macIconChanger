#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SETTINGS_VIEW="$REPO_ROOT/IconChanger/Views/SettingsView/SettingsView.swift"
ADVANCED_VIEW="$REPO_ROOT/IconChanger/Views/SettingsView/AdvancedSettingsView.swift"
DEVELOPER_VIEW="$REPO_ROOT/IconChanger/Views/SettingsView/DeveloperSettingsView.swift"

grep -q '@AppStorage("t2e") private var developerModeEnabled' "$SETTINGS_VIEW"
grep -q 'if developerModeEnabled' "$SETTINGS_VIEW"
grep -q 'DeveloperSettingsView()' "$SETTINGS_VIEW"
grep -q 'Label("Developer", systemImage: "hammer")' "$SETTINGS_VIEW"

if grep -q 'DiagnosticsSettings\\|Additional API Keys\\|Disable Developer Mode' "$ADVANCED_VIEW"; then
    echo "FAIL: developer-only settings must not remain in AdvancedSettingsView"
    exit 1
fi

grep -q 'Toggle("Setup and Helper"' "$DEVELOPER_VIEW"
grep -q 'Toggle("Permissions"' "$DEVELOPER_VIEW"
grep -q 'Toggle("Background and Update Detection"' "$DEVELOPER_VIEW"
grep -q 'Toggle("Application Discovery"' "$DEVELOPER_VIEW"
grep -q 'Toggle("Cache and Storage"' "$DEVELOPER_VIEW"
grep -q 'Toggle("Network and API"' "$DEVELOPER_VIEW"
grep -q 'Toggle("Helper Process Output"' "$DEVELOPER_VIEW"
grep -q 'Button("Record System Snapshot")' "$DEVELOPER_VIEW"

echo "PASS: developer settings are isolated in a developer-only peer tab"
