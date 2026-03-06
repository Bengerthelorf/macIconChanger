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

    private static let shortDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .short
        return f
    }()
    
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
        let openItem = NSMenuItem(title: NSLocalizedString("Open IconChanger", comment: "Menu item"), action: #selector(openMainWindow(_:)), keyEquivalent: "o")
        openItem.target = self
        menu.addItem(openItem)
        
        // Cached Icons count
        let cachedCount = IconCacheManager.shared.getCachedIconsCount()
        let cachedCountItem = NSMenuItem(title: String(format: NSLocalizedString("Cached Icons: %lld", comment: "Menu item"), cachedCount), action: nil, keyEquivalent: "")
        cachedCountItem.isEnabled = false
        menu.addItem(cachedCountItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Restore icons manually
        let restoreItem = NSMenuItem(title: NSLocalizedString("Restore Cached Icons", comment: "Menu item"), action: #selector(restoreCachedIcons), keyEquivalent: "r")
        restoreItem.target = self
        menu.addItem(restoreItem)
        
        // Last restore time
        if lastScheduledRestore != Date.distantPast {
            let lastRestoreItem = NSMenuItem(title: String(format: NSLocalizedString("Last Restore: %@", comment: "Menu item"), Self.shortDateFormatter.string(from: lastScheduledRestore)), action: nil, keyEquivalent: "")
            lastRestoreItem.isEnabled = false
            menu.addItem(lastRestoreItem)
        }
        
        menu.addItem(NSMenuItem.separator())
        
        // Background settings
        let settingsSubmenu = NSMenu()
        
        // Menu bar visibility
        let menuBarItem = NSMenuItem(title: NSLocalizedString("Show in Menu Bar", comment: "Menu item"), action: #selector(toggleMenuBarVisibility), keyEquivalent: "")
        menuBarItem.target = self
        menuBarItem.state = showInMenuBar ? .on : .off
        settingsSubmenu.addItem(menuBarItem)
        
        // Dock visibility
        let dockItem = NSMenuItem(title: NSLocalizedString("Show in Dock", comment: "Menu item"), action: #selector(toggleDockVisibility), keyEquivalent: "")
        dockItem.target = self
        dockItem.state = showInDock ? .on : .off
        settingsSubmenu.addItem(dockItem)
        
        settingsSubmenu.addItem(NSMenuItem.separator())
        
        // Auto restore on schedule
        let autoRestoreItem = NSMenuItem(title: NSLocalizedString("Auto-Restore on Schedule", comment: "Menu item"), action: #selector(toggleScheduledRestore), keyEquivalent: "")
        autoRestoreItem.target = self
        autoRestoreItem.state = enableScheduledRestore ? .on : .off
        settingsSubmenu.addItem(autoRestoreItem)
        
        // Interval submenu
        if enableScheduledRestore {
            let intervalSubmenu = NSMenu()
            
            // Regular intervals
            let regularIntervalsItem = NSMenuItem(title: NSLocalizedString("Preset Intervals", comment: "Menu item"), action: nil, keyEquivalent: "")
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
            
            let customIntervalItem = NSMenuItem(title: String(format: NSLocalizedString("Custom: %@", comment: "Menu item"), formatInterval(customScheduledRestoreInterval)), action: #selector(toggleCustomRestoreInterval), keyEquivalent: "")
            customIntervalItem.target = self
            customIntervalItem.state = useCustomScheduledRestoreInterval ? .on : .off
            intervalSubmenu.addItem(customIntervalItem)
            
            let intervalMenuItem = NSMenuItem(title: NSLocalizedString("Restore Interval", comment: "Menu item"), action: nil, keyEquivalent: "")
            intervalMenuItem.submenu = intervalSubmenu
            settingsSubmenu.addItem(intervalMenuItem)
        }
        
        settingsSubmenu.addItem(NSMenuItem.separator())
        
        // Auto restore on update
        let autoUpdateItem = NSMenuItem(title: NSLocalizedString("Auto-Restore When Apps Update", comment: "Menu item"), action: #selector(toggleAutoRestoreOnUpdate), keyEquivalent: "")
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
            
            let checkIntervalMenuItem = NSMenuItem(title: NSLocalizedString("Check Interval", comment: "Menu item"), action: nil, keyEquivalent: "")
            checkIntervalMenuItem.submenu = checkIntervalSubmenu
            settingsSubmenu.addItem(checkIntervalMenuItem)
        }
        
        // Settings menu item
        let settingsItem = NSMenuItem(title: NSLocalizedString("Settings", comment: "Menu item"), action: nil, keyEquivalent: ",")
        settingsItem.submenu = settingsSubmenu
        menu.addItem(settingsItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Quit
        let quitItem = NSMenuItem(title: NSLocalizedString("Quit", comment: "Menu item"), action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        quitItem.target = NSApplication.shared
        menu.addItem(quitItem)
        
        // Set the menu
        statusItem?.menu = menu
        statusMenu = menu
    }
    
    /// Purge in-memory image caches to reduce footprint when running in background.
    func purgeImageCaches() {
        Task {
            await IconImageLoader.shared.purgeMemoryCache()
        }
        AppIconCache.shared.removeAll()
        IconFetchCacheManager.shared.clearAllCache()
    }

    // Update dock visibility based on settings
    private func updateDockVisibility() {
        if runInBackground && !showInDock {
            NSApp.setActivationPolicy(.accessory)
            // When going to accessory (no UI), purge image caches to minimize memory.
            purgeImageCaches()
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
            // Calculate the actual time until next restore.
            let intervalHours = getActiveRestoreInterval()
            let intervalSeconds = TimeInterval(intervalHours * 3600)
            let nextRestore = lastScheduledRestore.addingTimeInterval(intervalSeconds)
            let delay = max(60, nextRestore.timeIntervalSinceNow) // at least 60s

            scheduledRestoreTimer = makeOneShotThenRepeatingTimer(
                initialDelay: delay,
                repeatingInterval: intervalSeconds
            ) { [weak self] in
                self?.checkScheduledRestore()
            }
        }

        if enableAutoRestoreOnUpdate {
            let timeInterval = Double(autoRestoreCheckInterval * 60)
            updateCheckTimer = makeRepeatingTimer(interval: timeInterval) { [weak self] in
                self?.checkForAppUpdates()
            }
        }

        // Only run fetch cache cleanup if there are entries, and use a longer interval.
        if IconFetchCacheManager.shared.getCacheCount() > 0 {
            fetchCacheCleanupTimer = makeRepeatingTimer(interval: 900) { [weak self] in
                self?.cleanupFetchCache()
            }
        }
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
        // Use generous leeway (10% of interval, min 30s) so the OS can coalesce wakes.
        let leeway = max(30, Int(interval * 0.10))
        timer.schedule(deadline: .now() + interval, repeating: interval, leeway: .seconds(leeway))
        timer.setEventHandler(handler: handler)
        timer.resume()
        return timer
    }

    /// Creates a timer that fires after `initialDelay`, then repeats every `repeatingInterval`.
    private func makeOneShotThenRepeatingTimer(initialDelay: TimeInterval,
                                               repeatingInterval: TimeInterval,
                                               handler: @escaping @Sendable () -> Void) -> DispatchSourceTimer {
        let timer = DispatchSource.makeTimerSource(queue: timerQueue)
        let leeway = max(30, Int(repeatingInterval * 0.10))
        timer.schedule(deadline: .now() + initialDelay, repeating: repeatingInterval, leeway: .seconds(leeway))
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
                    // Reschedule the timer so the next fire uses the correct interval
                    // relative to the new lastScheduledRestore.
                    setupTimers()
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

                // Show error alert on main actor
                await MainActor.run {
                    let alert = NSAlert()
                    alert.messageText = NSLocalizedString("Icon Restoration Failed", comment: "Alert title")
                    alert.informativeText = error.localizedDescription
                    alert.alertStyle = .warning
                    alert.addButton(withTitle: NSLocalizedString("OK", comment: "Alert button"))
                    alert.runModal()
                }
            }
        }
    }
    
    // Check cached apps for updates — compares each app's modification date
    // against the timestamp when its icon was cached. Only returns apps that
    // were modified AFTER their custom icon was applied.
    private func checkCachedAppsForUpdates() async throws -> [AppItem] {
        let cachedIcons = IconCacheManager.shared.getAllCachedIcons()
        guard !cachedIcons.isEmpty else { return [] }

        // Use the existing app list; only reload if empty.
        let currentApps: [AppItem] = await MainActor.run { iconManager.apps }
        let appMap: [String: AppItem]
        if currentApps.isEmpty {
            let loaded = iconManager.loadAppItems()
            await MainActor.run { iconManager.apps = loaded }
            appMap = Dictionary(uniqueKeysWithValues: loaded.map { ($0.url.universalPath(), $0) })
        } else {
            appMap = Dictionary(uniqueKeysWithValues: currentApps.map { ($0.url.universalPath(), $0) })
        }

        let updatedApps: [AppItem] = cachedIcons.compactMap { cache in
            let appPath = cache.appPath
            guard let appItem = appMap[appPath] else { return nil }

            // Compare the app's modification date against when we cached its icon.
            // If the app was modified after the icon was cached, it likely got updated
            // and needs its custom icon re-applied.
            guard let attributes = try? FileManager.default.attributesOfItem(atPath: appPath),
                  let modDate = attributes[.modificationDate] as? Date,
                  modDate > cache.timestamp else {
                return nil
            }

            return appItem
        }

        return updatedApps
    }
    
    // Restore icons for updated apps and bump their cache timestamps
    private func restoreUpdatedApps(_ apps: [AppItem]) async throws {
        for app in apps {
            let appPath = app.url.universalPath()
            if let _ = IconCacheManager.shared.getIconCache(for: appPath),
               let iconURL = IconCacheManager.shared.getCachedIconURL(for: appPath),
               let image = NSImage(contentsOf: iconURL) {
                try await iconManager.setIconWithoutCaching(image, app: app)
                // Update the cache timestamp so this app isn't detected as
                // "updated" again on the next check cycle.
                IconCacheManager.shared.updateTimestamp(for: appPath)
            }
        }
    }
    
    // Show restoration notification using the modern UserNotifications framework
    private func showRestoreNotification() {
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("Icons Restored", comment: "Notification title")
        content.body = NSLocalizedString("All cached app icons have been successfully restored.", comment: "Notification body")
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
        content.title = NSLocalizedString("App Icons Restored", comment: "Notification title")
        content.body = String(format: NSLocalizedString("%lld updated app(s) had their custom icons restored.", comment: "Notification body"), appCount)
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
        case 1: return NSLocalizedString("Every Hour", comment: "Interval option")
        case 24: return NSLocalizedString("Every Day", comment: "Interval option")
        case 48: return NSLocalizedString("Every 2 Days", comment: "Interval option")
        case 72: return NSLocalizedString("Every 3 Days", comment: "Interval option")
        default: return String(format: NSLocalizedString("Every %lld Hours", comment: "Interval option"), hours)
        }
    }

    // Helper to format minute interval
    func formatMinuteInterval(_ minutes: Int) -> String {
        switch minutes {
        case 1: return NSLocalizedString("Every Minute", comment: "Interval option")
        case 60: return NSLocalizedString("Every Hour", comment: "Interval option")
        case 120: return NSLocalizedString("Every 2 Hours", comment: "Interval option")
        default: return String(format: NSLocalizedString("Every %lld Minutes", comment: "Interval option"), minutes)
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
