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

    private var refreshTask: Task<Void, Never>?

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
        refresh()
    }
    
    @objc func refresh() {
        refreshTask?.cancel()
        refreshTask = Task {
            try? await Task.sleep(nanoseconds: 150_000_000) // debounce
            guard !Task.isCancelled else { return }
            let sortedApps = loadAppItems()
            guard !Task.isCancelled else { return }
            await MainActor.run {
                self.apps = sortedApps
            }
        }
    }
    
    func loadAppItems() -> [AppItem] {
        var allApps: [AppItem] = []
        
        do {
            let helper = try LaunchPadManagerDBHelper()
            let dbApps = try helper.getAllAppInfos()
            let dbAppItems = dbApps.map { AppItem(name: $0.name, url: $0.url, originalAppInfo: $0) }
            allApps.append(contentsOf: dbAppItems)
        } catch {
            logger.error("Error fetching LaunchPad apps: \(error.localizedDescription)")
        }
        
        let localApps = scanLocalApps()

        let existingPaths = Set(allApps.map { $0.id })
        for localApp in localApps {
            if !existingPaths.contains(localApp.id) {
                allApps.append(localApp)
            }
        }
        
        return allApps.sorted(by: { $0.name.localizedStandardCompare($1.name) == .orderedAscending })
    }
    
    func scanLocalApps() -> [AppItem] {
        let fileManager = FileManager.default
        var appItems = [AppItem]()
        
        let permissions = FolderPermission.shared.permissions
        let maxDepth = 5

        for permission in permissions {
            let dir = permission.bookmarkedURL
            guard let enumerator = fileManager.enumerator(
                at: dir,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles, .skipsPackageDescendants]
            ) else {
                continue
            }
            
            for case let url as URL in enumerator {
                if enumerator.level > maxDepth {
                    enumerator.skipDescendants()
                    continue
                }
                
                if url.pathExtension == "app" {
                    let name = url.deletingPathExtension().lastPathComponent
                    appItems.append(AppItem(name: name, url: url, originalAppInfo: nil))
                    enumerator.skipDescendants()
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

            copyIfNeeded(from: fileiconBundlePath, to: fileiconDestPath, name: "fileicon")
            _ = try? Self.safeShell("chmod u+x '\(fileiconDestPath.shellEscaped)'")

            copyIfNeeded(from: helperBundlePath, to: helperDestPath, name: "helper.sh")
            _ = try? Self.safeShell("chmod u+x '\(helperDestPath.shellEscaped)'")
            
            logger.log("ensureHelperFilesCopied finished successfully.")
            
        } catch {
            logger.error("Error during ensureHelperFilesCopied: \(error.localizedDescription)")
        }
    }
    
    
    
    private func copyIfNeeded(from sourcePath: String, to destPath: String, name: String) {
        let fm = FileManager.default
        if fm.fileExists(atPath: destPath) {
            if let sourceData = fm.contents(atPath: sourcePath),
               let destData = fm.contents(atPath: destPath),
               sourceData == destData {
                logger.log("'\(name)' is up to date at \(destPath)")
                return
            }
            logger.log("'\(name)' is outdated, replacing at \(destPath)")
            try? fm.removeItem(atPath: destPath)
        } else {
            logger.log("'\(name)' does not exist, copying to \(destPath)")
        }
        do {
            try fm.copyItem(atPath: sourcePath, toPath: destPath)
            logger.log("'\(name)' copied successfully.")
        } catch {
            logger.error("Failed to copy '\(name)': \(error.localizedDescription)")
        }
    }

    enum ImageSaveError: Error, LocalizedError {
        case cgImageConversionFailed
        case pngEncodingFailed

        var errorDescription: String? {
            switch self {
            case .cgImageConversionFailed: return "Failed to convert NSImage to CGImage."
            case .pngEncodingFailed: return "Failed to encode image as PNG."
            }
        }
    }

    @discardableResult
    static func saveImage(_ image: NSImage, atUrl url: URL) -> Error? {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return ImageSaveError.cgImageConversionFailed
        }
        let newRep = NSBitmapImageRep(cgImage: cgImage)
        newRep.size = image.size
        guard let pngData = newRep.representation(using: .png, properties: [:]) else {
            return ImageSaveError.pngEncodingFailed
        }
        do {
            try pngData.write(to: url)
            return nil
        } catch {
            return error
        }
    }
    

    
    private func ensureSetupCompleted() throws {
        ensureHelperFilesCopied()
        let status = checkSetupStatus()
        guard case .completed = status else {
            logger.error("Setup incomplete: \(String(describing: status))")
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
    }

    private func applyIcon(_ image: NSImage, to app: AppItem) throws {
        let tempDir = FileManager.default.temporaryDirectory
        let imageURL = tempDir.appendingPathComponent("icon_\(UUID().uuidString).png")

        if let saveError = Self.saveImage(image, atUrl: imageURL) {
            throw saveError
        }
        defer { try? FileManager.default.removeItem(at: imageURL) }

        try runHelperTool(appPath: app.url.universalPath(), imagePath: imageURL.path)
    }

    /// Remove the custom icon from an app, restoring its original bundle icon.
    /// Uses setxattr syscall to clear the FinderInfo flag and removes the Icon\r file.
    func removeIcon(from app: AppItem) throws {
        let appPath = app.url.universalPath()
        logger.log("removeIcon called for app: \(app.name) at \(appPath)")

        // Step 1: Clear the custom icon flag (bit 0x04 at byte 8) in com.apple.FinderInfo
        let finderInfoName = "com.apple.FinderInfo"
        var finderInfo = [UInt8](repeating: 0, count: 32)
        let size = getxattr(appPath, finderInfoName, &finderInfo, 32, 0, 0)

        if size > 0 {
            if finderInfo[8] & 0x04 != 0 {
                finderInfo[8] = finderInfo[8] & ~0x04

                // If all bytes are zero, remove the attribute entirely
                let allZero = finderInfo.allSatisfy { $0 == 0 }
                if allZero {
                    removexattr(appPath, finderInfoName, 0)
                } else {
                    let result = setxattr(appPath, finderInfoName, &finderInfo, 32, 0, 0)
                    if result != 0 {
                        let err = String(cString: strerror(errno))
                        logger.error("Failed to clear FinderInfo custom icon flag: \(err)")
                        throw NSError(domain: "IconManager", code: 30,
                                      userInfo: [NSLocalizedDescriptionKey: "Failed to clear custom icon flag: \(err)"])
                    }
                }
                logger.log("FinderInfo custom icon flag cleared.")
            }
        }

        // Step 2: Remove the Icon\r file
        let iconFile = app.url.appendingPathComponent("Icon\r")
        if FileManager.default.fileExists(atPath: iconFile.path) {
            do {
                try FileManager.default.removeItem(at: iconFile)
                logger.log("Icon\\r file removed.")
            } catch {
                logger.error("Failed to remove Icon\\r: \(error.localizedDescription)")
                throw NSError(domain: "IconManager", code: 31,
                              userInfo: [NSLocalizedDescriptionKey: "Failed to remove custom icon file: \(error.localizedDescription)"])
            }
        }

        // Step 3: Remove from icon cache
        IconCacheManager.shared.removeCachedIcon(for: appPath)

        Task { @MainActor in
            AppIconCache.shared.remove(for: app.url)
            self.iconRefreshTrigger = UUID()
        }

        logger.log("Icon restored to default for \(app.name)")
    }

    func setImage(_ image: NSImage, app: AppItem) throws {
        logger.log("setImage called for app: \(app.name)")

        _ = try IconCacheManager.shared.cacheIcon(image: image, for: app.url.universalPath(), appName: app.name)
        logger.log("Icon cached for \(app.name)")

        try ensureSetupCompleted()
        try applyIcon(image, to: app)

        Task { @MainActor in
            AppIconCache.shared.remove(for: app.url)
            self.iconRefreshTrigger = UUID()
        }
    }

    func setIconWithoutCaching(_ image: NSImage, app: AppItem) async throws {
        logger.log("setIconWithoutCaching called for app: \(app.name)")

        try ensureSetupCompleted()
        try applyIcon(image, to: app)

        await MainActor.run {
            AppIconCache.shared.remove(for: app.url)
            self.iconRefreshTrigger = UUID()
        }
    }

    func restoreAllCachedIcons() async throws {
        logger.log("Starting restoreAllCachedIcons...")
        try ensureSetupCompleted()

        let currentApps: [AppItem] = await MainActor.run { apps }
        let appList: [AppItem]
        if currentApps.isEmpty {
            let loaded = loadAppItems()
            await MainActor.run { apps = loaded }
            appList = loaded
        } else {
            appList = currentApps
        }
        let appMap = Dictionary(uniqueKeysWithValues: appList.map { ($0.url.universalPath(), $0) })

        let cachedIcons = IconCacheManager.shared.getAllCachedIcons()
        var failedApps: [(String, Error)] = []

        for cache in cachedIcons {
            do {
                let appPath = cache.appPath
                let iconURL = IconCacheManager.cacheDirectory.appendingPathComponent(cache.iconFileName)

                if FileManager.default.fileExists(atPath: appPath) &&
                    FileManager.default.fileExists(atPath: iconURL.path) {

                    if let image = NSImage(contentsOf: iconURL) {
                        if let appInfo = appMap[appPath] {
                            try await setIconWithoutCaching(image, app: appInfo)
                            logger.info("Successfully restored icon for \(cache.appName)")
                        } else {
                            logger.warning("App info not found for \(cache.appName) at \(appPath), skipping restore.")
                        }
                    } else {
                        logger.error("Could not load cached icon image for \(cache.appName) from \(iconURL.path)")
                        IconCacheManager.shared.removeCachedIcon(for: appPath)
                        throw RestoreError.iconFileNotFound(cache.appName)
                    }
                } else if !FileManager.default.fileExists(atPath: appPath) {
                    logger.warning("App at path \(appPath) no longer exists, removing cache for \(cache.appName).")
                    IconCacheManager.shared.removeCachedIcon(for: appPath)
                } else if !FileManager.default.fileExists(atPath: iconURL.path) {
                    logger.warning("Icon file \(cache.iconFileName) missing for \(cache.appName), removing cache.")
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
        
        if let cachedIcons = IconFetchCacheManager.shared.getCachedIcons(
            appName: appName,
            bundleName: bundleName,
            aliasName: aliasName,
            style: style.rawValue
        ) {
            logger.log("Using cached icon fetch results for \(appName)")
            return cachedIcons
        }
        
        logger.log("Cache miss, fetching icons from network for \(appName)")

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
        
        let command = "sudo -n '\(helperToolPath.shellEscaped)' '\(fileiconPath.shellEscaped)' '\(appPath.shellEscaped)' '\(imagePath.shellEscaped)'"
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
            throw error
        }
        
        if output.lowercased().contains("incorrect password") || output.lowercased().contains("try again") {
            logger.error("Helper tool output suggests a password was required unexpectedly: \(output)")
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
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        task.standardInput = nil

        task.environment = ProcessInfo.processInfo.environment
        task.environment?["PATH"] = "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:" + (task.environment?["PATH"] ?? "")

        // Read output asynchronously to prevent pipe buffer deadlocks
        var outputData = Data()
        var errorData = Data()

        let outputHandle = pipe.fileHandleForReading
        let errorHandle = errorPipe.fileHandleForReading

        let outputQueue = DispatchQueue(label: "com.iconchanger.shell.stdout")
        let errorQueue = DispatchQueue(label: "com.iconchanger.shell.stderr")

        let outputGroup = DispatchGroup()
        outputGroup.enter()
        outputQueue.async {
            outputData = outputHandle.readDataToEndOfFile()
            outputGroup.leave()
        }
        outputGroup.enter()
        errorQueue.async {
            errorData = errorHandle.readDataToEndOfFile()
            outputGroup.leave()
        }

        let semaphore = DispatchSemaphore(value: 0)
        var timedOut = false

        task.terminationHandler = { _ in
            semaphore.signal()
        }

        do {
            try task.run()
        } catch {
            throw ShellError.taskCreationFailed(error)
        }

        let waitResult = semaphore.wait(timeout: .now() + timeout)
        if waitResult == .timedOut {
            timedOut = true
            task.terminate()
        }

        outputGroup.wait()

        let output = String(data: outputData, encoding: .utf8) ?? ""
        let errorOutput = String(data: errorData, encoding: .utf8) ?? ""
        let status = task.terminationStatus

        if timedOut {
            throw ShellError.timeout
        }

        if status != 0 {
            let combinedOutput = "Stdout:\n\(output)\nStderr:\n\(errorOutput)".trimmingCharacters(in: .whitespacesAndNewlines)
            throw ShellError.commandFailed(status: status, output: combinedOutput.isEmpty ? "No output" : combinedOutput)
        }

        return output
    }
    
    
    /// Automatically configure the sudoers entry via a macOS admin password prompt.
    func configureSudoers() throws {
        let helperPath = self.helperScriptURL.path
        let sudoersLine = "ALL ALL=(ALL) NOPASSWD: \(helperPath)"
        let sudoersFile = "/etc/sudoers.d/iconchanger"

        // Write to a temp file first, validate with visudo, then move into place.
        // This prevents writing a malformed sudoers file that could lock out sudo.
        let tmpFile = "/tmp/iconchanger_sudoers_\(ProcessInfo.processInfo.processIdentifier)"

        // Build the shell command: write → validate → install
        let commands = [
            "echo '\(sudoersLine.shellEscaped)' > '\(tmpFile.shellEscaped)'",
            "visudo -c -f '\(tmpFile.shellEscaped)'",
            "mv '\(tmpFile.shellEscaped)' '\(sudoersFile.shellEscaped)'",
            "chmod 0440 '\(sudoersFile.shellEscaped)'",
            "chown root:wheel '\(sudoersFile.shellEscaped)'"
        ].joined(separator: " && ")

        logger.log("Running sudoers configuration via osascript...")

        let task = Process()
        let errorPipe = Pipe()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        let appleScript = "do shell script \"\(commands.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\""))\" with administrator privileges"
        task.arguments = ["-e", appleScript]
        task.standardOutput = Pipe()
        task.standardError = errorPipe

        try task.run()
        task.waitUntilExit()

        let errorOutput = String(data: errorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""

        if task.terminationStatus != 0 {
            // Clean up temp file on failure
            try? FileManager.default.removeItem(atPath: tmpFile)

            if errorOutput.contains("User canceled") || errorOutput.contains("-128") {
                logger.log("User canceled the admin password dialog.")
                throw NSError(domain: "IconManager", code: 20,
                              userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Setup was canceled.", comment: "User canceled admin dialog")])
            }
            logger.error("Sudoers configuration failed: \(errorOutput)")
            throw NSError(domain: "IconManager", code: 21,
                          userInfo: [NSLocalizedDescriptionKey: String(format: NSLocalizedString("Failed to configure permissions: %@", comment: "Sudoers config error"), errorOutput)])
        }

        logger.log("Sudoers configuration completed successfully.")
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
        
        let helperPath = self.helperScriptURL.path
        let escapedHelperPathForGrep = helperPath.replacingOccurrences(of: " ", with: "[[:space:]]")

        let grepPattern = "NOPASSWD:[[:space:]]*\(escapedHelperPathForGrep)"

        let checkCommand = "sudo -n -l | grep -q -E '\(grepPattern.shellEscaped)'"
        
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

    var shellEscaped: String {
        self.replacingOccurrences(of: "'", with: "'\\''")
    }
}
