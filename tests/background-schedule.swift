import Foundation

@main
enum BackgroundScheduleTests {
    static func main() {
        assertTrue(
            BackgroundVisibilityPolicy.resolved(
                showInDock: false,
                showInMenuBar: false,
                changedPreference: .dock
            ) == .init(showInDock: false, showInMenuBar: true),
            "hiding the last Dock entry must leave a menu-bar entry"
        )
        assertTrue(
            BackgroundVisibilityPolicy.resolved(
                showInDock: false,
                showInMenuBar: false,
                changedPreference: .menuBar
            ) == .init(showInDock: true, showInMenuBar: false),
            "hiding the last menu-bar entry must leave a Dock entry"
        )
        assertTrue(
            BackgroundVisibilityPolicy.resolved(
                showInDock: true,
                showInMenuBar: true,
                changedPreference: .menuBar
            ) == .init(showInDock: true, showInMenuBar: true),
            "valid visibility preferences must remain unchanged"
        )
        assertTrue(
            BackgroundSchedulePolicy.validRestoreInterval("8760") == 8760,
            "a custom restore interval may span up to one year"
        )
        assertTrue(
            BackgroundSchedulePolicy.validRestoreInterval(String(Int.max)) == nil,
            "an overflowing custom restore interval must not be accepted"
        )
        assertTrue(
            BackgroundSchedulePolicy.validCheckInterval("525600") == 525600,
            "a custom update-check interval may span up to one year"
        )
        assertTrue(
            BackgroundSchedulePolicy.validCheckInterval(String(Int.max)) == nil,
            "an overflowing custom check interval must not be accepted"
        )
        assertTrue(
            BackgroundSchedulePolicy.validRestoreInterval("0") == nil
                && BackgroundSchedulePolicy.validCheckInterval("-1") == nil
                && BackgroundSchedulePolicy.validCheckInterval("abc") == nil,
            "custom scheduling requires a positive whole-number interval"
        )
        assertTrue(
            BackgroundSchedulePolicy.normalizedRestoreIntervalHours(Int.max) == 8760
                && BackgroundSchedulePolicy.normalizedCheckIntervalMinutes(Int.max) == 525600,
            "out-of-range persisted settings must use a safe maximum"
        )
        assertTrue(
            BackgroundSchedulePolicy.normalizedRestoreIntervalHours(0) == 1
                && BackgroundSchedulePolicy.normalizedCheckIntervalMinutes(-1) == 1,
            "out-of-range persisted settings must use a safe minimum"
        )

        assertEqual(
            BackgroundSchedulePolicy.nextDelay(
                interval: 15 * 60,
                lastRun: .distantPast,
                now: Date(timeIntervalSince1970: 10_000),
                minimumDelay: 1
            ),
            1,
            "a never-run update check should start immediately"
        )

        assertEqual(
            BackgroundSchedulePolicy.nextDelay(
                interval: 15 * 60,
                lastRun: Date(timeIntervalSince1970: 1_000),
                now: Date(timeIntervalSince1970: 2_000),
                minimumDelay: 1
            ),
            1,
            "an overdue update check should start immediately"
        )

        assertEqual(
            BackgroundSchedulePolicy.nextDelay(
                interval: 15 * 60,
                lastRun: Date(timeIntervalSince1970: 1_700),
                now: Date(timeIntervalSince1970: 2_000),
                minimumDelay: 1
            ),
            600,
            "a recent update check should wait only for the remaining interval"
        )

        assertEqual(
            BackgroundSchedulePolicy.nextDelay(
                interval: 0,
                lastRun: Date(timeIntervalSince1970: 1_700),
                now: Date(timeIntervalSince1970: 2_000),
                minimumDelay: 1
            ),
            1,
            "an invalid interval must not create a busy timer"
        )

        assertTrue(
            CachedAppUpdatePolicy.hasUpdate(
                cachedVersion: "100",
                currentVersion: "101",
                cachedAt: Date(timeIntervalSince1970: 1_000),
                modifiedAt: nil
            ),
            "a changed bundle build must be detected"
        )

        assertFalse(
            CachedAppUpdatePolicy.hasUpdate(
                cachedVersion: "100",
                currentVersion: "100",
                cachedAt: Date(timeIntervalSince1970: 1_000),
                modifiedAt: Date(timeIntervalSince1970: 2_000)
            ),
            "an unchanged bundle build must not be a modification-date false positive"
        )

        assertFalse(
            CachedAppUpdatePolicy.hasUpdate(
                cachedVersion: "100",
                currentVersion: nil,
                cachedAt: Date(timeIntervalSince1970: 1_000),
                modifiedAt: Date(timeIntervalSince1970: 2_000)
            ),
            "an unreadable bundle version must not be reported as an update"
        )

        assertTrue(
            CachedAppUpdatePolicy.hasUpdate(
                cachedVersion: nil,
                currentVersion: nil,
                cachedAt: Date(timeIntervalSince1970: 1_000),
                modifiedAt: Date(timeIntervalSince1970: 2_000)
            ),
            "legacy caches should fall back to modification date"
        )

        assertStringEqual(
            CachedAppVersionPolicy.preferredVersion(
                bundleVersion: nil,
                shortVersion: "5.1.3"
            ),
            "5.1.3",
            "apps without CFBundleVersion should use CFBundleShortVersionString"
        )

        assertEqual(
            CachedAppUpdatePolicy.referenceModificationDate(
                isApplicationBundle: true,
                rootModifiedAt: Date(timeIntervalSince1970: 3_000),
                infoPlistModifiedAt: Date(timeIntervalSince1970: 1_500),
                executableModifiedAt: Date(timeIntervalSince1970: 2_000)
            )?.timeIntervalSince1970 ?? -1,
            2_000,
            "app update fallback must ignore root metadata changed by custom icons"
        )

        print("PASS: background visibility and interval safety; update checks resume from persisted state")
    }

    private static func assertEqual(
        _ actual: TimeInterval,
        _ expected: TimeInterval,
        _ message: String
    ) {
        guard abs(actual - expected) < 0.001 else {
            fputs("FAIL: \(message); expected \(expected), got \(actual)\n", stderr)
            exit(1)
        }
    }

    private static func assertTrue(_ value: Bool, _ message: String) {
        guard value else {
            fputs("FAIL: \(message)\n", stderr)
            exit(1)
        }
    }

    private static func assertFalse(_ value: Bool, _ message: String) {
        assertTrue(!value, message)
    }

    private static func assertStringEqual(
        _ actual: String?,
        _ expected: String?,
        _ message: String
    ) {
        guard actual == expected else {
            fputs(
                "FAIL: \(message); expected \(expected ?? "nil"), got \(actual ?? "nil")\n",
                stderr
            )
            exit(1)
        }
    }
}
