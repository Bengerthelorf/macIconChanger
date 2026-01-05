//
//  BackgroundService.swift
//  IconChanger
//
//  Created by Bengerthelorf on 2025/03/23.
//  Modified by CantonMonkey on 2025/10/11.
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
    @Published var runInBackground: Bool {
        didSet {
            UserDefaults.standard.set(runInBackground, forKey: "runInBackground")
        }
    }
    
    @Published var showInDock: Bool {
        didSet {
            UserDefaults.standard.set(showInDock, forKey: "showInDock")
        }
    }
    
    @Published var showInMenuBar: Bool {
        didSet {
            UserDefaults.standard.set(showInMenuBar, forKey: "showInMenuBar")
        }
    }
    
    // Auto-restore settings
    @Published var enableScheduledRestore: Bool {
        didSet {
            UserDefaults.standard.set(enableScheduledRestore, forKey: "enableScheduledRestore")
        }
    }
    
    @Published var scheduledRestoreInterval: Int {
        didSet {
            UserDefaults.standard.set(scheduledRestoreInterval, forKey: "scheduledRestoreInterval")
        }
    }
    
    @Published var customScheduledRestoreInterval: Int {
        didSet {
            UserDefaults.standard.set(customScheduledRestoreInterval, forKey: "customScheduledRestoreInterval")
        }
    }
    
    @Published var useCustomScheduledRestoreInterval: Bool {
        didSet {
            UserDefaults.standard.set(useCustomScheduledRestoreInterval, forKey: "useCustomScheduledRestoreInterval")
        }
    }
    
    @Published var lastScheduledRestore: Date {
        didSet {
            UserDefaults.standard.set(lastScheduledRestore, forKey: "lastScheduledRestore")
        }
    }
    
    @Published var enableAutoRestoreOnUpdate: Bool {
        didSet {
            UserDefaults.standard.set(enableAutoRestoreOnUpdate, forKey: "enableAutoRestoreOnUpdate")
        }
    }
    
    @Published var autoRestoreCheckInterval: Int {
        didSet {
            UserDefaults.standard.set(autoRestoreCheckInterval, forKey: "autoRestoreCheckInterval")
        }
    }
    
    @Published var lastUpdateCheck: Date {
        didSet {
            UserDefaults.standard.set(lastUpdateCheck, forKey: "lastUpdateCheck")
        }
    }
    
    // Reference to the app manager
    private let iconManager = IconManager.shared
    
    // Timer for scheduled checks
    private var scheduledRestoreTimer: DispatchSourceTimer?
    private var updateCheckTimer: DispatchSourceTimer?
    private var fetchCacheCleanupTimer: DispatchSourceTimer?
    private let timerQueue = DispatchQueue(label: "com.iconchanger.backgroundservice.timers", qos: .utility)
    
    // Initialize
    private init() {
        // First, initialize all properties with default values
        self.runInBackground = false
        self.showInDock = true
        self.showInMenuBar = true
        self.enableScheduledRestore = false
        self.scheduledRestoreInterval = 24
        self.customScheduledRestoreInterval = 36
        self.useCustomScheduledRestoreInterval = false
        self.lastScheduledRestore = Date.distantPast
        self.enableAutoRestoreOnUpdate = false
        self.autoRestoreCheckInterval = 15
        self.lastUpdateCheck = Date.distantPast
        
        // Then, after all properties are initialized, we can load values from UserDefaults
        self.runInBackground = UserDefaults.standard.bool(forKey: "runInBackground")
        
        if UserDefaults.standard.object(forKey: "showInDock") != nil {
            self.showInDock = UserDefaults.standard.bool(forKey: "showInDock")
        }
        
        if UserDefaults.standard.object(forKey: "showInMenuBar") != nil {
            self.showInMenuBar = UserDefaults.standard.bool(forKey: "showInMenuBar")
        }
        
        self.enableScheduledRestore = UserDefaults.standard.bool(forKey: "enableScheduledRestore")
        
        if UserDefaults.standard.object(forKey: "scheduledRestoreInterval") != nil {
            let interval = UserDefaults.standard.integer(forKey: "scheduledRestoreInterval")
            if interval > 0 {
                self.scheduledRestoreInterval = interval
            }
        }
        
        if UserDefaults.standard.object(forKey: "customScheduledRestoreInterval") != nil {
            let interval = UserDefaults.standard.integer(forKey: "customScheduledRestoreInterval")
            if interval > 0 {
                self.customScheduledRestoreInterval = interval
            }
        }
        
        self.useCustomScheduledRestoreInterval = UserDefaults.standard.bool(forKey: "useCustomScheduledRestoreInterval")
        
        if let date = UserDefaults.standard.object(forKey: "lastScheduledRestore") as? Date {
            self.lastScheduledRestore = date
        }
        
        self.enableAutoRestoreOnUpdate = UserDefaults.standard.bool(forKey: "enableAutoRestoreOnUpdate")
        
        if UserDefaults.standard.object(forKey: "autoRestoreCheckInterval") != nil {
            let interval = UserDefaults.standard.integer(forKey: "autoRestoreCheckInterval")
            if interval > 0 {
                self.autoRestoreCheckInterval = interval
            }
        }
        
        if let date = UserDefaults.standard.object(forKey: "lastUpdateCheck") as? Date {
            self.lastUpdateCheck = date
        }
        
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
        
        // Cancel timers
        cancelTimer(&scheduledRestoreTimer)
        cancelTimer(&updateCheckTimer)
        cancelTimer(&fetchCacheCleanupTimer)
        
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
        cancelTimer(&scheduledRestoreTimer)
        cancelTimer(&updateCheckTimer)
        cancelTimer(&fetchCacheCleanupTimer)

        if enableScheduledRestore {
            scheduledRestoreTimer = makeRepeatingTimer(interval: 3600) { [weak self] in
                self?.checkScheduledRestore()
            }
            checkScheduledRestore()
        }

        if enableAutoRestoreOnUpdate {
            let timeInterval = Double(autoRestoreCheckInterval * 60)
            updateCheckTimer = makeRepeatingTimer(interval: timeInterval) { [weak self] in
                self?.checkForAppUpdates()
            }
            checkForAppUpdates()
        }

        fetchCacheCleanupTimer = makeRepeatingTimer(interval: 600) { [weak self] in
            self?.cleanupFetchCache()
        }
        cleanupFetchCache()
    }

    private func cancelTimer(_ timer: inout DispatchSourceTimer?) {
        guard let existing = timer else { return }
        existing.setEventHandler {}
        existing.cancel()
        timer = nil
    }

    private func makeRepeatingTimer(interval: TimeInterval,
                                    handler: @escaping @Sendable () -> Void) -> DispatchSourceTimer {
        let timer = DispatchSource.makeTimerSource(queue: timerQueue)
        timer.schedule(deadline: .now() + interval, repeating: interval, leeway: .seconds(30))
        timer.setEventHandler(handler: handler)
        timer.resume()
        return timer
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
                
                await MainActor.run {
                    lastUpdateCheck = Date()
                }
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
                
                await MainActor.run {
                    lastScheduledRestore = Date()
                    updateStatusMenu()
                }
                
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
                let alert = await NSAlert()
                alert.messageText = "Icon Restoration Failed"
                alert.informativeText = error.localizedDescription
                alert.alertStyle = .warning
                alert.addButton(withTitle: "OK")
                alert.runModal()
            }
        }
    }
    
    // Check cached apps for updates
    private func checkCachedAppsForUpdates() async throws -> [AppItem] {
        let cachedIcons = IconCacheManager.shared.getAllCachedIcons()
        guard !cachedIcons.isEmpty else { return [] }

        let helper = try LaunchPadManagerDBHelper()
        let allApps = try helper.getAllAppInfos()
        // Convert to AppItem
        let appItems = allApps.map { AppItem(id: $0.url, name: $0.name, url: $0.url, originalAppInfo: $0) }
        
        let sortedApps = appItems.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }

        await MainActor.run {
            iconManager.apps = sortedApps
        }

        let appMap = Dictionary(uniqueKeysWithValues: sortedApps.map { ($0.url.universalPath(), $0) })

        let updatedApps: [AppItem] = cachedIcons.compactMap { cache in
            let appPath = cache.appPath

            guard FileManager.default.fileExists(atPath: appPath) else {
                return nil
            }

            let attributes = try? FileManager.default.attributesOfItem(atPath: appPath)
            guard let modDate = attributes?[.modificationDate] as? Date,
                  modDate > lastUpdateCheck else {
                return nil
            }

            return appMap[appPath]
        }

        return updatedApps
    }
    
    // Restore icons for updated apps
    private func restoreUpdatedApps(_ apps: [AppItem]) async throws {
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

    // MARK: - Icon Fetch Cache Cleanup

    /// Clean up icon fetch cache (called every 10 minutes)
    /// Only removes entries that haven't been accessed in the last 10 minutes (true LRU)
    @objc func cleanupFetchCache() {
        let maxAge: TimeInterval = 600  // 10 minutes
        let removed = IconFetchCacheManager.shared.clearExpiredCache(olderThan: maxAge)

        if removed > 0 {
            print("🧹 Periodic cleanup: Removed \(removed) expired entries (not accessed for 10+ min)")
        } else {
            print("🧹 Periodic cleanup: No expired entries found")
        }
    }
}
