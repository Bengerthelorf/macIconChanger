import Foundation

@main
enum SetupHealthTests {
    static func main() {
        assertEqual(SetupHealth.ready.statusSymbolName, "app.badge.checkmark.fill")
        assertEqual(SetupHealth.manualMode.statusSymbolName, "exclamationmark.triangle.fill")
        assertFalse(
            SetupHealth.checking.needsAttention,
            "checking is a transient state, not a failure"
        )
        assertTrue(
            SetupHealth.outdatedHelperFiles.needsAttention,
            "outdated privileged helpers require user attention"
        )
        assertTrue(
            SetupHealth.needsLegacyPermissionCleanup.needsAttention,
            "a legacy user-writable sudoers rule requires explicit cleanup"
        )
        assertTrue(
            SetupHealth.ready.backgroundAutomationAvailable,
            "healthy setup enables background automation"
        )
        assertFalse(
            SetupHealth.manualMode.backgroundAutomationAvailable,
            "manual mode must pause root-required background automation"
        )

        let contentViewSource = try! String(
            contentsOfFile: "IconChanger/App/ContentView.swift",
            encoding: .utf8
        )
        precondition(
            contentViewSource.contains(".onChange(of: setupMonitor.health)"),
            "manual mode alerts must observe the shared health state instead of relying on one check completion"
        )
        precondition(
            contentViewSource.contains(
                "presentManualModeAlertIfNeeded(setupMonitor.health)"
            ),
            "manual mode must also be presented when the view appears after health was already published"
        )

        assertTrue(
            SetupNotificationPolicy.shouldNotify(
                previousReady: nil,
                current: .needsFolderPermission,
                launchedHidden: true
            ),
            "a hidden launch must notify when setup needs attention"
        )

        assertFalse(
            SetupNotificationPolicy.shouldNotify(
                previousReady: nil,
                current: .needsFolderPermission,
                launchedHidden: false
            ),
            "a visible first-run setup screen should not also notify"
        )

        assertTrue(
            SetupNotificationPolicy.shouldNotify(
                previousReady: true,
                current: .outdatedHelperFiles,
                launchedHidden: false
            ),
            "a regression from a previously healthy setup should notify"
        )

        assertFalse(
            SetupNotificationPolicy.shouldNotify(
                previousReady: true,
                current: .ready,
                launchedHidden: true
            ),
            "a healthy setup must never post an attention notification"
        )

        print("PASS: setup health drives menu and notification behavior")
    }

    private static func assertEqual<T: Equatable>(
        _ actual: T,
        _ expected: T
    ) {
        guard actual == expected else {
            fputs("FAIL: expected \(expected), got \(actual)\n", stderr)
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
