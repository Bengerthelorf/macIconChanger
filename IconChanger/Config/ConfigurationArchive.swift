import Foundation

enum ConfigurationValue: Codable, Equatable {
    case bool(Bool)
    case int(Int)
    case double(Double)
    case string(String)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else {
            throw DecodingError.typeMismatch(
                ConfigurationValue.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unsupported configuration value"
                )
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .bool(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        case .double(let value):
            try container.encode(value)
        case .string(let value):
            try container.encode(value)
        }
    }

    init?(value: Any) {
        switch value {
        case let value as Bool:
            self = .bool(value)
        case let value as Int:
            self = .int(value)
        case let value as Double:
            self = .double(value)
        case let value as String:
            self = .string(value)
        default:
            return nil
        }
    }

    var value: Any {
        switch self {
        case .bool(let value):
            return value
        case .int(let value):
            return value
        case .double(let value):
            return value
        case .string(let value):
            return value
        }
    }
}

struct AppConfigurationArchive: Codable, Equatable {
    var appAliases: [AliasConfigurationArchive]
    var cachedIcons: [IconCacheConfigurationArchive]
    var appearanceIcons: [AppearanceIconConfigurationArchive]
    var settings: [String: ConfigurationValue]?
    var version: String
    var exportDate: Date

    init(
        appAliases: [AliasConfigurationArchive] = [],
        cachedIcons: [IconCacheConfigurationArchive] = [],
        appearanceIcons: [AppearanceIconConfigurationArchive] = [],
        settings: [String: ConfigurationValue]? = nil,
        version: String = "3.0",
        exportDate: Date = Date()
    ) {
        self.appAliases = appAliases
        self.cachedIcons = cachedIcons
        self.appearanceIcons = appearanceIcons
        self.settings = settings
        self.version = version
        self.exportDate = exportDate
    }

    private enum CodingKeys: String, CodingKey {
        case appAliases
        case cachedIcons
        case appearanceIcons
        case settings
        case version
        case exportDate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        appAliases = try container.decodeIfPresent(
            [AliasConfigurationArchive].self,
            forKey: .appAliases
        ) ?? []
        cachedIcons = try container.decodeIfPresent(
            [IconCacheConfigurationArchive].self,
            forKey: .cachedIcons
        ) ?? []
        appearanceIcons = try container.decodeIfPresent(
            [AppearanceIconConfigurationArchive].self,
            forKey: .appearanceIcons
        ) ?? []
        settings = try container.decodeIfPresent(
            [String: ConfigurationValue].self,
            forKey: .settings
        )
        version = try container.decodeIfPresent(String.self, forKey: .version) ?? "1.0"
        exportDate = try container.decodeIfPresent(Date.self, forKey: .exportDate) ?? Date()
    }
}

struct AliasConfigurationArchive: Codable, Equatable {
    var appName: String
    var aliasName: String
}

struct IconCacheConfigurationArchive: Codable, Equatable {
    var appPath: String
    var appName: String
    var iconFileName: String
    var iconData: Data
    var appVersion: String?
}

struct AppearanceIconConfigurationArchive: Codable, Equatable {
    var appPath: String
    var appName: String
    var lightIconData: Data?
    var darkIconData: Data?
}

enum ConfigurationArchivePolicy {
    static let maximumEncodedArchiveBytes = 768 * 1024 * 1024
    static let maximumIconBytes = 20 * 1024 * 1024
    static let maximumTotalIconBytes = 512 * 1024 * 1024
    static let maximumIconCount = 2_000

    static func validatesEncodedFileSize(_ url: URL) -> Bool {
        guard let size = try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize else {
            return false
        }
        return size > 0 && size <= maximumEncodedArchiveBytes
    }

    static func validatesSizeLimits(_ archive: AppConfigurationArchive) -> Bool {
        let sizes = archive.cachedIcons.map(\.iconData.count)
            + archive.appearanceIcons.flatMap { configuration in
                [configuration.lightIconData, configuration.darkIconData]
                    .compactMap { $0?.count }
            }
        guard sizes.count <= maximumIconCount,
              sizes.allSatisfy({ $0 > 0 && $0 <= maximumIconBytes }) else {
            return false
        }
        return sizes.reduce(0, +) <= maximumTotalIconBytes
    }
}
