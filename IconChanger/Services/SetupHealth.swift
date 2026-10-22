//
//  SetupHealth.swift
//  IconChanger
//

import Foundation

enum SetupHealth: Equatable {
    case checking
    case ready
    case needsFolderPermission
    case missingHelperFiles([String])
    case outdatedHelperFiles
    case manualMode
    case needsLegacyPermissionCleanup
    case needsAppManagementPermission
    case error(String)

    var allowsIconBrowsing: Bool {
        switch self {
        case .ready, .manualMode: return true
        default: return false
        }
    }

    var permissionStatusTitle: String {
        switch self {
        case .ready: return NSLocalizedString("Ready", comment: "Permission status")
        case .manualMode: return NSLocalizedString("Manual Mode", comment: "Permission status")
        case .checking: return NSLocalizedString("Checking…", comment: "Permission status")
        default: return NSLocalizedString("Needs Attention", comment: "Permission status")
        }
    }

    var needsAttention: Bool {
        switch self {
        case .checking, .ready:
            return false
        default:
            return true
        }
    }

    var backgroundAutomationAvailable: Bool {
        if case .ready = self {
            return true
        }
        return false
    }

    var statusSymbolName: String {
        switch self {
        case .checking:
            return "clock.badge.questionmark"
        case .ready:
            return "app.badge.checkmark.fill"
        default:
            return "exclamationmark.triangle.fill"
        }
    }

    var statusDescription: String {
        switch self {
        case .checking:
            return NSLocalizedString("Checking setup…", comment: "Setup health status")
        case .ready:
            return NSLocalizedString("Setup ready", comment: "Setup health status")
        case .needsFolderPermission:
            return NSLocalizedString("Applications folder access required", comment: "Setup health status")
        case .missingHelperFiles:
            return NSLocalizedString("Helper files missing", comment: "Setup health status")
        case .outdatedHelperFiles:
            return NSLocalizedString("Helper files need an update", comment: "Setup health status")
        case .manualMode:
            return NSLocalizedString("Manual mode — background automation paused", comment: "Setup health status")
        case .needsLegacyPermissionCleanup:
            return NSLocalizedString("Legacy administrator permission cleanup required", comment: "Setup health status")
        case .needsAppManagementPermission:
            return NSLocalizedString("App Management permission required", comment: "Setup health status")
        case .error(let message):
            return message
        }
    }
}

enum SetupNotificationPolicy {
    static func shouldNotify(
        previousReady: Bool?,
        current: SetupHealth,
        launchedHidden: Bool
    ) -> Bool {
        guard current.needsAttention else { return false }
        return launchedHidden || previousReady == true
    }
}

/// A request received during a check must validate a fresh state before callbacks run.
struct SetupCheckQueue {
    private(set) var isChecking = false
    private var needsRecheck = false

    mutating func request() -> Bool {
        guard !isChecking else {
            needsRecheck = true
            return false
        }
        isChecking = true
        return true
    }

    mutating func finish() -> Bool {
        isChecking = false
        let recheck = needsRecheck
        needsRecheck = false
        return recheck
    }
}
