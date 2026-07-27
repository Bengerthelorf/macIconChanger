//
//  BackgroundSchedulePolicy.swift
//  IconChanger
//

import Foundation

enum BackgroundSchedulePolicy {
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
}
