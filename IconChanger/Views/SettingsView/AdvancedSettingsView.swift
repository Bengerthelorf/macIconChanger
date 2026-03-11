//
//  AdvancedSettingsView.swift
//  IconChanger
//

import SwiftUI

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
        }
        .formStyle(.grouped)
        .onAppear {
            ConfigManager.shared.checkForCLIImports()
            fetchCacheCount = IconFetchCacheManager.shared.getCacheCount()
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
            }
        } catch {
            await MainActor.run {
                let errorMessage = extractErrorMessage(from: error)
                testResult = String(format: NSLocalizedString("API test failed: %@", comment: "API testing error"), errorMessage)
                testSuccess = false
                isTestingAPI = false
            }
        }
    }

    private func extractErrorMessage(from error: Error) -> String {
        let errorDescription = error.localizedDescription

        if errorDescription.contains("API error:") {
            if let messageStart = errorDescription.range(of: "\"message\":\""),
               let messageEnd = errorDescription.range(of: "\"}", options: [], range: messageStart.upperBound..<errorDescription.endIndex) {
                return String(errorDescription[messageStart.upperBound..<messageEnd.lowerBound])
            }
        }

        return errorDescription
    }
}
