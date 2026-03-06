//
//  IconFetchCache.swift
//  IconChanger
//
//  Created by CantonMonkey on 2025/10/11.
//

import Foundation
import AppKit

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
struct IconFetchCacheEntry {
    let cacheKey: String
    let icons: [CachedIconRes]    // non-failable init, change it to failable for error handling 
    let timestamp: Date           // Creation time (for debugging/statistics)
    var lastAccessTime: Date      // Last access time (for LRU eviction)
}

// MARK: - Icon Fetch Cache Manager

/// Manager for icon fetch results caching (in-memory, periodically cleared)
class IconFetchCacheManager {
    static let shared = IconFetchCacheManager()

    // MARK: - Properties

    /// Maximum number of cache entries (prevent memory overflow)
    private let maxCacheEntries: Int = 500

    /// In-memory cache storage (not persisted)
    private var cache: [String: IconFetchCacheEntry] = [:]

    /// Lock for thread-safe operations
    private let cacheLock = NSLock()

    /// Cache statistics
    private(set) var hitCount: Int = 0
    private(set) var missCount: Int = 0
    private(set) var evictionCount: Int = 0  // Track evicted entries

    // MARK: - Initialization

    private init() {
//        print("📦 IconFetchCacheManager initialized")
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
//            print("❌ IconFetchCache MISS: \(key)")
            return nil
        }

        hitCount += 1

        // Update last access time (LRU)
        let now = Date()
        entry.lastAccessTime = now
        cache[key] = entry

        let age = now.timeIntervalSince(entry.timestamp)
        let timeSinceAccess = now.timeIntervalSince(entry.lastAccessTime)
//        print("✅ IconFetchCache HIT: \(key) (created: \(String(format: "%.1f", age))s ago, last accessed: \(String(format: "%.1f", timeSinceAccess))s ago, \(entry.icons.count) icons)")

        // Convert cached icons back to IconRes, filtering out any that fail validation
        let validIcons = entry.icons.compactMap { $0.toIconRes() }

        // If all icons failed validation, log a warning
        if validIcons.isEmpty && !entry.icons.isEmpty {
            print("⚠️ All cached icons failed validation for \(key)")
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
        defer { cacheLock.unlock() }

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
//        print("💾 IconFetchCache STORED: \(key) (\(icons.count) icons, total: \(cache.count))")
    }

    /// Evict the least recently used cache entry (by lastAccessTime)
    private func evictOldestEntry() {
        guard let lruKey = cache.min(by: { $0.value.lastAccessTime < $1.value.lastAccessTime })?.key else {
            return
        }

        cache.removeValue(forKey: lruKey)
        evictionCount += 1
//        print("🗑️ IconFetchCache EVICTED (LRU): \(lruKey) (count: \(cache.count))")
    }

    /// Clear all cache entries
    func clearAllCache() {
        cacheLock.lock()
        defer { cacheLock.unlock() }

        let count = cache.count
        cache.removeAll()
        hitCount = 0
        missCount = 0
        evictionCount = 0

        if count > 0 {
//            print("🧹 IconFetchCache CLEARED: Removed \(count) entries")
        }
    }

    /// Clear cache entries that haven't been accessed for longer than maxAge
    /// This implements true LRU behavior by checking lastAccessTime
    func clearExpiredCache(olderThan maxAge: TimeInterval) -> Int {
        cacheLock.lock()
        defer { cacheLock.unlock() }

        let now = Date()
        let expiredKeys = cache.filter { entry in
            // Check time since last access (not creation)
            now.timeIntervalSince(entry.value.lastAccessTime) > maxAge
        }.map { $0.key }

        for key in expiredKeys {
            cache.removeValue(forKey: key)
        }

        if !expiredKeys.isEmpty {
//            print("🧹 IconFetchCache EXPIRED: Removed \(expiredKeys.count) entries not accessed for \(String(format: "%.0f", maxAge))s (total: \(cache.count) remain)")
        }

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

    /// Print cache statistics
    func printStatistics() {
        let stats = getStatistics()
//        print("""
//        📊 IconFetchCache Statistics:
//           - Cache Hits: \(stats.hits)
//           - Cache Misses: \(stats.misses)
//           - Hit Rate: \(String(format: "%.1f%%", stats.hitRate * 100))
//           - Cached Entries: \(stats.total) / \(maxCacheEntries)
//           - Evictions: \(stats.evictions)
//        """)
    }
}
