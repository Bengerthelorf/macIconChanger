//
//  BackgroundService.swift
//  IconChanger
//
//  Created by Bengerthelorf on 2025/03/23.
//

import SwiftUI
import Combine
import LaunchPadManagerDBHelper
import UserNotifications // Add modern notification framework

class BackgroundService: ObservableObject {
    static let shared = BackgroundService()
    
    // Status bar item
    private var statusItem: NSStatusItem?
    private var statusMenu: NSMenu?
    
    // Background mode settings
    @AppStorage("runInBackground") var runInBackground: Bool = false
    @AppStorage("showInDock") var showInDock: Bool = true
    @AppStorage("showInMenuBar") var showInMenuBar: Bool = true
    
    // Auto-restore settings
    @AppStorage("enableScheduledRestore") var enableScheduledRestore: Bool = false
    @AppStorage("scheduledRestoreInterval") var scheduledRestoreInterval: Int = 24 // Hours
    @AppStorage("customScheduledRestoreInterval") var customScheduledRestoreInterval: Int = 36 // Hours
    @AppStorage("useCustomScheduledRestoreInterval") var useCustomScheduledRestoreInterval: Bool = false
    @AppStorage("lastScheduledRestore") var lastScheduledRestore: Date = Date.distantPast
    
    @AppStorage("enableAutoRestoreOnUpdate") var enableAutoRestoreOnUpdate: Bool = false
    @AppStorage("autoRestoreCheckInterval") var autoRestoreCheckInterval: Int = 15 // Minutes
    @AppStorage("lastUpdateCheck") var lastUpdateCheck: Date = Date.distantPast
    
    // Reference to the app manager
    private let iconManager = IconManager.shared
    
    // Timer for scheduled checks
    private var timer: Timer?
    private var updateCheckTimer: Timer?
    
    // Initialize
    private init() {
        // Setup only when app is fully launched
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(setupBackgroundMode),
            name: NSApplication.didFinishLaunchingNotification,
            object: nil
        )
    }
    
    // Setup background mode
    @objc func setupBackgroundMode() {
        if runInBackground {
            // Start the service
            startBackgroundService()
        }
    }
    
    // Start background service
    func startBackgroundService() {
        if showInMenuBar {
            setupStatusBar()
        }
        
        // Request notification permission
        requestNotificationPermission()
        
        setupTimers()
        
        // Update dock visibility
        updateDockVisibility()
        
        // Save state
        runInBackground = true
    }
    
    // Request permission to show notifications
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
    }
    
    // Stop background service
    func stopBackgroundService() {
        // Remove status bar item if it exists
        if statusItem != nil {
            NSStatusBar.system.removeStatusItem(statusItem!)
            statusItem = nil
        }
        
        // Invalidate timers
        timer?.invalidate()
        timer = nil
        
        updateCheckTimer?.invalidate()
        updateCheckTimer = nil
        
        // Always show in dock when not running in background
        NSApp.setActivationPolicy(.regular)
        
        // Save state
        runInBackground = false
    }
    
    // Setup status bar item and menu
    private func setupStatusBar() {
        if statusItem == nil {
            statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
            
            if let button = statusItem?.button {
                button.image = NSImage(systemSymbolName: "app.badge.checkmark.fill", accessibilityDescription: "IconChanger")
            }
            
            // Create menu
            updateStatusMenu()
        }
    }
    
    // Custom method to activate the app
    @objc func openMainWindow(_ sender: Any?) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        
        // Make sure a window is visible
        if NSApp.windows.isEmpty || !NSApp.windows.contains(where: { $0.isVisible }) {
            // Post a notification to open a window if needed
            NotificationCenter.default.post(name: NSNotification.Name("OpenMainWindow"), object: nil)
        }
    }
    
    // Update status menu
    func updateStatusMenu() {
        let menu = NSMenu()
        
        // App info
        let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "IconChanger"
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let appInfoItem = NSMenuItem(title: "\(appName) \(appVersion)", action: nil, keyEquivalent: "")
        appInfoItem.isEnabled = false
        menu.addItem(appInfoItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Show main window
        let openItem = NSMenuItem(title: "Open IconChanger", action: #selector(openMainWindow(_:)), keyEquivalent: "o")
        openItem.target = self
        menu.addItem(openItem)
        
        // Cached Icons count
        let cachedCount = IconCacheManager.shared.getCachedIconsCount()
        let cachedCountItem = NSMenuItem(title: "Cached Icons: \(cachedCount)", action: nil, keyEquivalent: "")
        cachedCountItem.isEnabled = false
        menu.addItem(cachedCountItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Restore icons manually
        let restoreItem = NSMenuItem(title: "Restore Cached Icons", action: #selector(restoreCachedIcons), keyEquivalent: "r")
        restoreItem.target = self
        menu.addItem(restoreItem)
        
        // Last restore time
        if lastScheduledRestore != Date.distantPast {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            let lastRestoreItem = NSMenuItem(title: "Last Restore: \(formatter.string(from: lastScheduledRestore))", action: nil, keyEquivalent: "")
            lastRestoreItem.isEnabled = false
            menu.addItem(lastRestoreItem)
        }
        
        menu.addItem(NSMenuItem.separator())
        
        // Background settings
        let settingsSubmenu = NSMenu()
        
        // Menu bar visibility
        let menuBarItem = NSMenuItem(title: "Show in Menu Bar", action: #selector(toggleMenuBarVisibility), keyEquivalent: "")
        menuBarItem.target = self
        menuBarItem.state = showInMenuBar ? .on : .off
        settingsSubmenu.addItem(menuBarItem)
        
        // Dock visibility
        let dockItem = NSMenuItem(title: "Show in Dock", action: #selector(toggleDockVisibility), keyEquivalent: "")
        dockItem.target = self
        dockItem.state = showInDock ? .on : .off
        settingsSubmenu.addItem(dockItem)
        
        settingsSubmenu.addItem(NSMenuItem.separator())
        
        // Auto restore on schedule
        let autoRestoreItem = NSMenuItem(title: "Auto-Restore on Schedule", action: #selector(toggleScheduledRestore), keyEquivalent: "")
        autoRestoreItem.target = self
        autoRestoreItem.state = enableScheduledRestore ? .on : .off
        settingsSubmenu.addItem(autoRestoreItem)
        
        // Interval submenu
        if enableScheduledRestore {
            let intervalSubmenu = NSMenu()
            
            // Regular intervals
            let regularIntervalsItem = NSMenuItem(title: "Preset Intervals", action: nil, keyEquivalent: "")
            regularIntervalsItem.isEnabled = false
            intervalSubmenu.addItem(regularIntervalsItem)
            
            for interval in [1, 3, 6, 12, 24, 48, 72] {
                let intervalItem = NSMenuItem(title: formatInterval(interval), action: #selector(setRestoreInterval(_:)), keyEquivalent: "")
                intervalItem.target = self
                intervalItem.state = (scheduledRestoreInterval == interval && !useCustomScheduledRestoreInterval) ? .on : .off
                intervalItem.representedObject = interval
                intervalSubmenu.addItem(intervalItem)
            }
            
            // Custom interval
            intervalSubmenu.addItem(NSMenuItem.separator())
            
            let customIntervalItem = NSMenuItem(title: "Custom: \(formatInterval(customScheduledRestoreInterval))", action: #selector(toggleCustomRestoreInterval), keyEquivalent: "")
            customIntervalItem.target = self
            customIntervalItem.state = useCustomScheduledRestoreInterval ? .on : .off
            intervalSubmenu.addItem(customIntervalItem)
            
            let intervalMenuItem = NSMenuItem(title: "Restore Interval", action: nil, keyEquivalent: "")
            intervalMenuItem.submenu = intervalSubmenu
            settingsSubmenu.addItem(intervalMenuItem)
        }
        
        settingsSubmenu.addItem(NSMenuItem.separator())
        
        // Auto restore on update
        let autoUpdateItem = NSMenuItem(title: "Auto-Restore When Apps Update", action: #selector(toggleAutoRestoreOnUpdate), keyEquivalent: "")
        autoUpdateItem.target = self
        autoUpdateItem.state = enableAutoRestoreOnUpdate ? .on : .off
        settingsSubmenu.addItem(autoUpdateItem)
        
        // Check interval submenu if auto-restore on update is enabled
        if enableAutoRestoreOnUpdate {
            let checkIntervalSubmenu = NSMenu()
            
            for minutes in [5, 15, 30, 60, 120] {
                let intervalItem = NSMenuItem(title: formatMinuteInterval(minutes), action: #selector(setCheckInterval(_:)), keyEquivalent: "")
                intervalItem.target = self
                intervalItem.state = autoRestoreCheckInterval == minutes ? .on : .off
                intervalItem.representedObject = minutes
                checkIntervalSubmenu.addItem(intervalItem)
            }
            
            let checkIntervalMenuItem = NSMenuItem(title: "Check Interval", action: nil, keyEquivalent: "")
            checkIntervalMenuItem.submenu = checkIntervalSubmenu
            settingsSubmenu.addItem(checkIntervalMenuItem)
        }
        
        // Settings menu item
        let settingsItem = NSMenuItem(title: "Settings", action: nil, keyEquivalent: ",")
        settingsItem.submenu = settingsSubmenu
        menu.addItem(settingsItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Quit
        let quitItem = NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        quitItem.target = NSApplication.shared
        menu.addItem(quitItem)
        
        // Set the menu
        statusItem?.menu = menu
        statusMenu = menu
    }
    
    // Update dock visibility based on settings
    private func updateDockVisibility() {
        if runInBackground && !showInDock {
            NSApp.setActivationPolicy(.accessory)
        } else {
            NSApp.setActivationPolicy(.regular)
        }
    }
    
    // Toggle menu bar visibility
    @objc func toggleMenuBarVisibility() {
        showInMenuBar.toggle()
        
        if showInMenuBar {
            setupStatusBar()
        } else {
            if statusItem != nil {
                NSStatusBar.system.removeStatusItem(statusItem!)
                statusItem = nil
            }
            
            // Ensure at least one visibility option is enabled
            if !showInDock {
                showInDock = true
                updateDockVisibility()
            }
        }
        
        updateStatusMenu()
    }
    
    // Toggle dock visibility
    @objc func toggleDockVisibility() {
        showInDock.toggle()
        
        // Ensure at least one visibility option is enabled
        if !showInDock && !showInMenuBar {
            showInMenuBar = true
            setupStatusBar()
        }
        
        updateDockVisibility()
        updateStatusMenu()
    }
    
    // Toggle scheduled restore
    @objc func toggleScheduledRestore() {
        enableScheduledRestore.toggle()
        setupTimers()
        updateStatusMenu()
    }
    
    // Toggle auto restore on update
    @objc func toggleAutoRestoreOnUpdate() {
        enableAutoRestoreOnUpdate.toggle()
        setupTimers()
        updateStatusMenu()
    }
    
    // Toggle custom restore interval
    @objc func toggleCustomRestoreInterval() {
        useCustomScheduledRestoreInterval.toggle()
        setupTimers()
        updateStatusMenu()
    }
    
    // Set restore interval
    @objc func setRestoreInterval(_ sender: NSMenuItem) {
        guard let interval = sender.representedObject as? Int else { return }
        scheduledRestoreInterval = interval
        useCustomScheduledRestoreInterval = false
        setupTimers()
        updateStatusMenu()
    }
    
    // Set check interval for app updates
    @objc func setCheckInterval(_ sender: NSMenuItem) {
        guard let interval = sender.representedObject as? Int else { return }
        autoRestoreCheckInterval = interval
        setupTimers()
        updateStatusMenu()
    }
    
    // Setup timers for scheduled tasks
    // Changed from private to internal so it can be accessed from BackgroundSettingsView
    func setupTimers() {
        // Invalidate existing timers
        timer?.invalidate()
        timer = nil
        
        updateCheckTimer?.invalidate()
        updateCheckTimer = nil
        
        // Setup scheduled restore timer if enabled
        if enableScheduledRestore {
            // Check every hour to see if it's time to restore
            timer = Timer.scheduledTimer(timeInterval: 3600, target: self, selector: #selector(checkScheduledRestore), userInfo: nil, repeats: true)
        }
        
        // Setup app update check timer if enabled
        if enableAutoRestoreOnUpdate {
            // Convert minutes to seconds
            let timeInterval = Double(autoRestoreCheckInterval * 60)
            updateCheckTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(checkForAppUpdates), userInfo: nil, repeats: true)
        }
    }
    
    // Get the current active restore interval in hours
    func getActiveRestoreInterval() -> Int {
        return useCustomScheduledRestoreInterval ? customScheduledRestoreInterval : scheduledRestoreInterval
    }
    
    // Check if it's time for scheduled restore
    @objc func checkScheduledRestore() {
        guard enableScheduledRestore else { return }
        
        let interval = getActiveRestoreInterval()
        let timeInterval = TimeInterval(interval * 3600) // Convert hours to seconds
        let nextRestoreTime = lastScheduledRestore.addingTimeInterval(timeInterval)
        
        if Date() >= nextRestoreTime {
            performScheduledRestore()
        }
    }
    
    // Check for app updates
    @objc func checkForAppUpdates() {
        guard enableAutoRestoreOnUpdate else { return }
        
        Task {
            do {
                let updatedApps = try await checkCachedAppsForUpdates()
                
                if !updatedApps.isEmpty {
                    try await restoreUpdatedApps(updatedApps)
                    showUpdateNotification(appCount: updatedApps.count)
                }
                
                // Update last check time
                lastUpdateCheck = Date()
            } catch {
                print("Error checking for app updates: \(error.localizedDescription)")
            }
        }
    }
    
    // Perform scheduled restore
    private func performScheduledRestore() {
        Task {
            do {
                try await iconManager.restoreAllCachedIcons()
                lastScheduledRestore = Date()
                
                updateStatusMenu()
                showRestoreNotification()
            } catch {
                print("Scheduled restore failed: \(error.localizedDescription)")
            }
        }
    }
    
    // Manual restore from menu
    @objc func restoreCachedIcons() {
        Task {
            do {
                try await iconManager.restoreAllCachedIcons()
                lastScheduledRestore = Date()
                
                updateStatusMenu()
                showRestoreNotification()
            } catch {
                print("Manual restore failed: \(error.localizedDescription)")
                
                // Show error alert
                let alert = NSAlert()
                alert.messageText = "Icon Restoration Failed"
                alert.informativeText = error.localizedDescription
                alert.alertStyle = .warning
                alert.addButton(withTitle: "OK")
                alert.runModal()
            }
        }
    }
    
    // Check cached apps for updates
    private func checkCachedAppsForUpdates() async throws -> [LaunchPadManagerDBHelper.AppInfo] {
        var updatedApps: [LaunchPadManagerDBHelper.AppInfo] = []
        let cachedIcons = IconCacheManager.shared.getAllCachedIcons()
        
        for cache in cachedIcons {
            let appPath = cache.appPath
            
            // Verify app still exists
            guard FileManager.default.fileExists(atPath: appPath) else {
                continue
            }
            
            // Get file modification date
            let attributes = try? FileManager.default.attributesOfItem(atPath: appPath)
            if let modDate = attributes?[.modificationDate] as? Date {
                // If file was modified since last check
                if modDate > lastUpdateCheck {
                    // Find app info
                    if let appInfo = iconManager.apps.first(where: { $0.url.universalPath() == appPath }) {
                        updatedApps.append(appInfo)
                    }
                }
            }
        }
        
        return updatedApps
    }
    
    // Restore icons for updated apps
    private func restoreUpdatedApps(_ apps: [LaunchPadManagerDBHelper.AppInfo]) async throws {
        for app in apps {
            // Get cached icon
            if let _ = IconCacheManager.shared.getIconCache(for: app.url.universalPath()),
               let iconURL = IconCacheManager.shared.getCachedIconURL(for: app.url.universalPath()),
               let image = NSImage(contentsOf: iconURL) {
                // Restore icon
                try await iconManager.setIconWithoutCaching(image, app: app)
            }
        }
    }
    
    // Show restoration notification using the modern UserNotifications framework
    private func showRestoreNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Icons Restored"
        content.body = "All cached app icons have been successfully restored."
        content.sound = UNNotificationSound.default
        
        // Create a request with a unique identifier
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil  // Deliver immediately
        )
        
        // Schedule the notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error showing notification: \(error.localizedDescription)")
            }
        }
    }
    
    // Show update notification
    private func showUpdateNotification(appCount: Int) {
        let content = UNMutableNotificationContent()
        content.title = "App Icons Restored"
        content.body = "\(appCount) updated app(s) had their custom icons restored."
        content.sound = UNNotificationSound.default
        
        // Create a request with a unique identifier
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil  // Deliver immediately
        )
        
        // Schedule the notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error showing notification: \(error.localizedDescription)")
            }
        }
    }
    
    // Helper to format time interval (hours)
    func formatInterval(_ hours: Int) -> String {
        switch hours {
        case 1: return "Every Hour"
        case 24: return "Every Day"
        case 48: return "Every 2 Days"
        case 72: return "Every 3 Days"
        default: return "Every \(hours) Hours"
        }
    }
    
    // Helper to format minute interval
    func formatMinuteInterval(_ minutes: Int) -> String {
        switch minutes {
        case 1: return "Every Minute"
        case 60: return "Every Hour"
        case 120: return "Every 2 Hours"
        default: return "Every \(minutes) Minutes"
        }
    }
}
