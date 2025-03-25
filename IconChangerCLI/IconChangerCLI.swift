//
//  main.swift
//  IconChangerCLI
//
//  Created by Zane on 3/26/25.
//

import Foundation
import ArgumentParser

@main
struct IconChangerCLI: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "iconchanger",
        abstract: "Command-line interface for IconChanger",
        version: "1.0.0",
        subcommands: [
            ImportCommand.self,
            ExportCommand.self
        ],
        defaultSubcommand: nil
    )
}

// Import configuration
struct ImportCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "import",
        abstract: "Import an IconChanger configuration"
    )
    
    @Argument(help: "Path to configuration file")
    var configPath: String
    
    func run() throws {
        guard FileManager.default.fileExists(atPath: configPath) else {
            throw ValidationError("Configuration file not found at \(configPath)")
        }
        
        // Load the configuration file
        let configURL = URL(fileURLWithPath: configPath)
        let configData = try Data(contentsOf: configURL)
        
        // Save to the shared configuration directory
        let sharedConfigDir = getSharedConfigDirectory()
        let importedConfigFile = sharedConfigDir.appendingPathComponent("imported_config.json")
        
        try configData.write(to: importedConfigFile)
        
        // Create a flag file to indicate a pending import
        let flagFile = sharedConfigDir.appendingPathComponent("pending_import")
        try Data().write(to: flagFile)
        
        print("Configuration imported successfully from \(configPath)")
        print("The configuration will be applied the next time IconChanger is launched")
    }
}

// Export configuration
struct ExportCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "export",
        abstract: "Export IconChanger configuration"
    )
    
    @Argument(help: "Path to save the configuration file")
    var outputPath: String
    
    func run() throws {
        // Check for the most recent export from the app
        let sharedConfigDir = getSharedConfigDirectory()
        let latestExportFile = sharedConfigDir.appendingPathComponent("latest_export.json")
        
        guard FileManager.default.fileExists(atPath: latestExportFile.path) else {
            throw ValidationError("No exported configuration found. Please use the IconChanger app to export your configuration first.")
        }
        
        // Read the exported configuration
        let configData = try Data(contentsOf: latestExportFile)
        
        // Write to the specified output path
        let outputURL = URL(fileURLWithPath: outputPath)
        try configData.write(to: outputURL)
        
        print("Configuration exported successfully to \(outputPath)")
    }
}

// Helper function to get the shared configuration directory
func getSharedConfigDirectory() -> URL {
    let path = "\(NSHomeDirectory())/.iconchanger/config"
    let url = URL(fileURLWithPath: path)
    
    if !FileManager.default.fileExists(atPath: path) {
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
    
    return url
}
