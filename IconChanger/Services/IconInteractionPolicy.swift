import Foundation

enum IconFetchInteractionEvent {
    case viewAppeared
    case styleChanged
    case localIconChanged
    case userRequestedLoad
    case userRequestedRefresh

    var isAutomatic: Bool {
        switch self {
        case .viewAppeared, .styleChanged:
            return true
        case .localIconChanged, .userRequestedLoad, .userRequestedRefresh:
            return false
        }
    }
}

enum IconFetchInteractionAction: Equatable {
    case none
    case loadAllowingCache
    case refreshFromNetwork
}

enum IconFetchInteractionPolicy {
    static let automaticallyLoadIconsKey = "automaticallyLoadIcons"
    static let defaultAutomaticallyLoadIcons = true

    static func action(
        for event: IconFetchInteractionEvent,
        automaticallyLoadIcons: Bool,
        hasRequestedIcons: Bool
    ) -> IconFetchInteractionAction {
        switch event {
        case .viewAppeared:
            return automaticallyLoadIcons && !hasRequestedIcons
                ? .loadAllowingCache
                : .none
        case .styleChanged:
            return automaticallyLoadIcons ? .loadAllowingCache : .none
        case .localIconChanged:
            return .none
        case .userRequestedLoad:
            return .loadAllowingCache
        case .userRequestedRefresh:
            return .refreshFromNetwork
        }
    }

    static func shouldResetRequestAfterLeaving(
        pendingAutomaticLoad: Bool,
        isLoadingIcons: Bool
    ) -> Bool {
        pendingAutomaticLoad || isLoadingIcons
    }
}

enum IconRemoteRequestPolicy {
    static func normalizedAPIKey(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

enum IconApplicationSource {
    case local
    case remote
    case favorite
    case history
}

enum IconApplicationPolicy {
    static func shouldRecordHistory(source: IconApplicationSource) -> Bool {
        source != .history
    }
}

/// Keep the last successful cache until the helper has accepted the new icon.
enum IconApplicationTransaction {
    static func perform<Prepared>(
        prepare: () throws -> Prepared,
        apply: (Prepared) throws -> Void,
        commit: (Prepared) throws -> Void,
        discard: (Prepared) -> Void
    ) throws {
        let prepared = try prepare()
        do {
            try apply(prepared)
            try commit(prepared)
        } catch {
            discard(prepared)
            throw error
        }
    }
}

enum DockPreviewPolicy {
    static func shouldShow(mode: String, isDockFilter: Bool, isFolderFilter: Bool) -> Bool {
        !isFolderFilter && mode != "never" && (mode == "always" || isDockFilter)
    }
}

/// A successful process exit alone must not commit an icon the OS did not retain.
enum IconWriteVerification {
    struct Failure: LocalizedError {
        var errorDescription: String? {
            NSLocalizedString("macOS did not retain the requested icon change. This app may be protected or may manage its own icon.", comment: "Icon write verification failure")
        }
    }

    static func verify(removing: Bool, hasCustomIcon: Bool) throws {
        guard hasCustomIcon == !removing else { throw Failure() }
    }
}
