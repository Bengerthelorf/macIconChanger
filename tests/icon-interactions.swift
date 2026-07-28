import Foundation

@main
enum IconInteractionTests {
    static func main() {
        assertEqual(
            IconFetchInteractionPolicy.action(
                for: .viewAppeared,
                automaticallyLoadIcons: true,
                hasRequestedIcons: false
            ),
            .loadAllowingCache,
            "opening an app should load icons by default"
        )
        assertEqual(
            IconFetchInteractionPolicy.action(
                for: .viewAppeared,
                automaticallyLoadIcons: false,
                hasRequestedIcons: false
            ),
            .none,
            "opening an app must wait when automatic loading is disabled"
        )
        assertEqual(
            IconFetchInteractionPolicy.action(
                for: .viewAppeared,
                automaticallyLoadIcons: true,
                hasRequestedIcons: true
            ),
            .none,
            "a repeated appearance must not load icons twice"
        )
        assertEqual(
            IconFetchInteractionPolicy.action(
                for: .styleChanged,
                automaticallyLoadIcons: true,
                hasRequestedIcons: false
            ),
            .loadAllowingCache,
            "changing style should load icons when automatic loading is enabled"
        )
        assertEqual(
            IconFetchInteractionPolicy.action(
                for: .styleChanged,
                automaticallyLoadIcons: false,
                hasRequestedIcons: false
            ),
            .none,
            "changing style must wait when automatic loading is disabled"
        )
        assertEqual(
            IconFetchInteractionPolicy.action(
                for: .localIconChanged,
                automaticallyLoadIcons: true,
                hasRequestedIcons: true
            ),
            .none,
            "applying an icon must not refresh remote results"
        )
        assertEqual(
            IconFetchInteractionPolicy.action(
                for: .userRequestedLoad,
                automaticallyLoadIcons: false,
                hasRequestedIcons: false
            ),
            .loadAllowingCache,
            "the load button must work when automatic loading is disabled"
        )
        assertEqual(
            IconFetchInteractionPolicy.action(
                for: .userRequestedRefresh,
                automaticallyLoadIcons: false,
                hasRequestedIcons: true
            ),
            .refreshFromNetwork,
            "the refresh button must explicitly request fresh results"
        )
        assertTrue(
            IconFetchInteractionPolicy.defaultAutomaticallyLoadIcons,
            "automatic icon loading must default to enabled"
        )
        assertTrue(
            IconFetchInteractionPolicy.shouldResetRequestAfterLeaving(
                pendingAutomaticLoad: true,
                isLoadingIcons: false
            ),
            "leaving during the automatic debounce must allow a later reload"
        )
        assertTrue(
            IconFetchInteractionPolicy.shouldResetRequestAfterLeaving(
                pendingAutomaticLoad: false,
                isLoadingIcons: true
            ),
            "leaving during a request must allow a later reload"
        )
        assertFalse(
            IconFetchInteractionPolicy.shouldResetRequestAfterLeaving(
                pendingAutomaticLoad: false,
                isLoadingIcons: false
            ),
            "completed results must remain requested when the view leaves"
        )
        assertEqual(
            IconRemoteRequestPolicy.normalizedAPIKey("  usable-key \n"),
            "usable-key",
            "API keys should be normalized before use"
        )
        assertEqual(
            IconRemoteRequestPolicy.normalizedAPIKey(" \n\t"),
            nil,
            "a missing API key must stop before usage is recorded"
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

        print("PASS: automatic remote icon loading is configurable and history reuse is idempotent")
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
