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
    
    // Configuration types to export/import
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
    
    // Export configuration to a JSON file
    func exportConfiguration() -> URL? {
        // Create the configuration object
        var config = AppConfiguration()
        
        // Add alias configurations
        for alias in AliasNames.getAll() {
            config.appAliases.append(AliasConfig(appName: alias.appName, aliasName: alias.aliasName))
        }
        
        // Add cached icon configurations
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
        
        // Convert to JSON
        do {
            let data = try JSONEncoder().encode(config)
            
            // Save to temporary file
            let tempDir = FileManager.default.temporaryDirectory
            let exportURL = tempDir.appendingPathComponent("IconChanger_Config_\(Date().timeIntervalSince1970).json")
            
            try data.write(to: exportURL)
            return exportURL
        } catch {
            print("Error exporting configuration: \(error.localizedDescription)")
            return nil
        }
    }
    
    // Import configuration from a JSON file
    func importConfiguration(from url: URL) -> (aliases: Int, icons: Int) {
        do {
            let data = try Data(contentsOf: url)
            let config = try JSONDecoder().decode(AppConfiguration.self, from: data)
            
            // Import aliases
            var importedAliases = 0
            var existingAliases = AliasNames.getAll()
            
            for alias in config.appAliases {
                if !existingAliases.contains(where: { $0.appName == alias.appName }) {
                    // Add new alias
                    existingAliases.append(AliasName(appName: alias.appName, aliasName: alias.aliasName))
                    importedAliases += 1
                }
            }
            
            // Save imported aliases
            AliasNames.save(existingAliases)
            
            // Import cached icons
            var importedIcons = 0
            
            for iconConfig in config.cachedIcons {
                // Check if the app still exists
                if FileManager.default.fileExists(atPath: iconConfig.appPath) {
                    // Create a new unique filename for the icon
                    let newFileName = "\(UUID().uuidString).png"
                    let iconURL = IconCacheManager.cacheDirectory.appendingPathComponent(newFileName)
                    
                    // Write the icon data to the file
                    try iconConfig.iconData.write(to: iconURL)
                    
                    // Create a new cache entry and add to cache manager
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
    
    // Export configuration dialog
    func showExportDialog() {
        let savePanel = NSSavePanel()
        savePanel.title = "Export IconChanger Configuration"
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
                        // If file already exists, remove it
                        if FileManager.default.fileExists(atPath: url.path) {
                            try FileManager.default.removeItem(at: url)
                        }
                        
                        // Copy from temp to selected location
                        try FileManager.default.copyItem(at: tempURL, to: url)
                        
                        // Show success notification
                        self.showNotification(
                            title: "Export Successful",
                            message: "Configuration exported successfully",
                            success: true
                        )
                    } catch {
                        print("Error saving to selected location: \(error.localizedDescription)")
                        self.showNotification(
                            title: "Export Failed",
                            message: "Unable to save configuration file: \(error.localizedDescription)",
                            success: false
                        )
                    }
                }
            }
        }
    }
    
    // Import configuration dialog
    func showImportDialog() {
        let openPanel = NSOpenPanel()
        openPanel.title = "Import IconChanger Configuration"
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
                
                // Show success notification
                if results.aliases > 0 || results.icons > 0 {
                    self.showNotification(
                        title: "Import Successful",
                        message: "Imported \(results.aliases) aliases and \(results.icons) icons",
                        success: true
                    )
                } else {
                    self.showNotification(
                        title: "Import Complete",
                        message: "No new items were found to import",
                        success: true
                    )
                }
            }
        }
    }
    
    // Helper function to format date for filenames
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        return formatter.string(from: Date())
    }
    
    // Show notification
    private func showNotification(title: String, message: String, success: Bool) {
        // Show direct feedback - using Alert
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = success ? .informational : .warning
        alert.addButton(withTitle: NSLocalizedString("OK", comment: "Alert button"))
        alert.runModal()
        
        //Send system notification simultaneously
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = UNNotificationSound.default
        
        // Set the notification icon and style
        if success {
            content.categoryIdentifier = "SUCCESS"
        } else {
            content.categoryIdentifier = "ERROR"
        }
        
        // Create notification request
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // Display immediately
        )
        
        // Add request to notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to send notification: \(error.localizedDescription)")
            }
        }
    }

    // Add code to request notification permissions in the init method of the ConfigManager class
    init() {
        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Notification permissions granted")
            } else if let error = error {
                print("Notification permission request failed: \(error.localizedDescription)")
            }
        }
    }}
