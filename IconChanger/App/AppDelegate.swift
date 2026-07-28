//
//  AppDelegate.swift
//  IconChanger
//

import SwiftUI
import UserNotifications
import OSLog

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let backgroundService = BackgroundService.shared
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "IconChanger", category: "AppDelegate")
    private let lastKnownSetupReadyKey = "lastKnownSetupReady"

    func applicationDidFinishLaunching(_ notification: Notification) {
        UNUserNotificationCenter.current().delegate = self

        if backgroundService.runInBackground {
            backgroundService.startBackgroundService()
        }

        IconAppearanceSwitchService.shared.setEnabled(
            backgroundService.enableAppearanceIconSwitching
        )

        let launchedHidden = backgroundService.shouldLaunchHidden && isLaunchedAtLogin(notification)

        if launchedHidden {
            DispatchQueue.main.async {
                for window in NSApp.windows where window.canBecomeMain {
                    window.close()
                }
                if !self.backgroundService.showInDock {
                    NSApp.setActivationPolicy(.accessory)
                }
            }
        }

        verifySetup(launchedHidden: launchedHidden)
    }

    private func verifySetup(launchedHidden: Bool) {
        let defaults = UserDefaults.standard
        let previousReady = defaults.object(forKey: lastKnownSetupReadyKey) as? Bool

        SetupMonitor.shared.check { [weak self] health in
            guard let self else { return }
            defaults.set(health == .ready, forKey: self.lastKnownSetupReadyKey)

            if SetupNotificationPolicy.shouldNotify(
                previousReady: previousReady,
                current: health,
                launchedHidden: launchedHidden
            ) {
                self.logger.error("Setup check needs attention: \(health.statusDescription)")
                self.postSetupNeededNotification(health: health)
            }
        }
    }

    private func postSetupNeededNotification(health: SetupHealth) {
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("IconChanger Needs Attention", comment: "Setup notification title")
        content.body = String(
            format: NSLocalizedString("%@. Open IconChanger to repair setup.", comment: "Setup notification body"),
            health.statusDescription
        )
        content.sound = UNNotificationSound.default
        content.userInfo = ["action": "openSetup"]

        let request = UNNotificationRequest(identifier: "iconchanger.setup.needed", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                self.logger.error("Failed to post setup notification: \(error.localizedDescription)")
            }
        }
    }

    private func isLaunchedAtLogin(_ notification: Notification) -> Bool {
        guard let launchEvent = NSAppleEventManager.shared().currentAppleEvent else {
            return false
        }
        return launchEvent.eventID == kAEOpenApplication
            && launchEvent.paramDescriptor(forKeyword: keyAEPropData)?.enumCodeValue == keyAELaunchedAsLogInItem
    }

    func applicationWillTerminate(_ notification: Notification) {
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            NSApp.setActivationPolicy(.regular)
            return true
        }
        return false
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        if backgroundService.runInBackground {
            backgroundService.handleLastWindowClosed()
            return false
        }
        return true
    }
}

extension AppDelegate: @preconcurrency UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if response.notification.request.content.userInfo["action"] as? String == "openSetup" {
            backgroundService.openMainWindow(nil)
        }
        completionHandler()
    }
}
