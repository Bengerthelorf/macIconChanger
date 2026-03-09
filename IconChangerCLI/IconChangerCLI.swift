//
//  main.swift
//  IconChangerCLI
//
//  Created by Zane on 3/26/25.
//  Rewritten by Bengerthelorf on 2026/3/9.
//

import Foundation
import ArgumentParser

// MARK: - Shared Paths & Constants

private let appBundleID = "com.zhuhaoyu.IconChanger"

private let iconchangerDir: URL = {
    let url = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent(".iconchanger", isDirectory: true)
    try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    return url
}()

private let sharedConfigDir: URL = {
    let url = iconchangerDir.appendingPathComponent("config", isDirectory: true)
    try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    return url
}()

private let cacheDir: URL = {
    let url = iconchangerDir.appendingPathComponent("cache", isDirectory: true)
    try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    return url
}()

private let helperScript = iconchangerDir.appendingPathComponent("helper.sh")
private let fileicon = iconchangerDir.appendingPathComponent("fileicon")

// MARK: - App Defaults Reader

/// Reads the main app's UserDefaults plist directly, since the CLI is a separate process.
private func appDefaults() -> [String: Any] {
    let plistPath = NSHomeDirectory() + "/Library/Preferences/\(appBundleID).plist"
    guard let data = FileManager.default.contents(atPath: plistPath),
          let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] else {
        return [:]
    }
    return plist
}

private func loadAliases() -> [String: String] {
    guard let data = appDefaults()["AliasName"] as? Data,
          let aliases = try? JSONDecoder().decode([String: String].self, from: data) else {
        return [:]
    }
    return aliases
}

private struct CachedIcon: Codable {
    let appPath: String
    let iconFileName: String
    let appName: String
    let timestamp: Date
}

private func loadCachedIcons() -> [String: CachedIcon] {
    guard let data = appDefaults()["com.iconchanger.cachedIcons"] as? Data,
          let icons = try? JSONDecoder().decode([String: CachedIcon].self, from: data) else {
        return [:]
    }
    return icons
}

// MARK: - Config Validation

private struct AppConfiguration: Codable {
    var appAliases: [AliasConfig] = []
    var cachedIcons: [IconCacheConfig] = []
    var version: String = "1.0"
    var exportDate: Date = Date()
}

private struct AliasConfig: Codable {
    var appName: String
    var aliasName: String
}

private struct IconCacheConfig: Codable {
    var appPath: String
    var appName: String
    var iconFileName: String
    var iconData: Data
}

private func validateConfig(at url: URL) throws -> AppConfiguration {
    let data = try Data(contentsOf: url)
    return try JSONDecoder().decode(AppConfiguration.self, from: data)
}

// MARK: - Shell Helpers

@discardableResult
private func shell(_ command: String, timeout: TimeInterval = 15.0) throws -> String {
    let task = Process()
    let outPipe = Pipe()
    let errPipe = Pipe()

    task.standardOutput = outPipe
    task.standardError = errPipe
    task.arguments = ["-c", command]
    task.executableURL = URL(fileURLWithPath: "/bin/zsh")
    task.standardInput = nil
    task.environment = ProcessInfo.processInfo.environment

    do {
        try task.run()
    } catch {
        throw CLIError.shellFailed("Failed to start process: \(error.localizedDescription)")
    }

    let deadline = DispatchTime.now() + timeout
    let group = DispatchGroup()
    var outData = Data()
    var errData = Data()

    group.enter()
    DispatchQueue.global().async {
        outData = outPipe.fileHandleForReading.readDataToEndOfFile()
        group.leave()
    }
    group.enter()
    DispatchQueue.global().async {
        errData = errPipe.fileHandleForReading.readDataToEndOfFile()
        group.leave()
    }

    if group.wait(timeout: deadline) == .timedOut {
        task.terminate()
        throw CLIError.shellFailed("Command timed out after \(Int(timeout))s")
    }

    task.waitUntilExit()

    let output = String(data: outData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    let errOutput = String(data: errData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

    if task.terminationStatus != 0 {
        let combined = errOutput.isEmpty ? output : errOutput
        throw CLIError.shellFailed("Exit code \(task.terminationStatus): \(combined)")
    }

    return output
}

private extension String {
    var shellEscaped: String {
        self.replacingOccurrences(of: "'", with: "'\\''")
    }
}

// MARK: - Errors

private enum CLIError: Error, LocalizedError {
    case shellFailed(String)
    case setupIncomplete(String)
    case fileNotFound(String)
    case invalidConfig(String)
    case iconSetFailed(String)

    var errorDescription: String? {
        switch self {
        case .shellFailed(let msg): return msg
        case .setupIncomplete(let msg): return msg
        case .fileNotFound(let msg): return msg
        case .invalidConfig(let msg): return msg
        case .iconSetFailed(let msg): return msg
        }
    }
}

// MARK: - Root Command

@main
struct IconChangerCLI: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "iconchanger",
        abstract: "Command-line interface for IconChanger — manage macOS app icons",
        version: "2.1.0",
        subcommands: [
            StatusCommand.self,
            ListCommand.self,
            SetIconCommand.self,
            RemoveIconCommand.self,
            RestoreCommand.self,
            ImportCommand.self,
            ExportCommand.self,
            ValidateCommand.self,
            EscapeJailCommand.self,
            RefreshDockCommand.self,
            CompletionsCommand.self,
        ]
    )
}

// MARK: - status

struct StatusCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "status",
        abstract: "Show setup status and statistics"
    )

    @Flag(name: .shortAndLong, help: "Show detailed status")
    var verbose = false

    func run() throws {
        let fm = FileManager.default

        // Helper files
        let helperOK = fm.fileExists(atPath: helperScript.path)
        let fileiconOK = fm.fileExists(atPath: fileicon.path)
        let helpersOK = helperOK && fileiconOK

        // Sudoers
        var sudoersOK = false
        if let result = try? shell("sudo -n -l 2>/dev/null | grep -q helper.sh && echo ok || echo no") {
            sudoersOK = result == "ok"
        }

        // Stats
        let aliases = loadAliases()
        let cached = loadCachedIcons()

        print("IconChanger CLI Status")
        print("──────────────────────")
        print("  Helper files:  \(helpersOK ? "✓ Installed" : "✗ Missing")")
        print("  Sudo access:   \(sudoersOK ? "✓ Configured" : "✗ Not configured")")
        print("  Aliases:       \(aliases.count)")
        print("  Cached icons:  \(cached.count)")
        print("  Setup:         \(helpersOK && sudoersOK ? "✓ Ready" : "✗ Run IconChanger app to complete setup")")

        if verbose {
            print("")
            print("Paths:")
            print("  Config dir:    \(iconchangerDir.path)")
            print("  Cache dir:     \(cacheDir.path)")
            print("  Helper:        \(helperScript.path) \(helperOK ? "✓" : "✗")")
            print("  Fileicon:      \(fileicon.path) \(fileiconOK ? "✓" : "✗")")

            let plistPath = NSHomeDirectory() + "/Library/Preferences/\(appBundleID).plist"
            let plistOK = fm.fileExists(atPath: plistPath)
            print("  App defaults:  \(plistPath) \(plistOK ? "✓" : "✗")")
        }
    }
}

// MARK: - list

struct ListCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List aliases and cached icons"
    )

    @Flag(name: .long, help: "Show only aliases")
    var aliases = false

    @Flag(name: .long, help: "Show only cached icons")
    var icons = false

    func run() throws {
        let showAll = !aliases && !icons

        if showAll || aliases {
            let aliasMap = loadAliases()
            if aliasMap.isEmpty {
                print("No aliases configured.")
            } else {
                print("Aliases (\(aliasMap.count)):")
                for (app, alias) in aliasMap.sorted(by: { $0.key < $1.key }) {
                    print("  \(app) → \(alias)")
                }
            }

            if showAll { print("") }
        }

        if showAll || icons {
            let cached = loadCachedIcons()
            if cached.isEmpty {
                print("No cached icons.")
            } else {
                print("Cached Icons (\(cached.count)):")
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                formatter.timeStyle = .short

                for icon in cached.values.sorted(by: { $0.appName < $1.appName }) {
                    let exists = FileManager.default.fileExists(atPath: icon.appPath) ? "" : " [app missing]"
                    let iconFile = cacheDir.appendingPathComponent(icon.iconFileName)
                    let hasIcon = FileManager.default.fileExists(atPath: iconFile.path) ? "" : " [icon file missing]"
                    print("  \(icon.appName)\(exists)\(hasIcon)")
                    print("    Path:   \(icon.appPath)")
                    print("    Cached: \(formatter.string(from: icon.timestamp))")
                }
            }
        }
    }
}

// MARK: - set-icon

struct SetIconCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "set-icon",
        abstract: "Set a custom icon on an app"
    )

    @Argument(help: "Path to the .app bundle")
    var appPath: String

    @Argument(help: "Path to the icon image (PNG, ICNS, JPEG, etc.)")
    var iconPath: String

    func run() throws {
        let fm = FileManager.default

        // Resolve paths
        let resolvedApp = resolve(path: appPath)
        let resolvedIcon = resolve(path: iconPath)

        guard fm.fileExists(atPath: resolvedApp) else {
            throw CLIError.fileNotFound("App not found: \(resolvedApp)")
        }
        guard fm.fileExists(atPath: resolvedIcon) else {
            throw CLIError.fileNotFound("Icon file not found: \(resolvedIcon)")
        }
        guard resolvedApp.hasSuffix(".app") else {
            throw ValidationError("Target must be an .app bundle: \(resolvedApp)")
        }

        // Check setup
        guard fm.fileExists(atPath: helperScript.path),
              fm.fileExists(atPath: fileicon.path) else {
            throw CLIError.setupIncomplete("Helper files not found. Run the IconChanger app to complete setup first.")
        }

        // Run helper
        let command = "sudo -n '\(helperScript.path.shellEscaped)' '\(fileicon.path.shellEscaped)' '\(resolvedApp.shellEscaped)' '\(resolvedIcon.shellEscaped)'"

        do {
            try shell(command)
        } catch {
            throw CLIError.iconSetFailed("Failed to set icon: \(error.localizedDescription)\n\nMake sure sudoers is configured. Run the IconChanger app to set up permissions.")
        }

        print("✓ Icon set successfully on \(URL(fileURLWithPath: resolvedApp).lastPathComponent)")
    }
}

// MARK: - remove-icon

struct RemoveIconCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "remove-icon",
        abstract: "Remove custom icon from an app (restore default)"
    )

    @Argument(help: "Path to the .app bundle")
    var appPath: String

    func run() throws {
        let resolvedApp = resolve(path: appPath)

        guard FileManager.default.fileExists(atPath: resolvedApp) else {
            throw CLIError.fileNotFound("App not found: \(resolvedApp)")
        }

        // Read FinderInfo
        let finderInfoName = "com.apple.FinderInfo"
        var finderInfo = [UInt8](repeating: 0, count: 32)
        let size = getxattr(resolvedApp, finderInfoName, &finderInfo, 32, 0, 0)

        if size > 0 && (finderInfo[8] & 0x04 != 0) {
            // Clear custom icon flag
            finderInfo[8] = finderInfo[8] & ~0x04

            let allZero = finderInfo.allSatisfy { $0 == 0 }
            if allZero {
                removexattr(resolvedApp, finderInfoName, 0)
            } else {
                let result = setxattr(resolvedApp, finderInfoName, &finderInfo, 32, 0, 0)
                if result != 0 {
                    // Try with sudo
                    let hexBytes = finderInfo.map { String(format: "%02x", $0) }.joined()
                    let cmd = "sudo -n python3 -c \"import xattr; xattr.setxattr('\(resolvedApp.shellEscaped)', '\(finderInfoName)', bytes.fromhex('\(hexBytes)'))\""
                    _ = try? shell(cmd)
                }
            }
        }

        // Remove Icon\r file
        let iconFile = URL(fileURLWithPath: resolvedApp).appendingPathComponent("Icon\r")
        if FileManager.default.fileExists(atPath: iconFile.path) {
            try? FileManager.default.removeItem(at: iconFile)
        }

        let appName = URL(fileURLWithPath: resolvedApp).deletingPathExtension().lastPathComponent
        print("✓ Default icon restored for \(appName)")
    }
}

// MARK: - restore

struct RestoreCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "restore",
        abstract: "Restore cached custom icons to apps"
    )

    @Argument(help: "App name or path to restore (omit to restore all)")
    var target: String?

    @Flag(name: .shortAndLong, help: "Show what would be done without making changes")
    var dryRun = false

    @Flag(name: .shortAndLong, help: "Show detailed output")
    var verbose = false

    func run() throws {
        let fm = FileManager.default
        let cached = loadCachedIcons()

        guard !cached.isEmpty else {
            print("No cached icons to restore.")
            return
        }

        // Check setup
        guard fm.fileExists(atPath: helperScript.path),
              fm.fileExists(atPath: fileicon.path) else {
            throw CLIError.setupIncomplete("Helper files not found. Run the IconChanger app to complete setup first.")
        }

        // Filter targets
        let toRestore: [CachedIcon]
        if let target = target {
            let lowered = target.lowercased()
            toRestore = cached.values.filter {
                $0.appName.lowercased().contains(lowered) ||
                $0.appPath.lowercased().contains(lowered)
            }
            guard !toRestore.isEmpty else {
                throw ValidationError("No cached icon found matching '\(target)'")
            }
        } else {
            toRestore = Array(cached.values)
        }

        var success = 0
        var failed = 0
        var skipped = 0

        for icon in toRestore.sorted(by: { $0.appName < $1.appName }) {
            let iconFile = cacheDir.appendingPathComponent(icon.iconFileName)

            guard fm.fileExists(atPath: icon.appPath) else {
                if verbose { print("  ⊘ \(icon.appName) — app not found at \(icon.appPath)") }
                skipped += 1
                continue
            }

            guard fm.fileExists(atPath: iconFile.path) else {
                if verbose { print("  ⊘ \(icon.appName) — cached icon file missing") }
                skipped += 1
                continue
            }

            if dryRun {
                print("  → Would restore \(icon.appName)")
                success += 1
                continue
            }

            let command = "sudo -n '\(helperScript.path.shellEscaped)' '\(fileicon.path.shellEscaped)' '\(icon.appPath.shellEscaped)' '\(iconFile.path.shellEscaped)'"

            do {
                try shell(command)
                if verbose { print("  ✓ \(icon.appName)") }
                success += 1
            } catch {
                if verbose { print("  ✗ \(icon.appName) — \(error.localizedDescription)") }
                failed += 1
            }
        }

        print("")
        if dryRun {
            print("Dry run: \(success) icon(s) would be restored, \(skipped) skipped")
        } else {
            print("\(success) restored, \(failed) failed, \(skipped) skipped")
        }
    }
}

// MARK: - import

struct ImportCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "import",
        abstract: "Import an IconChanger configuration"
    )

    @Argument(help: "Path to configuration file (.json)")
    var configPath: String

    @Flag(name: .shortAndLong, help: "Validate the configuration without importing")
    var dryRun = false

    func run() throws {
        let resolvedPath = resolve(path: configPath)

        guard FileManager.default.fileExists(atPath: resolvedPath) else {
            throw CLIError.fileNotFound("Configuration file not found: \(resolvedPath)")
        }

        let configURL = URL(fileURLWithPath: resolvedPath)

        // Validate first
        let config: AppConfiguration
        do {
            config = try validateConfig(at: configURL)
        } catch {
            throw CLIError.invalidConfig("Invalid configuration file: \(error.localizedDescription)")
        }

        print("Configuration: v\(config.version)")
        print("  Aliases: \(config.appAliases.count)")
        print("  Icons:   \(config.cachedIcons.count)")

        if dryRun {
            print("\nDry run — no changes made.")
            return
        }

        // Copy to shared directory for app to pick up
        let configData = try Data(contentsOf: configURL)
        let importedConfigFile = sharedConfigDir.appendingPathComponent("imported_config.json")
        try configData.write(to: importedConfigFile, options: .atomic)

        let flagFile = sharedConfigDir.appendingPathComponent("pending_import")
        try Data().write(to: flagFile, options: .atomic)

        print("\n✓ Configuration staged for import.")
        print("  Restart IconChanger to apply changes.")
    }
}

// MARK: - export

struct ExportCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "export",
        abstract: "Export IconChanger configuration"
    )

    @Argument(help: "Path to save the configuration file")
    var outputPath: String

    @Flag(name: .shortAndLong, help: "Overwrite existing file without prompting")
    var force = false

    func run() throws {
        let resolvedOutput = resolve(path: outputPath)

        // Check for latest export from app
        let latestExportFile = sharedConfigDir.appendingPathComponent("latest_export.json")

        guard FileManager.default.fileExists(atPath: latestExportFile.path) else {
            throw CLIError.fileNotFound("No exported configuration found.\nUse the IconChanger app to export your configuration first,\nor use: iconchanger export-direct <path>")
        }

        // Check if output file already exists
        if FileManager.default.fileExists(atPath: resolvedOutput) && !force {
            print("File already exists: \(resolvedOutput)")
            print("Use --force to overwrite.")
            throw ExitCode.failure
        }

        let configData = try Data(contentsOf: latestExportFile)

        // Validate before writing
        _ = try JSONDecoder().decode(AppConfiguration.self, from: configData)

        let outputURL = URL(fileURLWithPath: resolvedOutput)

        // Ensure parent directory exists
        let parentDir = outputURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: parentDir, withIntermediateDirectories: true)

        try configData.write(to: outputURL, options: .atomic)

        print("✓ Configuration exported to \(resolvedOutput)")
    }
}

// MARK: - validate

struct ValidateCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "validate",
        abstract: "Validate a configuration file"
    )

    @Argument(help: "Path to configuration file (.json)")
    var configPath: String

    func run() throws {
        let resolvedPath = resolve(path: configPath)

        guard FileManager.default.fileExists(atPath: resolvedPath) else {
            throw CLIError.fileNotFound("File not found: \(resolvedPath)")
        }

        let configURL = URL(fileURLWithPath: resolvedPath)
        let config: AppConfiguration

        do {
            config = try validateConfig(at: configURL)
        } catch {
            print("✗ Invalid configuration: \(error.localizedDescription)")
            throw ExitCode.failure
        }

        // Detailed validation
        var warnings: [String] = []

        for alias in config.appAliases {
            if alias.appName.isEmpty {
                warnings.append("Empty app name in alias entry")
            }
            if alias.aliasName.isEmpty {
                warnings.append("Empty alias name for '\(alias.appName)'")
            }
        }

        for icon in config.cachedIcons {
            if icon.iconData.isEmpty {
                warnings.append("Empty icon data for '\(icon.appName)'")
            }
            if !FileManager.default.fileExists(atPath: icon.appPath) {
                warnings.append("App not found: \(icon.appPath) (\(icon.appName))")
            }
        }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium

        print("✓ Valid configuration file")
        print("  Version:     \(config.version)")
        print("  Export date: \(formatter.string(from: config.exportDate))")
        print("  Aliases:     \(config.appAliases.count)")
        print("  Icons:       \(config.cachedIcons.count)")

        let totalIconSize = config.cachedIcons.reduce(0) { $0 + $1.iconData.count }
        print("  Icon data:   \(ByteCountFormatter.string(fromByteCount: Int64(totalIconSize), countStyle: .file))")

        if !warnings.isEmpty {
            print("\nWarnings:")
            for w in warnings {
                print("  ⚠ \(w)")
            }
        }
    }
}

// MARK: - escape-jail

struct EscapeJailCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "escape-jail",
        abstract: "Escape macOS Tahoe squircle jail by re-applying bundled icons as custom icons"
    )

    @Argument(help: "Path to a specific .app bundle (omit to process all apps in /Applications)")
    var appPath: String?

    @Flag(name: .shortAndLong, help: "Show what would be done without making changes")
    var dryRun = false

    @Flag(name: .shortAndLong, help: "Show detailed output")
    var verbose = false

    func run() throws {
        let fm = FileManager.default

        // Check setup
        guard fm.fileExists(atPath: helperScript.path),
              fm.fileExists(atPath: fileicon.path) else {
            throw CLIError.setupIncomplete("Helper files not found. Run the IconChanger app to complete setup first.")
        }

        if let appPath = appPath {
            // Single app mode
            let resolved = resolve(path: appPath)
            guard fm.fileExists(atPath: resolved) else {
                throw CLIError.fileNotFound("App not found: \(resolved)")
            }
            guard resolved.hasSuffix(".app") else {
                throw ValidationError("Target must be an .app bundle: \(resolved)")
            }

            try processApp(atPath: resolved, dryRun: dryRun, verbose: verbose)
        } else {
            // Batch mode: scan /Applications
            let appsDir = "/Applications"
            guard let contents = try? fm.contentsOfDirectory(atPath: appsDir) else {
                throw CLIError.fileNotFound("Cannot read /Applications")
            }

            let apps = contents.filter { $0.hasSuffix(".app") }.sorted()
            var processed = 0
            var skipped = 0
            var failed = 0

            for appName in apps {
                let fullPath = "\(appsDir)/\(appName)"

                // Check if already has custom icon
                let finderInfoName = "com.apple.FinderInfo"
                var finderInfo = [UInt8](repeating: 0, count: 32)
                let size = getxattr(fullPath, finderInfoName, &finderInfo, 32, 0, 0)
                if size > 0 && (finderInfo[8] & 0x04 != 0) {
                    if verbose { print("  ⊘ \(appName) — already has custom icon") }
                    skipped += 1
                    continue
                }

                do {
                    try processApp(atPath: fullPath, dryRun: dryRun, verbose: verbose)
                    processed += 1
                } catch {
                    if verbose { print("  ✗ \(appName) — \(error.localizedDescription)") }
                    failed += 1
                }
            }

            print("")
            if dryRun {
                print("Dry run: \(processed) app(s) would escape jail, \(skipped) skipped, \(failed) failed")
            } else {
                print("\(processed) escaped, \(skipped) skipped, \(failed) failed")
            }
        }
    }

    private func processApp(atPath path: String, dryRun: Bool, verbose: Bool) throws {
        let appURL = URL(fileURLWithPath: path)
        let appName = appURL.deletingPathExtension().lastPathComponent

        // Read Info.plist to find the bundled icon
        let plistURL = appURL.appendingPathComponent("Contents").appendingPathComponent("Info.plist")
        guard let plist = NSDictionary(contentsOf: plistURL) as? [String: Any] else {
            throw CLIError.fileNotFound("Cannot read Info.plist for \(appName)")
        }

        guard var iconFileName = plist["CFBundleIconFile"] as? String else {
            throw CLIError.fileNotFound("No CFBundleIconFile in \(appName)")
        }
        if !iconFileName.hasSuffix(".icns") {
            iconFileName += ".icns"
        }

        let iconPath = appURL
            .appendingPathComponent("Contents")
            .appendingPathComponent("Resources")
            .appendingPathComponent(iconFileName)
            .path

        guard FileManager.default.fileExists(atPath: iconPath) else {
            throw CLIError.fileNotFound("Icon file not found: \(iconPath)")
        }

        if dryRun {
            print("  → Would escape jail for \(appName)")
            return
        }

        // Apply the app's own icon as a custom icon via fileicon
        let command = "sudo -n '\(helperScript.path.shellEscaped)' '\(fileicon.path.shellEscaped)' '\(path.shellEscaped)' '\(iconPath.shellEscaped)'"
        try shell(command)

        if verbose {
            print("  ✓ \(appName)")
        } else {
            print("✓ Escaped squircle jail for \(appName)")
        }
    }
}

// MARK: - refresh-dock

struct RefreshDockCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "refresh-dock",
        abstract: "Restart the Dock to refresh all icon displays"
    )

    func run() throws {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/killall")
        task.arguments = ["Dock"]
        try task.run()
        task.waitUntilExit()
        print("✓ Dock restarted")
    }
}

// MARK: - completions

struct CompletionsCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "completions",
        abstract: "Generate shell completion scripts",
        discussion: """
        Install completions for your shell:

          # Zsh (add to ~/.zshrc)
          source <(iconchanger completions zsh)

          # Bash (add to ~/.bashrc)
          source <(iconchanger completions bash)

          # Fish (save to completions directory)
          iconchanger completions fish > ~/.config/fish/completions/iconchanger.fish
        """
    )

    @Argument(help: "Shell type: zsh, bash, or fish")
    var shellName: String

    func run() throws {
        let shellLower = shellName.lowercased()
        guard ["zsh", "bash", "fish"].contains(shellLower) else {
            throw ValidationError("Unsupported shell '\(shellName)'. Use zsh, bash, or fish.")
        }

        let script = IconChangerCLI.completionScript(for: shellType(shellLower))
        print(script)
    }

    private func shellType(_ name: String) -> CompletionShell {
        switch name {
        case "zsh": return .zsh
        case "bash": return .bash
        case "fish": return .fish
        default: return .zsh
        }
    }
}

// MARK: - Path Resolution Helper

private func resolve(path: String) -> String {
    if path.hasPrefix("/") {
        return path
    }
    if path.hasPrefix("~") {
        return (path as NSString).expandingTildeInPath
    }
    let cwd = FileManager.default.currentDirectoryPath
    return URL(fileURLWithPath: cwd).appendingPathComponent(path).standardized.path
}
