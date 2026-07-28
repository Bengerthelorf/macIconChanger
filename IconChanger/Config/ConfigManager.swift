//
//  ConfigManager.swift
//  IconChanger
//

import Foundation
import Cocoa
import UniformTypeIdentifiers
import UserNotifications
import os

class ConfigManager {
    static let shared = ConfigManager()
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "IconChanger", category: "ConfigManager")

    typealias AppConfiguration = AppConfigurationArchive
    typealias AliasConfig = AliasConfigurationArchive
    typealias IconCacheConfig = IconCacheConfigurationArchive

    enum ImportError: LocalizedError {
        case invalidArchiveSize
        case invalidIconData(String)

        var errorDescription: String? {
            switch self {
            case .invalidArchiveSize:
                return "The configuration contains too many icons or icon data that is too large."
            case .invalidIconData(let appName):
                return "The configuration contains invalid icon data for \(appName)."
            }
        }
    }

    // MARK: - Export

    func exportConfiguration(password: String?) -> URL? {
        var config = AppConfiguration()

        for alias in AliasNames.getAll() {
            config.appAliases.append(AliasConfig(appName: alias.appName, aliasName: alias.aliasName))
        }

        for cache in IconCacheManager.shared.getAllCachedIcons() {
            if let iconURL = IconCacheManager.shared.getCachedIconURL(for: cache.appPath),
               let iconData = try? Data(contentsOf: iconURL) {
                config.cachedIcons.append(IconCacheConfig(
                    appPath: cache.appPath,
                    appName: cache.appName,
                    iconFileName: cache.iconFileName,
                    iconData: iconData,
                    appVersion: cache.appVersion
                ))
            }
        }

        for appearance in AppearanceIconStore.shared.getAllConfigurations() {
            let lightData = AppearanceIconStore.shared.iconURL(
                for: appearance.appPath,
                appearance: .light
            ).flatMap { try? Data(contentsOf: $0) }
            let darkData = AppearanceIconStore.shared.iconURL(
                for: appearance.appPath,
                appearance: .dark
            ).flatMap { try? Data(contentsOf: $0) }
            guard lightData != nil || darkData != nil else { continue }
            config.appearanceIcons.append(
                AppearanceIconConfigurationArchive(
                    appPath: appearance.appPath,
                    appName: appearance.appName,
                    lightIconData: lightData,
                    darkIconData: darkData
                )
            )
        }

        let t2Active = UserDefaults.standard.bool(forKey: "t2e")
        let includeSensitive = password?.isEmpty == false
        config.settings = AppSettings.shared.exportSettings(
            tier2Enabled: t2Active,
            includeSensitive: includeSensitive
        )

        do {
            let jsonData = try JSONEncoder().encode(config)
            let ext: String
            let outputData: Data

            if let password, !password.isEmpty {
                outputData = try ConfigCrypto.encrypt(jsonData, password: password)
                ext = "icconfig"
            } else {
                outputData = jsonData
                ext = "json"
            }

            let tempDir = FileManager.default.temporaryDirectory
            let exportURL = tempDir.appendingPathComponent("IconChanger_Config_\(formattedDate()).\(ext)")
            try writePrivateData(outputData, to: exportURL)
            return exportURL
        } catch {
            logger.error("Export failed: \(error.localizedDescription)")
            return nil
        }
    }

    // Legacy compat
    func exportConfiguration() -> URL? {
        exportConfiguration(password: nil)
    }

    // MARK: - Import

    struct ImportResult {
        var aliases: Int = 0
        var icons: Int = 0
        var appearanceIcons: Int = 0
        var settings: Int = 0
        var error: Error?
    }

    func importConfiguration(from url: URL, password: String? = nil) -> ImportResult {
        do {
            guard ConfigurationArchivePolicy.validatesEncodedFileSize(url) else {
                throw ImportError.invalidArchiveSize
            }
            let rawData = try Data(contentsOf: url)
            let jsonData: Data
            let isEncrypted = url.pathExtension.lowercased() == "icconfig"

            if isEncrypted {
                guard let password, !password.isEmpty else {
                    return ImportResult(error: ConfigCrypto.CryptoError.wrongPassword)
                }
                jsonData = try ConfigCrypto.decrypt(rawData, password: password)
            } else {
                jsonData = rawData
            }

            let config = try JSONDecoder().decode(AppConfiguration.self, from: jsonData)
            guard ConfigurationArchivePolicy.validatesSizeLimits(config) else {
                throw ImportError.invalidArchiveSize
            }
            try validateIconData(in: config)

            var importedAliases = 0
            var existingAliases = AliasNames.getAll()
            var existingNames = Set(existingAliases.map(\.appName))

            for alias in config.appAliases {
                if existingNames.insert(alias.appName).inserted {
                    existingAliases.append(AliasName(appName: alias.appName, aliasName: alias.aliasName))
                    importedAliases += 1
                }
            }
            AliasNames.save(existingAliases)

            var importedIcons = 0
            for iconConfig in config.cachedIcons {
                if FileManager.default.fileExists(atPath: iconConfig.appPath) {
                    let imported = try IconCacheManager.shared.importIconData(
                        iconConfig.iconData,
                        appPath: iconConfig.appPath,
                        appName: iconConfig.appName,
                        appVersion: iconConfig.appVersion
                    )
                    if imported {
                        importedIcons += 1
                    }
                }
            }

            var importedAppearanceIcons = 0
            for appearanceConfig in config.appearanceIcons {
                guard FileManager.default.fileExists(atPath: appearanceConfig.appPath) else {
                    continue
                }
                importedAppearanceIcons += try AppearanceIconStore.shared.importSlots(
                    appPath: appearanceConfig.appPath,
                    appName: appearanceConfig.appName,
                    lightIconData: appearanceConfig.lightIconData,
                    darkIconData: appearanceConfig.darkIconData
                )
            }

            let importedSettings: Int
            if let settings = config.settings {
                importedSettings = AppSettings.shared.importSettings(
                    settings,
                    includeSensitive: isEncrypted
                )
                Task { @MainActor in
                    BackgroundService.shared.reloadPersistentSettingsAfterImport()
                }
            } else {
                importedSettings = 0
            }

            return ImportResult(
                aliases: importedAliases,
                icons: importedIcons,
                appearanceIcons: importedAppearanceIcons,
                settings: importedSettings
            )
        } catch let error as ConfigCrypto.CryptoError {
            logger.error("Import failed: \(error.localizedDescription)")
            return ImportResult(error: error)
        } catch {
            logger.error("Import failed: \(error.localizedDescription)")
            return ImportResult(error: error)
        }
    }

    // MARK: - Dialogs

    func showExportDialog(password: String? = nil) {
        let ext = (password != nil && !password!.isEmpty) ? "icconfig" : "json"
        let savePanel = NSSavePanel()
        savePanel.title = NSLocalizedString("Export IconChanger Configuration", comment: "Save panel title")
        savePanel.nameFieldLabel = "Save As:"
        savePanel.canCreateDirectories = true
        savePanel.showsTagField = false
        savePanel.allowedContentTypes = [UTType(filenameExtension: ext)].compactMap { $0 }
        savePanel.allowsOtherFileTypes = false
        savePanel.isExtensionHidden = false
        savePanel.nameFieldStringValue = "IconChanger_Config_\(formattedDate()).\(ext)"

        savePanel.begin { result in
            DispatchQueue.main.async {
            if result == .OK, let url = savePanel.url {
                if let tempURL = self.exportConfiguration(password: password) {
                    defer { try? FileManager.default.removeItem(at: tempURL) }
                    do {
                        if FileManager.default.fileExists(atPath: url.path) {
                            try FileManager.default.removeItem(at: url)
                        }
                        try FileManager.default.copyItem(at: tempURL, to: url)
                        try FileManager.default.setAttributes(
                            [.posixPermissions: 0o600],
                            ofItemAtPath: url.path
                        )
                        self.showNotification(
                            title: NSLocalizedString("Export Successful", comment: ""),
                            message: NSLocalizedString("Configuration exported successfully", comment: ""),
                            success: true
                        )
                    } catch {
                        self.logger.error("Save failed: \(error.localizedDescription)")
                        self.showNotification(
                            title: NSLocalizedString("Export Failed", comment: ""),
                            message: error.localizedDescription,
                            success: false
                        )
                    }
                }
            }
            }
        }
    }

    func showImportDialog() {
        let openPanel = NSOpenPanel()
        openPanel.title = NSLocalizedString("Import IconChanger Configuration", comment: "")
        openPanel.showsHiddenFiles = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowsMultipleSelection = false
        openPanel.allowedContentTypes = [
            UTType(filenameExtension: "json"),
            UTType(filenameExtension: "icconfig")
        ].compactMap { $0 }

        openPanel.begin { result in
            DispatchQueue.main.async {
                guard result == .OK, let url = openPanel.url else { return }

                if url.pathExtension.lowercased() == "icconfig" {
                    self.promptPassword { password in
                        guard let password else { return }
                        let results = self.importConfiguration(from: url, password: password)
                        self.showImportResults(results)
                    }
                } else {
                    let results = self.importConfiguration(from: url)
                    self.showImportResults(results)
                }
            }
        }
    }

    // MARK: - Private

    private func promptPassword(completion: @escaping (String?) -> Void) {
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("Enter Password", comment: "")
        alert.informativeText = NSLocalizedString("This configuration file is encrypted.", comment: "")
        alert.alertStyle = .informational
        alert.addButton(withTitle: NSLocalizedString("OK", comment: ""))
        alert.addButton(withTitle: NSLocalizedString("Cancel", comment: ""))

        let input = NSSecureTextField(frame: NSRect(x: 0, y: 0, width: 260, height: 24))
        alert.accessoryView = input

        if alert.runModal() == .alertFirstButtonReturn {
            completion(input.stringValue)
        } else {
            completion(nil)
        }
    }

    static let didImportNotification = Notification.Name("ConfigManagerDidImport")

    private func showImportResults(_ result: ImportResult) {
        if let error = result.error {
            showNotification(
                title: NSLocalizedString("Import Failed", comment: ""),
                message: error.localizedDescription,
                success: false
            )
            return
        }

        NotificationCenter.default.post(name: Self.didImportNotification, object: nil)
        if result.aliases > 0 ||
            result.icons > 0 ||
            result.appearanceIcons > 0 ||
            result.settings > 0 {
            showNotification(
                title: NSLocalizedString("Import Successful", comment: ""),
                message: String(
                    format: NSLocalizedString(
                        "Imported %lld aliases, %lld icons, %lld appearance slots, and %lld settings",
                        comment: ""
                    ),
                    result.aliases,
                    result.icons,
                    result.appearanceIcons,
                    result.settings
                ),
                success: true
            )
        } else {
            showNotification(
                title: NSLocalizedString("Import Complete", comment: ""),
                message: NSLocalizedString("No new items were found to import", comment: ""),
                success: true
            )
        }
    }

    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        return formatter.string(from: Date())
    }

    private func validateIconData(in config: AppConfiguration) throws {
        for icon in config.cachedIcons where NSImage(data: icon.iconData) == nil {
            throw ImportError.invalidIconData(icon.appName)
        }
        for appearance in config.appearanceIcons {
            if let data = appearance.lightIconData, NSImage(data: data) == nil {
                throw ImportError.invalidIconData(appearance.appName)
            }
            if let data = appearance.darkIconData, NSImage(data: data) == nil {
                throw ImportError.invalidIconData(appearance.appName)
            }
        }
    }

    private func writePrivateData(_ data: Data, to url: URL) throws {
        try data.write(to: url, options: .atomic)
        try FileManager.default.setAttributes(
            [.posixPermissions: 0o600],
            ofItemAtPath: url.path
        )
    }

    private func showNotification(title: String, message: String, success: Bool) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = success ? .informational : .warning
        alert.addButton(withTitle: NSLocalizedString("OK", comment: ""))
        alert.runModal()

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = UNNotificationSound.default
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    init() {
    }
}
