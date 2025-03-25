//
//  CLIManager.swift
//  IconChanger
//
//  Created by Zane on 3/26/25.
//

import SwiftUI
import Foundation

class CLIManager: ObservableObject {
    static let shared = CLIManager()
    
    @Published var isInstalled: Bool = false
    @Published var isInstalling: Bool = false
    @Published var installLocation: String = "/usr/local/bin/iconchanger"
    @Published var lastError: String? = nil
    
    private let bundledCLIName = "IconChangerCLI"
    
    init() {
        checkInstallation()
    }
    
    func checkInstallation() {
        isInstalled = FileManager.default.fileExists(atPath: installLocation)
    }
    
    func installCLI() {
        isInstalling = true
        lastError = nil
        
        Task {
            do {
                // Get the CLI tool from the application's bundle
                guard let bundlePath = Bundle.main.path(forResource: bundledCLIName, ofType: nil) else {
                    throw NSError(domain: "CLIManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "CLI executable not found in application bundle"])
                }
                
                // Use osascript to execute the sudo command for installation
                let script = """
                do shell script "cp '\(bundlePath)' '\(installLocation)' && chmod +x '\(installLocation)'" with administrator privileges
                """
                
                let appleScript = NSAppleScript(source: script)
                var errorDict: NSDictionary?
                appleScript?.executeAndReturnError(&errorDict)
                
                if let error = errorDict {
                    throw NSError(domain: "AppleScript", code: 2, userInfo: [NSLocalizedDescriptionKey: error["NSAppleScriptErrorMessage"] as? String ?? "Unknown error"])
                }
                
                await MainActor.run {
                    self.isInstalling = false
                    self.checkInstallation()
                }
            } catch {
                await MainActor.run {
                    self.lastError = error.localizedDescription
                    self.isInstalling = false
                }
            }
        }
    }
    
    func uninstallCLI() {
        isInstalling = true
        lastError = nil
        
        Task {
            do {
                // Use osascript to execute the sudo command for uninstallation
                let script = """
                do shell script "rm '\(installLocation)'" with administrator privileges
                """
                
                let appleScript = NSAppleScript(source: script)
                var errorDict: NSDictionary?
                appleScript?.executeAndReturnError(&errorDict)
                
                if let error = errorDict {
                    throw NSError(domain: "AppleScript", code: 3, userInfo: [NSLocalizedDescriptionKey: error["NSAppleScriptErrorMessage"] as? String ?? "Unknown error"])
                }
                
                await MainActor.run {
                    self.isInstalling = false
                    self.checkInstallation()
                }
            } catch {
                await MainActor.run {
                    self.lastError = error.localizedDescription
                    self.isInstalling = false
                }
            }
        }
    }
}
