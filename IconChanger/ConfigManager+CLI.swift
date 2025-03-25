//
//  ConfigManager+CLI.swift
//  IconChanger
//
//  Created by Zane on 3/26/25.
//

import Foundation

extension ConfigManager {
    // Export configuration and save the latest version for CLI use
    func exportConfigurationForCLI() -> URL? {
        // Export configuration
        if let exportUrl = exportConfiguration() {
            // Save a copy to the shared directory for CLI use
            let sharedConfigDir = getSharedConfigDirectory()
            let latestExportFile = sharedConfigDir.appendingPathComponent("latest_export.json")
            
            do {
                let data = try Data(contentsOf: exportUrl)
                try data.write(to: latestExportFile)
                return exportUrl
            } catch {
                print("Error saving for CLI: \(error.localizedDescription)")
            }
        }
        return nil
    }
    
    // Check and apply configurations imported via CLI
    func checkForCLIImports() {
        let sharedConfigDir = getSharedConfigDirectory()
        let flagFile = sharedConfigDir.appendingPathComponent("pending_import")
        let importedFile = sharedConfigDir.appendingPathComponent("imported_config.json")
        
        // If the import flag exists, process the imported configuration
        if FileManager.default.fileExists(atPath: flagFile.path) &&
           FileManager.default.fileExists(atPath: importedFile.path) {
            
            do {
                // Import configuration
                let result = importConfiguration(from: importedFile)
                print("CLI Import completed: \(result.aliases) aliases and \(result.icons) icons imported")
                
                // Delete the flag file
                try FileManager.default.removeItem(at: flagFile)
            } catch {
                print("Error processing CLI import: \(error.localizedDescription)")
            }
        }
    }
    
    // Get the shared configuration directory
    private func getSharedConfigDirectory() -> URL {
        let path = "\(NSHomeDirectory())/.iconchanger/config"
        let url = URL(fileURLWithPath: path)
        
        if !FileManager.default.fileExists(atPath: path) {
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        }
        
        return url
    }
}
