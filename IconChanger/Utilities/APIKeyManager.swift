//
//  APIKeyManager.swift
//  IconChanger
//

import Foundation

enum APIKeyManager {
    private static let extraKeysKey = "apiExtraKeys"
    private static let keyIndexKey = "com.iconchanger.currentKeyIndex"

    static var primaryKey: String {
        KeychainHelper.load(key: "apiKey") ?? ""
    }

    static var allKeys: [String] {
        var keys: [String] = []
        let primary = primaryKey
        if !primary.isEmpty { keys.append(primary) }
        if UserDefaults.standard.bool(forKey: "developerOptionsEnabled") {
            keys.append(contentsOf: loadExtraKeys().filter { !$0.isEmpty })
        }
        return keys
    }

    static func pickKey() -> String {
        let keys = allKeys
        guard !keys.isEmpty else { return "" }
        if keys.count == 1 { return keys[0] }
        let index = UserDefaults.standard.integer(forKey: keyIndexKey) % keys.count
        return keys[index]
    }

    static func rotateToNextKey() {
        let keys = allKeys
        guard keys.count > 1 else { return }
        let current = UserDefaults.standard.integer(forKey: keyIndexKey)
        UserDefaults.standard.set((current + 1) % keys.count, forKey: keyIndexKey)
    }

    static func loadExtraKeys() -> [String] {
        guard let json = KeychainHelper.load(key: extraKeysKey),
              let data = json.data(using: .utf8),
              let array = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return array
    }

    static func saveExtraKeys(_ keys: [String]) {
        guard let data = try? JSONEncoder().encode(keys),
              let json = String(data: data, encoding: .utf8) else { return }
        KeychainHelper.save(key: extraKeysKey, value: json)
    }
}
