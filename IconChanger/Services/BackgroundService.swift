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
import UserNotifications
import os

class BackgroundService: ObservableObject {
    static let shared = BackgroundService()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "BackgroundService")

    private var statusItem: NSStatusItem?
    private var statusMenu: NSMenu?

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

    private let iconManager = IconManager.shared

    private static let shortDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .short
        return f
    }()

    private var scheduledRestoreTimer: DispatchSourceTimer?
    private var updateCheckTimer: DispatchSourceTimer?
    private var fetchCacheCleanupTimer: DispatchSourceTimer?
    private let timerQueue = DispatchQueue(label: "com.iconchanger.backgroundservice.timers", qos: .utility)

    private init() {
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
    }

    func startBackgroundService() {
        if showInMenuBar {
            setupStatusBar()
        }

        requestNotificationPermission()
        setupTimers()

        runInBackground = true
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                self.logger.error("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
    }

    func stopBackgroundService() {
        if statusItem != nil {
            NSStatusBar.system.removeStatusItem(statusItem!)
            statusItem = nil
        }

        cancelTimer(&scheduledRestoreTimer)
        cancelTimer(&updateCheckTimer)
        cancelTimer(&fetchCacheCleanupTimer)

        NSApp.setActivationPolicy(.regular)
        runInBackground = false
    }

    private func setupStatusBar() {
        if statusItem == nil {
            statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

            if let button = statusItem?.button {
                button.image = NSImage(systemSymbolName: "app.badge.checkmark.fill", accessibilityDescription: "IconChanger")
            }

            updateStatusMenu()
        }
    }

    @objc func openMainWindow(_ sender: Any?) {
        NSApp.setActivationPolicy(.regular)

        // If there's still a window alive, just show it
        if let window = NSApp.windows.first(where: { $0.canBecomeMain }) {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let config = NSWorkspace.OpenConfiguration()
        config.activates = true
        NSWorkspace.shared.openApplication(
            at: Bundle.main.bundleURL,
            configuration: config
        ) { _, _ in }
    }

    func handleLastWindowClosed() {
        guard runInBackground else { return }
        if !showInDock {
            NSApp.setActivationPolicy(.accessory)
        }
        purgeImageCaches()
    }

    func updateStatusMenu() {
        let menu = NSMenu()

        let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "IconChanger"
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let appInfoItem = NSMenuItem(title: "\(appName) \(appVersion)", action: nil, keyEquivalent: "")
        appInfoItem.image = NSImage(systemSymbolName: "app.badge.checkmark.fill", accessibilityDescription: nil)
        appInfoItem.isEnabled = false
        menu.addItem(appInfoItem)

        menu.addItem(NSMenuItem.separator())

        let openItem = NSMenuItem(title: NSLocalizedString("Open IconChanger", comment: "Menu item"), action: #selector(openMainWindow(_:)), keyEquivalent: "o")
        openItem.image = NSImage(systemSymbolName: "macwindow", accessibilityDescription: nil)
        openItem.target = self
        menu.addItem(openItem)

        let cachedCount = IconCacheManager.shared.getCachedIconsCount()
        let cachedCountItem = NSMenuItem(title: String(format: NSLocalizedString("Cached Icons: %lld", comment: "Menu item"), cachedCount), action: nil, keyEquivalent: "")
        cachedCountItem.image = NSImage(systemSymbolName: "square.stack.3d.up", accessibilityDescription: nil)
        cachedCountItem.isEnabled = false
        menu.addItem(cachedCountItem)

        menu.addItem(NSMenuItem.separator())

        let restoreItem = NSMenuItem(title: NSLocalizedString("Restore Cached Icons", comment: "Menu item"), action: #selector(restoreCachedIcons), keyEquivalent: "r")
        restoreItem.image = NSImage(systemSymbolName: "arrow.clockwise", accessibilityDescription: nil)
        restoreItem.target = self
        menu.addItem(restoreItem)

        if lastScheduledRestore != Date.distantPast {
            let lastRestoreItem = NSMenuItem(title: String(format: NSLocalizedString("Last Restore: %@", comment: "Menu item"), Self.shortDateFormatter.string(from: lastScheduledRestore)), action: nil, keyEquivalent: "")
            lastRestoreItem.image = NSImage(systemSymbolName: "clock", accessibilityDescription: nil)
            lastRestoreItem.isEnabled = false
            menu.addItem(lastRestoreItem)
        }

        menu.addItem(NSMenuItem.separator())

        let settingsSubmenu = NSMenu()

        let menuBarItem = NSMenuItem(title: NSLocalizedString("Show in Menu Bar", comment: "Menu item"), action: #selector(toggleMenuBarVisibility), keyEquivalent: "")
        menuBarItem.image = NSImage(systemSymbolName: "menubar.rectangle", accessibilityDescription: nil)
        menuBarItem.target = self
        menuBarItem.state = showInMenuBar ? .on : .off
        settingsSubmenu.addItem(menuBarItem)

        let dockItem = NSMenuItem(title: NSLocalizedString("Show in Dock", comment: "Menu item"), action: #selector(toggleDockVisibility), keyEquivalent: "")
        dockItem.image = NSImage(systemSymbolName: "dock.rectangle", accessibilityDescription: nil)
        dockItem.target = self
        dockItem.state = showInDock ? .on : .off
        settingsSubmenu.addItem(dockItem)

        settingsSubmenu.addItem(NSMenuItem.separator())

        let autoRestoreItem = NSMenuItem(title: NSLocalizedString("Auto-Restore on Schedule", comment: "Menu item"), action: #selector(toggleScheduledRestore), keyEquivalent: "")
        autoRestoreItem.image = NSImage(systemSymbolName: "calendar.badge.clock", accessibilityDescription: nil)
        autoRestoreItem.target = self
        autoRestoreItem.state = enableScheduledRestore ? .on : .off
        settingsSubmenu.addItem(autoRestoreItem)

        if enableScheduledRestore {
            let intervalSubmenu = NSMenu()

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

            intervalSubmenu.addItem(NSMenuItem.separator())

            let customIntervalItem = NSMenuItem(title: String(format: NSLocalizedString("Custom: %@", comment: "Menu item"), formatInterval(customScheduledRestoreInterval)), action: #selector(toggleCustomRestoreInterval), keyEquivalent: "")
            customIntervalItem.target = self
            customIntervalItem.state = useCustomScheduledRestoreInterval ? .on : .off
            intervalSubmenu.addItem(customIntervalItem)

            let intervalMenuItem = NSMenuItem(title: NSLocalizedString("Restore Interval", comment: "Menu item"), action: nil, keyEquivalent: "")
            intervalMenuItem.image = NSImage(systemSymbolName: "timer", accessibilityDescription: nil)
            intervalMenuItem.submenu = intervalSubmenu
            settingsSubmenu.addItem(intervalMenuItem)
        }

        settingsSubmenu.addItem(NSMenuItem.separator())

        let autoUpdateItem = NSMenuItem(title: NSLocalizedString("Auto-Restore When Apps Update", comment: "Menu item"), action: #selector(toggleAutoRestoreOnUpdate), keyEquivalent: "")
        autoUpdateItem.image = NSImage(systemSymbolName: "arrow.triangle.2.circlepath", accessibilityDescription: nil)
        autoUpdateItem.target = self
        autoUpdateItem.state = enableAutoRestoreOnUpdate ? .on : .off
        settingsSubmenu.addItem(autoUpdateItem)

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
            checkIntervalMenuItem.image = NSImage(systemSymbolName: "timer", accessibilityDescription: nil)
            checkIntervalMenuItem.submenu = checkIntervalSubmenu
            settingsSubmenu.addItem(checkIntervalMenuItem)
        }

        let settingsItem = NSMenuItem(title: NSLocalizedString("Settings", comment: "Menu item"), action: nil, keyEquivalent: ",")
        settingsItem.image = NSImage(systemSymbolName: "gearshape", accessibilityDescription: nil)
        settingsItem.submenu = settingsSubmenu
        menu.addItem(settingsItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: NSLocalizedString("Quit", comment: "Menu item"), action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        quitItem.image = NSImage(systemSymbolName: "power", accessibilityDescription: nil)
        quitItem.target = NSApplication.shared
        menu.addItem(quitItem)

        statusItem?.menu = menu
        statusMenu = menu
    }

    func purgeImageCaches() {
        Task {
            await IconImageLoader.shared.purgeMemoryCache()
        }
        AppIconCache.shared.removeAll()
        IconFetchCacheManager.shared.clearAllCache()
    }

    private func updateDockVisibility() {
        let hasVisibleWindow = NSApp.windows.contains(where: { $0.isVisible && $0.canBecomeMain })
        if runInBackground && !showInDock && !hasVisibleWindow {
            NSApp.setActivationPolicy(.accessory)
        } else {
            NSApp.setActivationPolicy(.regular)
        }
    }

    @objc func toggleMenuBarVisibility() {
        showInMenuBar.toggle()

        if showInMenuBar {
            setupStatusBar()
        } else {
            if statusItem != nil {
                NSStatusBar.system.removeStatusItem(statusItem!)
                statusItem = nil
            }

            if !showInDock {
                showInDock = true
                updateDockVisibility()
            }
        }

        updateStatusMenu()
    }

    @objc func toggleDockVisibility() {
        showInDock.toggle()

        if !showInDock && !showInMenuBar {
            showInMenuBar = true
            setupStatusBar()
        }

        updateDockVisibility()
        updateStatusMenu()
    }

    @objc func toggleScheduledRestore() {
        enableScheduledRestore.toggle()
        setupTimers()
        updateStatusMenu()
    }

    @objc func toggleAutoRestoreOnUpdate() {
        enableAutoRestoreOnUpdate.toggle()
        setupTimers()
        updateStatusMenu()
    }

    @objc func toggleCustomRestoreInterval() {
        useCustomScheduledRestoreInterval.toggle()
        setupTimers()
        updateStatusMenu()
    }

    @objc func setRestoreInterval(_ sender: NSMenuItem) {
        guard let interval = sender.representedObject as? Int else { return }
        scheduledRestoreInterval = interval
        useCustomScheduledRestoreInterval = false
        setupTimers()
        updateStatusMenu()
    }

    @objc func setCheckInterval(_ sender: NSMenuItem) {
        guard let interval = sender.representedObject as? Int else { return }
        autoRestoreCheckInterval = interval
        setupTimers()
        updateStatusMenu()
    }

    func setupTimers() {
        cancelTimer(&scheduledRestoreTimer)
        cancelTimer(&updateCheckTimer)
        cancelTimer(&fetchCacheCleanupTimer)

        if enableScheduledRestore {
            let intervalHours = getActiveRestoreInterval()
            let intervalSeconds = TimeInterval(intervalHours * 3600)
            let nextRestore = lastScheduledRestore.addingTimeInterval(intervalSeconds)
            let delay = max(60, nextRestore.timeIntervalSinceNow)

            scheduledRestoreTimer = makeOneShotThenRepeatingTimer(
                initialDelay: delay,
                repeatingInterval: intervalSeconds
            ) { [weak self] in
                DispatchQueue.main.async { self?.checkScheduledRestore() }
            }
        }

        if enableAutoRestoreOnUpdate {
            let timeInterval = Double(autoRestoreCheckInterval * 60)
            updateCheckTimer = makeRepeatingTimer(interval: timeInterval) { [weak self] in
                DispatchQueue.main.async { self?.checkForAppUpdates() }
            }
        }

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
        let leeway = max(30, Int(interval * 0.10))
        timer.schedule(deadline: .now() + interval, repeating: interval, leeway: .seconds(leeway))
        timer.setEventHandler(handler: handler)
        timer.resume()
        return timer
    }

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

    func getActiveRestoreInterval() -> Int {
        return useCustomScheduledRestoreInterval ? customScheduledRestoreInterval : scheduledRestoreInterval
    }

    @objc func checkScheduledRestore() {
        guard enableScheduledRestore else { return }

        let interval = getActiveRestoreInterval()
        let timeInterval = TimeInterval(interval * 3600)
        let nextRestoreTime = lastScheduledRestore.addingTimeInterval(timeInterval)

        if Date() >= nextRestoreTime {
            performScheduledRestore()
        }
    }

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
                logger.error("Error checking for app updates: \(error.localizedDescription)")
            }
        }
    }

    private func performScheduledRestore() {
        Task {
            do {
                try await iconManager.restoreAllCachedIcons()

                await MainActor.run {
                    lastScheduledRestore = Date()
                    updateStatusMenu()
                    setupTimers()
                }

                showRestoreNotification()
            } catch {
                logger.error("Scheduled restore failed: \(error.localizedDescription)")
            }
        }
    }

    @objc func restoreCachedIcons() {
        Task {
            do {
                try await iconManager.restoreAllCachedIcons()
                await MainActor.run {
                    lastScheduledRestore = Date()
                }
                updateStatusMenu()
                showRestoreNotification()
            } catch {
                logger.error("Manual restore failed: \(error.localizedDescription)")

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

    private func checkCachedAppsForUpdates() async throws -> [AppItem] {
        let cachedIcons = IconCacheManager.shared.getAllCachedIcons()
        guard !cachedIcons.isEmpty else { return [] }

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

            guard let attributes = try? FileManager.default.attributesOfItem(atPath: appPath),
                  let modDate = attributes[.modificationDate] as? Date,
                  modDate > cache.timestamp else {
                return nil
            }

            return appItem
        }

        return updatedApps
    }

    private func restoreUpdatedApps(_ apps: [AppItem]) async throws {
        for app in apps {
            let appPath = app.url.universalPath()
            if let _ = IconCacheManager.shared.getIconCache(for: appPath),
               let iconURL = IconCacheManager.shared.getCachedIconURL(for: appPath),
               let image = NSImage(contentsOf: iconURL) {
                try await iconManager.setIconWithoutCaching(image, app: app)
                IconCacheManager.shared.updateTimestamp(for: appPath)
            }
        }
    }

    private func showRestoreNotification() {
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("Icons Restored", comment: "Notification title")
        content.body = NSLocalizedString("All cached app icons have been successfully restored.", comment: "Notification body")
        content.sound = UNNotificationSound.default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                self.logger.error("Error showing notification: \(error.localizedDescription)")
            }
        }
    }

    private func showUpdateNotification(appCount: Int) {
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("App Icons Restored", comment: "Notification title")
        content.body = String(format: NSLocalizedString("%lld updated app(s) had their custom icons restored.", comment: "Notification body"), appCount)
        content.sound = UNNotificationSound.default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                self.logger.error("Error showing notification: \(error.localizedDescription)")
            }
        }
    }

    func formatInterval(_ hours: Int) -> String {
        switch hours {
        case 1: return NSLocalizedString("Every Hour", comment: "Interval option")
        case 24: return NSLocalizedString("Every Day", comment: "Interval option")
        case 48: return NSLocalizedString("Every 2 Days", comment: "Interval option")
        case 72: return NSLocalizedString("Every 3 Days", comment: "Interval option")
        default: return String(format: NSLocalizedString("Every %lld Hours", comment: "Interval option"), hours)
        }
    }

    func formatMinuteInterval(_ minutes: Int) -> String {
        switch minutes {
        case 1: return NSLocalizedString("Every Minute", comment: "Interval option")
        case 60: return NSLocalizedString("Every Hour", comment: "Interval option")
        case 120: return NSLocalizedString("Every 2 Hours", comment: "Interval option")
        default: return String(format: NSLocalizedString("Every %lld Minutes", comment: "Interval option"), minutes)
        }
    }

    // MARK: - Icon Fetch Cache Cleanup

    @objc func cleanupFetchCache() {
        let maxAge: TimeInterval = 600
        IconFetchCacheManager.shared.clearExpiredCache(olderThan: maxAge)
    }
}
