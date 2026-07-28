//
//  ConfigManager+CLI.swift
//  IconChanger
//

import Foundation

extension ConfigManager {

    static var sharedConfigDirectory: URL {
        AppPaths.sharedConfigDirectory
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
        logger.info(
            "CLI Import completed: \(result.aliases) aliases, \(result.icons) icons, \(result.appearanceIcons) appearance slots, and \(result.settings) settings imported"
        )

        try? FileManager.default.removeItem(at: flagFile)
        try? FileManager.default.removeItem(at: importedFile)
    }
}
