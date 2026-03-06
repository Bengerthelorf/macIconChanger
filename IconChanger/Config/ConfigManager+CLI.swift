//
//  ConfigManager+CLI.swift
//  IconChanger
//
//  Created by Zane on 3/26/25.
//

import Foundation

extension ConfigManager {
    func exportConfigurationForCLI() -> URL? {
        if let exportUrl = exportConfiguration() {
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

    func checkForCLIImports() {
        let sharedConfigDir = getSharedConfigDirectory()
        let flagFile = sharedConfigDir.appendingPathComponent("pending_import")
        let importedFile = sharedConfigDir.appendingPathComponent("imported_config.json")

        if FileManager.default.fileExists(atPath: flagFile.path) &&
           FileManager.default.fileExists(atPath: importedFile.path) {

            do {
                let result = importConfiguration(from: importedFile)
                print("CLI Import completed: \(result.aliases) aliases and \(result.icons) icons imported")

                try FileManager.default.removeItem(at: flagFile)
            } catch {
                print("Error processing CLI import: \(error.localizedDescription)")
            }
        }
    }

    private func getSharedConfigDirectory() -> URL {
        let path = "\(NSHomeDirectory())/.iconchanger/config"
        let url = URL(fileURLWithPath: path)

        if !FileManager.default.fileExists(atPath: path) {
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        }

        return url
    }
}
