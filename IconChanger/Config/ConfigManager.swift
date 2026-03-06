//
//  ConfigManager.swift
//  IconChanger
//
//  Created by Bengerthelorf on 2025/03/25.
//

import Foundation
import SwiftyJSON
import Cocoa
import UniformTypeIdentifiers
import UserNotifications

class ConfigManager {
    static let shared = ConfigManager()

    struct AppConfiguration: Codable {
        var appAliases: [AliasConfig] = []
        var cachedIcons: [IconCacheConfig] = []
        var version: String = "1.0"
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

    func exportConfiguration() -> URL? {
        var config = AppConfiguration()

        for alias in AliasNames.getAll() {
            config.appAliases.append(AliasConfig(appName: alias.appName, aliasName: alias.aliasName))
        }

        for cache in IconCacheManager.shared.getAllCachedIcons() {
            if let iconURL = IconCacheManager.shared.getCachedIconURL(for: cache.appPath),
               let iconData = try? Data(contentsOf: iconURL) {
                let iconConfig = IconCacheConfig(
                    appPath: cache.appPath,
                    appName: cache.appName,
                    iconFileName: cache.iconFileName,
                    iconData: iconData
                )
                config.cachedIcons.append(iconConfig)
            }
        }

        do {
            let data = try JSONEncoder().encode(config)

            let tempDir = FileManager.default.temporaryDirectory
            let exportURL = tempDir.appendingPathComponent("IconChanger_Config_\(Date().timeIntervalSince1970).json")

            try data.write(to: exportURL)
            return exportURL
        } catch {
            print("Error exporting configuration: \(error.localizedDescription)")
            return nil
        }
    }

    func importConfiguration(from url: URL) -> (aliases: Int, icons: Int) {
        do {
            let data = try Data(contentsOf: url)
            let config = try JSONDecoder().decode(AppConfiguration.self, from: data)

            var importedAliases = 0
            var existingAliases = AliasNames.getAll()

            for alias in config.appAliases {
                if !existingAliases.contains(where: { $0.appName == alias.appName }) {
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

                    let cache = IconCache(
                        appPath: iconConfig.appPath,
                        iconFileName: newFileName,
                        appName: iconConfig.appName,
                        timestamp: Date()
                    )

                    IconCacheManager.shared.addImportedCache(cache)
                    importedIcons += 1
                }
            }

            return (importedAliases, importedIcons)
        } catch {
            print("Error importing configuration: \(error.localizedDescription)")
            return (0, 0)
        }
    }

    func showExportDialog() {
        let savePanel = NSSavePanel()
        savePanel.title = NSLocalizedString("Export IconChanger Configuration", comment: "Save panel title")
        savePanel.nameFieldLabel = "Save As:"
        savePanel.canCreateDirectories = true
        savePanel.showsTagField = false
        savePanel.allowedContentTypes = [UTType(filenameExtension: "json")].compactMap { $0 }
        savePanel.allowsOtherFileTypes = false
        savePanel.isExtensionHidden = false
        savePanel.nameFieldStringValue = "IconChanger_Config_\(formattedDate()).json"

        savePanel.begin { result in
            if result == .OK, let url = savePanel.url {
                if let tempURL = self.exportConfiguration() {
                    do {
                        if FileManager.default.fileExists(atPath: url.path) {
                            try FileManager.default.removeItem(at: url)
                        }

                        try FileManager.default.copyItem(at: tempURL, to: url)

                        self.showNotification(
                            title: NSLocalizedString("Export Successful", comment: "Notification title"),
                            message: NSLocalizedString("Configuration exported successfully", comment: "Notification body"),
                            success: true
                        )
                    } catch {
                        print("Error saving to selected location: \(error.localizedDescription)")
                        self.showNotification(
                            title: NSLocalizedString("Export Failed", comment: "Notification title"),
                            message: String(format: NSLocalizedString("Unable to save configuration file: %@", comment: "Notification body"), error.localizedDescription),
                            success: false
                        )
                    }
                }
            }
        }
    }

    func showImportDialog() {
        let openPanel = NSOpenPanel()
        openPanel.title = NSLocalizedString("Import IconChanger Configuration", comment: "Open panel title")
        openPanel.showsResizeIndicator = true
        openPanel.showsHiddenFiles = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowsMultipleSelection = false
        openPanel.allowedContentTypes = [UTType(filenameExtension: "json")].compactMap { $0 }

        openPanel.begin { result in
            if result == .OK, let url = openPanel.url {
                let results = self.importConfiguration(from: url)

                if results.aliases > 0 || results.icons > 0 {
                    self.showNotification(
                        title: NSLocalizedString("Import Successful", comment: "Notification title"),
                        message: String(format: NSLocalizedString("Imported %lld aliases and %lld icons", comment: "Notification body"), results.aliases, results.icons),
                        success: true
                    )
                } else {
                    self.showNotification(
                        title: NSLocalizedString("Import Complete", comment: "Notification title"),
                        message: NSLocalizedString("No new items were found to import", comment: "Notification body"),
                        success: true
                    )
                }
            }
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
        alert.addButton(withTitle: NSLocalizedString("OK", comment: "Alert button"))
        alert.runModal()

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = success ? "SUCCESS" : "ERROR"

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to send notification: \(error.localizedDescription)")
            }
        }
    }

    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission request failed: \(error.localizedDescription)")
            }
        }
    }
}
