//
//  ConfigManager.swift
//  IconChanger
//

import Foundation
import SwiftyJSON
import Cocoa
import UniformTypeIdentifiers
import UserNotifications
import os

class ConfigManager {
    static let shared = ConfigManager()
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ConfigManager")

    struct AppConfiguration: Codable {
        var appAliases: [AliasConfig] = []
        var cachedIcons: [IconCacheConfig] = []
        var settings: [String: JSON]?
        var version: String = "2.0"
        var exportDate: Date = Date()
    }

    struct AliasConfig: Codable {
        var appName: String
        var aliasName: String
    }

    struct IconCacheConfig: Codable {
        var appPath: String
        var appName: String
        var iconFileName: String
        var iconData: Data
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
                    iconData: iconData
                ))
            }
        }

        let t2Active = UserDefaults.standard.bool(forKey: "t2e")
        let settingsDict = AppSettings.shared.exportSettings(tier2Enabled: t2Active)
        config.settings = settingsDict.mapValues { JSON($0) }

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
            try outputData.write(to: exportURL)
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
        var settings: Int = 0
        var error: Error?
    }

    func importConfiguration(from url: URL, password: String? = nil) -> ImportResult {
        do {
            let rawData = try Data(contentsOf: url)
            let jsonData: Data

            if url.pathExtension == "icconfig" {
                guard let password, !password.isEmpty else {
                    return ImportResult(error: ConfigCrypto.CryptoError.wrongPassword)
                }
                jsonData = try ConfigCrypto.decrypt(rawData, password: password)
            } else {
                jsonData = rawData
            }

            let config = try JSONDecoder().decode(AppConfiguration.self, from: jsonData)

            var importedAliases = 0
            var existingAliases = AliasNames.getAll()
            let existingNames = Set(existingAliases.map(\.appName))

            for alias in config.appAliases {
                if !existingNames.contains(alias.appName) {
                    existingAliases.append(AliasName(appName: alias.appName, aliasName: alias.aliasName))
                    importedAliases += 1
                }
            }
            AliasNames.save(existingAliases)

            var importedIcons = 0
            for iconConfig in config.cachedIcons {
                if FileManager.default.fileExists(atPath: iconConfig.appPath) {
                    let newFileName = "\(UUID().uuidString).png"
                    let iconURL = IconCacheManager.cacheDirectory.appendingPathComponent(newFileName)
                    try iconConfig.iconData.write(to: iconURL)
                    IconCacheManager.shared.addImportedCache(IconCache(
                        appPath: iconConfig.appPath,
                        iconFileName: newFileName,
                        appName: iconConfig.appName,
                        timestamp: Date()
                    ))
                    importedIcons += 1
                }
            }

            var importedSettings = 0
            if let settings = config.settings {
                let dict = settings.mapValues { $0.object }
                AppSettings.shared.importSettings(dict as [String: Any])
                importedSettings = settings.count
            }

            return ImportResult(aliases: importedAliases, icons: importedIcons, settings: importedSettings)
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
            if result == .OK, let url = savePanel.url {
                if let tempURL = self.exportConfiguration(password: password) {
                    do {
                        if FileManager.default.fileExists(atPath: url.path) {
                            try FileManager.default.removeItem(at: url)
                        }
                        try FileManager.default.copyItem(at: tempURL, to: url)
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
            guard result == .OK, let url = openPanel.url else { return }

            if url.pathExtension == "icconfig" {
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
        if result.aliases > 0 || result.icons > 0 || result.settings > 0 {
            showNotification(
                title: NSLocalizedString("Import Successful", comment: ""),
                message: String(format: NSLocalizedString("Imported %lld aliases, %lld icons, and %lld settings", comment: ""),
                                result.aliases, result.icons, result.settings),
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
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, error in
            if let error = error {
                self.logger.error("Notification permission failed: \(error.localizedDescription)")
            }
        }
    }
}
