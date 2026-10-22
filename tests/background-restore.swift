import Foundation

struct AppItem {
    let name: String
}

enum DiagnosticsSource: Equatable {
    case appUpdate
}

enum FixtureError: Error {
    case missingIcon
}

@MainActor
final class IconManager {
    struct RestoreResult {
        var restored = 0
        var skippedNotInstalled = 0
        var failed: [(String, Error)] = []
    }

    var calls: [String] = []

    func restoreCachedIcon(
        for app: AppItem,
        allowRepair: Bool,
        refreshDock: Bool,
        source: DiagnosticsSource
    ) async throws -> Bool {
        precondition(!allowRepair && !refreshDock && source == .appUpdate)
        calls.append(app.name)
        switch app.name {
        case "Broken": throw FixtureError.missingIcon
        case "No Eligible Icon": return false
        default: return true
        }
    }
}

struct TestLogger {
    func error(_ message: String) {}
}

@MainActor
enum DockRefreshService {
    static var calls = 0

    static func refreshTwice() async -> Bool {
        calls += 1
        return true
    }
}

enum UNNotificationSound {
    case `default`
}

final class UNMutableNotificationContent {
    var title = ""
    var body = ""
    var sound: UNNotificationSound?
}

struct UNNotificationRequest {
    let identifier: String
    let content: UNMutableNotificationContent
    let trigger: String?
}

@MainActor
final class UNUserNotificationCenter {
    private static let instance = UNUserNotificationCenter()
    var requests: [UNNotificationRequest] = []

    static func current() -> UNUserNotificationCenter { instance }

    func add(_ request: UNNotificationRequest, completionHandler: (Error?) -> Void) {
        requests.append(request)
        completionHandler(nil)
    }
}

@main
enum BackgroundRestoreTests {
    @MainActor
    static func main() async {
        let harness = BackgroundRestoreHarness()
        let result = await harness.restoreUpdatedApps([
            AppItem(name: "Broken"),
            AppItem(name: "Healthy"),
            AppItem(name: "No Eligible Icon"),
        ])
        guard harness.iconManager.calls == ["Broken", "Healthy", "No Eligible Icon"] else {
            fail("every updated app must receive its own restoration attempt")
        }
        guard result.restored == 1,
              result.failed.count == 1,
              result.failed.first?.0 == "Broken",
              result.failed.first?.1 is FixtureError else {
            fail("batch counts must distinguish a success, a failure, and an ineligible icon")
        }
        guard DockRefreshService.calls == 1 else {
            fail("a successful batch must refresh the Dock once")
        }

        DockRefreshService.calls = 0
        let unsuccessfulHarness = BackgroundRestoreHarness()
        let unsuccessfulResult = await unsuccessfulHarness.restoreUpdatedApps([
            AppItem(name: "Broken"),
            AppItem(name: "No Eligible Icon"),
        ])
        guard unsuccessfulResult.restored == 0,
              unsuccessfulResult.failed.count == 1,
              unsuccessfulHarness.iconManager.calls == ["Broken", "No Eligible Icon"],
              DockRefreshService.calls == 0 else {
            fail("failed and ineligible icons must not count as restored or refresh the Dock")
        }

        let emptyResult = await BackgroundRestoreHarness().restoreUpdatedApps([])
        guard emptyResult.restored == 0,
              emptyResult.failed.isEmpty,
              DockRefreshService.calls == 0 else {
            fail("an empty update batch must have no side effects")
        }

        let center = UNUserNotificationCenter.current()
        harness.showUpdateNotification(restored: 0, failed: 0)
        harness.showRestoreNotification(result: IconManager.RestoreResult())
        guard center.requests.isEmpty else {
            fail("an empty restore result must not produce a success notification")
        }

        harness.showUpdateNotification(restored: 2, failed: 3)
        guard let updateNotification = center.requests.last?.content,
              updateNotification.title == "Icon Restoration Failed",
              updateNotification.body.contains("2 updated app(s)"),
              updateNotification.body.contains("3 failed") else {
            fail("update notifications must report actual successes and failures")
        }

        var partialResult = IconManager.RestoreResult()
        partialResult.restored = 2
        partialResult.skippedNotInstalled = 5
        partialResult.failed = (1...3).map { ("Broken \($0)", FixtureError.missingIcon) }
        harness.showRestoreNotification(result: partialResult)
        guard center.requests.count == 2,
              let restoreNotification = center.requests.last?.content,
              restoreNotification.title == "Icon Restoration Failed",
              restoreNotification.body.contains("2 icons restored"),
              restoreNotification.body.contains("5 skipped"),
              restoreNotification.body.contains("3 failed") else {
            fail("scheduled restore notifications must retain partial results")
        }
        print("PASS: background app restore continues after failures and reports actual successes")
    }

    private static func fail(_ message: String) -> Never {
        fputs("FAIL: \(message)\n", stderr)
        exit(1)
    }
}
