//
//  ConfigManager+CLI.swift
//  IconChanger
//

import Foundation

extension ConfigManager {

    static let sharedConfigDirectory: URL = {
        let url = URL(fileURLWithPath: NSHomeDirectory())
            .appendingPathComponent(".iconchanger/config", isDirectory: true)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }()

    func exportConfigurationForCLI() -> URL? {
        guard let exportUrl = exportConfiguration() else { return nil }

        let latestExportFile = Self.sharedConfigDirectory.appendingPathComponent("latest_export.json")

        do {
            let data = try Data(contentsOf: exportUrl)
            try data.write(to: latestExportFile, options: .atomic)
            return exportUrl
        } catch {
            logger.error("Error saving for CLI: \(error.localizedDescription)")
            return nil
        }
    }

    func checkForCLIImports() {
        let flagFile = Self.sharedConfigDirectory.appendingPathComponent("pending_import")
        let importedFile = Self.sharedConfigDirectory.appendingPathComponent("imported_config.json")

        guard FileManager.default.fileExists(atPath: flagFile.path),
              FileManager.default.fileExists(atPath: importedFile.path) else {
            return
        }

        // Validate config before importing
        do {
            let data = try Data(contentsOf: importedFile)
            _ = try JSONDecoder().decode(AppConfiguration.self, from: data)
        } catch {
            logger.error("CLI import file is invalid, removing flag: \(error.localizedDescription)")
            try? FileManager.default.removeItem(at: flagFile)
            return
        }

        let result = importConfiguration(from: importedFile)
        logger.info("CLI Import completed: \(result.aliases) aliases and \(result.icons) icons imported")

        try? FileManager.default.removeItem(at: flagFile)
        try? FileManager.default.removeItem(at: importedFile)
    }
}
