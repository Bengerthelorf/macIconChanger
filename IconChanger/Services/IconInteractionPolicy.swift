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
