//
//  IconFetchCache.swift
//  IconChanger
//
//  Created by CantonMonkey on 2025/10/11.
//

import Foundation
import AppKit
import os

// MARK: - Codable IconRes Wrapper

/// Codable version of IconRes for caching
struct CachedIconRes: Codable {
    let appName: String
    let icnsUrl: URL
    let lowResPngUrl: URL
    let downloads: Int

    /// Convert to IconRes (may return nil if validation fails)
    func toIconRes() -> IconRes? {
        return IconRes(
            appName: appName,
            icnsUrl: icnsUrl,
            lowResPngUrl: lowResPngUrl,
            downloads: downloads
        )
    }

    /// Create from IconRes
    static func from(_ iconRes: IconRes) -> CachedIconRes {
        return CachedIconRes(
            appName: iconRes.appName,
            icnsUrl: iconRes.icnsUrl,
            lowResPngUrl: iconRes.lowResPngUrl,
            downloads: iconRes.downloads
        )
    }
}

// MARK: - Cache Entry

/// Cache entry for icon fetch results
struct IconFetchCacheEntry: Codable {
    let cacheKey: String
    let icons: [CachedIconRes]
    let timestamp: Date           // Creation time (for debugging/statistics)
    var lastAccessTime: Date      // Last access time (for LRU eviction)
}

// MARK: - Icon Fetch Cache Manager

/// Manager for icon fetch results caching (in-memory, periodically cleared)
class IconFetchCacheManager {
    static let shared = IconFetchCacheManager()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "IconFetchCache")

    // MARK: - Properties

    /// Maximum number of cache entries (prevent memory overflow)
    private let maxCacheEntries: Int = 200

    /// In-memory cache storage (not persisted)
    private var cache: [String: IconFetchCacheEntry] = [:]

    /// Lock for thread-safe operations
    private let cacheLock = NSLock()

    /// Cache statistics
    private(set) var hitCount: Int = 0
    private(set) var missCount: Int = 0
    private(set) var evictionCount: Int = 0  // Track evicted entries

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

    /// Persist the in-memory cache to disk (called outside the lock).
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

    /// Load persisted cache from disk into memory.
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

    /// Delete the on-disk cache file.
    func deleteDiskCache() {
        try? FileManager.default.removeItem(at: Self.persistentCacheFileURL)
        logger.log("Deleted persistent icon fetch cache file")
    }

    // MARK: - Initialization

    private init() {
        loadFromDisk()
    }

    // MARK: - Cache Key Generation

    /// Generate cache key from app info and style
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

    /// Get cached icons if available
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

        // Convert cached icons back to IconRes, filtering out any that fail validation
        let validIcons = entry.icons.compactMap { $0.toIconRes() }

        // If all icons failed validation, log a warning
        if validIcons.isEmpty && !entry.icons.isEmpty {
            logger.warning("All cached icons failed validation for \(key)")
            return nil
        }

        return validIcons
    }

    /// Cache icon fetch results
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

        // Check if we need to evict old entries
        if cache.count >= maxCacheEntries {
            evictOldestEntry()
        }

        cache[key] = entry
        cacheLock.unlock()
        saveToDisk()
    }

    /// Evict the least recently used cache entry (by lastAccessTime)
    private func evictOldestEntry() {
        guard let lruKey = cache.min(by: { $0.value.lastAccessTime < $1.value.lastAccessTime })?.key else {
            return
        }

        cache.removeValue(forKey: lruKey)
        evictionCount += 1
    }

    /// Clear all cache entries
    func clearAllCache() {
        cacheLock.lock()
        cache.removeAll()
        hitCount = 0
        missCount = 0
        evictionCount = 0
        cacheLock.unlock()
        saveToDisk()
    }

    /// Clear cache entries that haven't been accessed for longer than maxAge
    /// This implements true LRU behavior by checking lastAccessTime
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

    /// Get cache count
    func getCacheCount() -> Int {
        cacheLock.lock()
        defer { cacheLock.unlock() }
        return cache.count
    }

    /// Get cache statistics
    func getStatistics() -> (hits: Int, misses: Int, total: Int, hitRate: Double, evictions: Int) {
        cacheLock.lock()
        defer { cacheLock.unlock() }

        let total = hitCount + missCount
        let hitRate = total > 0 ? Double(hitCount) / Double(total) : 0.0

        return (hitCount, missCount, cache.count, hitRate, evictionCount)
    }

}
