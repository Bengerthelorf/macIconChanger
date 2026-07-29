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
    case helperFilesOutdated
    case sudoersPermissionMissing
    case legacySudoersPermissionPresent
    case unknownError(String)
}

class IconManager: ObservableObject {
    static let shared = IconManager()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "IconChanger", category: "IconManager")
    private let diagnostics = DiagnosticsLogger.shared
    
    @Published var icons = [(String, String)]()
    @Published var apps: [AppItem] = []
    @Published var needsSetupCheck: Bool = false
    @Published var iconRefreshTrigger = UUID()
    @Published var isRestoring: Bool = false
    @Published var restoreProgress: (current: Int, total: Int) = (0, 0)
    @Published var restoringAppName: String = ""

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

    private var legacyHelperScriptPath: String {
        LegacySudoersPolicy.legacyHelperPath(
            homeDirectory: FileManager.default.homeDirectoryForCurrentUser.path
        )
    }
    
    private static let auditDateFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        return f
    }()

    private static let auditLogURL: URL = {
        AppPaths.applicationSupportRoot.appendingPathComponent("audit.log")
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
        let diagnosticsContext = DiagnosticsContext(
            operation: .discovery,
            source: .system
        )
        let timer = DiagnosticsTimer()
        diagnostics.log(
            .operation,
            phase: "app_discovery.start",
            context: diagnosticsContext,
            details: [
                "folder_permission_count": String(FolderPermission.shared.permissions.count)
            ]
        )
        var allApps: [AppItem] = []
        var launchpadCount = 0

        do {
            let helper = try LaunchPadManagerDBHelper()
            let dbApps = try helper.getAllAppInfos()
            let dbAppItems = dbApps.map { AppItem(name: $0.name, url: $0.url, originalAppInfo: $0) }
            allApps.append(contentsOf: dbAppItems)
            launchpadCount = dbAppItems.count
            diagnostics.log(
                .step,
                phase: "app_discovery.launchpad_loaded",
                context: diagnosticsContext,
                details: ["count": String(launchpadCount)]
            )
        } catch {
            logger.error("Error fetching LaunchPad apps: \(error.localizedDescription)")
            diagnostics.log(
                .failure,
                phase: "app_discovery.launchpad_failed",
                context: diagnosticsContext,
                details: DiagnosticsLogger.errorDetails(error)
            )
        }
        
        let localApps = scanLocalApps(diagnosticsContext: diagnosticsContext)

        let existingPaths = Set(allApps.map { $0.id })
        for localApp in localApps {
            if !existingPaths.contains(localApp.id) {
                allApps.append(localApp)
            }
        }
        
        let result = allApps.sorted(by: {
            $0.name.localizedStandardCompare($1.name) == .orderedAscending
        })
        diagnostics.log(
            .operation,
            phase: "app_discovery.completed",
            context: diagnosticsContext,
            durationMilliseconds: timer.elapsedMilliseconds,
            details: [
                "launchpad_count": String(launchpadCount),
                "folder_scan_count": String(localApps.count),
                "combined_count": String(result.count),
            ]
        )
        return result
    }
    
    func scanLocalApps(
        diagnosticsContext: DiagnosticsContext? = nil
    ) -> [AppItem] {
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
                if let diagnosticsContext {
                    diagnostics.log(
                        .failure,
                        phase: "app_discovery.folder_enumerator_failed",
                        context: DiagnosticsContext(
                            operation: .discovery,
                            operationID: diagnosticsContext.operationID,
                            source: diagnosticsContext.source,
                            appName: dir.lastPathComponent,
                            appPath: dir.path
                        )
                    )
                }
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

        if let diagnosticsContext {
            diagnostics.log(
                .step,
                phase: "app_discovery.folder_scan_completed",
                context: diagnosticsContext,
                details: [
                    "folder_count": String(permissions.count),
                    "app_count": String(appItems.count),
                ]
            )
        }
        
        return appItems
    }
    
    func ensureHelperFilesCopied() {
        let diagnosticsContext = DiagnosticsContext(operation: .setup)
        let timer = DiagnosticsTimer()
        diagnostics.log(
            .operation,
            phase: "helper_install_check.start",
            context: diagnosticsContext
        )
        guard let fileiconBundlePath = Bundle.main.path(forResource: "fileicon", ofType: nil) else {
            logger.error("Cannot find 'fileicon' in bundle.")
            diagnostics.log(
                .failure,
                phase: "helper_install_check.bundled_fileicon_missing",
                context: diagnosticsContext,
                durationMilliseconds: timer.elapsedMilliseconds
            )
            return
        }
        guard let helperBundlePath = Bundle.main.path(forResource: "helper", ofType: "sh") else {
            logger.error("Cannot find 'helper.sh' in bundle.")
            diagnostics.log(
                .failure,
                phase: "helper_install_check.bundled_helper_missing",
                context: diagnosticsContext,
                durationMilliseconds: timer.elapsedMilliseconds
            )
            return
        }

        let helperDir   = helperDirectoryURL.path
        let fileiconDst = fileiconURL.path
        let helperDst   = helperScriptURL.path

        if verifyHelperIntegrity() {
            logger.debug("Helper files are up to date, skipping install.")
            diagnostics.log(
                .skipped,
                phase: "helper_install_check.already_current",
                context: diagnosticsContext,
                durationMilliseconds: timer.elapsedMilliseconds
            )
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
            diagnostics.log(
                .failure,
                phase: "helper_install.launch_failed",
                context: diagnosticsContext,
                durationMilliseconds: timer.elapsedMilliseconds,
                details: DiagnosticsLogger.errorDetails(error)
            )
            return
        }

        if task.terminationStatus != 0 {
            let errMsg = String(data: errPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
            logger.error("Helper file install failed (status \(task.terminationStatus)): \(errMsg)")
            diagnostics.log(
                .failure,
                phase: "helper_install.failed",
                context: diagnosticsContext,
                durationMilliseconds: timer.elapsedMilliseconds,
                details: [
                    "exit_status": String(task.terminationStatus),
                    "process_stderr": errMsg,
                ]
            )
        } else {
            logger.log("Helper files installed successfully at \(helperDir).")
            cleanupLegacyHelperFiles()
            diagnostics.log(
                .operation,
                phase: "helper_install.completed",
                context: diagnosticsContext,
                durationMilliseconds: timer.elapsedMilliseconds
            )
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

    private func ensureSetupCompleted(allowRepair: Bool = true) throws {
        if allowRepair {
            ensureHelperFilesCopied()
        }

        let status = checkSetupStatus()
        guard case .completed = status else {
            logger.error("Setup incomplete: \(String(describing: status))")
            let errorDescription: String
            switch status {
            case .helperFilesMissing(let missingFiles):
                errorDescription = "Required helper files are missing: \(missingFiles.joined(separator: ", ")). Please check setup."
            case .helperFilesOutdated:
                errorDescription = "Installed helper files are outdated or failed integrity verification. Please repair setup."
            case .sudoersPermissionMissing:
                errorDescription = "Sudo permission for helper script is missing or incorrect. Please check setup."
            case .legacySudoersPermissionPresent:
                errorDescription = "A legacy user-writable sudoers rule must be removed before changing icons. Please repair permissions."
            default:
                errorDescription = "An unknown setup error occurred. Please check setup."
            }
            throw NSError(domain: "IconManager", code: 11, userInfo: [NSLocalizedDescriptionKey: errorDescription])
        }
    }

    private func applyIcon(
        _ image: NSImage,
        to app: AppItem,
        diagnosticsContext: DiagnosticsContext
    ) throws {
        let tempDir = FileManager.default.temporaryDirectory
        let imageURL = tempDir.appendingPathComponent("icon_\(UUID().uuidString).png")
        let encodeTimer = DiagnosticsTimer()

        diagnostics.log(
            .step,
            phase: "image_encode.start",
            context: diagnosticsContext
        )
        if let saveError = Self.saveImage(image, atUrl: imageURL) {
            diagnostics.log(
                .failure,
                phase: "image_encode.failed",
                context: diagnosticsContext,
                durationMilliseconds: encodeTimer.elapsedMilliseconds,
                details: DiagnosticsLogger.errorDetails(saveError)
            )
            throw saveError
        }
        diagnostics.log(
            .performance,
            phase: "image_encode.finish",
            context: diagnosticsContext,
            durationMilliseconds: encodeTimer.elapsedMilliseconds
        )
        defer { try? FileManager.default.removeItem(at: imageURL) }

        try runHelperTool(
            appPath: app.url.universalPath(),
            imagePath: imageURL.path,
            diagnosticsContext: diagnosticsContext
        )
    }

    func removeIcon(from app: AppItem) throws {
        let appPath = app.url.universalPath()
        let context = DiagnosticsContext(
            operation: .remove,
            appName: app.name,
            appPath: appPath
        )
        let timer = DiagnosticsTimer()
        logger.log("removeIcon called for app: \(app.name) at \(appPath)")
        diagnostics.log(.operation, phase: "remove.start", context: context)

        do {
            diagnostics.log(.step, phase: "setup_check.start", context: context)
            try ensureSetupCompleted()
            diagnostics.log(.step, phase: "setup_check.finish", context: context)
            try runHelperRemove(appPath: appPath, diagnosticsContext: context)

            IconCacheManager.shared.removeCachedIcon(for: appPath)
            AppearanceIconStore.shared.removeConfiguration(for: appPath)

            Task { @MainActor in
                AppIconCache.shared.remove(for: app.url)
                self.iconRefreshTrigger = UUID()
            }

            auditLog(operation: "remove_icon", appName: app.name, appPath: appPath)
            diagnostics.log(
                .operation,
                phase: "remove.completed",
                context: context,
                durationMilliseconds: timer.elapsedMilliseconds
            )
            logger.log("Icon restored to default for \(app.name)")
        } catch {
            diagnostics.log(
                .failure,
                phase: "remove.failed",
                context: context,
                durationMilliseconds: timer.elapsedMilliseconds,
                details: DiagnosticsLogger.errorDetails(error)
            )
            throw error
        }
    }

    func setImage(
        _ image: NSImage,
        app: AppItem,
        source: IconApplicationSource = .local
    ) throws {
        let appPath = app.url.universalPath()
        let sourceName: String
        switch source {
        case .local: sourceName = "local"
        case .remote: sourceName = "remote"
        case .favorite: sourceName = "favorite"
        case .history: sourceName = "history"
        }
        let context = DiagnosticsContext(
            operation: .replace,
            appName: app.name,
            appPath: appPath,
            iconKind: sourceName
        )
        let timer = DiagnosticsTimer()
        logger.log("setImage called for app: \(app.name)")
        diagnostics.log(.operation, phase: "replace.start", context: context)

        do {
            let cacheTimer = DiagnosticsTimer()
            diagnostics.log(.step, phase: "cache_write.start", context: context)
            _ = try IconCacheManager.shared.cacheIcon(
                image: image,
                for: appPath,
                appName: app.name
            )
            diagnostics.log(
                .performance,
                phase: "cache_write.finish",
                context: context,
                durationMilliseconds: cacheTimer.elapsedMilliseconds
            )
            logger.log("Icon cached for \(app.name)")

            diagnostics.log(.step, phase: "setup_check.start", context: context)
            try ensureSetupCompleted()
            diagnostics.log(.step, phase: "setup_check.finish", context: context)
            try applyIcon(image, to: app, diagnosticsContext: context)

            auditLog(operation: "set_icon", appName: app.name, appPath: appPath)

            if IconApplicationPolicy.shouldRecordHistory(source: source) {
                diagnostics.log(.step, phase: "history_write.start", context: context)
                IconHistoryManager.shared.addEntry(
                    image: image,
                    for: appPath,
                    appName: app.name
                )
                diagnostics.log(.step, phase: "history_write.finish", context: context)
            }

            Task { @MainActor in
                AppIconCache.shared.remove(for: app.url)
                self.iconRefreshTrigger = UUID()
            }
            diagnostics.log(
                .operation,
                phase: "replace.completed",
                context: context,
                durationMilliseconds: timer.elapsedMilliseconds
            )
        } catch {
            diagnostics.log(
                .failure,
                phase: "replace.failed",
                context: context,
                durationMilliseconds: timer.elapsedMilliseconds,
                details: DiagnosticsLogger.errorDetails(error)
            )
            throw error
        }
    }

    func setIconWithoutCaching(
        _ image: NSImage,
        app: AppItem,
        allowRepair: Bool = true,
        diagnosticsOperation: DiagnosticsOperation = .restore,
        diagnosticsSource: DiagnosticsSource = .manual,
        diagnosticsIconKind: String? = nil,
        diagnosticsIconPath: String? = nil,
        diagnosticsBatchID: UUID? = nil
    ) async throws {
        let context = DiagnosticsContext(
            operation: diagnosticsOperation,
            batchID: diagnosticsBatchID,
            source: diagnosticsSource,
            appName: app.name,
            appPath: app.url.universalPath(),
            iconKind: diagnosticsIconKind,
            iconPath: diagnosticsIconPath
        )
        let timer = DiagnosticsTimer()
        logger.log("setIconWithoutCaching called for app: \(app.name)")
        diagnostics.log(
            .operation,
            phase: "\(diagnosticsOperation.rawValue).start",
            context: context
        )

        do {
            diagnostics.log(.step, phase: "setup_check.start", context: context)
            try ensureSetupCompleted(allowRepair: allowRepair)
            diagnostics.log(.step, phase: "setup_check.finish", context: context)
            try applyIcon(image, to: app, diagnosticsContext: context)

            await MainActor.run {
                AppIconCache.shared.remove(for: app.url)
                self.iconRefreshTrigger = UUID()
            }

            let auditOperation = diagnosticsOperation == .appearance
                ? "appearance_switch"
                : "restore_icon"
            auditLog(
                operation: auditOperation,
                appName: app.name,
                appPath: app.url.universalPath(),
                detail: diagnosticsIconKind.map { "icon_kind=\($0)" } ?? ""
            )
            diagnostics.log(
                .operation,
                phase: "\(diagnosticsOperation.rawValue).completed",
                context: context,
                durationMilliseconds: timer.elapsedMilliseconds
            )
        } catch {
            diagnostics.log(
                .failure,
                phase: "\(diagnosticsOperation.rawValue).failed",
                context: context,
                durationMilliseconds: timer.elapsedMilliseconds,
                details: DiagnosticsLogger.errorDetails(error)
            )
            throw error
        }
    }

    struct RestoreResult {
        var restored: Int = 0
        var skippedNotInstalled: Int = 0
        var failed: [(String, Error)] = []
    }

    @discardableResult
    func restoreCachedIcon(
        for app: AppItem,
        allowRepair: Bool = true,
        refreshDock: Bool = true,
        source: DiagnosticsSource = .manual
    ) async throws -> Bool {
        let context = DiagnosticsContext(
            operation: .restore,
            source: source,
            appName: app.name,
            appPath: app.url.universalPath()
        )
        let timer = DiagnosticsTimer()
        diagnostics.log(.operation, phase: "restore.start", context: context)

        do {
            diagnostics.log(.step, phase: "setup_check.start", context: context)
            try ensureSetupCompleted(allowRepair: allowRepair)
            diagnostics.log(.step, phase: "setup_check.finish", context: context)
            guard
                let restoredContext = try applyBestCachedIcon(
                    for: app,
                    diagnosticsContext: context
                )
            else {
                diagnostics.log(
                    .skipped,
                    phase: "restore.no_eligible_icon",
                    context: context,
                    durationMilliseconds: timer.elapsedMilliseconds
                )
                return false
            }
            if refreshDock {
                _ = await DockRefreshService.refreshTwice(
                    diagnosticsContext: restoredContext
                )
            }
            auditLog(
                operation: "restore_icon",
                appName: app.name,
                appPath: app.url.universalPath(),
                detail: restoredContext.iconKind.map { "icon_kind=\($0)" } ?? ""
            )
            diagnostics.log(
                .operation,
                phase: "restore.completed",
                context: restoredContext,
                durationMilliseconds: timer.elapsedMilliseconds
            )
            return true
        } catch {
            diagnostics.log(
                .failure,
                phase: "restore.failed",
                context: context,
                durationMilliseconds: timer.elapsedMilliseconds,
                details: DiagnosticsLogger.errorDetails(error)
            )
            throw error
        }
    }

    func restoreAllCachedIcons(
        allowRepair: Bool = true,
        source: DiagnosticsSource = .manual
    ) async throws -> RestoreResult {
        let batchID = UUID()
        let batchContext = DiagnosticsContext(
            operation: .restore,
            batchID: batchID,
            source: source
        )
        let batchTimer = DiagnosticsTimer()
        logger.log("Starting restoreAllCachedIcons...")
        diagnostics.log(.operation, phase: "restore_batch.start", context: batchContext)

        do {
            diagnostics.log(.step, phase: "setup_check.start", context: batchContext)
            try ensureSetupCompleted(allowRepair: allowRepair)
            diagnostics.log(.step, phase: "setup_check.finish", context: batchContext)
        } catch {
            diagnostics.log(
                .failure,
                phase: "restore_batch.setup_failed",
                context: batchContext,
                durationMilliseconds: batchTimer.elapsedMilliseconds,
                details: DiagnosticsLogger.errorDetails(error)
            )
            throw error
        }

        let cachedIcons = IconCacheManager.shared.getAllCachedIcons()
        let appearanceConfigurations = AppearanceIconStore.shared.getAllConfigurations()
        let cacheByPath = Dictionary(uniqueKeysWithValues: cachedIcons.map { ($0.appPath, $0) })
        let appearanceByPath = Dictionary(
            uniqueKeysWithValues: appearanceConfigurations.map { ($0.appPath, $0) }
        )
        let allPaths = Set(cacheByPath.keys).union(appearanceByPath.keys).sorted()
        var result = RestoreResult()

        await MainActor.run {
            isRestoring = true
            restoreProgress = (0, allPaths.count)
        }

        for (index, appPath) in allPaths.enumerated() {
            let appName = cacheByPath[appPath]?.appName
                ?? appearanceByPath[appPath]?.appName
                ?? URL(fileURLWithPath: appPath).deletingPathExtension().lastPathComponent
            await MainActor.run {
                restoreProgress = (index, allPaths.count)
                restoringAppName = appName
            }

            let appContext = DiagnosticsContext(
                operation: .restore,
                batchID: batchID,
                source: source,
                appName: appName,
                appPath: appPath
            )
            let appTimer = DiagnosticsTimer()
            diagnostics.log(.operation, phase: "restore.start", context: appContext)

            do {
                guard FileManager.default.fileExists(atPath: appPath) else {
                    result.skippedNotInstalled += 1
                    diagnostics.log(
                        .skipped,
                        phase: "restore.app_not_installed",
                        context: appContext,
                        durationMilliseconds: appTimer.elapsedMilliseconds
                    )
                    continue
                }
                let app = AppItem(
                    name: appName,
                    url: URL(fileURLWithPath: appPath),
                    originalAppInfo: nil
                )
                if let restoredContext = try applyBestCachedIcon(
                    for: app,
                    diagnosticsContext: appContext
                ) {
                    result.restored += 1
                    auditLog(
                        operation: "restore_icon",
                        appName: appName,
                        appPath: appPath,
                        detail: restoredContext.iconKind.map { "icon_kind=\($0)" } ?? ""
                    )
                    diagnostics.log(
                        .operation,
                        phase: "restore.completed",
                        context: restoredContext,
                        durationMilliseconds: appTimer.elapsedMilliseconds
                    )
                } else {
                    diagnostics.log(
                        .skipped,
                        phase: "restore.no_eligible_icon",
                        context: appContext,
                        durationMilliseconds: appTimer.elapsedMilliseconds
                    )
                }
            } catch {
                logger.error("Failed to restore icon for \(appName): \(error.localizedDescription)")
                result.failed.append((appName, error))
                diagnostics.log(
                    .failure,
                    phase: "restore.failed",
                    context: appContext,
                    durationMilliseconds: appTimer.elapsedMilliseconds,
                    details: DiagnosticsLogger.errorDetails(error)
                )
            }
        }

        if result.restored > 0 {
            _ = await DockRefreshService.refreshTwice(
                diagnosticsContext: batchContext
            )
        }

        await MainActor.run {
            isRestoring = false
            restoreProgress = (0, 0)
            restoringAppName = ""
            AppIconCache.shared.removeAll()
            iconRefreshTrigger = UUID()
        }

        diagnostics.log(
            .operation,
            phase: "restore_batch.completed",
            context: batchContext,
            durationMilliseconds: batchTimer.elapsedMilliseconds,
            details: [
                "restored": String(result.restored),
                "skipped": String(
                    max(0, allPaths.count - result.restored - result.failed.count)
                ),
                "skipped_not_installed": String(result.skippedNotInstalled),
                "failed": String(result.failed.count),
                "total": String(allPaths.count),
            ]
        )
        return result
    }

    private func applyBestCachedIcon(
        for app: AppItem,
        diagnosticsContext: DiagnosticsContext
    ) throws -> DiagnosticsContext? {
        let appPath = app.url.universalPath()
        let cache = IconCacheManager.shared.getIconCache(for: appPath)
        let normalURL = cache.map {
            IconCacheManager.cacheDirectory.appendingPathComponent($0.iconFileName)
        }
        let normalAvailable = normalURL.map {
            FileManager.default.fileExists(atPath: $0.path)
        } ?? false
        let storedConfiguration = AppearanceIconStore.shared.configuration(for: appPath)
        let configuration = storedConfiguration.flatMap { candidate -> AppearanceIconConfiguration? in
            guard candidate.isComplete,
                  IconAppearance.allCases.allSatisfy({ appearance in
                      AppearanceIconStore.shared.iconURL(
                          for: appPath,
                          appearance: appearance
                      ).map { FileManager.default.fileExists(atPath: $0.path) } ?? false
                  }) else {
                return nil
            }
            return candidate
        }
        let currentAppearance = SystemAppearanceMonitor.readAppearance()
        let choice = IconAppearancePolicy.restoreChoice(
            configuration: configuration,
            normalIconAvailable: normalAvailable,
            switchingEnabled: UserDefaults.standard.bool(forKey: "enableAppearanceIconSwitching"),
            currentAppearance: currentAppearance
        )

        switch choice {
        case .appearance(let appearance):
            guard let iconURL = AppearanceIconStore.shared.iconURL(
                for: appPath,
                appearance: appearance
            ), let image = NSImage(contentsOf: iconURL) else {
                throw RestoreError.iconFileNotFound(app.name)
            }
            let restoredContext = diagnosticsContext.withIcon(
                kind: "appearance_\(appearance.rawValue)",
                path: iconURL.path
            )
            diagnostics.log(
                .step,
                phase: "restore.icon_selected",
                context: restoredContext
            )
            try applyIcon(
                image,
                to: app,
                diagnosticsContext: restoredContext
            )
            AppearanceIconStore.shared.markApplied(appearance, for: appPath)
            Task { @MainActor in
                AppIconCache.shared.remove(for: app.url)
                self.iconRefreshTrigger = UUID()
            }
            return restoredContext
        case .normal:
            guard let normalURL, let image = NSImage(contentsOf: normalURL) else {
                throw RestoreError.iconFileNotFound(app.name)
            }
            let restoredContext = diagnosticsContext.withIcon(
                kind: "cached_normal",
                path: normalURL.path
            )
            diagnostics.log(
                .step,
                phase: "restore.icon_selected",
                context: restoredContext
            )
            try applyIcon(
                image,
                to: app,
                diagnosticsContext: restoredContext
            )
            IconCacheManager.shared.updateTimestamp(for: appPath)
            AppearanceIconStore.shared.resetAppliedAppearance(for: appPath)
            Task { @MainActor in
                AppIconCache.shared.remove(for: app.url)
                self.iconRefreshTrigger = UUID()
            }
            return restoredContext
        case .none:
            return nil
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

        let context = DiagnosticsContext(
            operation: .replace,
            appName: app.name,
            appPath: app.url.universalPath(),
            iconKind: "bundled_icon",
            iconPath: iconURL.path
        )
        try ensureSetupCompleted()
        // Pass the .icns file directly to fileicon to preserve all resolutions
        try runHelperTool(
            appPath: app.url.universalPath(),
            imagePath: iconURL.path,
            diagnosticsContext: context
        )

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
            let lowered = value.lowercased()
            if seenQueries.insert(lowered).inserted {
                orderedQueries.append(lowered)
            }
        }

        let isFolder = app.url.pathExtension != "app"
        let extendedSearch = UserDefaults.standard.bool(forKey: "extendedSearch")

        if isFolder {
            appendQuery("folder \(appName)")
            if extendedSearch {
                appendQuery(appName)
            }
        } else {
            appendQuery(appName)
            if extendedSearch {
                appendQuery(urlName)
                appendQuery(bundleName)
            }
        }
        appendQuery(aliasName)

        let selectedKey = APIKeyManager.pickKey()
        let fetchedIcons: [IconRes] = try await withThrowingTaskGroup(of: [IconRes].self) { group in
            for query in orderedQueries {
                group.addTask {
                    try Task.checkCancellation()
                    return try await queryController.sendRequest(query, style: style, apiKey: selectedKey)
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
    
    func runHelperTool(
        appPath: String,
        imagePath: String,
        diagnosticsContext: DiagnosticsContext? = nil
    ) throws {
        let context =
            diagnosticsContext
            ?? DiagnosticsContext(
                operation: .replace,
                appPath: appPath,
                iconKind: "file",
                iconPath: imagePath
            )
        try runHelper(
            arguments: [fileiconURL.path, appPath, imagePath],
            operation: "set",
            appPath: appPath,
            diagnosticsContext: context
        )
    }

    private func runHelperRemove(
        appPath: String,
        diagnosticsContext: DiagnosticsContext
    ) throws {
        try runHelper(
            arguments: ["--remove", fileiconURL.path, appPath],
            operation: "remove",
            appPath: appPath,
            diagnosticsContext: diagnosticsContext
        )
    }

    private func runHelper(
        arguments: [String],
        operation: String,
        appPath: String,
        diagnosticsContext: DiagnosticsContext
    ) throws {
        let helperToolPath = self.helperScriptURL.path
        let helperTimer = DiagnosticsTimer()

        let task = Process()
        let outPipe = Pipe()
        let errPipe = Pipe()

        task.executableURL = URL(fileURLWithPath: "/usr/bin/sudo")
        task.arguments = ["-n", helperToolPath] + arguments
        task.standardOutput = outPipe
        task.standardError = errPipe
        task.standardInput = nil

        logger.debug(
            "Executing privileged icon \(operation, privacy: .public) for \(appPath, privacy: .private)"
        )
        let targetURL = URL(fileURLWithPath: appPath)
        let resourceValues = try? targetURL.resourceValues(
            forKeys: [.volumeIsInternalKey, .isWritableKey]
        )
        let targetRunning = NSWorkspace.shared.runningApplications.contains {
            $0.bundleURL?.standardizedFileURL.path
                == targetURL.standardizedFileURL.path
        }
        diagnostics.log(
            .step,
            phase: "helper.start",
            context: diagnosticsContext,
            details: [
                "mode": operation,
                "target_exists": String(
                    FileManager.default.fileExists(atPath: appPath)
                ),
                "target_running": String(targetRunning),
                "target_user_writable": String(resourceValues?.isWritable ?? false),
                "target_volume_internal": String(
                    resourceValues?.volumeIsInternal ?? false
                ),
            ]
        )

        // Read pipes concurrently to avoid deadlock when buffers fill up
        var outputData = Data()
        var errorData = Data()
        let pipeGroup = DispatchGroup()

        pipeGroup.enter()
        DispatchQueue.global().async {
            outputData = outPipe.fileHandleForReading.readDataToEndOfFile()
            pipeGroup.leave()
        }
        pipeGroup.enter()
        DispatchQueue.global().async {
            errorData = errPipe.fileHandleForReading.readDataToEndOfFile()
            pipeGroup.leave()
        }

        let semaphore = DispatchSemaphore(value: 0)
        var timedOut = false

        task.terminationHandler = { _ in
            semaphore.signal()
        }

        do {
            try task.run()
        } catch {
            diagnostics.log(
                .failure,
                phase: "helper.launch_failed",
                context: diagnosticsContext,
                durationMilliseconds: helperTimer.elapsedMilliseconds,
                details: DiagnosticsLogger.errorDetails(error)
            )
            throw NSError(domain: "IconManager", code: 15,
                          userInfo: [NSLocalizedDescriptionKey: "Failed to start helper tool process: \(error.localizedDescription)"])
        }

        let waitResult = semaphore.wait(timeout: .now() + 15.0)
        if waitResult == .timedOut {
            timedOut = true
            task.terminate()
        }

        pipeGroup.wait()
        let output = String(data: outputData, encoding: .utf8) ?? ""
        let errorOutput = String(data: errorData, encoding: .utf8) ?? ""

        if timedOut {
            diagnostics.log(
                .failure,
                phase: "helper.timed_out",
                context: diagnosticsContext,
                durationMilliseconds: helperTimer.elapsedMilliseconds
            )
            throw NSError(domain: "IconManager", code: 14,
                          userInfo: [NSLocalizedDescriptionKey: "Helper tool timed out"])
        }

        if task.terminationStatus != 0 {
            diagnostics.log(
                .failure,
                phase: "helper.failed",
                context: diagnosticsContext,
                durationMilliseconds: helperTimer.elapsedMilliseconds,
                details: [
                    "exit_status": String(task.terminationStatus),
                    "process_stdout": output,
                    "process_stderr": errorOutput,
                ]
            )
            let combined = "Stdout:\n\(output)\nStderr:\n\(errorOutput)".trimmingCharacters(in: .whitespacesAndNewlines)
            throw NSError(domain: "IconManager", code: 10,
                          userInfo: [NSLocalizedDescriptionKey: "Helper tool failed (status: \(task.terminationStatus)): \(combined.isEmpty ? "No output" : combined)"])
        }

        let combinedLower = (output + errorOutput).lowercased()
        if combinedLower.contains("incorrect password") || combinedLower.contains("try again") {
            diagnostics.log(
                .failure,
                phase: "helper.unexpected_password_prompt",
                context: diagnosticsContext,
                durationMilliseconds: helperTimer.elapsedMilliseconds
            )
            throw NSError(domain: "IconManager", code: 16,
                          userInfo: [NSLocalizedDescriptionKey: "Helper tool unexpectedly asked for a password: \(output)\(errorOutput)"])
        }

        let app = AppItem(
            name: diagnosticsContext.appName ?? targetURL.deletingPathExtension().lastPathComponent,
            url: targetURL,
            originalAppInfo: nil
        )
        let customIconPresent = hasCustomIcon(app: app)
        let postconditionSatisfied =
            operation == "remove" ? !customIconPresent : customIconPresent
        diagnostics.log(
            postconditionSatisfied ? .step : .failure,
            phase: "helper.postcondition_checked",
            context: diagnosticsContext,
            details: [
                "custom_icon_present": String(customIconPresent),
                "expected_custom_icon": String(operation != "remove"),
            ]
        )
        diagnostics.log(
            .performance,
            phase: "helper.finish",
            context: diagnosticsContext,
            durationMilliseconds: helperTimer.elapsedMilliseconds,
            details: [
                "exit_status": String(task.terminationStatus),
                "process_stdout": output,
                "process_stderr": errorOutput,
            ]
        )
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
    static func runProcess(
        executableURL: URL,
        arguments: [String],
        timeout: TimeInterval = 10.0
    ) throws -> String {
        let task = Process()
        let pipe = Pipe()
        let errorPipe = Pipe()

        task.standardOutput = pipe
        task.standardError = errorPipe
        task.arguments = arguments
        task.executableURL = executableURL
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

    @discardableResult
    static func safeShell(_ command: String, timeout: TimeInterval = 10.0) throws -> String {
        try runProcess(
            executableURL: URL(fileURLWithPath: "/bin/zsh"),
            arguments: ["-c", command],
            timeout: timeout
        )
    }

    private func probeSudoPermission() -> SudoPermissionProbeResult {
        do {
            _ = try Self.runProcess(
                executableURL: URL(fileURLWithPath: "/usr/bin/sudo"),
                arguments: ["-n", "--", helperScriptURL.path, "--self-test"],
                timeout: 5.0
            )
            return .authorized
        } catch let error as ShellError {
            switch error {
            case .commandFailed(let status, let output):
                return SudoPermissionProbePolicy.classify(
                    exitStatus: status,
                    output: output
                )
            case .timeout:
                return .helperFailed("Privileged helper self-test timed out.")
            case .taskCreationFailed(let underlying):
                return .helperFailed(
                    "Could not start sudo: \(underlying?.localizedDescription ?? "unknown error")"
                )
            }
        } catch {
            return .helperFailed(error.localizedDescription)
        }
    }

    private func legacySudoersRuleIsActive() -> Bool {
        let output: String
        do {
            output = try Self.runProcess(
                executableURL: URL(fileURLWithPath: "/usr/bin/sudo"),
                arguments: ["-n", "-l"],
                timeout: 5.0
            )
        } catch let error as ShellError {
            if case .commandFailed(_, let commandOutput) = error {
                return LegacySudoersPolicy.containsLegacyRule(
                    in: commandOutput,
                    homeDirectory: FileManager.default.homeDirectoryForCurrentUser.path
                )
            }
            return false
        } catch {
            return false
        }

        return LegacySudoersPolicy.containsLegacyRule(
            in: output,
            homeDirectory: FileManager.default.homeDirectoryForCurrentUser.path
        )
    }

    func configureSudoers() throws {
        let diagnosticsContext = DiagnosticsContext(operation: .setup)
        let timer = DiagnosticsTimer()
        diagnostics.log(
            .operation,
            phase: "sudoers_configuration.start",
            context: diagnosticsContext
        )
        let helperPath = self.helperScriptURL.path
        let username = NSUserName()
        guard username.range(of: "^[a-zA-Z0-9._-]+$", options: .regularExpression) != nil else {
            let error = NSError(
                domain: "IconManager",
                code: 22,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Username contains characters not safe for sudoers configuration."
                ]
            )
            diagnostics.log(
                .failure,
                phase: "sudoers_configuration.invalid_username",
                context: diagnosticsContext,
                durationMilliseconds: timer.elapsedMilliseconds,
                details: DiagnosticsLogger.errorDetails(error)
            )
            throw error
        }
        let sudoersLine = "\(username) ALL=(ALL) NOPASSWD: \(helperPath)"
        let sudoersFile = "/etc/sudoers.d/iconchanger"
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser.path
        let legacyLines = LegacySudoersPolicy.exactLegacyLines(
            username: username,
            homeDirectory: homeDirectory
        )
        let legacyFileiconPath = "\(homeDirectory)/.iconchanger/fileicon"

        let commands = [
            "RULE_TMP=$(mktemp /tmp/iconchanger_sudoers.XXXXXX)",
            "MAIN_TMP=$(mktemp /etc/sudoers.iconchanger.XXXXXX)",
            "trap 'rm -f \"$RULE_TMP\" \"$MAIN_TMP\"' EXIT",
            "echo '\(sudoersLine.shellEscaped)' > \"$RULE_TMP\"",
            "awk -v old_all='\(legacyLines[0].shellEscaped)' -v old_user='\(legacyLines[1].shellEscaped)' '$0 != old_all && $0 != old_user { print }' /etc/sudoers > \"$MAIN_TMP\"",
            "chmod 0440 \"$RULE_TMP\" \"$MAIN_TMP\"",
            "chown root:wheel \"$RULE_TMP\" \"$MAIN_TMP\"",
            "visudo -c -f \"$RULE_TMP\"",
            "visudo -c -f \"$MAIN_TMP\"",
            "if cmp -s /etc/sudoers \"$MAIN_TMP\"; then rm -f \"$MAIN_TMP\"; else mv \"$MAIN_TMP\" /etc/sudoers; fi",
            "mv \"$RULE_TMP\" '\(sudoersFile.shellEscaped)'",
            "rm -f '\(legacyHelperScriptPath.shellEscaped)' '\(legacyFileiconPath.shellEscaped)'",
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

        do {
            try task.run()
        } catch {
            diagnostics.log(
                .failure,
                phase: "sudoers_configuration.launch_failed",
                context: diagnosticsContext,
                durationMilliseconds: timer.elapsedMilliseconds,
                details: DiagnosticsLogger.errorDetails(error)
            )
            throw error
        }
        task.waitUntilExit()

        let errorOutput = String(data: errorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""

        if task.terminationStatus != 0 {
            if errorOutput.contains("User canceled") || errorOutput.contains("-128") {
                logger.log("User canceled the admin password dialog.")
                let error = NSError(
                    domain: "IconManager",
                    code: 20,
                    userInfo: [
                        NSLocalizedDescriptionKey:
                            NSLocalizedString("Setup was canceled.", comment: "User canceled admin dialog")
                    ]
                )
                diagnostics.log(
                    .skipped,
                    phase: "sudoers_configuration.cancelled",
                    context: diagnosticsContext,
                    durationMilliseconds: timer.elapsedMilliseconds
                )
                throw error
            }
            logger.error("Sudoers configuration failed: \(errorOutput)")
            let error = NSError(
                domain: "IconManager",
                code: 21,
                userInfo: [
                    NSLocalizedDescriptionKey: String(
                        format: NSLocalizedString(
                            "Failed to configure permissions: %@",
                            comment: "Sudoers config error"
                        ),
                        errorOutput
                    )
                ]
            )
            diagnostics.log(
                .failure,
                phase: "sudoers_configuration.failed",
                context: diagnosticsContext,
                durationMilliseconds: timer.elapsedMilliseconds,
                details: [
                    "exit_status": String(task.terminationStatus),
                    "process_stderr": errorOutput,
                    "error_domain": error.domain,
                    "error_code": String(error.code),
                    "error_message": error.localizedDescription,
                ]
            )
            throw error
        }

        switch probeSudoPermission() {
        case .authorized:
            guard !legacySudoersRuleIsActive() else {
                let error = NSError(
                    domain: "IconManager",
                    code: 25,
                    userInfo: [
                        NSLocalizedDescriptionKey:
                            "The current helper is authorized, but the legacy user-writable sudoers rule could not be removed."
                    ]
                )
                diagnostics.log(
                    .failure,
                    phase: "sudoers_configuration.legacy_rule_remaining",
                    context: diagnosticsContext,
                    durationMilliseconds: timer.elapsedMilliseconds,
                    details: DiagnosticsLogger.errorDetails(error)
                )
                throw error
            }
        case .permissionMissing:
            let error = NSError(
                domain: "IconManager",
                code: 23,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "The sudoers rule was installed, but the exact helper command still requires a password. A managed Mac policy may be overriding it."
                ]
            )
            diagnostics.log(
                .failure,
                phase: "sudoers_configuration.permission_missing_after_install",
                context: diagnosticsContext,
                durationMilliseconds: timer.elapsedMilliseconds,
                details: DiagnosticsLogger.errorDetails(error)
            )
            throw error
        case .helperFailed(let detail):
            let error = NSError(
                domain: "IconManager",
                code: 24,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "The sudoers rule was installed, but the helper self-test failed: \(detail)"
                ]
            )
            diagnostics.log(
                .failure,
                phase: "sudoers_configuration.helper_self_test_failed",
                context: diagnosticsContext,
                durationMilliseconds: timer.elapsedMilliseconds,
                details: DiagnosticsLogger.errorDetails(error)
            )
            throw error
        }
        diagnostics.log(
            .operation,
            phase: "sudoers_configuration.completed",
            context: diagnosticsContext,
            durationMilliseconds: timer.elapsedMilliseconds
        )
    }

    func checkSetupStatus(
        diagnosticsContext: DiagnosticsContext? = nil
    ) -> SetupStatus {
        var missingFiles: [String] = []
        let helperExists = FileManager.default.fileExists(atPath: self.helperScriptURL.path)
        let fileiconExists = FileManager.default.fileExists(atPath: self.fileiconURL.path)

        if let diagnosticsContext {
            diagnostics.log(
                .step,
                phase: "setup.helper_files_checked",
                context: diagnosticsContext,
                details: [
                    "helper_exists": String(helperExists),
                    "fileicon_exists": String(fileiconExists),
                ]
            )
        }
        
        if !helperExists {
            missingFiles.append(helperScriptURL.lastPathComponent)
            logger.warning("Helper script missing at \(self.helperScriptURL.path)")
        }
        if !fileiconExists {
            missingFiles.append(fileiconURL.lastPathComponent)
            logger.warning("Fileicon missing at \(self.fileiconURL.path)")
        }
        
        if !missingFiles.isEmpty {
            if let diagnosticsContext {
                diagnostics.log(
                    .failure,
                    phase: "setup.helper_files_missing",
                    context: diagnosticsContext,
                    details: ["missing_files": missingFiles.joined(separator: ",")]
                )
            }
            return .helperFilesMissing(missingFiles: missingFiles)
        }

        let integrityVerified = verifyHelperIntegrity()
        if let diagnosticsContext {
            diagnostics.log(
                integrityVerified ? .step : .failure,
                phase: "setup.helper_integrity_checked",
                context: diagnosticsContext,
                details: ["integrity_verified": String(integrityVerified)]
            )
        }
        guard integrityVerified else {
            return .helperFilesOutdated
        }

        let sudoProbe = probeSudoPermission()
        switch sudoProbe {
        case .authorized:
            if let diagnosticsContext {
                diagnostics.log(
                    .step,
                    phase: "setup.sudo_helper_probe",
                    context: diagnosticsContext,
                    details: ["authorization": "authorized"]
                )
            }
            let legacyRuleActive = legacySudoersRuleIsActive()
            if let diagnosticsContext {
                diagnostics.log(
                    legacyRuleActive ? .failure : .step,
                    phase: "setup.legacy_sudoers_checked",
                    context: diagnosticsContext,
                    details: ["legacy_rule_active": String(legacyRuleActive)]
                )
            }
            return legacyRuleActive ? .legacySudoersPermissionPresent : .completed
        case .permissionMissing:
            if let diagnosticsContext {
                diagnostics.log(
                    .failure,
                    phase: "setup.sudo_helper_probe",
                    context: diagnosticsContext,
                    details: ["authorization": "password_required"]
                )
            }
            return .sudoersPermissionMissing
        case .helperFailed(let detail):
            if let diagnosticsContext {
                diagnostics.log(
                    .failure,
                    phase: "setup.sudo_helper_probe",
                    context: diagnosticsContext,
                    details: [
                        "authorization": "helper_failed",
                        "error_message": detail,
                    ]
                )
            }
            return .unknownError("Privileged helper self-test failed: \(detail)")
        }
    }

    func recordDiagnosticsSnapshot(source: DiagnosticsSource = .manual) {
        let context = DiagnosticsContext(
            operation: .setup,
            source: source,
            appName: "IconChanger",
            appPath: Bundle.main.bundlePath
        )
        let timer = DiagnosticsTimer()
        diagnostics.log(
            .operation,
            phase: "diagnostic_snapshot.start",
            context: context
        )

        let fileManager = FileManager.default
        let helperAttributes = try? fileManager.attributesOfItem(
            atPath: helperScriptURL.path
        )
        let fileiconAttributes = try? fileManager.attributesOfItem(
            atPath: fileiconURL.path
        )
        let setupStatus = checkSetupStatus(diagnosticsContext: context)
        let appManagement = appManagementStatus()

        #if arch(arm64)
        let architecture = "arm64"
        #elseif arch(x86_64)
        let architecture = "x86_64"
        #else
        let architecture = "unknown"
        #endif

        var details: [String: String] = [
            "setup_status": diagnosticName(for: setupStatus),
            "app_management_status": diagnosticName(for: appManagement),
            "folder_permission_count": String(FolderPermission.shared.permissions.count),
            "icon_cache_count": String(IconCacheManager.shared.getCachedIconsCount()),
            "application_support_writable": String(
                fileManager.isWritableFile(atPath: AppPaths.applicationSupportRoot.path)
            ),
            "cache_root_writable": String(
                fileManager.isWritableFile(atPath: AppPaths.cachesRoot.path)
            ),
            "helper_owner_uid": String(
                (helperAttributes?[.ownerAccountID] as? NSNumber)?.intValue ?? -1
            ),
            "helper_owner_gid": String(
                (helperAttributes?[.groupOwnerAccountID] as? NSNumber)?.intValue ?? -1
            ),
            "helper_mode": String(
                format: "%o",
                (helperAttributes?[.posixPermissions] as? NSNumber)?.intValue ?? 0
            ),
            "fileicon_owner_uid": String(
                (fileiconAttributes?[.ownerAccountID] as? NSNumber)?.intValue ?? -1
            ),
            "fileicon_owner_gid": String(
                (fileiconAttributes?[.groupOwnerAccountID] as? NSNumber)?.intValue ?? -1
            ),
            "fileicon_mode": String(
                format: "%o",
                (fileiconAttributes?[.posixPermissions] as? NSNumber)?.intValue ?? 0
            ),
            "system_os_version": ProcessInfo.processInfo.operatingSystemVersionString,
            "system_architecture": architecture,
            "system_app_version":
                Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
                as? String ?? "unknown",
            "system_app_build":
                Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")
                as? String ?? "unknown",
            "system_installed_in_applications": String(
                Bundle.main.bundlePath.hasPrefix("/Applications/")
            ),
        ]
        details["background_enabled"] = String(
            UserDefaults.standard.bool(forKey: "runInBackground")
        )
        details["scheduled_restore_enabled"] = String(
            UserDefaults.standard.bool(forKey: "enableScheduledRestore")
        )
        details["app_update_detection_enabled"] = String(
            UserDefaults.standard.bool(forKey: "enableAutoRestoreOnUpdate")
        )

        diagnostics.log(
            setupStatus.isDiagnosticsReady ? .operation : .failure,
            phase: "diagnostic_snapshot.completed",
            context: context,
            durationMilliseconds: timer.elapsedMilliseconds,
            details: details
        )
    }

    private func diagnosticName(for status: SetupStatus) -> String {
        switch status {
        case .completed:
            return "completed"
        case .helperFilesMissing:
            return "helper_files_missing"
        case .helperFilesOutdated:
            return "helper_files_outdated"
        case .sudoersPermissionMissing:
            return "sudoers_permission_missing"
        case .legacySudoersPermissionPresent:
            return "legacy_sudoers_permission_present"
        case .unknownError:
            return "unknown_error"
        }
    }

    private func diagnosticName(for status: AppManagementStatus) -> String {
        switch status {
        case .authorized:
            return "authorized"
        case .denied:
            return "denied"
        case .notDetermined:
            return "not_determined"
        case .unknown:
            return "unknown"
        }
    }

    // MARK: - App Management (TCC) Permission

    private static let tccHandle: UnsafeMutableRawPointer? = {
        dlopen("/System/Library/PrivateFrameworks/TCC.framework/Versions/A/TCC", RTLD_NOW)
    }()

    private static let tccPreflight: (@convention(c) (CFString, CFDictionary?) -> Int)? = {
        guard let handle = tccHandle, let sym = dlsym(handle, "TCCAccessPreflight") else { return nil }
        return unsafeBitCast(sym, to: (@convention(c) (CFString, CFDictionary?) -> Int).self)
    }()

    private static let tccRequest: (@convention(c) (CFString, CFDictionary?, @escaping (Bool) -> Void) -> Void)? = {
        guard let handle = tccHandle, let sym = dlsym(handle, "TCCAccessRequest") else { return nil }
        return unsafeBitCast(sym, to: (@convention(c) (CFString, CFDictionary?, @escaping (Bool) -> Void) -> Void).self)
    }()

    private static let tccServiceAppBundles = "kTCCServiceSystemPolicyAppBundles" as CFString

    enum AppManagementStatus {
        case authorized, denied, notDetermined, unknown
    }

    func appManagementStatus() -> AppManagementStatus {
        guard Bundle.main.bundlePath.hasPrefix("/Applications/") else { return .authorized }
        guard let preflight = Self.tccPreflight else { return .unknown }

        // 0 = authorized, 1 = denied, 2 = not determined
        switch preflight(Self.tccServiceAppBundles, nil) {
        case 0: return .authorized
        case 1: return .denied
        case 2: return .notDetermined
        default: return .unknown
        }
    }

    // Triggers the system TCC prompt if status is notDetermined.
    func requestAppManagementPermission(completion: @escaping (Bool) -> Void) {
        let context = DiagnosticsContext(operation: .permission)
        let timer = DiagnosticsTimer()
        diagnostics.log(
            .operation,
            phase: "app_management_request.start",
            context: context
        )
        guard let request = Self.tccRequest else {
            diagnostics.log(
                .failure,
                phase: "app_management_request.unavailable",
                context: context,
                durationMilliseconds: timer.elapsedMilliseconds
            )
            completion(false)
            return
        }
        request(Self.tccServiceAppBundles, nil) { granted in
            DiagnosticsLogger.shared.log(
                granted ? .operation : .failure,
                phase: "app_management_request.completed",
                context: context,
                durationMilliseconds: timer.elapsedMilliseconds,
                details: ["granted": String(granted)]
            )
            DispatchQueue.main.async { completion(granted) }
        }
    }
}

extension LaunchPadManagerDBHelper.AppInfo: @retroactive Identifiable {
    public var id: URL {
        url
    }
}

private extension SetupStatus {
    var isDiagnosticsReady: Bool {
        if case .completed = self {
            return true
        }
        return false
    }
}

extension String {
    var shellEscaped: String {
        self.replacingOccurrences(of: "'", with: "'\\''")
    }
}
