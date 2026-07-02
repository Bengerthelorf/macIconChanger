//
//  AppDelegate.swift
//  IconChanger
//

import SwiftUI
import UserNotifications
import OSLog

class AppDelegate: NSObject, NSApplicationDelegate {
    private let backgroundService = BackgroundService.shared
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "IconChanger", category: "AppDelegate")

    func applicationDidFinishLaunching(_ notification: Notification) {
        UNUserNotificationCenter.current().delegate = self

        if backgroundService.runInBackground {
            backgroundService.startBackgroundService()
        }

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

        verifySetup(notifyOnFailure: launchedHidden)
    }

    /// Runs setup detection on every launch regardless of window visibility (#35).
    /// When launched hidden the Setup Error window never appears, so a broken setup
    /// is reported via a notification instead.
    private func verifySetup(notifyOnFailure: Bool) {
        DispatchQueue.global(qos: .utility).async {
            guard FolderPermission.shared.hasPermission else {
                self.logger.error("Setup check: folder permission missing")
                if notifyOnFailure { self.postSetupNeededNotification() }
                return
            }

            IconManager.shared.ensureHelperFilesCopied()
            let status = IconManager.shared.checkSetupStatus()

            let isReady: Bool
            switch status {
            case .completed:
                switch IconManager.shared.appManagementStatus() {
                case .authorized, .unknown: isReady = true
                case .denied, .notDetermined: isReady = false
                }
            default:
                isReady = false
            }

            if !isReady {
                self.logger.error("Setup check failed: \(String(describing: status))")
                if notifyOnFailure { self.postSetupNeededNotification() }
            }
        }
    }

    private func postSetupNeededNotification() {
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("IconChanger Needs Attention", comment: "Setup notification title")
        content.body = NSLocalizedString("Setup is incomplete, so custom icons may not be applied or restored. Open IconChanger to finish setup.", comment: "Setup notification body")
        content.sound = UNNotificationSound.default

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

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
