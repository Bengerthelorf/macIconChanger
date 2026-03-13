//
//  AdvancedSettingsView.swift
//  IconChanger
//

import SwiftUI

private struct IdentifiableKey: Identifiable {
    let id = UUID()
    var value: String
}

private struct MaskedKeyField: View {
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
        guard text.count > 10 else { return text.isEmpty ? "API Key" : text }
        let prefix = String(text.prefix(6))
        let suffix = String(text.suffix(5))
        return "\(prefix)...\(suffix)"
    }
}

enum AppAppearance: String, CaseIterable, Identifiable {
    case system = "system"
    case light = "light"
    case dark = "dark"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: return NSLocalizedString("System", comment: "Appearance option")
        case .light: return NSLocalizedString("Light", comment: "Appearance option")
        case .dark: return NSLocalizedString("Dark", comment: "Appearance option")
        }
    }

    var nsAppearance: NSAppearance? {
        switch self {
        case .system: return nil
        case .light: return NSAppearance(named: .aqua)
        case .dark: return NSAppearance(named: .darkAqua)
        }
    }

    static func apply(_ appearance: AppAppearance) {
        NSApp.appearance = appearance.nsAppearance
    }
}

struct AdvancedSettingsView: View {
    @State private var apiKey: String = KeychainHelper.load(key: "apiKey") ?? ""
    @State private var isTestingAPI = false
    @State private var testResult: String? = nil
    @State private var testSuccess = false
    @StateObject private var cliManager = CLIManager.shared
    @AppStorage("cacheAPIResults") private var cacheAPIResults = true
    @State private var fetchCacheCount: Int = IconFetchCacheManager.shared.getCacheCount()
    @AppStorage("apiRetryCount") private var apiRetryCount = 0
    @AppStorage("apiTimeoutSeconds") private var apiTimeoutSeconds: Double = 15.0
    @AppStorage("apiMonthlyLimit") private var apiMonthlyLimit = 50
    @AppStorage("extendedSearch") private var extendedSearch = false
    @AppStorage("developerOptionsEnabled") private var developerOptionsEnabled = false
    @State private var extraAPIKeys: [IdentifiableKey] = APIKeyManager.loadExtraKeys().map { IdentifiableKey(value: $0) }
    @State private var newAPIKey: String = ""
    @State private var extraKeyTestResults: [UUID: (success: Bool, message: String)] = [:]
    @State private var testingKeyIDs: Set<UUID> = []
    @State private var showDisableConfirmation = false
    @State private var usageCount: Int = APIUsageTracker.shared.currentCount

    private var aliasCount: Int {
        AliasNames.getAll().count
    }

    private var cachedIconsCount: Int {
        IconCacheManager.shared.getCachedIconsCount()
    }

    var body: some View {
        Form {
            // MARK: - API
            Section {
                SecureField(NSLocalizedString("API Key: ", comment: "API settings"), text: $apiKey)
                    .onChange(of: apiKey) { newValue in
                        KeychainHelper.save(key: "apiKey", value: newValue)
                    }
            } header: {
                Label(NSLocalizedString("API Key", comment: "Settings section"), systemImage: "key")
            } footer: {
                Text(NSLocalizedString("You need to obtain an API key from macosicons.com", comment: "API settings instruction"))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Section {
                HStack(spacing: 10) {
                    Button {
                        if !isTestingAPI && !apiKey.isEmpty {
                            isTestingAPI = true
                            testResult = nil
                            Task { await testAPI() }
                        }
                    } label: {
                        if isTestingAPI {
                            HStack(spacing: 6) {
                                ProgressView()
                                    .controlSize(.small)
                                Text(NSLocalizedString("Testing...", comment: "API testing status"))
                            }
                        } else {
                            Text(NSLocalizedString("Test API Connection", comment: "API settings button"))
                        }
                    }
                    .disabled(apiKey.isEmpty || isTestingAPI)

                    if let result = testResult {
                        Spacer()
                        Label(result, systemImage: testSuccess ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            .font(.callout)
                            .foregroundColor(testSuccess ? .green : .red)
                    }
                }
            } header: {
                Label(NSLocalizedString("Connection Test", comment: "Settings section"), systemImage: "network")
            }

            // MARK: - API Settings
            Section {
                Picker(NSLocalizedString("Retry Count", comment: "API setting"), selection: $apiRetryCount) {
                    Text(NSLocalizedString("No Retry", comment: "Retry option")).tag(0)
                    Text("1").tag(1)
                    Text("2").tag(2)
                    Text("3").tag(3)
                }

                HStack {
                    Text(NSLocalizedString("Timeout", comment: "API setting"))
                    Spacer()
                    TextField("", value: $apiTimeoutSeconds, format: .number)
                        .frame(width: 60)
                        .multilineTextAlignment(.trailing)
                    Text(NSLocalizedString("seconds", comment: "Timeout unit"))
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text(NSLocalizedString("Monthly Limit", comment: "API setting"))
                    Spacer()
                    TextField("", value: $apiMonthlyLimit, format: .number)
                        .frame(width: 60)
                        .multilineTextAlignment(.trailing)
                    Text(NSLocalizedString("queries", comment: "Limit unit"))
                        .foregroundColor(.secondary)
                }

                LabeledContent {
                    let remaining = max(0, apiMonthlyLimit - usageCount)
                    HStack(spacing: 4) {
                        Text("\(usageCount)/\(apiMonthlyLimit)")
                            .monospacedDigit()
                        Text("(\(remaining) " + NSLocalizedString("remaining", comment: "API usage") + ")")
                            .foregroundColor(remaining > 10 ? .secondary : .orange)
                    }
                } label: {
                    Label(NSLocalizedString("Monthly Usage", comment: "API setting"), systemImage: "chart.bar")
                }

                Button(role: .destructive) {
                    APIUsageTracker.shared.resetCount()
                    usageCount = 0
                } label: {
                    Label(NSLocalizedString("Reset Usage Counter", comment: "API setting"), systemImage: "arrow.counterclockwise")
                }
                Toggle(isOn: $extendedSearch) {
                    Label(NSLocalizedString("Extended Search", comment: "API setting"), systemImage: "text.magnifyingglass")
                }
            } header: {
                Label(NSLocalizedString("API Settings", comment: "Settings section"), systemImage: "gearshape")
            } footer: {
                Text(NSLocalizedString("Retry count controls how many times a failed request is retried. Timeout applies to each individual request attempt.\n\nExtended Search uses multiple queries per search to find more icons. This uses 2–3× more API calls.", comment: "API settings description"))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            // MARK: - Icon Search Cache
            Section {
                Toggle(isOn: $cacheAPIResults) {
                    Label(NSLocalizedString("Cache API Results", comment: "Cache setting"), systemImage: "arrow.down.doc")
                }
                .onChange(of: cacheAPIResults) { newValue in
                    if newValue {
                        IconFetchCacheManager.shared.saveToDisk(force: true)
                    } else {
                        IconFetchCacheManager.shared.deleteDiskCache()
                    }
                    fetchCacheCount = IconFetchCacheManager.shared.getCacheCount()
                }

                LabeledContent {
                    Text("\(fetchCacheCount)")
                        .monospacedDigit()
                        .foregroundColor(.secondary)
                } label: {
                    Label(NSLocalizedString("Cached Search Results", comment: "Cache setting"), systemImage: "magnifyingglass")
                }

                Button(role: .destructive) {
                    IconFetchCacheManager.shared.clearAllCache()
                    IconFetchCacheManager.shared.deleteDiskCache()
                    fetchCacheCount = 0
                } label: {
                    Label(NSLocalizedString("Clear Icon Search Cache", comment: "Cache setting"), systemImage: "trash")
                }
                .disabled(fetchCacheCount == 0)
            } header: {
                Label(NSLocalizedString("Icon Search Cache", comment: "Settings section"), systemImage: "magnifyingglass")
            } footer: {
                Text(NSLocalizedString("When enabled, icon search results are saved to disk and persist across app restarts. Use the refresh button to fetch fresh results.", comment: "Cache setting description"))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            // MARK: - Configuration
            Section {
                LabeledContent {
                    Text("\(aliasCount)")
                        .monospacedDigit()
                        .foregroundColor(.secondary)
                } label: {
                    Label("App Aliases", systemImage: "text.quote")
                }

                LabeledContent {
                    Text("\(cachedIconsCount)")
                        .monospacedDigit()
                        .foregroundColor(.secondary)
                } label: {
                    Label("Cached Icons", systemImage: "photo.on.rectangle")
                }
            } header: {
                Label("Configuration", systemImage: "doc.badge.gearshape")
            }

            Section {
                Button {
                    if let _ = ConfigManager.shared.exportConfigurationForCLI() {
                        ConfigManager.shared.showExportDialog()
                    }
                } label: {
                    Label("Export Configuration", systemImage: "square.and.arrow.up")
                }
                .disabled(aliasCount == 0 && cachedIconsCount == 0)

                Button {
                    ConfigManager.shared.showImportDialog()
                } label: {
                    Label("Import Configuration", systemImage: "square.and.arrow.down")
                }
            } footer: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Export your aliases and icon cache for backup or to use on another Mac.")
                    Text("Import will only add new items, never replace or remove existing ones.")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            // MARK: - CLI
            Section {
                LabeledContent {
                    HStack(spacing: 6) {
                        Image(systemName: cliManager.isInstalled ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(cliManager.isInstalled ? .green : .red)
                        Text(cliManager.isInstalled ? "Installed" : "Not Installed")
                    }
                } label: {
                    Text("Status")
                }

                HStack(spacing: 12) {
                    Button(role: cliManager.isInstalled ? .destructive : nil) {
                        if cliManager.isInstalled {
                            cliManager.uninstallCLI()
                        } else {
                            cliManager.installCLI()
                        }
                    } label: {
                        Label(
                            cliManager.isInstalled ? "Uninstall" : "Install",
                            systemImage: cliManager.isInstalled ? "trash" : "square.and.arrow.down"
                        )
                    }
                    .disabled(cliManager.isInstalling)

                    if cliManager.isInstalling {
                        ProgressView()
                            .controlSize(.small)
                    }
                }

                if let error = cliManager.lastError {
                    Label("Error: \(error)", systemImage: "exclamationmark.triangle")
                        .foregroundColor(.red)
                }
            } header: {
                Label("Command Line Tool", systemImage: "terminal")
            } footer: {
                Text("Install path: \(cliManager.installLocation)")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if developerOptionsEnabled {
                Section {
                    ForEach($extraAPIKeys) { $key in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                MaskedKeyField(text: $key.value)
                                    .onChange(of: key.value) { _ in
                                        syncExtraKeys()
                                        extraKeyTestResults.removeValue(forKey: key.id)
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
                            if let result = extraKeyTestResults[key.id] {
                                Label(result.message, systemImage: result.success ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                    .font(.caption)
                                    .foregroundColor(result.success ? .green : .red)
                            }
                        }
                    }

                    HStack {
                        SecureField("Add API Key...", text: $newAPIKey)
                            .onSubmit {
                                addExtraKey()
                            }
                        Button {
                            addExtraKey()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                        }
                        .buttonStyle(.borderless)
                        .disabled(newAPIKey.isEmpty)
                    }
                    Button(role: .destructive) {
                        showDisableConfirmation = true
                    } label: {
                        Label("Disable Developer Options", systemImage: "xmark.circle")
                    }
                    .alert("Disable Developer Options?", isPresented: $showDisableConfirmation) {
                        Button("Cancel", role: .cancel) {}
                        Button("Disable", role: .destructive) {
                            developerOptionsEnabled = false
                        }
                    } message: {
                        Text("Are you sure you want to disable Developer Options?")
                    }
                } header: {
                    Label("Developer Options", systemImage: "hammer")
                } footer: {
                    Text("Additional API keys are rotated automatically to distribute usage across keys.")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .formStyle(.grouped)
        .onAppear {
            ConfigManager.shared.checkForCLIImports()
            fetchCacheCount = IconFetchCacheManager.shared.getCacheCount()
        }
    }

    private func addExtraKey() {
        let trimmed = newAPIKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        extraAPIKeys.append(IdentifiableKey(value: trimmed))
        syncExtraKeys()
        newAPIKey = ""
    }

    private func syncExtraKeys() {
        APIKeyManager.saveExtraKeys(extraAPIKeys.map(\.value))
    }

    private func testExtraKey(_ key: IdentifiableKey) {
        testingKeyIDs.insert(key.id)
        Task {
            let controller = MyQueryRequestController()
            do {
                let result = try await controller.testAPIConnection(apiKey: key.value)
                await MainActor.run {
                    testingKeyIDs.remove(key.id)
                    extraKeyTestResults[key.id] = (true, result.iconCount > 0 ? "Connected" : "Connected (no results)")
                }
            } catch {
                await MainActor.run {
                    testingKeyIDs.remove(key.id)
                    extraKeyTestResults[key.id] = (false, extractErrorMessage(from: error))
                }
            }
        }
    }

    func testAPI() async {
        let testController = MyQueryRequestController()

        do {
            let result = try await testController.testAPIConnection()

            await MainActor.run {
                if result.iconCount == 0 {
                    testResult = NSLocalizedString("API connection established but no results returned.", comment: "API testing result")
                } else {
                    testResult = String(format: NSLocalizedString("API connection successful!", comment: "API testing result"), String(result.iconCount))
                }
                testSuccess = true
                isTestingAPI = false
                usageCount = APIUsageTracker.shared.currentCount
            }
        } catch {
            await MainActor.run {
                let errorMessage = extractErrorMessage(from: error)
                testResult = String(format: NSLocalizedString("API test failed: %@", comment: "API testing error"), errorMessage)
                testSuccess = false
                isTestingAPI = false
                usageCount = APIUsageTracker.shared.currentCount
            }
        }
    }

    private func extractErrorMessage(from error: Error) -> String {
        let nsError = error as NSError
        let code = nsError.code

        // Handle known HTTP status codes with clean messages
        if code == 429 {
            return NSLocalizedString("API call limit exceeded. Try again next month or contact macosicons.com for a higher quota.", comment: "API 429 error")
        }
        if code == 401 || code == 403 {
            return NSLocalizedString("Invalid or expired API key. Check your key in Settings.", comment: "API auth error")
        }
        if code == 500 || code == 502 || code == 503 {
            return NSLocalizedString("The macosicons.com server is temporarily unavailable. Try again later.", comment: "API server error")
        }

        // For NSURLError codes
        if nsError.domain == NSURLErrorDomain {
            if code == NSURLErrorTimedOut {
                return NSLocalizedString("Request timed out. Check your network connection.", comment: "Timeout error")
            }
            if code == NSURLErrorNotConnectedToInternet {
                return NSLocalizedString("No internet connection.", comment: "No internet error")
            }
        }

        // Try to extract "message" field from JSON in the error description
        let desc = error.localizedDescription
        if let data = desc.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let message = json["message"] as? String {
            return message
        }
        if desc.contains("\"message\"") {
            if let msgStart = desc.range(of: "\"message\":"),
               let quoteStart = desc.range(of: "\"", range: msgStart.upperBound..<desc.endIndex),
               let quoteEnd = desc.range(of: "\"", range: quoteStart.upperBound..<desc.endIndex) {
                return String(desc[quoteStart.upperBound..<quoteEnd.lowerBound])
            }
        }

        // Strip "API error: " prefix if present, to avoid showing raw JSON
        if desc.hasPrefix("API error: ") {
            return String(desc.dropFirst("API error: ".count).prefix(80))
        }

        return desc
    }
}
