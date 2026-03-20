import Foundation
import os

struct SettingDef {
    let key: String
    let type: ValueType
    let flags: Flags

    enum ValueType {
        case bool(Bool)
        case int(Int)
        case double(Double)
        case string(String)
    }

    struct Flags: OptionSet {
        let rawValue: Int
        static let exported = Flags(rawValue: 1 << 0)
        static let secured  = Flags(rawValue: 1 << 1)
        static let tier2    = Flags(rawValue: 1 << 2)
    }
}

final class AppSettings: ObservableObject {
    static let shared = AppSettings()
    private let defaults = UserDefaults.standard
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "IconChanger", category: "Settings")

    // Adding a new setting = adding one line. Export auto-includes it.
    static let definitions: [SettingDef] = [
        // API
        .init(key: "apiRetryCount",     type: .int(0),          flags: .exported),
        .init(key: "apiTimeoutSeconds", type: .double(15.0),    flags: .exported),
        .init(key: "apiMonthlyLimit",   type: .int(50),         flags: .exported),
        .init(key: "cacheAPIResults",   type: .bool(true),      flags: .exported),
        .init(key: "extendedSearch",    type: .bool(false),     flags: .exported),

        // Display
        .init(key: "appAppearance",       type: .string("system"), flags: .exported),
        .init(key: "showCustomIconBadge", type: .bool(false),      flags: .exported),
        .init(key: "dockPreviewMode",     type: .string(""),       flags: .exported),
        .init(key: "dockPreviewWallpaper", type: .bool(true),      flags: .exported),
        .init(key: "dockGlassIntensity",  type: .double(0.5),     flags: .exported),
        .init(key: "wallpaperBleed",      type: .double(0.0),     flags: .exported),
        .init(key: "wallpaperBlur",       type: .double(0.0),     flags: .exported),

        // Updates
        .init(key: "enablePreRelease", type: .bool(false), flags: .exported),

        // Secured (Keychain)
        .init(key: "apiKey", type: .string(""), flags: [.exported, .secured]),

        // Tier 2
        .init(key: "t2e",    type: .bool(false), flags: .tier2),
        .init(key: "t2k",    type: .string(""),  flags: [.exported, .secured, .tier2]),
        .init(key: "t2ki",   type: .int(0),      flags: .tier2),
    ]

    // MARK: - Read / Write

    func value(for def: SettingDef) -> Any {
        if def.flags.contains(.secured) {
            return KeychainHelper.load(key: def.key) ?? defaultString(def)
        }
        switch def.type {
        case .bool(let d):   return defaults.object(forKey: def.key) as? Bool ?? d
        case .int(let d):    return defaults.object(forKey: def.key) as? Int ?? d
        case .double(let d): return defaults.object(forKey: def.key) as? Double ?? d
        case .string(let d): return defaults.object(forKey: def.key) as? String ?? d
        }
    }

    func setValue(_ value: Any, for def: SettingDef) {
        if def.flags.contains(.secured) {
            KeychainHelper.save(key: def.key, value: value as? String ?? "")
        } else {
            defaults.set(value, forKey: def.key)
        }
        objectWillChange.send()
    }

    // MARK: - Export / Import

    func exportSettings(tier2Enabled: Bool = false) -> [String: Any] {
        var result: [String: Any] = [:]
        for def in Self.definitions {
            guard def.flags.contains(.exported) else { continue }
            if def.flags.contains(.tier2) && !tier2Enabled { continue }
            result[def.key] = value(for: def)
        }
        return result
    }

    func importSettings(_ dict: [String: Any]) {
        for def in Self.definitions {
            guard def.flags.contains(.exported) else { continue }
            guard let val = dict[def.key] else { continue }
            setValue(val, for: def)
        }
        objectWillChange.send()
    }

    // MARK: - Migration helpers

    /// Maps legacy key names used in older code to current definitions.
    static func definition(forLegacyKey key: String) -> SettingDef? {
        let map: [String: String] = [
            "developerOptionsEnabled": "t2e",
            "apiExtraKeys": "t2k",
            "com.iconchanger.currentKeyIndex": "t2ki",
        ]
        let resolved = map[key] ?? key
        return definitions.first { $0.key == resolved }
    }

    private func defaultString(_ def: SettingDef) -> String {
        if case .string(let d) = def.type { return d }
        return ""
    }
}
