import Foundation

enum IconAppearance: String, Codable, CaseIterable, Sendable {
    case light
    case dark

    var displayName: String {
        switch self {
        case .light:
            return NSLocalizedString("Light", comment: "Light icon appearance")
        case .dark:
            return NSLocalizedString("Dark", comment: "Dark icon appearance")
        }
    }

    var systemImage: String {
        switch self {
        case .light:
            return "sun.max"
        case .dark:
            return "moon"
        }
    }
}

struct AppearanceIconConfiguration: Codable, Identifiable, Equatable, Sendable {
    var id: String { appPath }

    let appPath: String
    var appName: String
    var lightIconFileName: String?
    var darkIconFileName: String?
    var lastAppliedAppearance: IconAppearance?
    var updatedAt: Date

    func fileName(for appearance: IconAppearance) -> String? {
        let candidate: String?
        switch appearance {
        case .light:
            candidate = lightIconFileName
        case .dark:
            candidate = darkIconFileName
        }
        return Self.validatedFileName(candidate)
    }

    mutating func setFileName(_ fileName: String?, for appearance: IconAppearance) {
        switch appearance {
        case .light:
            lightIconFileName = fileName
        case .dark:
            darkIconFileName = fileName
        }
    }

    var isComplete: Bool {
        fileName(for: .light) != nil && fileName(for: .dark) != nil
    }

    var isEmpty: Bool {
        fileName(for: .light) == nil && fileName(for: .dark) == nil
    }

    private static func validatedFileName(_ candidate: String?) -> String? {
        guard let candidate,
              candidate.utf8.count <= 40,
              candidate.hasSuffix(".png"),
              !candidate.contains("/"),
              !candidate.contains("\\") else {
            return nil
        }
        let uuidPart = String(candidate.dropLast(4))
        guard UUID(uuidString: uuidPart) != nil else { return nil }
        return candidate
    }
}

enum IconCacheSelectionTarget: Hashable, Sendable {
    case application(String)
    case appearance(String, IconAppearance)

    var appPath: String {
        switch self {
        case .application(let appPath), .appearance(let appPath, _):
            return appPath
        }
    }
}

enum IconAppearancePolicy {
    static func iconFileName(
        for appearance: IconAppearance,
        configuration: AppearanceIconConfiguration,
        switchingEnabled: Bool
    ) -> String? {
        guard switchingEnabled, configuration.isComplete else { return nil }
        guard configuration.lastAppliedAppearance != appearance else { return nil }
        return configuration.fileName(for: appearance)
    }

    static func toggling(
        _ target: IconCacheSelectionTarget,
        in selection: Set<IconCacheSelectionTarget>
    ) -> Set<IconCacheSelectionTarget> {
        var result = selection
        let appPath = target.appPath

        switch target {
        case .application:
            result.remove(.appearance(appPath, .light))
            result.remove(.appearance(appPath, .dark))
        case .appearance:
            result.remove(.application(appPath))
        }

        if result.contains(target) {
            result.remove(target)
        } else {
            result.insert(target)
        }
        return result
    }

    static func selectedApplicationPaths(
        in selection: Set<IconCacheSelectionTarget>
    ) -> Set<String> {
        Set(selection.compactMap { target in
            guard case .application(let appPath) = target else { return nil }
            return appPath
        })
    }

    static func restoreChoice(
        configuration: AppearanceIconConfiguration?,
        normalIconAvailable: Bool,
        switchingEnabled: Bool,
        currentAppearance: IconAppearance
    ) -> CachedIconRestoreChoice {
        if switchingEnabled,
           let configuration,
           configuration.isComplete,
           configuration.fileName(for: currentAppearance) != nil {
            return .appearance(currentAppearance)
        }
        return normalIconAvailable ? .normal : .none
    }
}

enum CachedIconRestoreChoice: Equatable, Sendable {
    case appearance(IconAppearance)
    case normal
    case none
}

enum RestoreDefaultErrorPolicy {
    static func friendlyMessage(_ raw: String) -> String {
        let lowered = raw.lowercased()
        if lowered.contains("permission") || raw.contains("权限") {
            return NSLocalizedString(
                "IconChanger could not modify this app. Check IconChanger's helper permissions in Settings and try again.",
                comment: "Permission error explanation"
            )
        }
        return raw
    }
}
