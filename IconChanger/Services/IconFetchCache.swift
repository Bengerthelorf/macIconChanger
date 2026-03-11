//
//  IconFetchCache.swift
//  IconChanger
//

import Foundation
import AppKit
import os

// MARK: - Codable IconRes Wrapper

struct CachedIconRes: Codable {
    let appName: String
    let icnsUrl: URL
    let lowResPngUrl: URL
    let downloads: Int

    func toIconRes() -> IconRes? {
        IconRes(
            appName: appName,
            icnsUrl: icnsUrl,
            lowResPngUrl: lowResPngUrl,
            downloads: downloads
        )
    }

    static func from(_ iconRes: IconRes) -> CachedIconRes {
        CachedIconRes(
            appName: iconRes.appName,
            icnsUrl: iconRes.icnsUrl,
            lowResPngUrl: iconRes.lowResPngUrl,
            downloads: iconRes.downloads
        )
    }
}

// MARK: - Cache Entry

struct IconFetchCacheEntry: Codable {
    let cacheKey: String
    let icons: [CachedIconRes]
    let timestamp: Date
    var lastAccessTime: Date
}

// MARK: - Icon Fetch Cache Manager

/// Manages icon search result caching with optional disk persistence.
class IconFetchCacheManager {
    static let shared = IconFetchCacheManager()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "IconFetchCache")

    // MARK: - Properties

    private let maxCacheEntries: Int = 200
    private var cache: [String: IconFetchCacheEntry] = [:]
    private let cacheLock = NSLock()

    private(set) var hitCount: Int = 0
    private(set) var missCount: Int = 0
    private(set) var evictionCount: Int = 0

    // MARK: - Disk Persistence

    private static var persistentCacheFileURL: URL {
        let dir = URL(fileURLWithPath: "\(NSHomeDirectory())/.iconchanger")
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir.appendingPathComponent("icon_fetch_cache.json")
    }

    private static let cacheAPIResultsKey = "cacheAPIResults"

    private var isPersistenceEnabled: Bool {
        // Default to true if never set by the user
        if UserDefaults.standard.object(forKey: Self.cacheAPIResultsKey) == nil {
            return true
        }
        return UserDefaults.standard.bool(forKey: Self.cacheAPIResultsKey)
    }

    func saveToDisk(force: Bool = false) {
        guard force || isPersistenceEnabled else { return }
        cacheLock.lock()
        let snapshot = cache
        cacheLock.unlock()

        do {
            let data = try JSONEncoder().encode(snapshot)
            try data.write(to: Self.persistentCacheFileURL, options: .atomic)
        } catch {
            logger.error("Failed to persist icon fetch cache: \(error.localizedDescription)")
        }
    }

    private func loadFromDisk() {
        guard isPersistenceEnabled else { return }
        let url = Self.persistentCacheFileURL
        guard FileManager.default.fileExists(atPath: url.path) else { return }

        do {
            let data = try Data(contentsOf: url)
            let loaded = try JSONDecoder().decode([String: IconFetchCacheEntry].self, from: data)
            cacheLock.lock()
            for (key, entry) in loaded where cache[key] == nil {
                cache[key] = entry
            }
            cacheLock.unlock()
            logger.log("Loaded \(loaded.count) entries from persistent icon fetch cache")
        } catch {
            logger.error("Failed to load persistent icon fetch cache: \(error.localizedDescription)")
        }
    }

    func deleteDiskCache() {
        try? FileManager.default.removeItem(at: Self.persistentCacheFileURL)
        logger.log("Deleted persistent icon fetch cache file")
    }

    // MARK: - Initialization

    private init() {
        loadFromDisk()
    }

    // MARK: - Cache Key Generation

    private func generateCacheKey(
        appName: String,
        bundleName: String?,
        aliasName: String?,
        style: String
    ) -> String {
        var components = [appName]
        if let bundle = bundleName {
            components.append(bundle)
        }
        if let alias = aliasName {
            components.append(alias)
        }
        components.append(style)
        return components.joined(separator: "|")
    }

    // MARK: - Cache Operations

    func getCachedIcons(
        appName: String,
        bundleName: String?,
        aliasName: String?,
        style: String
    ) -> [IconRes]? {
        cacheLock.lock()
        defer { cacheLock.unlock() }

        let key = generateCacheKey(
            appName: appName,
            bundleName: bundleName,
            aliasName: aliasName,
            style: style
        )

        guard var entry = cache[key] else {
            missCount += 1
            return nil
        }

        hitCount += 1

        let now = Date()
        entry.lastAccessTime = now
        cache[key] = entry

        let validIcons = entry.icons.compactMap { $0.toIconRes() }

        if validIcons.isEmpty && !entry.icons.isEmpty {
            logger.warning("All cached icons failed validation for \(key)")
            return nil
        }

        return validIcons
    }

    func cacheIcons(
        _ icons: [IconRes],
        appName: String,
        bundleName: String?,
        aliasName: String?,
        style: String
    ) {
        cacheLock.lock()

        let key = generateCacheKey(
            appName: appName,
            bundleName: bundleName,
            aliasName: aliasName,
            style: style
        )

        let cachedIcons = icons.map { CachedIconRes.from($0) }

        let now = Date()
        let entry = IconFetchCacheEntry(
            cacheKey: key,
            icons: cachedIcons,
            timestamp: now,
            lastAccessTime: now
        )

        if cache.count >= maxCacheEntries {
            evictOldestEntry()
        }

        cache[key] = entry
        cacheLock.unlock()
        saveToDisk()
    }

    private func evictOldestEntry() {
        guard let lruKey = cache.min(by: { $0.value.lastAccessTime < $1.value.lastAccessTime })?.key else {
            return
        }

        cache.removeValue(forKey: lruKey)
        evictionCount += 1
    }

    func clearAllCache() {
        cacheLock.lock()
        cache.removeAll()
        hitCount = 0
        missCount = 0
        evictionCount = 0
        cacheLock.unlock()
        saveToDisk()
    }

    @discardableResult
    func clearExpiredCache(olderThan maxAge: TimeInterval) -> Int {
        cacheLock.lock()

        let now = Date()
        let expiredKeys = cache.filter { entry in
            now.timeIntervalSince(entry.value.lastAccessTime) > maxAge
        }.map { $0.key }

        for key in expiredKeys {
            cache.removeValue(forKey: key)
        }
        cacheLock.unlock()

        if !expiredKeys.isEmpty { saveToDisk() }
        return expiredKeys.count
    }

    // MARK: - Cache Statistics

    func getCacheCount() -> Int {
        cacheLock.lock()
        defer { cacheLock.unlock() }
        return cache.count
    }

    func getStatistics() -> (hits: Int, misses: Int, total: Int, hitRate: Double, evictions: Int) {
        cacheLock.lock()
        defer { cacheLock.unlock() }

        let total = hitCount + missCount
        let hitRate = total > 0 ? Double(hitCount) / Double(total) : 0.0

        return (hitCount, missCount, cache.count, hitRate, evictionCount)
    }

}
