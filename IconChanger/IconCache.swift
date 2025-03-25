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
    
    // Save cached icons to UserDefaults
    private func saveCache() {
        if let encoded = try? JSONEncoder().encode(cachedIcons) {
            UserDefaults.standard.set(encoded, forKey: cacheKey)
        }
    }
    
    // Add or update a cached icon
    func cacheIcon(image: NSImage, for appPath: String, appName: String) throws -> URL {
        // Generate a unique filename for the icon
        let iconFileName = "\(UUID().uuidString).png"
        let iconURL = Self.cacheDirectory.appendingPathComponent(iconFileName)
        
        // Save the image to the cache directory
        IconManager.saveImage(image, atUrl: iconURL)
        
        // Create and store the cache information
        let iconCache = IconCache(
            appPath: appPath,
            iconFileName: iconFileName,
            appName: appName,
            timestamp: Date()
        )
        
        cachedIcons[appPath] = iconCache
        saveCache()
        
        return iconURL
    }
    
    // Get cached icon for an app
    func getIconCache(for appPath: String) -> IconCache? {
        return cachedIcons[appPath]
    }
    
    // Get cached icon URL for an app
    func getCachedIconURL(for appPath: String) -> URL? {
        guard let cache = cachedIcons[appPath] else { return nil }
        return Self.cacheDirectory.appendingPathComponent(cache.iconFileName)
    }
    
    // Get all cached icons
    func getAllCachedIcons() -> [IconCache] {
        return Array(cachedIcons.values)
    }
    
    // Count cached icons
    func getCachedIconsCount() -> Int {
        return cachedIcons.count
    }
    
    // Remove a cached icon
    func removeCachedIcon(for appPath: String) {
        if let cache = cachedIcons[appPath] {
            // Remove the icon file
            let iconURL = Self.cacheDirectory.appendingPathComponent(cache.iconFileName)
            try? FileManager.default.removeItem(at: iconURL)
            
            // Remove from cache
            cachedIcons.removeValue(forKey: appPath)
            saveCache()
        }
    }
    
    // Clear all cached icons
    func clearCache() {
        // Remove all icon files
        for cache in cachedIcons.values {
            let iconURL = Self.cacheDirectory.appendingPathComponent(cache.iconFileName)
            try? FileManager.default.removeItem(at: iconURL)
        }
        
        // Clear cache
        cachedIcons.removeAll()
        saveCache()
    }
    
    func addImportedCache(_ cache: IconCache) {
        // Create a new cache entry
        cachedIcons[cache.appPath] = cache
        saveCache()
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
