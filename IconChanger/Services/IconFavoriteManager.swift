//
//  IconFavoriteManager.swift
//  IconChanger
//

import Foundation
import AppKit

struct FavoriteIcon: Codable, Identifiable {
    let id: UUID
    let cachedFileName: String
    let sourceName: String
    let appPath: String?  // nil = universal favorite
    let timestamp: Date
}

class IconFavoriteManager {
    static let shared = IconFavoriteManager()

    private let storageKey = "com.iconchanger.favorites"
    private var favorites: [FavoriteIcon] = []
    private let lock = NSLock()

    static var favoritesDirectory: URL {
        let path = "\(NSHomeDirectory())/.iconchanger/favorites"
        let url = URL(fileURLWithPath: path)
        if !FileManager.default.fileExists(atPath: path) {
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
        return url
    }

    init() {
        loadFavorites()
    }

    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([FavoriteIcon].self, from: data) {
            favorites = decoded
        }
    }

    private func persistFavorites(_ snapshot: [FavoriteIcon]) {
        if let encoded = try? JSONEncoder().encode(snapshot) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    func addFavorite(image: NSImage, sourceName: String, appPath: String?) -> Bool {
        let fileName = "\(UUID().uuidString).png"
        let fileURL = Self.favoritesDirectory.appendingPathComponent(fileName)

        if IconManager.saveImage(image, atUrl: fileURL) != nil {
            return false
        }

        let favorite = FavoriteIcon(
            id: UUID(),
            cachedFileName: fileName,
            sourceName: sourceName,
            appPath: appPath,
            timestamp: Date()
        )

        let snapshot: [FavoriteIcon] = {
            lock.lock()
            defer { lock.unlock() }
            favorites.insert(favorite, at: 0)
            return favorites
        }()
        persistFavorites(snapshot)
        return true
    }

    func removeFavorite(_ favorite: FavoriteIcon) {
        let snapshot: [FavoriteIcon] = {
            lock.lock()
            defer { lock.unlock() }
            favorites.removeAll { $0.id == favorite.id }
            return favorites
        }()
        let fileURL = Self.favoritesDirectory.appendingPathComponent(favorite.cachedFileName)
        try? FileManager.default.removeItem(at: fileURL)
        persistFavorites(snapshot)
    }

    func getFavorites(for appPath: String?) -> [FavoriteIcon] {
        lock.lock()
        defer { lock.unlock() }
        if let appPath = appPath {
            return favorites.filter { $0.appPath == appPath || $0.appPath == nil }
        }
        return favorites
    }

    func getAppFavorites(for appPath: String) -> [FavoriteIcon] {
        lock.lock()
        defer { lock.unlock() }
        return favorites.filter { $0.appPath == appPath }
    }

    func isFavorited(fileName: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return favorites.contains { $0.cachedFileName == fileName }
    }

    func getIconURL(for favorite: FavoriteIcon) -> URL {
        Self.favoritesDirectory.appendingPathComponent(favorite.cachedFileName)
    }

    func getAllFavorites() -> [FavoriteIcon] {
        lock.lock()
        defer { lock.unlock() }
        return favorites
    }

    func clearAllFavorites() {
        let (snapshot, urlsToDelete): ([FavoriteIcon], [URL]) = {
            lock.lock()
            defer { lock.unlock() }
            let urls = favorites.map {
                Self.favoritesDirectory.appendingPathComponent($0.cachedFileName)
            }
            favorites.removeAll()
            return (favorites, urls)
        }()
        for url in urlsToDelete {
            try? FileManager.default.removeItem(at: url)
        }
        persistFavorites(snapshot)
    }

    func getFavoritesCount() -> Int {
        lock.lock()
        defer { lock.unlock() }
        return favorites.count
    }
}
