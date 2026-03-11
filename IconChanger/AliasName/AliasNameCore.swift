//
//  AliasNameCore.swift
//  IconChanger
//

import Foundation

struct AliasName: Identifiable {
    let id: String
    var appName: String
    var aliasName: String

    init(appName: String, aliasName: String) {
        self.id = appName
        self.appName = appName
        self.aliasName = aliasName
    }

    static func getName(for raw: String) -> String? {
        return AliasNames.getAll().first(where: { $0.appName == raw })?.aliasName
    }

    static func setName(_ name: String, for raw: String) {
        var aliases = AliasNames.getAll()
        if let index = aliases.firstIndex(where: { $0.appName == raw }) {
            aliases[index].aliasName = name
        } else {
            aliases.append(AliasName(appName: raw, aliasName: name))
        }
        AliasNames.save(aliases)

        // If user re-adds a previously removed default, un-track it
        var removed = UserDefaults.standard.stringArray(forKey: "RemovedDefaultAliases") ?? []
        if removed.contains(raw) {
            removed.removeAll(where: { $0 == raw })
            UserDefaults.standard.set(removed, forKey: "RemovedDefaultAliases")
        }
    }

    static func setEmpty(for raw: String) {
        var aliases = AliasNames.getAll()
        aliases.removeAll(where: { $0.appName == raw })
        AliasNames.save(aliases)
        trackRemoval(for: raw)
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
        }
    }
}