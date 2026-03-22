//
//  IconHistoryManager.swift
//  IconChanger
//

import Foundation
import AppKit

struct IconHistoryEntry: Codable, Identifiable {
    let id: UUID
    let cachedFileName: String
    let appPath: String
    let appName: String
    let timestamp: Date
}

class IconHistoryManager {
    static let shared = IconHistoryManager()

    private let storageKey = "com.iconchanger.iconHistory"
    private var history: [String: [IconHistoryEntry]] = [:] // keyed by appPath
    private let lock = NSLock()

    private let maxPerApp = 20
    private let maxTotal = 500

    static var historyDirectory: URL {
        let path = "\(NSHomeDirectory())/.iconchanger/history"
        let url = URL(fileURLWithPath: path)
        if !FileManager.default.fileExists(atPath: path) {
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
        return url
    }

    init() {
        loadHistory()
    }

    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([String: [IconHistoryEntry]].self, from: data) {
            history = decoded
        }
    }

    private func persistHistory(_ snapshot: [String: [IconHistoryEntry]]) {
        if let encoded = try? JSONEncoder().encode(snapshot) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    func addEntry(image: NSImage, for appPath: String, appName: String) {
        let fileName = "\(UUID().uuidString).png"
        let fileURL = Self.historyDirectory.appendingPathComponent(fileName)
        if IconManager.saveImage(image, atUrl: fileURL) != nil {
            return // failed to save, skip
        }

        let entry = IconHistoryEntry(
            id: UUID(),
            cachedFileName: fileName,
            appPath: appPath,
            appName: appName,
            timestamp: Date()
        )

        let (snapshot, urlsToDelete): ([String: [IconHistoryEntry]], [URL]) = {
            lock.lock()
            defer { lock.unlock() }
            var entries = history[appPath] ?? []
            entries.insert(entry, at: 0) // newest first

            // Enforce per-app limit
            var urls: [URL] = []
            while entries.count > maxPerApp {
                let removed = entries.removeLast()
                urls.append(Self.historyDirectory.appendingPathComponent(removed.cachedFileName))
            }
            history[appPath] = entries

            // Enforce total limit
            urls.append(contentsOf: enforceGlobalLimit())

            return (history, urls)
        }()
        for url in urlsToDelete {
            try? FileManager.default.removeItem(at: url)
        }
        persistHistory(snapshot)
    }

    /// Must be called while holding the lock. Returns URLs to delete after releasing the lock.
    private func enforceGlobalLimit() -> [URL] {
        var allEntries: [(appPath: String, entry: IconHistoryEntry)] = []
        for (appPath, entries) in history {
            for entry in entries {
                allEntries.append((appPath, entry))
            }
        }

        if allEntries.count <= maxTotal { return [] }

        // Sort by timestamp, oldest first
        allEntries.sort { $0.entry.timestamp < $1.entry.timestamp }

        let toRemove = allEntries.count - maxTotal
        var urls: [URL] = []
        for i in 0..<toRemove {
            let item = allEntries[i]
            urls.append(Self.historyDirectory.appendingPathComponent(item.entry.cachedFileName))
            history[item.appPath]?.removeAll { $0.id == item.entry.id }
        }

        // Clean up empty keys
        history = history.filter { !$0.value.isEmpty }
        return urls
    }

    func getHistory(for appPath: String) -> [IconHistoryEntry] {
        lock.lock()
        defer { lock.unlock() }
        return history[appPath] ?? []
    }

    func removeEntry(_ entry: IconHistoryEntry) {
        let snapshot: [String: [IconHistoryEntry]] = {
            lock.lock()
            defer { lock.unlock() }
            history[entry.appPath]?.removeAll { $0.id == entry.id }
            if history[entry.appPath]?.isEmpty == true {
                history.removeValue(forKey: entry.appPath)
            }
            return history
        }()
        let fileURL = Self.historyDirectory.appendingPathComponent(entry.cachedFileName)
        try? FileManager.default.removeItem(at: fileURL)
        persistHistory(snapshot)
    }

    func clearHistory(for appPath: String) {
        let (snapshot, urlsToDelete): ([String: [IconHistoryEntry]], [URL]) = {
            lock.lock()
            defer { lock.unlock() }
            let urls = (history[appPath] ?? []).map {
                Self.historyDirectory.appendingPathComponent($0.cachedFileName)
            }
            history.removeValue(forKey: appPath)
            return (history, urls)
        }()
        for url in urlsToDelete {
            try? FileManager.default.removeItem(at: url)
        }
        persistHistory(snapshot)
    }

    func clearAllHistory() {
        let (snapshot, urlsToDelete): ([String: [IconHistoryEntry]], [URL]) = {
            lock.lock()
            defer { lock.unlock() }
            let urls = history.values.flatMap { entries in
                entries.map { Self.historyDirectory.appendingPathComponent($0.cachedFileName) }
            }
            history.removeAll()
            return (history, urls)
        }()
        for url in urlsToDelete {
            try? FileManager.default.removeItem(at: url)
        }
        persistHistory(snapshot)
    }

    func getIconURL(for entry: IconHistoryEntry) -> URL {
        Self.historyDirectory.appendingPathComponent(entry.cachedFileName)
    }

    func getTotalCount() -> Int {
        lock.lock()
        defer { lock.unlock() }
        return history.values.reduce(0) { $0 + $1.count }
    }
}
