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
        if let data = UserDefaults.standard.data(forKey: cacheKey),
           let decoded = try? JSONDecoder().decode([String: IconCache].self, from: data) {
            cachedIcons = decoded
        }
    }

    /// Must be called outside the lock. Pass a snapshot of cachedIcons.
    private func persistCache(_ snapshot: [String: IconCache]) {
        do {
            let encoded = try JSONEncoder().encode(snapshot)
            UserDefaults.standard.set(encoded, forKey: cacheKey)
        } catch {
            logger.error("Failed to persist icon cache metadata: \(error.localizedDescription, privacy: .public)")
        }
    }

    func cacheIcon(image: NSImage, for appPath: String, appName: String) throws -> URL {
        let iconFileName = "\(UUID().uuidString).png"
        let iconURL = Self.cacheDirectory.appendingPathComponent(iconFileName)

        if let saveError = IconManager.saveImage(image, atUrl: iconURL) {
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
