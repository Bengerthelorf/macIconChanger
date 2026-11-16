//
//  AliasNameCore.swift
//  IconChanger
//

import Foundation

extension Notification.Name {
    static let aliasNamesDidChange = Notification.Name("IconChanger.aliasNamesDidChange")
}

struct AliasName: Identifiable {
    let id: UUID
    var appName: String
    var aliasName: String

    init(appName: String, aliasName: String) {
        self.id = UUID()
        self.appName = appName
        self.aliasName = aliasName
    }

    static func getName(for raw: String) -> String? {
        return AliasNames.getAll().first(where: { $0.appName == raw })?.aliasName
    }

    static func key(for url: URL) -> String {
        url.pathExtension.lowercased() == "app"
            ? url.deletingPathExtension().lastPathComponent
            : url.lastPathComponent
    }

    static func getName(for url: URL) -> String? {
        let aliases = Dictionary(AliasNames.getAll().map { ($0.appName, $0.aliasName) },
                                 uniquingKeysWith: { _, last in last })
        return getName(for: url, aliases: aliases)
    }

    static func getName(
        for url: URL,
        aliases: [String: String],
        removedAliases: [String] = UserDefaults.standard.stringArray(forKey: "RemovedDefaultAliases") ?? []
    ) -> String? {
        // Older versions stripped suffixes from folder names as well as apps.
        let currentKey = key(for: url)
        let legacy = removedAliases.contains(currentKey) ? nil : aliases[url.deletingPathExtension().lastPathComponent]
        let value = aliases[currentKey] ?? legacy
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed?.isEmpty == false ? trimmed : nil
    }

    static func setName(_ name: String, for raw: String) {
        var aliases = AliasNames.getAll()
        if let index = aliases.firstIndex(where: { $0.appName == raw }) {
            aliases[index].aliasName = name
        } else {
            aliases.append(AliasName(appName: raw, aliasName: name))
        }
        // If user re-adds a previously removed default, un-track it
        var removed = UserDefaults.standard.stringArray(forKey: "RemovedDefaultAliases") ?? []
        if removed.contains(raw) {
            removed.removeAll(where: { $0 == raw })
            UserDefaults.standard.set(removed, forKey: "RemovedDefaultAliases")
        }
        AliasNames.save(aliases)
    }

    static func setEmpty(for raw: String) {
        var aliases = AliasNames.getAll()
        aliases.removeAll(where: { $0.appName == raw })
        trackRemoval(for: raw)
        AliasNames.save(aliases)
    }

    static func trackRemoval(for raw: String) {
        var removed = UserDefaults.standard.stringArray(forKey: "RemovedDefaultAliases") ?? []
        if !removed.contains(raw) {
            removed.append(raw)
            UserDefaults.standard.set(removed, forKey: "RemovedDefaultAliases")
        }
    }
}

struct AliasNames {
    static func getAll() -> [AliasName] {
        if let data = UserDefaults.standard.data(forKey: "AliasName") {
            let aliases = try? JSONDecoder().decode([String: String].self, from: data)
            return aliases?.map {
                AliasName(appName: $0.key, aliasName: $0.value)
            } ?? []
        }
        return []
    }

    static func save(_ aliasNames: [AliasName]) {
        let aliasDict = aliasNames.reduce(into: [String: String]()) {
            $0[$1.appName] = $1.aliasName
        }
        if let data = try? JSONEncoder().encode(aliasDict) {
            UserDefaults.standard.set(data, forKey: "AliasName")
            NotificationCenter.default.post(name: .aliasNamesDidChange, object: nil)
        }
    }
}
