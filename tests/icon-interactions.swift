import Foundation

@main
enum IconInteractionTests {
    static func main() {
        assertEqual(
            IconFetchInteractionPolicy.action(for: .viewAppeared),
            .none,
            "opening an app must not spend an API request"
        )
        assertEqual(
            IconFetchInteractionPolicy.action(for: .styleChanged),
            .none,
            "changing style must wait for an explicit load"
        )
        assertEqual(
            IconFetchInteractionPolicy.action(for: .localIconChanged),
            .none,
            "applying an icon must not refresh remote results"
        )
        assertEqual(
            IconFetchInteractionPolicy.action(for: .userRequestedLoad),
            .loadAllowingCache,
            "the load button may use a cached response"
        )
        assertEqual(
            IconFetchInteractionPolicy.action(for: .userRequestedRefresh),
            .refreshFromNetwork,
            "the refresh button must explicitly request fresh results"
        )

        assertTrue(
            IconApplicationPolicy.shouldRecordHistory(source: .local),
            "new local icons should be recorded"
        )
        assertTrue(
            IconApplicationPolicy.shouldRecordHistory(source: .remote),
            "new remote icons should be recorded"
        )
        assertTrue(
            IconApplicationPolicy.shouldRecordHistory(source: .favorite),
            "favorites should remain normal icon applications"
        )
        assertFalse(
            IconApplicationPolicy.shouldRecordHistory(source: .history),
            "reusing a history entry must not create another entry"
        )

        print("PASS: remote icon loads are explicit and history reuse is idempotent")
    }

    private static func assertEqual<T: Equatable>(
        _ actual: T,
        _ expected: T,
        _ message: String
    ) {
        guard actual == expected else {
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
