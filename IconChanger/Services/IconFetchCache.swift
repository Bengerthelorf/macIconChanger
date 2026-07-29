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
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "IconChanger", category: "IconFetchCache")

    // MARK: - Properties

    private let maxCacheEntries: Int = 200
    private var cache: [String: IconFetchCacheEntry] = [:]
    private let cacheLock = NSLock()

    private(set) var hitCount: Int = 0
    private(set) var missCount: Int = 0
    private(set) var evictionCount: Int = 0

    // MARK: - Disk Persistence

    private static var persistentCacheFileURL: URL {
        AppPaths.iconFetchCacheFile
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
        let context = DiagnosticsContext(
            operation: .cache,
            iconKind: "search_result_cache",
            iconPath: Self.persistentCacheFileURL.path
        )
        let timer = DiagnosticsTimer()
        guard force || isPersistenceEnabled else {
            DiagnosticsLogger.shared.log(
                .skipped,
                phase: "search_cache.persist_disabled",
                context: context
            )
            return
        }
        cacheLock.lock()
        let snapshot = cache
        cacheLock.unlock()

        do {
            let data = try JSONEncoder().encode(snapshot)
            try data.write(to: Self.persistentCacheFileURL, options: .atomic)
            DiagnosticsLogger.shared.log(
                .performance,
                phase: "search_cache.persisted",
                context: context,
                durationMilliseconds: timer.elapsedMilliseconds,
                details: [
                    "entry_count": String(snapshot.count),
                    "bytes_written": String(data.count),
                ]
            )
        } catch {
            logger.error("Failed to persist icon fetch cache: \(error.localizedDescription)")
            DiagnosticsLogger.shared.log(
                .failure,
                phase: "search_cache.persist_failed",
                context: context,
                durationMilliseconds: timer.elapsedMilliseconds,
                details: DiagnosticsLogger.errorDetails(error)
            )
        }
    }

    private func loadFromDisk() {
        let context = DiagnosticsContext(
            operation: .cache,
            source: .startup,
            iconKind: "search_result_cache",
            iconPath: Self.persistentCacheFileURL.path
        )
        let timer = DiagnosticsTimer()
        guard isPersistenceEnabled else {
            DiagnosticsLogger.shared.log(
                .skipped,
                phase: "search_cache.load_disabled",
                context: context
            )
            return
        }
        let url = Self.persistentCacheFileURL
        guard FileManager.default.fileExists(atPath: url.path) else {
            DiagnosticsLogger.shared.log(
                .skipped,
                phase: "search_cache.file_not_found",
                context: context
            )
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let loaded = try JSONDecoder().decode([String: IconFetchCacheEntry].self, from: data)
            cacheLock.lock()
            for (key, entry) in loaded where cache[key] == nil {
                cache[key] = entry
            }
            cacheLock.unlock()
            logger.log("Loaded \(loaded.count) entries from persistent icon fetch cache")
            DiagnosticsLogger.shared.log(
                .operation,
                phase: "search_cache.loaded",
                context: context,
                durationMilliseconds: timer.elapsedMilliseconds,
                details: ["entry_count": String(loaded.count)]
            )
        } catch {
            logger.error("Failed to load persistent icon fetch cache: \(error.localizedDescription)")
            DiagnosticsLogger.shared.log(
                .failure,
                phase: "search_cache.load_failed",
                context: context,
                durationMilliseconds: timer.elapsedMilliseconds,
                details: DiagnosticsLogger.errorDetails(error)
            )
        }
    }

    func deleteDiskCache() {
        let context = DiagnosticsContext(
            operation: .cache,
            iconKind: "search_result_cache",
            iconPath: Self.persistentCacheFileURL.path
        )
        do {
            if FileManager.default.fileExists(atPath: Self.persistentCacheFileURL.path) {
                try FileManager.default.removeItem(at: Self.persistentCacheFileURL)
            }
            logger.log("Deleted persistent icon fetch cache file")
            DiagnosticsLogger.shared.log(
                .operation,
                phase: "search_cache.disk_file_deleted",
                context: context
            )
        } catch {
            DiagnosticsLogger.shared.log(
                .failure,
                phase: "search_cache.disk_file_delete_failed",
                context: context,
                details: DiagnosticsLogger.errorDetails(error)
            )
        }
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
            DiagnosticsLogger.shared.log(
                .step,
                phase: "search_cache.miss",
                context: DiagnosticsContext(
                    operation: .cache,
                    appName: appName,
                    iconKind: "search_result_cache"
                ),
                details: ["style": style]
            )
            return nil
        }

        hitCount += 1

        let now = Date()
        entry.lastAccessTime = now
        cache[key] = entry

        let validIcons = entry.icons.compactMap { $0.toIconRes() }

        if validIcons.isEmpty && !entry.icons.isEmpty {
            logger.warning("All cached icons failed validation for \(key)")
            DiagnosticsLogger.shared.log(
                .failure,
                phase: "search_cache.validation_failed",
                context: DiagnosticsContext(
                    operation: .cache,
                    appName: appName,
                    iconKind: "search_result_cache"
                ),
                details: ["stored_result_count": String(entry.icons.count)]
            )
            return nil
        }

        DiagnosticsLogger.shared.log(
            .step,
            phase: "search_cache.hit",
            context: DiagnosticsContext(
                operation: .cache,
                appName: appName,
                iconKind: "search_result_cache"
            ),
            details: [
                "style": style,
                "result_count": String(validIcons.count),
            ]
        )
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
        let entryCount = cache.count
        cacheLock.unlock()
        DiagnosticsLogger.shared.log(
            .operation,
            phase: "search_cache.updated",
            context: DiagnosticsContext(
                operation: .cache,
                appName: appName,
                iconKind: "search_result_cache",
                iconPath: Self.persistentCacheFileURL.path
            ),
            details: [
                "style": style,
                "result_count": String(icons.count),
                "entry_count": String(entryCount),
            ]
        )
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
        DiagnosticsLogger.shared.log(
            .operation,
            phase: "search_cache.cleared",
            context: DiagnosticsContext(
                operation: .cache,
                iconKind: "search_result_cache",
                iconPath: Self.persistentCacheFileURL.path
            )
        )
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

        if !expiredKeys.isEmpty {
            DiagnosticsLogger.shared.log(
                .operation,
                phase: "search_cache.expired_entries_removed",
                context: DiagnosticsContext(
                    operation: .cache,
                    source: .scheduled,
                    iconKind: "search_result_cache",
                    iconPath: Self.persistentCacheFileURL.path
                ),
                details: ["removed_count": String(expiredKeys.count)]
            )
            saveToDisk()
        }
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
