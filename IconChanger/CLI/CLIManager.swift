//
//  CLIManager.swift
//  IconChanger
//

import SwiftUI
import Foundation

@MainActor class CLIManager: ObservableObject {
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

        let cliName = bundledCLIName
        let location = installLocation
        Task.detached {
            do {
                guard let bundlePath = Bundle.main.path(forResource: cliName, ofType: nil) else {
                    throw NSError(domain: "CLIManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "CLI executable not found in application bundle"])
                }

                let escapedBundlePath = bundlePath.shellEscaped
                let escapedInstallLocation = location.shellEscaped
                let script = """
                do shell script "cp '\(escapedBundlePath)' '\(escapedInstallLocation)' && chmod +x '\(escapedInstallLocation)'" with administrator privileges
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

        let location = installLocation
        Task.detached {
            do {
                let script = """
                do shell script "rm '\(location.shellEscaped)'" with administrator privileges
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
