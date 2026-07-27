import Foundation

@main
enum BackgroundScheduleTests {
    static func main() {
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

        print("PASS: background update checks resume from persisted state")
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
}
