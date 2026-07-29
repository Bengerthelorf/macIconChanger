//
//  IconCache.swift
//  IconChanger
//

import Foundation
import AppKit
import os

struct IconCache: Codable, Identifiable {
    var id: String { appPath }
    let appPath: String
    let iconFileName: String
    let appName: String
    let timestamp: Date
    var appVersion: String?

    static func currentVersion(for appPath: String) -> String? {
        Bundle(path: appPath)?.object(forInfoDictionaryKey: "CFBundleVersion") as? String
    }
}

class IconCacheManager {
    static let shared = IconCacheManager()

    private let logger = Logger(subsystem: AppPaths.bundleID, category: "IconCache")
    private let cacheKey = "com.iconchanger.cachedIcons"
    private var cachedIcons: [String: IconCache] = [:]
    private let lock = NSLock()

    static var cacheDirectory: URL {
        AppPaths.iconCacheDirectory
    }

    init() {
        loadCache()
    }

    private func loadCache() {
        let context = DiagnosticsContext(
            operation: .cache,
            source: .startup
        )
        guard let data = UserDefaults.standard.data(forKey: cacheKey) else {
            DiagnosticsLogger.shared.log(
                .skipped,
                phase: "icon_cache_metadata.not_found",
                context: context
            )
            return
        }
        do {
            let decoded = try JSONDecoder().decode([String: IconCache].self, from: data)
            cachedIcons = decoded
            DiagnosticsLogger.shared.log(
                .operation,
                phase: "icon_cache_metadata.loaded",
                context: context,
                details: ["entry_count": String(decoded.count)]
            )
        } catch {
            DiagnosticsLogger.shared.log(
                .failure,
                phase: "icon_cache_metadata.decode_failed",
                context: context,
                details: DiagnosticsLogger.errorDetails(error)
            )
        }
    }

    /// Must be called outside the lock. Pass a snapshot of cachedIcons.
    private func persistCache(_ snapshot: [String: IconCache]) {
        let context = DiagnosticsContext(operation: .cache)
        let timer = DiagnosticsTimer()
        do {
            try persistCacheOrThrow(snapshot)
            DiagnosticsLogger.shared.log(
                .performance,
                phase: "icon_cache_metadata.persisted",
                context: context,
                durationMilliseconds: timer.elapsedMilliseconds,
                details: ["entry_count": String(snapshot.count)]
            )
        } catch {
            logger.error("Failed to persist icon cache metadata: \(error.localizedDescription, privacy: .public)")
            DiagnosticsLogger.shared.log(
                .failure,
                phase: "icon_cache_metadata.persist_failed",
                context: context,
                durationMilliseconds: timer.elapsedMilliseconds,
                details: DiagnosticsLogger.errorDetails(error)
            )
        }
    }

    private func persistCacheOrThrow(_ snapshot: [String: IconCache]) throws {
        let encoded = try JSONEncoder().encode(snapshot)
        UserDefaults.standard.set(encoded, forKey: cacheKey)
    }

    func cacheIcon(image: NSImage, for appPath: String, appName: String) throws -> URL {
        let iconFileName = "\(UUID().uuidString).png"
        let iconURL = Self.cacheDirectory.appendingPathComponent(iconFileName)
        let context = DiagnosticsContext(
            operation: .cache,
            appName: appName,
            appPath: appPath,
            iconKind: "cached_normal",
            iconPath: iconURL.path
        )
        let timer = DiagnosticsTimer()
        DiagnosticsLogger.shared.log(
            .operation,
            phase: "icon_cache_write.start",
            context: context
        )

        if let saveError = IconManager.saveImage(image, atUrl: iconURL) {
            DiagnosticsLogger.shared.log(
                .failure,
                phase: "icon_cache_write.failed",
                context: context,
                durationMilliseconds: timer.elapsedMilliseconds,
                details: DiagnosticsLogger.errorDetails(saveError)
            )
            throw saveError
        }

        let iconCache = IconCache(
            appPath: appPath,
            iconFileName: iconFileName,
            appName: appName,
            timestamp: Date(),
            appVersion: IconCache.currentVersion(for: appPath)
        )

        let snapshot: [String: IconCache] = {
            lock.lock()
            defer { lock.unlock() }
            cachedIcons[appPath] = iconCache
            return cachedIcons
        }()
        persistCache(snapshot)

        DiagnosticsLogger.shared.log(
            .operation,
            phase: "icon_cache_write.completed",
            context: context,
            durationMilliseconds: timer.elapsedMilliseconds,
            details: [
                "app_version": iconCache.appVersion ?? "unknown",
                "entry_count": String(snapshot.count),
            ]
        )

        return iconURL
    }

    func getIconCache(for appPath: String) -> IconCache? {
        lock.lock()
        defer { lock.unlock() }
        return cachedIcons[appPath]
    }

    func getCachedIconURL(for appPath: String) -> URL? {
        lock.lock()
        defer { lock.unlock() }
        guard let cache = cachedIcons[appPath] else { return nil }
        return Self.cacheDirectory.appendingPathComponent(cache.iconFileName)
    }

    func getAllCachedIcons() -> [IconCache] {
        lock.lock()
        defer { lock.unlock() }
        return Array(cachedIcons.values)
    }

    func getCachedIconsCount() -> Int {
        lock.lock()
        defer { lock.unlock() }
        return cachedIcons.count
    }

    func updateTimestamp(for appPath: String, to date: Date = Date()) {
        let snapshot: [String: IconCache]? = {
            lock.lock()
            defer { lock.unlock() }
            guard let existing = cachedIcons[appPath] else { return nil }
            cachedIcons[appPath] = IconCache(
                appPath: existing.appPath,
                iconFileName: existing.iconFileName,
                appName: existing.appName,
                timestamp: date,
                appVersion: IconCache.currentVersion(for: appPath)
            )
            return cachedIcons
        }()
        if let snapshot { persistCache(snapshot) }
    }

    func removeCachedIcon(for appPath: String) {
        let result: (snapshot: [String: IconCache], iconURL: URL)? = {
            lock.lock()
            defer { lock.unlock() }
            guard let cache = cachedIcons[appPath] else { return nil }
            let iconURL = Self.cacheDirectory.appendingPathComponent(cache.iconFileName)
            cachedIcons.removeValue(forKey: appPath)
            return (cachedIcons, iconURL)
        }()
        if let result {
            try? FileManager.default.removeItem(at: result.iconURL)
            persistCache(result.snapshot)
        }
    }

    func clearCache() {
        let (snapshot, urlsToDelete): ([String: IconCache], [URL]) = {
            lock.lock()
            defer { lock.unlock() }
            let urls = cachedIcons.values.map {
                Self.cacheDirectory.appendingPathComponent($0.iconFileName)
            }
            cachedIcons.removeAll()
            return (cachedIcons, urls)
        }()
        persistCache(snapshot)

        for url in urlsToDelete {
            try? FileManager.default.removeItem(at: url)
        }
    }

    func addImportedCache(_ cache: IconCache) {
        let snapshot: [String: IconCache] = {
            lock.lock()
            defer { lock.unlock() }
            cachedIcons[cache.appPath] = cache
            return cachedIcons
        }()
        persistCache(snapshot)
    }

    /// Imports a cache entry without replacing an existing entry for the app.
    /// The icon file and metadata are committed together; a metadata failure
    /// removes the newly written file.
    @discardableResult
    func importIconData(
        _ data: Data,
        appPath: String,
        appName: String,
        appVersion: String?
    ) throws -> Bool {
        guard let image = NSImage(data: data) else {
            throw IconManager.ImageSaveError.cgImageConversionFailed
        }

        lock.lock()
        let alreadyExists = cachedIcons[appPath] != nil
        lock.unlock()
        guard !alreadyExists else { return false }

        let iconFileName = "\(UUID().uuidString).png"
        let iconURL = Self.cacheDirectory.appendingPathComponent(iconFileName)
        if let saveError = IconManager.saveImage(image, atUrl: iconURL) {
            throw saveError
        }

        lock.lock()
        if cachedIcons[appPath] != nil {
            lock.unlock()
            try? FileManager.default.removeItem(at: iconURL)
            return false
        }

        let cache = IconCache(
            appPath: appPath,
            iconFileName: iconFileName,
            appName: appName,
            timestamp: Date(),
            appVersion: appVersion ?? IconCache.currentVersion(for: appPath)
        )
        var snapshot = cachedIcons
        snapshot[appPath] = cache

        do {
            try persistCacheOrThrow(snapshot)
            cachedIcons = snapshot
            lock.unlock()
            return true
        } catch {
            lock.unlock()
            try? FileManager.default.removeItem(at: iconURL)
            throw error
        }
    }
}

enum RestoreError: Error, LocalizedError {
    case someFailed(failed: [(String, Error)])
    case appNotFound(String)
    case iconFileNotFound(String)

    var errorDescription: String? {
        switch self {
        case .someFailed(let failed):
            let details = failed.prefix(5).map { "\($0.0): \($0.1.localizedDescription)" }.joined(separator: "\n")
            let suffix = failed.count > 5 ? "\n...and \(failed.count - 5) more" : ""
            return "Failed to restore \(failed.count) icon(s):\n\(details)\(suffix)"
        case .appNotFound(let appName):
            return "App not found: \(appName)"
        case .iconFileNotFound(let appName):
            return "Icon file not found for: \(appName)"
        }
    }
}
