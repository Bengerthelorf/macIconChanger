//
//  IconCache.swift
//  IconChanger
//
//  Created by Bengerthelorf on 2025/03/23.
//  Modified on 2025/03/24 to add configuration import support
//  Modified on 2025/03/25 to add funtion for Importing and Exporting configuration
//

import Foundation
import AppKit

struct IconCache: Codable, Identifiable {
    var id: String { appPath }
    let appPath: String
    let iconFileName: String
    let appName: String
    let timestamp: Date
}

class IconCacheManager {
    static let shared = IconCacheManager()

    private let cacheKey = "com.iconchanger.cachedIcons"
    private var cachedIcons: [String: IconCache] = [:]
    private let lock = NSLock()

    // Get the cache directory
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

    // Load cached icons from UserDefaults
    private func loadCache() {
        if let data = UserDefaults.standard.data(forKey: cacheKey),
           let decoded = try? JSONDecoder().decode([String: IconCache].self, from: data) {
            cachedIcons = decoded
        }
    }

    // Save cached icons to UserDefaults (must be called while lock is held)
    private func saveCache() {
        if let encoded = try? JSONEncoder().encode(cachedIcons) {
            UserDefaults.standard.set(encoded, forKey: cacheKey)
        }
    }

    // Add or update a cached icon
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
            timestamp: Date()
        )

        lock.lock()
        cachedIcons[appPath] = iconCache
        saveCache()
        lock.unlock()

        return iconURL
    }

    // Get cached icon for an app
    func getIconCache(for appPath: String) -> IconCache? {
        lock.lock()
        defer { lock.unlock() }
        return cachedIcons[appPath]
    }

    // Get cached icon URL for an app
    func getCachedIconURL(for appPath: String) -> URL? {
        lock.lock()
        defer { lock.unlock() }
        guard let cache = cachedIcons[appPath] else { return nil }
        return Self.cacheDirectory.appendingPathComponent(cache.iconFileName)
    }

    // Get all cached icons
    func getAllCachedIcons() -> [IconCache] {
        lock.lock()
        defer { lock.unlock() }
        return Array(cachedIcons.values)
    }

    // Count cached icons
    func getCachedIconsCount() -> Int {
        lock.lock()
        defer { lock.unlock() }
        return cachedIcons.count
    }

    // Update the timestamp of a cached icon (e.g. after re-applying it)
    func updateTimestamp(for appPath: String, to date: Date = Date()) {
        lock.lock()
        if let existing = cachedIcons[appPath] {
            cachedIcons[appPath] = IconCache(
                appPath: existing.appPath,
                iconFileName: existing.iconFileName,
                appName: existing.appName,
                timestamp: date
            )
            saveCache()
        }
        lock.unlock()
    }

    // Remove a cached icon
    func removeCachedIcon(for appPath: String) {
        lock.lock()
        if let cache = cachedIcons[appPath] {
            let iconURL = Self.cacheDirectory.appendingPathComponent(cache.iconFileName)
            try? FileManager.default.removeItem(at: iconURL)

            cachedIcons.removeValue(forKey: appPath)
            saveCache()
        }
        lock.unlock()
    }

    // Clear all cached icons
    func clearCache() {
        lock.lock()
        let urlsToDelete = cachedIcons.values.map {
            Self.cacheDirectory.appendingPathComponent($0.iconFileName)
        }
        cachedIcons.removeAll()
        saveCache()
        lock.unlock()

        // Delete files outside the lock to avoid blocking other operations
        for url in urlsToDelete {
            try? FileManager.default.removeItem(at: url)
        }
    }

    func addImportedCache(_ cache: IconCache) {
        lock.lock()
        cachedIcons[cache.appPath] = cache
        saveCache()
        lock.unlock()
    }
}

// Error type for restore failures
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
