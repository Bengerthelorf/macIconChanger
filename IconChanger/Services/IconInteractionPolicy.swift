enum IconFetchInteractionEvent {
    case viewAppeared
    case styleChanged
    case localIconChanged
    case userRequestedLoad
    case userRequestedRefresh
}

enum IconFetchInteractionAction: Equatable {
    case none
    case loadAllowingCache
    case refreshFromNetwork
}

enum IconFetchInteractionPolicy {
    static func action(for event: IconFetchInteractionEvent) -> IconFetchInteractionAction {
        switch event {
        case .viewAppeared, .styleChanged, .localIconChanged:
            return .none
        case .userRequestedLoad:
            return .loadAllowingCache
        case .userRequestedRefresh:
            return .refreshFromNetwork
        }
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
