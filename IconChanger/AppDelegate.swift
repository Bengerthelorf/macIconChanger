//
//  AppDelegate.swift
//  IconChanger
//
//  Created by Bengerthelorf on 2025/03/23.
//

import SwiftUI
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate {
    private let backgroundService = BackgroundService.shared

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Register as UNUserNotificationCenter delegate
        UNUserNotificationCenter.current().delegate = self

        // Setup background service if enabled
        if backgroundService.runInBackground {
            backgroundService.startBackgroundService()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Cleanup if needed
    }

    // Handle app activation when in background mode
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            // No visible windows, create one
            NSApp.activate(ignoringOtherApps: true)
            return true
        }
        return false
    }
}

// Extension to handle notifications using modern UNUserNotificationCenter
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notifications even when app is in foreground
        completionHandler([.banner, .sound])
    }
}
