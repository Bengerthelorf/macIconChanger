//
//  IconManager.swift
//  IconChanger
//

import SwiftUI
import SwiftyJSON
import LaunchPadManagerDBHelper
import os
import CommonCrypto

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
        URL(fileURLWithPath: "/usr/local/lib/iconchanger", isDirectory: true)
    }

    var helperScriptURL: URL {
        helperDirectoryURL.appendingPathComponent("helper.sh")
    }
    
    var fileiconURL: URL {
        helperDirectoryURL.appendingPathComponent("fileicon")
    }
    
    private static let auditDateFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        return f
    }()

    private static let auditLogURL: URL = {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("IconChanger")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("audit.log")
    }()

    private func auditLog(operation: String, appName: String, appPath: String, detail: String = "") {
        let timestamp = Self.auditDateFormatter.string(from: Date())
        let user = NSUserName()
        let entry = "[\(timestamp)] user=\(user) op=\(operation) app=\"\(appName)\" path=\"\(appPath)\"\(detail.isEmpty ? "" : " \(detail)")\n"
        logger.log("AUDIT: \(entry.trimmingCharacters(in: .newlines))")
        if let data = entry.data(using: .utf8) {
            if FileManager.default.fileExists(atPath: Self.auditLogURL.path) {
                if let handle = try? FileHandle(forWritingTo: Self.auditLogURL) {
                    handle.seekToEndOfFile()
                    handle.write(data)
                    handle.closeFile()
                }
            } else {
                try? data.write(to: Self.auditLogURL)
            }
        }
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
        guard let fileiconBundlePath = Bundle.main.path(forResource: "fileicon", ofType: nil) else {
            logger.error("Cannot find 'fileicon' in bundle.")
            return
        }
        guard let helperBundlePath = Bundle.main.path(forResource: "helper", ofType: "sh") else {
            logger.error("Cannot find 'helper.sh' in bundle.")
            return
        }

        let helperDir   = helperDirectoryURL.path
        let fileiconDst = fileiconURL.path
        let helperDst   = helperScriptURL.path

        if verifyHelperIntegrity() {
            logger.debug("Helper files are up to date, skipping install.")
            return
        }

        let esc = { (s: String) -> String in s.shellEscaped }
        let commands = [
            "mkdir -p '\(esc(helperDir))'",
            "cp '\(esc(fileiconBundlePath))' '\(esc(fileiconDst))'",
            "cp '\(esc(helperBundlePath))' '\(esc(helperDst))'",
            "chown root:wheel '\(esc(helperDir))' '\(esc(fileiconDst))' '\(esc(helperDst))'",
            "chmod 755 '\(esc(helperDir))' '\(esc(fileiconDst))' '\(esc(helperDst))'"
        ].joined(separator: " && ")

        let escaped = commands
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
        let appleScript = "do shell script \"\(escaped)\" with administrator privileges"

        logger.log("Installing helper files to \(helperDir) via osascript...")

        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        task.arguments = ["-e", appleScript]
        task.standardOutput = Pipe()
        let errPipe = Pipe()
        task.standardError = errPipe

        do {
            try task.run()
            task.waitUntilExit()
        } catch {
            logger.error("Failed to launch osascript for helper install: \(error.localizedDescription)")
            return
        }

        if task.terminationStatus != 0 {
            let errMsg = String(data: errPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
            logger.error("Helper file install failed (status \(task.terminationStatus)): \(errMsg)")
        } else {
            logger.log("Helper files installed successfully at \(helperDir).")
            cleanupLegacyHelperFiles()
        }
    }

    private func cleanupLegacyHelperFiles() {
        let fm = FileManager.default
        let legacyDir = fm.homeDirectoryForCurrentUser.appendingPathComponent(".iconchanger", isDirectory: true)
        let legacyFiles = ["helper.sh", "fileicon"]
        for file in legacyFiles {
            let path = legacyDir.appendingPathComponent(file).path
            if fm.fileExists(atPath: path) {
                try? fm.removeItem(atPath: path)
                logger.log("Removed legacy helper file: \(path)")
            }
        }
    }

    private func sha256(of path: String) -> String? {
        guard let data = FileManager.default.contents(atPath: path) else { return nil }
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes { buffer in
            _ = CC_SHA256(buffer.baseAddress, CC_LONG(data.count), &hash)
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }

    private func verifyHelperIntegrity() -> Bool {
        guard let bundledFileicon = Bundle.main.path(forResource: "fileicon", ofType: nil),
              let bundledHelper = Bundle.main.path(forResource: "helper", ofType: "sh") else {
            logger.error("Cannot find bundled helper files for integrity check.")
            return false
        }

        let installedFileicon = fileiconURL.path
        let installedHelper = helperScriptURL.path

        guard let bundledFileiconHash = sha256(of: bundledFileicon),
              let installedFileiconHash = sha256(of: installedFileicon),
              let bundledHelperHash = sha256(of: bundledHelper),
              let installedHelperHash = sha256(of: installedHelper) else {
            logger.error("Failed to compute hash for helper file integrity check.")
            return false
        }

        if bundledFileiconHash != installedFileiconHash {
            logger.error("SECURITY: Installed fileicon hash mismatch! Expected \(bundledFileiconHash), got \(installedFileiconHash)")
            return false
        }
        if bundledHelperHash != installedHelperHash {
            logger.error("SECURITY: Installed helper.sh hash mismatch! Expected \(bundledHelperHash), got \(installedHelperHash)")
            return false
        }

        logger.debug("Helper file integrity verified.")
        return true
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

    func removeIcon(from app: AppItem) throws {
        let appPath = app.url.universalPath()
        logger.log("removeIcon called for app: \(app.name) at \(appPath)")

        let finderInfoName = "com.apple.FinderInfo"
        var finderInfo = [UInt8](repeating: 0, count: 32)
        let size = getxattr(appPath, finderInfoName, &finderInfo, 32, 0, 0)

        if size > 0 {
            if finderInfo[8] & 0x04 != 0 {
                finderInfo[8] = finderInfo[8] & ~0x04

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
            }
        }

        let iconFile = app.url.appendingPathComponent("Icon\r")
        if FileManager.default.fileExists(atPath: iconFile.path) {
            do {
                try FileManager.default.removeItem(at: iconFile)
            } catch {
                logger.error("Failed to remove Icon\\r: \(error.localizedDescription)")
                throw NSError(domain: "IconManager", code: 31,
                              userInfo: [NSLocalizedDescriptionKey: "Failed to remove custom icon file: \(error.localizedDescription)"])
            }
        }

        IconCacheManager.shared.removeCachedIcon(for: appPath)

        Task { @MainActor in
            AppIconCache.shared.remove(for: app.url)
            self.iconRefreshTrigger = UUID()
        }

        auditLog(operation: "remove_icon", appName: app.name, appPath: appPath)
        logger.log("Icon restored to default for \(app.name)")
    }

    func setImage(_ image: NSImage, app: AppItem) throws {
        logger.log("setImage called for app: \(app.name)")

        _ = try IconCacheManager.shared.cacheIcon(image: image, for: app.url.universalPath(), appName: app.name)
        logger.log("Icon cached for \(app.name)")

        try ensureSetupCompleted()
        try applyIcon(image, to: app)

        auditLog(operation: "set_icon", appName: app.name, appPath: app.url.universalPath())

        // Record in history
        IconHistoryManager.shared.addEntry(image: image, for: app.url.universalPath(), appName: app.name)

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

                let appExists = FileManager.default.fileExists(atPath: appPath)
                let iconExists = FileManager.default.fileExists(atPath: iconURL.path)

                if appExists && iconExists {
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
                } else if !appExists {
                    logger.warning("App at path \(appPath) no longer exists, removing cache for \(cache.appName).")
                    IconCacheManager.shared.removeCachedIcon(for: appPath)
                } else {
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
        let resourcesURL = url.appendingPathComponent("Contents").appendingPathComponent("Resources")
        let files = (try? FileManager.default.contentsOfDirectory(atPath: resourcesURL.path)) ?? [String]()
        let icnsFiles = files.filter { $0.hasSuffix(".icns") }

        let plistURL = url.appendingPathComponent("Contents").appendingPathComponent("Info.plist")
        var primaryIconName: String? = nil
        if let plist = NSDictionary(contentsOf: plistURL) as? [String: Any] {
            if var iconFile = plist["CFBundleIconFile"] as? String {
                if !iconFile.hasSuffix(".icns") {
                    iconFile += ".icns"
                }
                primaryIconName = iconFile
            }
        }

        let sorted = icnsFiles.sorted { a, b in
            let aIsPrimary = (a == primaryIconName)
            let bIsPrimary = (b == primaryIconName)
            if aIsPrimary != bIsPrimary { return aIsPrimary }
            return a.localizedStandardCompare(b) == .orderedAscending
        }

        return sorted.map { resourcesURL.appendingPathComponent($0) }
    }

    // MARK: - Squircle Jail Escape (macOS Tahoe)

    /// Gets the primary bundled icon file URL for an app by reading CFBundleIconFile from Info.plist.
    func getBundledIconURL(for app: AppItem) -> URL? {
        let plistURL = app.url.appendingPathComponent("Contents").appendingPathComponent("Info.plist")
        guard let plist = NSDictionary(contentsOf: plistURL) as? [String: Any] else { return nil }

        guard var iconFileName = plist["CFBundleIconFile"] as? String else { return nil }
        if !iconFileName.hasSuffix(".icns") {
            iconFileName += ".icns"
        }

        let iconURL = app.url
            .appendingPathComponent("Contents")
            .appendingPathComponent("Resources")
            .appendingPathComponent(iconFileName)

        return FileManager.default.fileExists(atPath: iconURL.path) ? iconURL : nil
    }

    /// Checks if an app currently has a custom icon set (via extended attributes).
    func hasCustomIcon(app: AppItem) -> Bool {
        let appPath = app.url.universalPath()
        let finderInfoName = "com.apple.FinderInfo"
        var finderInfo = [UInt8](repeating: 0, count: 32)
        let size = getxattr(appPath, finderInfoName, &finderInfo, 32, 0, 0)
        return size > 0 && (finderInfo[8] & 0x04 != 0)
    }

    /// Escapes the squircle jail for a single app by re-applying its own bundled icon as a custom icon.
    /// This bypasses macOS Tahoe's squircle enforcement because custom icons are not subject to it.
    /// Uses the .icns file directly to preserve all icon resolutions.
    func escapeSquircleJail(for app: AppItem) throws {
        guard let iconURL = getBundledIconURL(for: app) else {
            throw NSError(domain: "IconManager", code: 40,
                          userInfo: [NSLocalizedDescriptionKey: "Could not find the bundled icon for \(app.name)."])
        }

        try ensureSetupCompleted()
        // Pass the .icns file directly to fileicon to preserve all resolutions
        try runHelperTool(appPath: app.url.universalPath(), imagePath: iconURL.path)

        auditLog(operation: "escape_squircle", appName: app.name, appPath: app.url.universalPath())
        logger.log("Escaped squircle jail for \(app.name)")

        Task { @MainActor in
            AppIconCache.shared.remove(for: app.url)
            self.iconRefreshTrigger = UUID()
        }
    }

    /// Escapes the squircle jail for all apps that don't already have a custom icon.
    /// Returns the count of apps processed and any failures.
    func escapeSquircleJailAll() async throws -> (processed: Int, skipped: Int, failed: [(String, Error)]) {
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

        var processed = 0
        var skipped = 0
        var failures: [(String, Error)] = []

        for app in appList {
            // Skip apps that already have custom icons set by the user (cached icons)
            if IconCacheManager.shared.getIconCache(for: app.url.universalPath()) != nil {
                skipped += 1
                continue
            }

            // Skip apps that already have custom icons (but not cached by us)
            if hasCustomIcon(app: app) {
                skipped += 1
                continue
            }

            guard getBundledIconURL(for: app) != nil else {
                skipped += 1
                continue
            }

            do {
                try escapeSquircleJail(for: app)
                processed += 1
            } catch {
                logger.error("Failed to escape squircle jail for \(app.name): \(error.localizedDescription)")
                failures.append((app.name, error))
            }
        }

        return (processed, skipped, failures)
    }

    func getIcons(_ app: AppItem, style: IconStyle = .all, forceRefresh: Bool = false) async throws -> [IconRes] {
        let appName = app.name
        let urlName = app.url.deletingPathExtension().lastPathComponent
        let bundleName = try getAppBundleName(app)
        let aliasName = AliasName.getName(for: app.url.deletingPathExtension().lastPathComponent)

        if !forceRefresh,
           let cachedIcons = IconFetchCacheManager.shared.getCachedIcons(
            appName: appName,
            bundleName: bundleName,
            aliasName: aliasName,
            style: style.rawValue
        ) {
            logger.log("Using cached icon fetch results for \(appName)")
            return cachedIcons
        }

        if forceRefresh {
            logger.log("Force refresh, fetching icons from network for \(appName)")
        } else {
            logger.log("Cache miss, fetching icons from network for \(appName)")
        }

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

        let task = Process()
        let outPipe = Pipe()
        let errPipe = Pipe()

        task.executableURL = URL(fileURLWithPath: "/usr/bin/sudo")
        task.arguments = ["-n", helperToolPath, fileiconPath, appPath, imagePath]
        task.standardOutput = outPipe
        task.standardError = errPipe
        task.standardInput = nil

        logger.debug("Executing: sudo -n \(helperToolPath) \(fileiconPath) \(appPath) \(imagePath)")

        let semaphore = DispatchSemaphore(value: 0)
        var timedOut = false

        task.terminationHandler = { _ in
            semaphore.signal()
        }

        do {
            try task.run()
        } catch {
            throw NSError(domain: "IconManager", code: 15,
                          userInfo: [NSLocalizedDescriptionKey: "Failed to start helper tool process: \(error.localizedDescription)"])
        }

        let waitResult = semaphore.wait(timeout: .now() + 15.0)
        if waitResult == .timedOut {
            timedOut = true
            task.terminate()
        }

        let outputData = outPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: outputData, encoding: .utf8) ?? ""
        let errorOutput = String(data: errorData, encoding: .utf8) ?? ""

        if timedOut {
            throw NSError(domain: "IconManager", code: 14,
                          userInfo: [NSLocalizedDescriptionKey: "Helper tool timed out"])
        }

        if task.terminationStatus != 0 {
            let combined = "Stdout:\n\(output)\nStderr:\n\(errorOutput)".trimmingCharacters(in: .whitespacesAndNewlines)
            throw NSError(domain: "IconManager", code: 10,
                          userInfo: [NSLocalizedDescriptionKey: "Helper tool failed (status: \(task.terminationStatus)): \(combined.isEmpty ? "No output" : combined)"])
        }

        let combinedLower = (output + errorOutput).lowercased()
        if combinedLower.contains("incorrect password") || combinedLower.contains("try again") {
            throw NSError(domain: "IconManager", code: 16,
                          userInfo: [NSLocalizedDescriptionKey: "Helper tool unexpectedly asked for a password: \(output)\(errorOutput)"])
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

    func configureSudoers() throws {
        let helperPath = self.helperScriptURL.path
        let username = NSUserName()
        let sudoersLine = "\(username) ALL=(ALL) NOPASSWD: \(helperPath)"
        let sudoersFile = "/etc/sudoers.d/iconchanger"

        let commands = [
            "TMPFILE=$(mktemp /tmp/iconchanger_sudoers.XXXXXX)",
            "trap 'rm -f \"$TMPFILE\"' EXIT",
            "echo '\(sudoersLine.shellEscaped)' > \"$TMPFILE\"",
            "visudo -c -f \"$TMPFILE\"",
            "mv \"$TMPFILE\" '\(sudoersFile.shellEscaped)'",
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
            if errorOutput.contains("User canceled") || errorOutput.contains("-128") {
                logger.log("User canceled the admin password dialog.")
                throw NSError(domain: "IconManager", code: 20,
                              userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Setup was canceled.", comment: "User canceled admin dialog")])
            }
            logger.error("Sudoers configuration failed: \(errorOutput)")
            throw NSError(domain: "IconManager", code: 21,
                          userInfo: [NSLocalizedDescriptionKey: String(format: NSLocalizedString("Failed to configure permissions: %@", comment: "Sudoers config error"), errorOutput)])
        }

    }

    func checkSetupStatus() -> SetupStatus {
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
            return .helperFilesMissing(missingFiles: missingFiles)
        }
        
        let helperPath = self.helperScriptURL.path
        let escapedHelperPathForGrep = helperPath.replacingOccurrences(of: " ", with: "[[:space:]]")
        let grepPattern = "NOPASSWD:[[:space:]]*\(escapedHelperPathForGrep)"

        let checkCommand = "sudo -n -l | grep -q -E '\(grepPattern.shellEscaped)'"
        
        do {
            _ = try Self.safeShell(checkCommand)
            return .completed
        } catch let error as ShellError {
            switch error {
            case .commandFailed(let status, let output):
                logger.debug("Sudoers check failed (status \(status)): \(output)")
                return .sudoersPermissionMissing
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
