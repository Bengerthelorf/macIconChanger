//
//  AppPaths.swift
//  IconChanger
//

import Foundation
import os

/// Centralizes filesystem locations for IconChanger data.
///
/// Storage follows Apple conventions:
/// - Caches (regeneratable): `~/Library/Caches/<bundleID>/`
/// - User data: `~/Library/Application Support/<bundleID>/`
///
/// Legacy layout at `~/.iconchanger/` is migrated on first launch.
enum AppPaths {
    static let bundleID = "com.zhuhaoyu.IconChanger"

    private static let logger = Logger(subsystem: bundleID, category: "AppPaths")

    // MARK: - Roots

    static var cachesRoot: URL {
        ensureDirectory(
            FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
                .appendingPathComponent(bundleID, isDirectory: true)
        )
    }

    static var applicationSupportRoot: URL {
        ensureDirectory(
            FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
                .appendingPathComponent(bundleID, isDirectory: true)
        )
    }

    static var legacyRoot: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".iconchanger", isDirectory: true)
    }

    /// Pre-bundle-id Application Support folder (held `audit.log` before the migration).
    static var legacyApplicationSupportRoot: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("IconChanger", isDirectory: true)
    }

    // MARK: - Well-known paths

    static var iconCacheDirectory: URL {
        ensureDirectory(cachesRoot.appendingPathComponent("cache", isDirectory: true))
    }

    static var iconFetchCacheFile: URL {
        cachesRoot.appendingPathComponent("icon_fetch_cache.json")
    }

    static var iconHistoryDirectory: URL {
        ensureDirectory(applicationSupportRoot.appendingPathComponent("history", isDirectory: true))
    }

    static var iconFavoritesDirectory: URL {
        ensureDirectory(applicationSupportRoot.appendingPathComponent("favorites", isDirectory: true))
    }

    static var sharedConfigDirectory: URL {
        ensureDirectory(applicationSupportRoot.appendingPathComponent("config", isDirectory: true))
    }

    // MARK: - Migration

    /// Moves legacy `~/.iconchanger/` data and pre-bundle-id Application Support contents
    /// to standard macOS locations. Idempotent and safe to call on every launch.
    static func migrateLegacyDirectoryIfNeeded() {
        migrateDotFolderRoot()
        migrateApplicationSupportRoot()
    }

    private static func migrateDotFolderRoot() {
        let fm = FileManager.default
        let legacy = legacyRoot
        guard fm.fileExists(atPath: legacy.path) else { return }

        let dirMoves: [(from: URL, to: URL)] = [
            (legacy.appendingPathComponent("cache", isDirectory: true), iconCacheDirectory),
            (legacy.appendingPathComponent("history", isDirectory: true), iconHistoryDirectory),
            (legacy.appendingPathComponent("favorites", isDirectory: true), iconFavoritesDirectory),
            (legacy.appendingPathComponent("config", isDirectory: true), sharedConfigDirectory)
        ]
        for move in dirMoves where fm.fileExists(atPath: move.from.path) {
            mergeDirectory(from: move.from, to: move.to)
        }

        let legacyFetchCache = legacy.appendingPathComponent("icon_fetch_cache.json")
        if fm.fileExists(atPath: legacyFetchCache.path) {
            let destination = iconFetchCacheFile
            if !fm.fileExists(atPath: destination.path) {
                do {
                    try fm.moveItem(at: legacyFetchCache, to: destination)
                    logger.info("Migrated icon_fetch_cache.json")
                } catch {
                    logger.error("Failed migrating icon_fetch_cache.json: \(error.localizedDescription, privacy: .public)")
                }
            } else {
                try? fm.removeItem(at: legacyFetchCache)
            }
        }

        let remaining = (try? fm.contentsOfDirectory(atPath: legacy.path)) ?? []
        let nonIgnored = remaining.filter { $0 != ".DS_Store" }
        if nonIgnored.isEmpty {
            try? fm.removeItem(at: legacy)
            logger.info("Removed legacy directory")
        }
    }

    private static func migrateApplicationSupportRoot() {
        let fm = FileManager.default
        let legacy = legacyApplicationSupportRoot
        guard fm.fileExists(atPath: legacy.path) else { return }

        mergeDirectory(from: legacy, to: applicationSupportRoot)
    }

    // MARK: - Private

    @discardableResult
    private static func ensureDirectory(_ url: URL) -> URL {
        let fm = FileManager.default
        if !fm.fileExists(atPath: url.path) {
            try? fm.createDirectory(at: url, withIntermediateDirectories: true)
        }
        return url
    }

    private static func mergeDirectory(from source: URL, to destination: URL) {
        let fm = FileManager.default
        ensureDirectory(destination)
        guard let items = try? fm.contentsOfDirectory(atPath: source.path) else { return }
        for item in items {
            let src = source.appendingPathComponent(item)
            let dst = destination.appendingPathComponent(item)
            if fm.fileExists(atPath: dst.path) {
                try? fm.removeItem(at: src)
            } else {
                do {
                    try fm.moveItem(at: src, to: dst)
                } catch {
                    logger.error("Failed moving \(item, privacy: .public): \(error.localizedDescription, privacy: .public)")
                }
            }
        }
        if let remaining = try? fm.contentsOfDirectory(atPath: source.path), remaining.isEmpty {
            try? fm.removeItem(at: source)
        }
    }
}
