//
//  AppDelegate.swift
//  IconChanger
//
//  Created by Bengerthelorf on 2025/03/23.
//

import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private let backgroundService = BackgroundService.shared
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Register user notification delegate
        let center = NSUserNotificationCenter.default
        center.delegate = self
        
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

// Extension to handle notifications
extension AppDelegate: NSUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        // Always show notifications, even when app is in foreground
        return true
    }
}
