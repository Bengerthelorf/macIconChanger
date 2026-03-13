//
//  APIKeyManager.swift
//  IconChanger
//

import Foundation

enum APIKeyManager {
    private static let extraKeysKey = "apiExtraKeys"

    /// Returns the primary API key from Keychain.
    static var primaryKey: String {
        KeychainHelper.load(key: "apiKey") ?? ""
    }

    /// Returns all available API keys (primary + extras when developer mode is on). Empty keys are excluded.
    static var allKeys: [String] {
        var keys: [String] = []
        let primary = primaryKey
        if !primary.isEmpty { keys.append(primary) }
        if UserDefaults.standard.bool(forKey: "developerOptionsEnabled") {
            keys.append(contentsOf: loadExtraKeys().filter { !$0.isEmpty })
        }
        return keys
    }

    /// Picks a random API key from the pool. Falls back to primary if no extras.
    static func pickKey() -> String {
        let keys = allKeys
        guard !keys.isEmpty else { return "" }
        return keys.randomElement()!
    }

    // MARK: - Extra Keys Storage

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
