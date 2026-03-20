//
//  IconCache.swift
//  IconChanger
//

import Foundation
import AppKit

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

    private let cacheKey = "com.iconchanger.cachedIcons"
    private var cachedIcons: [String: IconCache] = [:]
    private let lock = NSLock()

    static var cacheDirectory: URL {
        let path = "\(NSHomeDirectory())/.iconchanger/cache"
        let url = URL(fileURLWithPath: path)
        if !FileManager.default.fileExists(atPath: path) {
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
        return url
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
        if let encoded = try? JSONEncoder().encode(snapshot) {
            UserDefaults.standard.set(encoded, forKey: cacheKey)
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

        lock.lock()
        cachedIcons[appPath] = iconCache
        let snapshot = cachedIcons
        lock.unlock()
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
        var snapshot: [String: IconCache]?
        lock.lock()
        if let existing = cachedIcons[appPath] {
            cachedIcons[appPath] = IconCache(
                appPath: existing.appPath,
                iconFileName: existing.iconFileName,
                appName: existing.appName,
                timestamp: date,
                appVersion: IconCache.currentVersion(for: appPath)
            )
            snapshot = cachedIcons
        }
        lock.unlock()
        if let snapshot { persistCache(snapshot) }
    }

    func removeCachedIcon(for appPath: String) {
        var snapshot: [String: IconCache]?
        lock.lock()
        if let cache = cachedIcons[appPath] {
            let iconURL = Self.cacheDirectory.appendingPathComponent(cache.iconFileName)
            try? FileManager.default.removeItem(at: iconURL)

            cachedIcons.removeValue(forKey: appPath)
            snapshot = cachedIcons
        }
        lock.unlock()
        if let snapshot { persistCache(snapshot) }
    }

    func clearCache() {
        lock.lock()
        let urlsToDelete = cachedIcons.values.map {
            Self.cacheDirectory.appendingPathComponent($0.iconFileName)
        }
        cachedIcons.removeAll()
        let snapshot = cachedIcons
        lock.unlock()
        persistCache(snapshot)

        for url in urlsToDelete {
            try? FileManager.default.removeItem(at: url)
        }
    }

    func addImportedCache(_ cache: IconCache) {
        lock.lock()
        cachedIcons[cache.appPath] = cache
        let snapshot = cachedIcons
        lock.unlock()
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
            return "Failed to restore \(failed.count) icons"
        case .appNotFound(let appName):
            return "App not found: \(appName)"
        case .iconFileNotFound(let appName):
            return "Icon file not found for: \(appName)"
        }
    }
}
