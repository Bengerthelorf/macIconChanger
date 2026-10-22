//
//  BackgroundSchedulePolicy.swift
//  IconChanger
//

import Foundation

enum BackgroundSchedulePolicy {
    // Keep timers and date formatting within a useful, representable range.
    static let restoreIntervalHoursRange = 1...(24 * 365)
    static let checkIntervalMinutesRange = 1...(60 * 24 * 365)

    static func validRestoreInterval(_ text: String) -> Int? {
        guard let value = Int(text.trimmingCharacters(in: .whitespacesAndNewlines)),
              restoreIntervalHoursRange.contains(value) else { return nil }
        return value
    }

    static func validCheckInterval(_ text: String) -> Int? {
        guard let value = Int(text.trimmingCharacters(in: .whitespacesAndNewlines)),
              checkIntervalMinutesRange.contains(value) else { return nil }
        return value
    }

    static func normalizedRestoreIntervalHours(_ value: Int) -> Int {
        min(max(value, restoreIntervalHoursRange.lowerBound), restoreIntervalHoursRange.upperBound)
    }

    static func normalizedCheckIntervalMinutes(_ value: Int) -> Int {
        min(max(value, checkIntervalMinutesRange.lowerBound), checkIntervalMinutesRange.upperBound)
    }

    static func nextDelay(
        interval: TimeInterval,
        lastRun: Date,
        now: Date = Date(),
        minimumDelay: TimeInterval
    ) -> TimeInterval {
        guard interval > 0 else { return minimumDelay }
        guard lastRun != .distantPast else { return minimumDelay }

        let nextRun = lastRun.addingTimeInterval(interval)
        return max(minimumDelay, nextRun.timeIntervalSince(now))
    }
}

enum BackgroundVisibilityPolicy {
    enum Preference {
        case dock
        case menuBar
    }

    struct Visibility: Equatable {
        let showInDock: Bool
        let showInMenuBar: Bool
    }

    static func resolved(
        showInDock: Bool,
        showInMenuBar: Bool,
        changedPreference: Preference
    ) -> Visibility {
        guard !showInDock && !showInMenuBar else {
            return Visibility(showInDock: showInDock, showInMenuBar: showInMenuBar)
        }
        switch changedPreference {
        case .dock:
            return Visibility(showInDock: false, showInMenuBar: true)
        case .menuBar:
            return Visibility(showInDock: true, showInMenuBar: false)
        }
    }
}

enum CachedAppVersionPolicy {
    static func preferredVersion(
        bundleVersion: String?,
        shortVersion: String?
    ) -> String? {
        for candidate in [bundleVersion, shortVersion] {
            let trimmed = candidate?.trimmingCharacters(in: .whitespacesAndNewlines)
            if let trimmed, !trimmed.isEmpty {
                return trimmed
            }
        }
        return nil
    }
}

enum CachedAppUpdatePolicy {
    static func hasUpdate(
        cachedVersion: String?,
        currentVersion: String?,
        cachedAt: Date,
        modifiedAt: Date?
    ) -> Bool {
        if let cachedVersion {
            guard let currentVersion else { return false }
            return currentVersion != cachedVersion
        }

        guard let modifiedAt else { return false }
        return modifiedAt > cachedAt
    }

    static func referenceModificationDate(
        isApplicationBundle: Bool,
        rootModifiedAt: Date?,
        infoPlistModifiedAt: Date?,
        executableModifiedAt: Date?
    ) -> Date? {
        guard isApplicationBundle else { return rootModifiedAt }
        return [infoPlistModifiedAt, executableModifiedAt]
            .compactMap { $0 }
            .max()
    }
}
