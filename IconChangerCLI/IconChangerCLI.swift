//
//  main.swift
//  IconChangerCLI
//
//  Created by Zane on 3/26/25.
//

import Foundation
import ArgumentParser

// MARK: - Shared Paths & Constants

private let appBundleID = "com.zhuhaoyu.IconChanger"

/// Legacy root from pre-migration versions (`~/.iconchanger/`).
private let legacyRoot: URL = FileManager.default.homeDirectoryForCurrentUser
    .appendingPathComponent(".iconchanger", isDirectory: true)

private let cachesRoot: URL = {
    let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        .appendingPathComponent(appBundleID, isDirectory: true)
    try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    return url
}()

private let applicationSupportRoot: URL = {
    let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        .appendingPathComponent(appBundleID, isDirectory: true)
    try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    return url
}()

private let sharedConfigDir: URL = {
    let url = applicationSupportRoot.appendingPathComponent("config", isDirectory: true)
    try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    return url
}()

private let cacheDir: URL = {
    let url = cachesRoot.appendingPathComponent("cache", isDirectory: true)
    try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    return url
}()

private let appearanceIconsDir: URL = {
    let url = applicationSupportRoot.appendingPathComponent("appearance-icons", isDirectory: true)
    try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    return url
}()

private let appearanceMetadataFile = applicationSupportRoot.appendingPathComponent("appearance-icons.json")

private let helperScript = URL(fileURLWithPath: "/usr/local/lib/iconchanger/helper.sh")
private let fileicon = URL(fileURLWithPath: "/usr/local/lib/iconchanger/fileicon")

/// Idempotent one-time migration from legacy `~/.iconchanger/` layout.
/// Kept in sync with the GUI app's `AppPaths.migrateLegacyDirectoryIfNeeded()`.
private func migrateLegacyDirectoryIfNeeded() {
    let fm = FileManager.default
    guard fm.fileExists(atPath: legacyRoot.path) else { return }

    let applicationSupportHistoryDir = applicationSupportRoot.appendingPathComponent("history", isDirectory: true)
    let applicationSupportFavoritesDir = applicationSupportRoot.appendingPathComponent("favorites", isDirectory: true)

    let dirMoves: [(from: URL, to: URL)] = [
        (legacyRoot.appendingPathComponent("cache", isDirectory: true), cacheDir),
        (legacyRoot.appendingPathComponent("history", isDirectory: true), applicationSupportHistoryDir),
        (legacyRoot.appendingPathComponent("favorites", isDirectory: true), applicationSupportFavoritesDir),
        (legacyRoot.appendingPathComponent("config", isDirectory: true), sharedConfigDir)
    ]
    for move in dirMoves where fm.fileExists(atPath: move.from.path) {
        try? fm.createDirectory(at: move.to, withIntermediateDirectories: true)
        if let items = try? fm.contentsOfDirectory(atPath: move.from.path) {
            for item in items {
                let src = move.from.appendingPathComponent(item)
                let dst = move.to.appendingPathComponent(item)
                if fm.fileExists(atPath: dst.path) {
                    try? fm.removeItem(at: src)
                } else {
                    try? fm.moveItem(at: src, to: dst)
                }
            }
        }
        if let remaining = try? fm.contentsOfDirectory(atPath: move.from.path), remaining.isEmpty {
            try? fm.removeItem(at: move.from)
        }
    }

    let legacyFetchCache = legacyRoot.appendingPathComponent("icon_fetch_cache.json")
    if fm.fileExists(atPath: legacyFetchCache.path) {
        let destination = cachesRoot.appendingPathComponent("icon_fetch_cache.json")
        if !fm.fileExists(atPath: destination.path) {
            try? fm.moveItem(at: legacyFetchCache, to: destination)
        } else {
            try? fm.removeItem(at: legacyFetchCache)
        }
    }

    let remaining = (try? fm.contentsOfDirectory(atPath: legacyRoot.path)) ?? []
    let nonIgnored = remaining.filter { $0 != ".DS_Store" }
    if nonIgnored.isEmpty {
        try? fm.removeItem(at: legacyRoot)
    }
}

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
    let appVersion: String?
}

private func loadCachedIcons() -> [String: CachedIcon] {
    guard let data = appDefaults()["com.iconchanger.cachedIcons"] as? Data,
          let icons = try? JSONDecoder().decode([String: CachedIcon].self, from: data) else {
        return [:]
    }
    return icons
}

// MARK: - Config Validation

private enum ConfigurationValue: Codable {
    case bool(Bool)
    case int(Int)
    case double(Double)
    case string(String)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Bool.self) { self = .bool(value) }
        else if let value = try? container.decode(Int.self) { self = .int(value) }
        else if let value = try? container.decode(Double.self) { self = .double(value) }
        else { self = .string(try container.decode(String.self)) }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .bool(let value): try container.encode(value)
        case .int(let value): try container.encode(value)
        case .double(let value): try container.encode(value)
        case .string(let value): try container.encode(value)
        }
    }

    init?(_ value: Any) {
        switch value {
        case let value as Bool: self = .bool(value)
        case let value as Int: self = .int(value)
        case let value as Double: self = .double(value)
        case let value as String: self = .string(value)
        default: return nil
        }
    }
}

private struct AppConfiguration: Codable {
    var appAliases: [AliasConfig] = []
    var cachedIcons: [IconCacheConfig] = []
    var appearanceIcons: [AppearanceIconConfig] = []
    var settings: [String: ConfigurationValue]? = nil
    var version: String = "3.0"
    var exportDate: Date = Date()

    private enum CodingKeys: String, CodingKey {
        case appAliases, cachedIcons, appearanceIcons, settings, version, exportDate
    }

    init() {}

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        appAliases = try values.decodeIfPresent([AliasConfig].self, forKey: .appAliases) ?? []
        cachedIcons = try values.decodeIfPresent([IconCacheConfig].self, forKey: .cachedIcons) ?? []
        appearanceIcons = try values.decodeIfPresent([AppearanceIconConfig].self, forKey: .appearanceIcons) ?? []
        settings = try values.decodeIfPresent([String: ConfigurationValue].self, forKey: .settings)
        version = try values.decodeIfPresent(String.self, forKey: .version) ?? "1.0"
        exportDate = try values.decodeIfPresent(Date.self, forKey: .exportDate) ?? Date()
    }
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
    var appVersion: String?
}

private struct AppearanceIconConfig: Codable {
    var appPath: String
    var appName: String
    var lightIconData: Data?
    var darkIconData: Data?
}

private struct StoredAppearanceIconConfig: Codable {
    var appPath: String
    var appName: String
    var lightIconFileName: String?
    var darkIconFileName: String?
    var lastAppliedAppearance: String?
    var updatedAt: Date

    private enum CodingKeys: String, CodingKey {
        case appPath, appName, lightIconFileName, darkIconFileName
        case lastAppliedAppearance, updatedAt
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        appPath = try values.decode(String.self, forKey: .appPath)
        appName = try values.decode(String.self, forKey: .appName)
        lightIconFileName = try values.decodeIfPresent(String.self, forKey: .lightIconFileName)
        darkIconFileName = try values.decodeIfPresent(String.self, forKey: .darkIconFileName)
        lastAppliedAppearance = try values.decodeIfPresent(
            String.self,
            forKey: .lastAppliedAppearance
        )
        updatedAt = try values.decodeIfPresent(Date.self, forKey: .updatedAt) ?? Date()
    }
}

private func loadAppearanceIcons() -> [String: StoredAppearanceIconConfig] {
    guard let data = try? Data(contentsOf: appearanceMetadataFile),
          let decoded = try? JSONDecoder().decode(
            [String: StoredAppearanceIconConfig].self,
            from: data
          ) else {
        return [:]
    }
    return decoded
}

private func removeCachedConfiguration(for appPath: String) {
    let fm = FileManager.default
    var cached = loadCachedIcons()
    if let removed = cached.removeValue(forKey: appPath) {
        try? fm.removeItem(at: cacheDir.appendingPathComponent(removed.iconFileName))
        if let data = try? JSONEncoder().encode(cached),
           let defaults = UserDefaults(suiteName: appBundleID) {
            defaults.set(data, forKey: "com.iconchanger.cachedIcons")
        }
    }

    var appearances = loadAppearanceIcons()
    if let removed = appearances.removeValue(forKey: appPath) {
        for fileName in [removed.lightIconFileName, removed.darkIconFileName].compactMap({ $0 }) {
            guard fileName.hasSuffix(".png"),
                  !fileName.contains("/"),
                  !fileName.contains("\\"),
                  UUID(uuidString: String(fileName.dropLast(4))) != nil else {
                continue
            }
            try? fm.removeItem(at: appearanceIconsDir.appendingPathComponent(fileName))
        }
        if let data = try? JSONEncoder().encode(appearances) {
            try? data.write(to: appearanceMetadataFile, options: .atomic)
            try? fm.setAttributes(
                [.posixPermissions: 0o600],
                ofItemAtPath: appearanceMetadataFile.path
            )
        }
    }
}

private func appearanceIconURL(
    _ config: StoredAppearanceIconConfig,
    dark: Bool
) -> URL? {
    let candidate = dark ? config.darkIconFileName : config.lightIconFileName
    guard let candidate,
          candidate.hasSuffix(".png"),
          !candidate.contains("/"),
          !candidate.contains("\\"),
          UUID(uuidString: String(candidate.dropLast(4))) != nil else {
        return nil
    }
    return appearanceIconsDir.appendingPathComponent(candidate)
}

private func currentSystemUsesDarkAppearance() -> Bool {
    let global = UserDefaults.standard.persistentDomain(forName: UserDefaults.globalDomain)
    return (global?["AppleInterfaceStyle"] as? String)?
        .caseInsensitiveCompare("Dark") == .orderedSame
}

private func refreshDockTwice() throws {
    _ = try shell("killall Dock")
    Thread.sleep(forTimeInterval: 1)
    _ = try shell("killall Dock")
}

private func validateConfig(at url: URL) throws -> AppConfiguration {
    guard let fileSize = try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize,
          fileSize > 0,
          fileSize <= 768 * 1_024 * 1_024 else {
        throw CLIError.invalidConfig("Configuration file exceeds safe size limits")
    }
    let data = try Data(contentsOf: url)
    let config = try JSONDecoder().decode(AppConfiguration.self, from: data)
    let iconData = config.cachedIcons.map(\.iconData)
        + config.appearanceIcons.flatMap { [$0.lightIconData, $0.darkIconData].compactMap { $0 } }
    guard iconData.count <= 2_000,
          iconData.allSatisfy({ $0.count <= 20 * 1_024 * 1_024 }),
          iconData.reduce(0, { $0 + $1.count }) <= 512 * 1_024 * 1_024 else {
        throw CLIError.invalidConfig("Configuration icon data exceeds safe size limits")
    }
    return config
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

    static func main() {
        migrateLegacyDirectoryIfNeeded()
        Self.main(nil)
    }
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
        let appearanceSlots = loadAppearanceIcons().values.reduce(0) {
            $0 + ($1.lightIconFileName == nil ? 0 : 1) + ($1.darkIconFileName == nil ? 0 : 1)
        }

        print("IconChanger CLI Status")
        print("──────────────────────")
        print("  Helper files:  \(helpersOK ? "✓ Installed" : "✗ Missing")")
        print("  Sudo access:   \(sudoersOK ? "✓ Configured" : "✗ Not configured")")
        print("  Aliases:       \(aliases.count)")
        print("  Cached icons:  \(cached.count)")
        print("  Light/Dark:    \(appearanceSlots) slots")
        print("  Setup:         \(helpersOK && sudoersOK ? "✓ Ready" : "✗ Run IconChanger app to complete setup")")

        if verbose {
            print("")
            print("Paths:")
            print("  Config dir:    \(sharedConfigDir.path)")
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

            let appearance = loadAppearanceIcons()
            if !appearance.isEmpty {
                print("\nLight/Dark Icons (\(appearance.count) apps):")
                for icon in appearance.values.sorted(by: { $0.appName < $1.appName }) {
                    let light = icon.lightIconFileName == nil ? "—" : "light"
                    let dark = icon.darkIconFileName == nil ? "—" : "dark"
                    print("  \(icon.appName): \(light) / \(dark)")
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
        let fm = FileManager.default

        guard fm.fileExists(atPath: resolvedApp) else {
            throw CLIError.fileNotFound("App not found: \(resolvedApp)")
        }
        guard fm.fileExists(atPath: helperScript.path),
              fm.fileExists(atPath: fileicon.path) else {
            throw CLIError.setupIncomplete(
                "Helper files not found. Run the IconChanger app to complete setup first."
            )
        }
        let command = "sudo -n '\(helperScript.path.shellEscaped)' --remove '\(fileicon.path.shellEscaped)' '\(resolvedApp.shellEscaped)'"
        try shell(command)
        removeCachedConfiguration(for: resolvedApp)

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
        let appearances = loadAppearanceIcons()
        let switchingEnabled = appDefaults()["enableAppearanceIconSwitching"] as? Bool ?? false
        let dark = currentSystemUsesDarkAppearance()
        let allPaths = Set(cached.keys).union(appearances.keys)

        guard !allPaths.isEmpty else {
            print("No cached icons to restore.")
            return
        }

        // Check setup
        guard fm.fileExists(atPath: helperScript.path),
              fm.fileExists(atPath: fileicon.path) else {
            throw CLIError.setupIncomplete("Helper files not found. Run the IconChanger app to complete setup first.")
        }

        let selectedPaths: [String]
        if let target {
            let lowered = target.lowercased()
            selectedPaths = allPaths.filter { path in
                let name = cached[path]?.appName ?? appearances[path]?.appName ?? ""
                return name.lowercased().contains(lowered) || path.lowercased().contains(lowered)
            }
            guard !selectedPaths.isEmpty else {
                throw ValidationError("No cached icon found matching '\(target)'")
            }
        } else {
            selectedPaths = Array(allPaths)
        }

        var success = 0
        var failed = 0
        var skipped = 0

        for appPath in selectedPaths.sorted() {
            let normal = cached[appPath]
            let appearance = appearances[appPath]
            let appName = normal?.appName ?? appearance?.appName
                ?? URL(fileURLWithPath: appPath).deletingPathExtension().lastPathComponent
            let appearanceURL = switchingEnabled
                ? appearance.flatMap { config -> URL? in
                    guard config.lightIconFileName != nil, config.darkIconFileName != nil else {
                        return nil
                    }
                    return appearanceIconURL(config, dark: dark)
                }
                : nil
            let iconFile = appearanceURL ?? normal.map {
                cacheDir.appendingPathComponent($0.iconFileName)
            }

            guard fm.fileExists(atPath: appPath) else {
                if verbose { print("  ⊘ \(appName) — app not found at \(appPath)") }
                skipped += 1
                continue
            }

            guard let iconFile, fm.fileExists(atPath: iconFile.path) else {
                if verbose { print("  ⊘ \(appName) — eligible cached icon file missing") }
                skipped += 1
                continue
            }

            if dryRun {
                print("  → Would restore \(appName)")
                success += 1
                continue
            }

            let command = "sudo -n '\(helperScript.path.shellEscaped)' '\(fileicon.path.shellEscaped)' '\(appPath.shellEscaped)' '\(iconFile.path.shellEscaped)'"

            do {
                try shell(command)
                if verbose { print("  ✓ \(appName)") }
                success += 1
            } catch {
                if verbose { print("  ✗ \(appName) — \(error.localizedDescription)") }
                failed += 1
            }
        }

        if !dryRun, success > 0 {
            try refreshDockTwice()
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
        print("  Light/Dark apps: \(config.appearanceIcons.count)")
        print("  Settings: \(config.settings?.count ?? 0)")

        if dryRun {
            print("\nDry run — no changes made.")
            return
        }

        // Copy to shared directory for app to pick up
        let configData = try Data(contentsOf: configURL)
        let importedConfigFile = sharedConfigDir.appendingPathComponent("imported_config.json")
        try configData.write(to: importedConfigFile, options: .atomic)
        try FileManager.default.setAttributes(
            [.posixPermissions: 0o600],
            ofItemAtPath: importedConfigFile.path
        )

        let flagFile = sharedConfigDir.appendingPathComponent("pending_import")
        try Data().write(to: flagFile, options: .atomic)
        try FileManager.default.setAttributes(
            [.posixPermissions: 0o600],
            ofItemAtPath: flagFile.path
        )

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

        // Check if output file already exists
        if FileManager.default.fileExists(atPath: resolvedOutput) && !force {
            print("File already exists: \(resolvedOutput)")
            print("Use --force to overwrite.")
            throw ExitCode.failure
        }

        var config = AppConfiguration()
        config.appAliases = loadAliases().map {
            AliasConfig(appName: $0.key, aliasName: $0.value)
        }
        config.cachedIcons = loadCachedIcons().values.compactMap { icon in
            let url = cacheDir.appendingPathComponent(icon.iconFileName)
            guard let data = try? Data(contentsOf: url) else { return nil }
            return IconCacheConfig(
                appPath: icon.appPath,
                appName: icon.appName,
                iconFileName: icon.iconFileName,
                iconData: data,
                appVersion: icon.appVersion
            )
        }
        config.appearanceIcons = loadAppearanceIcons().values.compactMap { icon in
            let light = appearanceIconURL(icon, dark: false).flatMap { try? Data(contentsOf: $0) }
            let dark = appearanceIconURL(icon, dark: true).flatMap { try? Data(contentsOf: $0) }
            guard light != nil || dark != nil else { return nil }
            return AppearanceIconConfig(
                appPath: icon.appPath,
                appName: icon.appName,
                lightIconData: light,
                darkIconData: dark
            )
        }
        let exportedSettingKeys: Set<String> = [
            "apiRetryCount", "apiTimeoutSeconds", "apiMonthlyLimit", "cacheAPIResults",
            "extendedSearch", "appAppearance", "showCustomIconBadge", "dockPreviewMode",
            "dockPreviewWallpaper", "dockGlassIntensity", "wallpaperBleed", "wallpaperBlur",
            "runInBackground", "showInDock", "showInMenuBar", "launchBehavior",
            "enableScheduledRestore", "scheduledRestoreInterval",
            "customScheduledRestoreInterval", "useCustomScheduledRestoreInterval",
            "enableAutoRestoreOnUpdate", "autoRestoreCheckInterval",
            "enableAppearanceIconSwitching", "appLanguage", "enablePreRelease", "t2e"
        ]
        config.settings = appDefaults().reduce(into: [:]) { result, entry in
            guard exportedSettingKeys.contains(entry.key),
                  let value = ConfigurationValue(entry.value) else { return }
            result[entry.key] = value
        }
        let configData = try JSONEncoder().encode(config)

        let outputURL = URL(fileURLWithPath: resolvedOutput)

        // Ensure parent directory exists
        let parentDir = outputURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: parentDir, withIntermediateDirectories: true)

        try configData.write(to: outputURL, options: .atomic)
        try FileManager.default.setAttributes(
            [.posixPermissions: 0o600],
            ofItemAtPath: outputURL.path
        )

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
        let appearanceSlotCount = config.appearanceIcons.reduce(0) {
            $0 + ($1.lightIconData == nil ? 0 : 1) + ($1.darkIconData == nil ? 0 : 1)
        }
        print("  Light/Dark:  \(appearanceSlotCount)")
        print("  Settings:    \(config.settings?.count ?? 0)")

        let totalIconSize = config.cachedIcons.reduce(0) { $0 + $1.iconData.count }
            + config.appearanceIcons.reduce(0) {
                $0 + ($1.lightIconData?.count ?? 0) + ($1.darkIconData?.count ?? 0)
            }
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
        try refreshDockTwice()
        print("✓ Dock restarted twice")
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
