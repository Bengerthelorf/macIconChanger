//
//  IconManager.swift
//  IconChanger
//
//  Created by 朱浩宇 on 2022/4/27.
//  Modified by Bengerthelorf on 2025/3/21.
//  Modified by CantonMonkey on 2025/10/10.
//

import SwiftUI
import SwiftyJSON
import LaunchPadManagerDBHelper
import os

enum SetupStatus {
    case completed
    case helperFilesMissing(missingFiles: [String])
    case sudoersPermissionMissing
    case unknownError(String)
}

class IconManager: ObservableObject {
    static let shared = IconManager()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "IconManager")
    
    @Published var icons = [(String, String)]()
    @Published var apps: [AppItem] = []
    @Published var needsSetupCheck: Bool = false
    @Published var iconRefreshTrigger = UUID()
    
    var helperDirectoryURL: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".iconchanger", isDirectory: true)
    }
    
    var helperScriptURL: URL {
        helperDirectoryURL.appendingPathComponent("helper.sh")
    }
    
    var fileiconURL: URL {
        helperDirectoryURL.appendingPathComponent("fileicon")
    }
    
    init() {
        let _ = NotificationCenter.default
        
        refresh()
    }
    
    @objc func refresh() {
        Task {
            var allApps: [AppItem] = []
            
            // 1. Fetch from LaunchPad DB
            do {
                let helper = try LaunchPadManagerDBHelper()
                let dbApps = try helper.getAllAppInfos()
                let dbAppItems = dbApps.map { AppItem(id: $0.url, name: $0.name, url: $0.url, originalAppInfo: $0) }
                allApps.append(contentsOf: dbAppItems)
            } catch {
                logger.error("Error fetching LaunchPad apps: \(error.localizedDescription)")
            }
            
            // 2. Scan Filesystem
            let localApps = scanLocalApps()
            
            // 3. Merge (prefer DB apps if duplicate URL)
            let existingURLs = Set(allApps.map { $0.url.path })
            for localApp in localApps {
                if !existingURLs.contains(localApp.url.path) {
                    allApps.append(localApp)
                }
            }
            
            let sortedApps = allApps.sorted(by: { $0.name.localizedStandardCompare($1.name) == .orderedAscending })
            
            await MainActor.run {
                self.apps = sortedApps
            }
        }
    }
    
    func scanLocalApps() -> [AppItem] {
        let fileManager = FileManager.default
        var appItems = [AppItem]()
        
        // Directories to scan
        // Use permissions managed by FolderPermission
        let dirs = FolderPermission.shared.permissions.map { $0.bookmarkedURL }
        
        // If no directories are configured, we don't scan any local paths.
        // Users should add directories in Settings -> Application.
        
        for dir in dirs {
            // Get contents (not recursive deep scan, just top level apps for now as typical behavior)
            guard let contents = try? fileManager.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) else { continue }
            
            for url in contents {
                if url.pathExtension == "app" {
                    let name = url.deletingPathExtension().lastPathComponent
                    appItems.append(AppItem(id: url, name: name, url: url, originalAppInfo: nil))
                }
            }
        }
        
        return appItems
    }
    
    func ensureHelperFilesCopied() {
        logger.log("Ensuring helper files are copied...")
        let helperDir = helperDirectoryURL.path
        
        do {
            if !FileManager.default.fileExists(atPath: helperDir) {
                logger.log("Helper directory does not exist, creating: \(helperDir)")
                try FileManager.default.createDirectory(at: helperDirectoryURL, withIntermediateDirectories: true, attributes: nil)
            } else {
                logger.log("Helper directory exists: \(helperDir)")
            }
            
            guard let fileiconBundlePath = Bundle.main.path(forResource: "fileicon", ofType: nil) else {
                logger.error("Cannot find 'fileicon' in bundle.")
                return
            }
            guard let helperBundlePath = Bundle.main.path(forResource: "helper", ofType: "sh") else {
                logger.error("Cannot find 'helper.sh' in bundle.")
                return
            }
            
            let fileiconDestPath = fileiconURL.path
            let helperDestPath = helperScriptURL.path
            
            if !FileManager.default.fileExists(atPath: fileiconDestPath) {
                logger.log("Copying 'fileicon' from bundle to \(fileiconDestPath)")
                try FileManager.default.copyItem(atPath: fileiconBundlePath, toPath: fileiconDestPath)
                logger.log("'fileicon' copied.")
            } else {
                logger.log("'fileicon' already exists at \(fileiconDestPath)")
            }
            _ = try? Self.safeShell("chmod u+x '\(fileiconDestPath)'")
            
            if !FileManager.default.fileExists(atPath: helperDestPath) {
                logger.log("Copying 'helper.sh' from bundle to \(helperDestPath)")
                try FileManager.default.copyItem(atPath: helperBundlePath, toPath: helperDestPath)
                logger.log("'helper.sh' copied.")
            } else {
                logger.log("'helper.sh' already exists at \(helperDestPath)")
            }
            _ = try? Self.safeShell("chmod u+x '\(helperDestPath)'")
            
            logger.log("ensureHelperFilesCopied finished successfully.")
            
        } catch {
            logger.error("Error during ensureHelperFilesCopied: \(error.localizedDescription)")
        }
    }
    
    
    
    static func saveImage(_ image: NSImage, atUrl url: URL) {
        guard
            let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)
        else {
            return
        } // TODO: handle error
        let newRep = NSBitmapImageRep(cgImage: cgImage)
        newRep.size = image.size
        guard
            let pngData = newRep.representation(using: .png, properties: [:])
        else {
            return
        } // TODO: handle error
        do {
            try pngData.write(to: url)
        } catch {
            print("error saving: \(error)")
        }
    }
    

    
    func setImage(_ image: NSImage, app: AppItem) throws {
        logger.log("setImage called for app: \(app.name)")
        //
        ensureHelperFilesCopied()
        
        // First, cache the icon
        _ = try IconCacheManager.shared.cacheIcon(image: image, for: app.url.universalPath(), appName: app.name)
        logger.log("Icon cached for \(app.name)")
        
        let tempDir = FileManager.default.temporaryDirectory
        let imageURL = tempDir.appendingPathComponent("icon_\(UUID().uuidString).png")
        logger.log("Saving temporary icon to: \(imageURL.path)")
        
        Self.saveImage(image, atUrl: imageURL)
        
        let status = checkSetupStatus()
        guard case .completed = status else {
            logger.error("Setup incomplete (\(String(describing: status))), cannot set icon for \(app.name).")
            let errorDescription: String
            switch status {
            case .helperFilesMissing(let missingFiles):
                errorDescription = "Required helper files are missing: \(missingFiles.joined(separator: ", ")). Please check setup."
            case .sudoersPermissionMissing:
                errorDescription = "Sudo permission for helper script is missing or incorrect. Please check setup."
            default:
                errorDescription = "An unknown setup error occurred. Please check setup."
            }
            throw NSError(domain: "IconManager", code: 11, userInfo: [NSLocalizedDescriptionKey: errorDescription])
        }
        
        try runHelperTool(appPath: app.url.universalPath(), imagePath: imageURL.path)
        
        logger.log("Attempting to remove temporary icon file: \(imageURL.path)")
        try? FileManager.default.removeItem(at: imageURL)
        logger.log("Temporary icon file removed (if existed). setImage finished.")
    }
    
    func setIconWithoutCaching(_ image: NSImage, app: AppItem) async throws {
        logger.log("setIconWithoutCaching called for app: \(app.name)")
        
        ensureHelperFilesCopied()
        
        let status = checkSetupStatus()
        guard case .completed = status else {
            logger.error("Setup incomplete (\(String(describing: status))), cannot set icon without caching for \(app.name).")
            let errorDescription: String
            switch status {
            case .helperFilesMissing(let missingFiles):
                errorDescription = "Required helper files are missing: \(missingFiles.joined(separator: ", ")). Please check setup."
            case .sudoersPermissionMissing:
                errorDescription = "Sudo permission for helper script is missing or incorrect. Please check setup."
            default:
                errorDescription = "An unknown setup error occurred. Please check setup."
            }
            throw NSError(domain: "IconManager", code: 12, userInfo: [NSLocalizedDescriptionKey: errorDescription])
        }
        
        let tempDir = FileManager.default.temporaryDirectory
        let imageURL = tempDir.appendingPathComponent("icon_\(UUID().uuidString).png")
        logger.log("Saving temporary icon to: \(imageURL.path)")
        
        Self.saveImage(image, atUrl: imageURL)
        
        try runHelperTool(appPath: app.url.universalPath(), imagePath: imageURL.path)
        
        logger.log("Attempting to remove temporary icon file: \(imageURL.path)")
        try? FileManager.default.removeItem(at: imageURL)
        logger.log("Temporary icon file removed (if existed). setIconWithoutCaching finished.")
    }
    
    // Restore all cached icons
    func restoreAllCachedIcons() async throws {
        logger.log("Starting restoreAllCachedIcons...")
        let initialStatus = checkSetupStatus()
        guard case .completed = initialStatus else {
            logger.error("Setup incomplete (\(String(describing: initialStatus))), cannot restore icons.")
            let errorDescription: String
            switch initialStatus {
            case .helperFilesMissing(let missingFiles):
                errorDescription = "Required helper files are missing: \(missingFiles.joined(separator: ", ")). Cannot restore icons."
            case .sudoersPermissionMissing:
                errorDescription = "Sudo permission for helper script is missing or incorrect. Cannot restore icons."
            default:
                errorDescription = "An unknown setup error occurred. Cannot restore icons."
            }
            throw NSError(domain: "IconManager", code: 13, userInfo: [NSLocalizedDescriptionKey: errorDescription])
        }
        
        let cachedIcons = IconCacheManager.shared.getAllCachedIcons()
        var failedApps: [(String, Error)] = []
        
        for cache in cachedIcons {
            do {
                let appPath = cache.appPath
                let iconURL = IconCacheManager.cacheDirectory.appendingPathComponent(cache.iconFileName)
                
                // Check if the app and icon still exist
                if FileManager.default.fileExists(atPath: appPath) &&
                    FileManager.default.fileExists(atPath: iconURL.path) {
                    
                    // Load the icon image
                    if let image = NSImage(contentsOf: iconURL) {
                        if let appInfo = apps.first(where: { $0.url.universalPath() == appPath }) {
                            // Set the icon (without re-caching to avoid duplication)
                            try await setIconWithoutCaching(image, app: appInfo)
                            logger.info("Successfully restored icon for \(cache.appName)")
                        } else {
                            logger.warning("App info not found for \(cache.appName) at \(appPath), skipping restore.")
                        }
                    } else {
                        logger.error("Could not load cached icon image for \(cache.appName) from \(iconURL.path)")
                        IconCacheManager.shared.removeCachedIcon(for: appPath) // Remove cache if icon is broken
                        throw RestoreError.iconFileNotFound(cache.appName)
                    }
                } else if !FileManager.default.fileExists(atPath: appPath) {
                    logger.warning("App at path \(appPath) no longer exists, removing cache for \(cache.appName).")
                    // App no longer exists, remove from cache
                    IconCacheManager.shared.removeCachedIcon(for: appPath)
                } else if !FileManager.default.fileExists(atPath: iconURL.path) {
                    logger.warning("Icon file \(cache.iconFileName) missing for \(cache.appName), removing cache.")
                    // Icon file missing, remove from cache
                    IconCacheManager.shared.removeCachedIcon(for: appPath)
                }
            } catch {
                logger.error("Failed to restore icon for \(cache.appName): \(error.localizedDescription)")
                failedApps.append((cache.appName, error))
            }
        }
        
        if !failedApps.isEmpty {
            logger.error("Restore process completed with \(failedApps.count) failures.")
            throw RestoreError.someFailed(failed: failedApps)
        }
    }
    
    func findSearchedImage(_ search: String) -> [AppItem] {
        apps.filter {
            $0.name.localizedCaseInsensitiveContains(search) || $0.url.deletingPathExtension().lastPathComponent.localizedCaseInsensitiveContains(search)
        }
    }
    
    func getIconInPath(_ url: URL) -> [URL] {
        let url = url.appendingPathComponent("Contents").appendingPathComponent("Resources")
        let file = (try? FileManager.default.contentsOfDirectory(atPath: url.path)) ?? [String]()
        return file.filter {
            $0.contains(".icns")
        }
        .map {
            url.appendingPathComponent($0).path
        }
        .map {
            URL(fileURLWithPath: $0)
        }
    }
    

    
    func getIcons(_ app: AppItem, style: IconStyle = .all) async throws -> [IconRes] {
        let appName = app.name
        let urlName = app.url.deletingPathExtension().lastPathComponent
        let bundleName = try getAppBundleName(app)
        let aliasName = AliasName.getName(for: app.url.deletingPathExtension().lastPathComponent)
        
        // Check fetch cache first
        if let cachedIcons = IconFetchCacheManager.shared.getCachedIcons(
            appName: appName,
            bundleName: bundleName,
            aliasName: aliasName,
            style: style.rawValue
        ) {
            logger.log("✅ Using cached icon fetch results for \(appName)")
            return cachedIcons
        }
        
        // Cache miss - fetch from network
        logger.log("❌ Cache miss, fetching icons from network for \(appName)")

        let queryController = MyQueryRequestController.shared
        var orderedQueries: [String] = []
        var seenQueries = Set<String>()

        func appendQuery(_ value: String?) {
            guard let value = value, !value.isEmpty else { return }
            if seenQueries.insert(value).inserted {
                orderedQueries.append(value)
            }
        }

        appendQuery(appName)
        appendQuery(urlName)
        appendQuery(bundleName)
        appendQuery(aliasName)

        let fetchedIcons: [IconRes] = try await withThrowingTaskGroup(of: [IconRes].self) { group in
            for query in orderedQueries {
                group.addTask {
                    try Task.checkCancellation()
                    return try await queryController.sendRequest(query, style: style)
                }
            }

            var aggregated: [IconRes] = []
            for try await icons in group {
                aggregated.append(contentsOf: icons)
            }
            return aggregated
        }

        let uniqueRes = Set(fetchedIcons).map { $0 }.sorted { first, second in
            first.downloads > second.downloads
        }

        // Store in fetch cache
        IconFetchCacheManager.shared.cacheIcons(
            uniqueRes,
            appName: appName,
            bundleName: bundleName,
            aliasName: aliasName,
            style: style.rawValue
        )

        return uniqueRes
    }
    
    func getAppBundleName(_ app: AppItem) throws -> String? {
        let plistURL = app.url.universalappending(path: "Contents").universalappending(path: "Info.plist")
        let plist = (try? NSDictionary(contentsOf: plistURL, error: ())) as? Dictionary<String, AnyObject>
        
        return (plist?["CFBundleDisplayName"] as? String) ?? (plist?["CFBundleName"] as? String)
    }
    
    func runHelperTool(appPath: String, imagePath: String) throws {
        let helperToolPath = self.helperScriptURL.path
        let fileiconPath = self.fileiconURL.path
        
        let command = "sudo -n '\(helperToolPath)' '\(fileiconPath)' '\(appPath)' '\(imagePath)'"
        logger.log("Executing command with -n: \(command)")
        
        let output: String
        do {
            output = try Self.safeShell(command, timeout: 15.0) // 15 second timeout
            logger.log("Helper tool output: \(output)")
        } catch let error as ShellError {
            logger.error("safeShell failed: \(error.localizedDescription)")
            switch error {
            case .commandFailed(let status, let errOutput):
                logger.error("Helper tool exited with status \(status). Output: \(errOutput)")
                throw NSError(domain: "IconManager", code: 10, userInfo: [NSLocalizedDescriptionKey: "Helper tool failed (status: \(status)). Output: \(errOutput). Check sudoers configuration and file permissions."])
            case .timeout:
                logger.error("Helper tool command timed out.")
                throw NSError(domain: "IconManager", code: 14, userInfo: [NSLocalizedDescriptionKey: "Helper tool command timed out. Check for password prompts or system load."])
            case .taskCreationFailed(let underlyingError):
                logger.error("Failed to create task for helper tool: \(underlyingError?.localizedDescription ?? "Unknown reason")")
                throw NSError(domain: "IconManager", code: 15, userInfo: [NSLocalizedDescriptionKey: "Failed to start helper tool process."])
            }
        } catch {
            logger.error("An unexpected error occurred running the helper tool: \(error.localizedDescription)")
            throw error // Re-throw other unexpected errors
        }
        
        if output.lowercased().contains("incorrect password") || output.lowercased().contains("try again") {
            logger.error("Helper tool output suggests a password was required unexpectedly: \(output)")
            // This shouldn't happen if sudoers is correct, but catch it just in case.
            throw NSError(domain: "IconManager", code: 16, userInfo: [NSLocalizedDescriptionKey: "Helper tool unexpectedly asked for a password. Check sudoers configuration. Output: \(output)"])
        } else {
            logger.log("Helper tool executed apparently successfully.")
        }
    }
    
    enum ShellError: Error, LocalizedError {
        case commandFailed(status: Int32, output: String)
        case timeout
        case taskCreationFailed(Error?)
        
        var errorDescription: String? {
            switch self {
            case .commandFailed(let status, let output):
                return "Command failed with status \(status). Output: \(output)"
            case .timeout:
                return "Command timed out."
            case .taskCreationFailed(let error):
                return "Failed to create shell task: \(error?.localizedDescription ?? "Unknown error")"
            }
        }
    }
    
    @discardableResult
    static func safeShell(_ command: String, timeout: TimeInterval = 10.0) throws -> String {
        let task = Process()
        let pipe = Pipe()
        let errorPipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = errorPipe
        task.arguments = ["-c", command]
        task.executableURL = URL(fileURLWithPath: "/bin/zsh") // Or /bin/bash
        task.standardInput = nil
        
        // Set environment, crucial for finding commands if PATH is modified
        task.environment = ProcessInfo.processInfo.environment
        task.environment?["PATH"] = "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:" + (task.environment?["PATH"] ?? "")
        
        
        let group = DispatchGroup()
        group.enter()
        
        var timedOut = false
        let timer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { _ in
            if task.isRunning {
                timedOut = true
                task.terminate()
                print("Shell command timed out, terminating task.")
                group.leave()
            }
        }
        
        task.terminationHandler = { process in
            timer.invalidate()
            if !timedOut {
                group.leave()
            }
        }
        
        do {
            try task.run()
            print("Executing shell command: \(command)")
        } catch {
            print("Failed to run task: \(error)")
            timer.invalidate()
            group.leave()
            throw ShellError.taskCreationFailed(error)
        }
        
        group.wait() // Wait for task to finish or timeout
        
        let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: outputData, encoding: .utf8) ?? ""
        let errorOutput = String(data: errorData, encoding: .utf8) ?? ""
        
        let status = task.terminationStatus
        
        print("Shell command finished. Status: \(status), Timed Out: \(timedOut)")
        print("Stdout: \(output)")
        print("Stderr: \(errorOutput)")
        
        
        if timedOut {
            throw ShellError.timeout
        }
        
        if status != 0 {
            // Combine stdout and stderr for error context
            let combinedOutput = "Stdout:\n\(output)\nStderr:\n\(errorOutput)".trimmingCharacters(in: .whitespacesAndNewlines)
            throw ShellError.commandFailed(status: status, output: combinedOutput.isEmpty ? "No output" : combinedOutput)
        }
        
        // If status is 0, return stdout, even if there's stderr output (some tools use stderr for info)
        return output
    }
    
    
    func checkSetupStatus() -> SetupStatus {
        logger.log("Checking setup status...")
        
        var missingFiles: [String] = []
        let helperExists = FileManager.default.fileExists(atPath: self.helperScriptURL.path)
        let fileiconExists = FileManager.default.fileExists(atPath: self.fileiconURL.path)
        
        if !helperExists {
            missingFiles.append(helperScriptURL.lastPathComponent)
            logger.warning("Helper script missing at \(self.helperScriptURL.path)")
        }
        if !fileiconExists {
            missingFiles.append(fileiconURL.lastPathComponent)
            logger.warning("Fileicon missing at \(self.fileiconURL.path)")
        }
        
        if !missingFiles.isEmpty {
            logger.error("Setup check failed: Helper files missing.")
            return .helperFilesMissing(missingFiles: missingFiles)
        }
        logger.log("Helper files exist.")
        
        // Now check sudoers permission
        let helperPath = self.helperScriptURL.path
        let escapedHelperPathForGrep = helperPath.replacingOccurrences(of: " ", with: "\\\\ ")
        
        let grepPattern = "NOPASSWD:[[:space:]]*\(escapedHelperPathForGrep)"
        
        let checkCommand = "sudo -n -l | grep -q -E \"\(grepPattern)\""
        
        logger.log("Executing sudoers check command: \(checkCommand)")
        
        do {
            _ = try Self.safeShell(checkCommand)
            logger.log("Sudoers check successful: NOPASSWD rule for helper script found and effective.")
            return .completed
        } catch let error as ShellError {
            switch error {
            case .commandFailed(let status, let output):
                if status == 1 {
                    logger.warning("Sudoers check failed: Pattern \"\(grepPattern)\" not found in sudo -n -l output.")
                    logger.warning("Run 'sudo -n -l' in Terminal to check the exact output format.")
                    return .sudoersPermissionMissing
                } else {
                    logger.error("Sudoers check command failed with status \(status). Output: \(output). Assuming permission missing.")
                    logger.error("Detailed error output: \(output)")
                    logger.warning("Run 'sudo -n -l' in Terminal to check the exact output format and potential errors.")
                    return .sudoersPermissionMissing
                }
            case .timeout:
                logger.error("Sudoers check command timed out. Assuming permission missing.")
                return .sudoersPermissionMissing
            case .taskCreationFailed:
                logger.error("Failed to create task for sudoers check. Error: \(error.localizedDescription)")
                return .unknownError("Failed to execute sudoers check.")
            }
        } catch {
            logger.error("Unexpected error during sudoers check: \(error.localizedDescription)")
            return .unknownError("An unexpected error occurred during sudoers check.")
        }
    }
}

extension LaunchPadManagerDBHelper.AppInfo: @retroactive Identifiable {
    public var id: URL {
        url
    }
}

extension String {
    func replace(target: String, withString: String) -> String {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
}
