//
//  DeveloperSettingsView.swift
//  IconChanger
//

import SwiftUI

private struct DeveloperAPIKey: Identifiable {
    let id = UUID()
    var value: String
}

private struct DeveloperMaskedKeyField: View {
    @Binding var text: String
    @State private var isEditing = false
    @FocusState private var isFocused: Bool

    var body: some View {
        Group {
            if isEditing {
                TextField("API Key", text: $text)
                    .focused($isFocused)
                    .onChange(of: isFocused) { focused in
                        if !focused { isEditing = false }
                    }
            } else {
                Text(maskedText)
                    .foregroundColor(text.isEmpty ? .secondary : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isEditing = true
                        DispatchQueue.main.async { isFocused = true }
                    }
            }
        }
        .textFieldStyle(.roundedBorder)
    }

    private var maskedText: String {
        guard text.count > 10 else {
            return text.isEmpty ? "API Key" : text
        }
        return "\(text.prefix(6))...\(text.suffix(5))"
    }
}

struct DeveloperSettingsView: View {
    @AppStorage("t2e") private var developerModeEnabled = false
    @AppStorage(DiagnosticsSettings.enabled) private var diagnosticsEnabled = false

    @AppStorage(DiagnosticsSettings.recordReplace) private var recordReplace = true
    @AppStorage(DiagnosticsSettings.recordRestore) private var recordRestore = true
    @AppStorage(DiagnosticsSettings.recordRemove) private var recordRemove = true
    @AppStorage(DiagnosticsSettings.recordAppearance) private var recordAppearance = true
    @AppStorage(DiagnosticsSettings.recordSetup) private var recordSetup = true
    @AppStorage(DiagnosticsSettings.recordPermission) private var recordPermission = true
    @AppStorage(DiagnosticsSettings.recordBackground) private var recordBackground = true
    @AppStorage(DiagnosticsSettings.recordDiscovery) private var recordDiscovery = true
    @AppStorage(DiagnosticsSettings.recordCache) private var recordCache = true
    @AppStorage(DiagnosticsSettings.recordNetwork) private var recordNetwork = true

    @AppStorage(DiagnosticsSettings.recordSteps) private var recordSteps = true
    @AppStorage(DiagnosticsSettings.recordPerformance) private var recordPerformance = true
    @AppStorage(DiagnosticsSettings.recordFailures) private var recordFailures = true
    @AppStorage(DiagnosticsSettings.recordSkipped) private var recordSkipped = true

    @AppStorage(DiagnosticsSettings.includeAppNames) private var includeAppNames = true
    @AppStorage(DiagnosticsSettings.includeAppPaths) private var includeAppPaths = true
    @AppStorage(DiagnosticsSettings.includeIconDetails) private var includeIconDetails = false
    @AppStorage(DiagnosticsSettings.includeIconPaths) private var includeIconPaths = false
    @AppStorage(DiagnosticsSettings.includeErrorMessages) private var includeErrorMessages = true
    @AppStorage(DiagnosticsSettings.includeProcessOutput) private var includeProcessOutput = false
    @AppStorage(DiagnosticsSettings.includeSystemInfo) private var includeSystemInfo = true

    @State private var extraAPIKeys = APIKeyManager.loadExtraKeys().map {
        DeveloperAPIKey(value: $0)
    }
    @State private var newAPIKey = ""
    @State private var keyTestResults: [UUID: (success: Bool, message: String)] = [:]
    @State private var testingKeyIDs: Set<UUID> = []
    @State private var showDisableConfirmation = false
    @State private var showClearConfirmation = false
    @State private var diagnosticsFileSize =
        DiagnosticsLogger.shared.fileSizeDescription()

    var body: some View {
        Form {
            Section {
                Toggle("Enable Diagnostics Log", isOn: $diagnosticsEnabled)
                    .onChange(of: diagnosticsEnabled) { _ in
                        refreshDiagnosticsFileSize()
                    }

                if diagnosticsEnabled {
                    DisclosureGroup("Icon Operations") {
                        Toggle("Icon Replacement", isOn: $recordReplace)
                        Toggle("Cached Icon Restore", isOn: $recordRestore)
                        Toggle("Restore Default Icon", isOn: $recordRemove)
                        Toggle("Automatic Appearance Switching", isOn: $recordAppearance)
                    }

                    DisclosureGroup("Diagnostic Areas") {
                        Toggle("Setup and Helper", isOn: $recordSetup)
                        Toggle("Permissions", isOn: $recordPermission)
                        Toggle("Background and Update Detection", isOn: $recordBackground)
                        Toggle("Application Discovery", isOn: $recordDiscovery)
                        Toggle("Cache and Storage", isOn: $recordCache)
                        Toggle("Network and API", isOn: $recordNetwork)
                    }

                    DisclosureGroup("Event Types") {
                        Toggle("Operation Steps", isOn: $recordSteps)
                        Toggle("Performance Timings", isOn: $recordPerformance)
                        Toggle("Failures", isOn: $recordFailures)
                        Toggle("Skipped Work", isOn: $recordSkipped)
                    }

                    DisclosureGroup("Recorded Data") {
                        Toggle("Application Names", isOn: $includeAppNames)
                        Toggle("Application Paths", isOn: $includeAppPaths)
                        Toggle("Icon Selection Details", isOn: $includeIconDetails)
                        Toggle("Icon File Paths", isOn: $includeIconPaths)
                            .disabled(!includeIconDetails)
                        Toggle("Error Messages", isOn: $includeErrorMessages)
                        Toggle("Helper Process Output", isOn: $includeProcessOutput)
                        Toggle("System and Version Information", isOn: $includeSystemInfo)
                    }
                }

                LabeledContent("Log File") {
                    Text(diagnosticsFileSize)
                        .foregroundColor(.secondary)
                        .monospacedDigit()
                }

                HStack {
                    Button("Record System Snapshot") {
                        IconManager.shared.recordDiagnosticsSnapshot()
                        DiagnosticsLogger.shared.flush()
                        refreshDiagnosticsFileSize()
                    }
                    .disabled(!diagnosticsEnabled)

                    Button("Open Log") {
                        openDiagnosticsLog()
                    }

                    Button("Reveal in Finder") {
                        revealDiagnosticsLog()
                    }
                }

                Button("Clear Log", role: .destructive) {
                    showClearConfirmation = true
                }
                .alert("Clear Diagnostics Log?", isPresented: $showClearConfirmation) {
                    Button("Cancel", role: .cancel) {}
                    Button("Clear", role: .destructive) {
                        DiagnosticsLogger.shared.clear()
                        refreshDiagnosticsFileSize()
                    }
                } message: {
                    Text("This removes the current diagnostics log and its rotated archives.")
                }
            } header: {
                Label("Diagnostics", systemImage: "stethoscope")
            } footer: {
                Text(
                    "Diagnostics require both Developer Mode and this switch. Helper output and icon file paths are off by default because they may contain sensitive local information."
                )
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Section {
                ForEach($extraAPIKeys) { $key in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            DeveloperMaskedKeyField(text: $key.value)
                                .onChange(of: key.value) { _ in
                                    syncExtraKeys()
                                    keyTestResults.removeValue(forKey: key.id)
                                }
                            Button {
                                testExtraKey(key)
                            } label: {
                                if testingKeyIDs.contains(key.id) {
                                    ProgressView().controlSize(.small)
                                } else {
                                    Image(systemName: "play.circle")
                                }
                            }
                            .buttonStyle(.borderless)
                            .disabled(key.value.isEmpty || testingKeyIDs.contains(key.id))

                            Button(role: .destructive) {
                                extraAPIKeys.removeAll { $0.id == key.id }
                                syncExtraKeys()
                            } label: {
                                Image(systemName: "minus.circle.fill")
                            }
                            .buttonStyle(.borderless)
                        }

                        if let result = keyTestResults[key.id] {
                            Label(
                                result.message,
                                systemImage: result.success
                                    ? "checkmark.circle.fill"
                                    : "exclamationmark.triangle.fill"
                            )
                            .font(.caption)
                            .foregroundColor(result.success ? .green : .red)
                        }
                    }
                }

                HStack {
                    SecureField("Add API Key...", text: $newAPIKey)
                        .onSubmit { addExtraKey() }
                    Button {
                        addExtraKey()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .buttonStyle(.borderless)
                    .disabled(newAPIKey.isEmpty)
                }
            } header: {
                Label("Additional API Keys", systemImage: "key.horizontal")
            } footer: {
                Text("Additional API keys are rotated automatically to distribute usage.")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Section {
                Button(role: .destructive) {
                    showDisableConfirmation = true
                } label: {
                    Label("Disable Developer Mode", systemImage: "xmark.circle")
                }
                .alert("Disable Developer Mode?", isPresented: $showDisableConfirmation) {
                    Button("Cancel", role: .cancel) {}
                    Button("Disable", role: .destructive) {
                        diagnosticsEnabled = false
                        developerModeEnabled = false
                    }
                } message: {
                    Text("Developer settings will be hidden and diagnostics logging will stop.")
                }
            } header: {
                Label("Developer Mode", systemImage: "hammer")
            }
        }
        .formStyle(.grouped)
        .onAppear {
            extraAPIKeys = APIKeyManager.loadExtraKeys().map {
                DeveloperAPIKey(value: $0)
            }
            refreshDiagnosticsFileSize()
        }
    }

    private func addExtraKey() {
        let trimmed = newAPIKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        extraAPIKeys.append(DeveloperAPIKey(value: trimmed))
        syncExtraKeys()
        newAPIKey = ""
    }

    private func syncExtraKeys() {
        APIKeyManager.saveExtraKeys(extraAPIKeys.map(\.value))
    }

    private func testExtraKey(_ key: DeveloperAPIKey) {
        testingKeyIDs.insert(key.id)
        Task {
            do {
                let result = try await MyQueryRequestController().testAPIConnection(
                    apiKey: key.value
                )
                await MainActor.run {
                    testingKeyIDs.remove(key.id)
                    keyTestResults[key.id] = (
                        true,
                        result.iconCount > 0 ? "Connected" : "Connected (no results)"
                    )
                }
            } catch {
                await MainActor.run {
                    testingKeyIDs.remove(key.id)
                    keyTestResults[key.id] = (false, error.localizedDescription)
                }
            }
        }
    }

    private func refreshDiagnosticsFileSize() {
        diagnosticsFileSize = DiagnosticsLogger.shared.fileSizeDescription()
    }

    private func openDiagnosticsLog() {
        let url = DiagnosticsLogger.logURL
        if FileManager.default.fileExists(atPath: url.path) {
            NSWorkspace.shared.open(url)
        } else {
            NSWorkspace.shared.open(url.deletingLastPathComponent())
        }
        refreshDiagnosticsFileSize()
    }

    private func revealDiagnosticsLog() {
        let url = DiagnosticsLogger.logURL
        if FileManager.default.fileExists(atPath: url.path) {
            NSWorkspace.shared.activateFileViewerSelecting([url])
        } else {
            NSWorkspace.shared.open(url.deletingLastPathComponent())
        }
        refreshDiagnosticsFileSize()
    }
}
