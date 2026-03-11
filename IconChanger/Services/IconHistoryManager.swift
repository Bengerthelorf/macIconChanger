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

        // Save image to disk
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

        lock.lock()
        var entries = history[appPath] ?? []
        entries.insert(entry, at: 0) // newest first

        // Enforce per-app limit
        while entries.count > maxPerApp {
            let removed = entries.removeLast()
            let removeURL = Self.historyDirectory.appendingPathComponent(removed.cachedFileName)
            try? FileManager.default.removeItem(at: removeURL)
        }
        history[appPath] = entries

        // Enforce total limit
        enforceGlobalLimit()

        let snapshot = history
        lock.unlock()
        persistHistory(snapshot)
    }

    private func enforceGlobalLimit() {
        var allEntries: [(appPath: String, entry: IconHistoryEntry)] = []
        for (appPath, entries) in history {
            for entry in entries {
                allEntries.append((appPath, entry))
            }
        }

        if allEntries.count <= maxTotal { return }

        // Sort by timestamp, oldest first
        allEntries.sort { $0.entry.timestamp < $1.entry.timestamp }

        let toRemove = allEntries.count - maxTotal
        for i in 0..<toRemove {
            let item = allEntries[i]
            let removeURL = Self.historyDirectory.appendingPathComponent(item.entry.cachedFileName)
            try? FileManager.default.removeItem(at: removeURL)
            history[item.appPath]?.removeAll { $0.id == item.entry.id }
        }

        // Clean up empty keys
        history = history.filter { !$0.value.isEmpty }
    }

    func getHistory(for appPath: String) -> [IconHistoryEntry] {
        lock.lock()
        defer { lock.unlock() }
        return history[appPath] ?? []
    }

    func removeEntry(_ entry: IconHistoryEntry) {
        lock.lock()
        let fileURL = Self.historyDirectory.appendingPathComponent(entry.cachedFileName)
        try? FileManager.default.removeItem(at: fileURL)
        history[entry.appPath]?.removeAll { $0.id == entry.id }
        if history[entry.appPath]?.isEmpty == true {
            history.removeValue(forKey: entry.appPath)
        }
        let snapshot = history
        lock.unlock()
        persistHistory(snapshot)
    }

    func clearHistory(for appPath: String) {
        lock.lock()
        if let entries = history[appPath] {
            for entry in entries {
                let fileURL = Self.historyDirectory.appendingPathComponent(entry.cachedFileName)
                try? FileManager.default.removeItem(at: fileURL)
            }
            history.removeValue(forKey: appPath)
        }
        let snapshot = history
        lock.unlock()
        persistHistory(snapshot)
    }

    func clearAllHistory() {
        lock.lock()
        for (_, entries) in history {
            for entry in entries {
                let fileURL = Self.historyDirectory.appendingPathComponent(entry.cachedFileName)
                try? FileManager.default.removeItem(at: fileURL)
            }
        }
        history.removeAll()
        let snapshot = history
        lock.unlock()
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
