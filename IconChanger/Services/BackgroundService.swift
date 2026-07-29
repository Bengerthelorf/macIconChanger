//
//  BackgroundService.swift
//  IconChanger
//

import SwiftUI
import Combine
import LaunchPadManagerDBHelper
import UserNotifications
import ServiceManagement
import os

@MainActor class BackgroundService: ObservableObject {
    static let shared = BackgroundService()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "IconChanger", category: "BackgroundService")

    private static let fetchCacheMaxAge: TimeInterval = 600
    private static let fetchCacheCleanupInterval: TimeInterval = 900

    private var statusItem: NSStatusItem?
    private var statusMenu: NSMenu?

    enum LaunchBehavior: Int, CaseIterable {
        case openWindow = 0
        case hidden = 1
    }

    @Published var launchAtLogin: Bool = false {
        didSet {
            updateLoginItem()
        }
    }

    @Published var launchBehavior: LaunchBehavior = .openWindow {
        didSet {
            UserDefaults.standard.set(launchBehavior.rawValue, forKey: "launchBehavior")
        }
    }

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

    @Published var enableAppearanceIconSwitching: Bool {
        didSet {
            UserDefaults.standard.set(
                enableAppearanceIconSwitching,
                forKey: "enableAppearanceIconSwitching"
            )
            IconAppearanceSwitchService.shared.setEnabled(enableAppearanceIconSwitching)
        }
    }

    @Published var enableScheduledRestore: Bool {
        didSet {
            UserDefaults.standard.set(enableScheduledRestore, forKey: "enableScheduledRestore")
            rescheduleIfRunning(changed: enableScheduledRestore != oldValue)
        }
    }

    @Published var scheduledRestoreInterval: Int {
        didSet {
            UserDefaults.standard.set(scheduledRestoreInterval, forKey: "scheduledRestoreInterval")
            rescheduleIfRunning(changed: scheduledRestoreInterval != oldValue)
        }
    }

    @Published var customScheduledRestoreInterval: Int {
        didSet {
            UserDefaults.standard.set(customScheduledRestoreInterval, forKey: "customScheduledRestoreInterval")
            rescheduleIfRunning(changed: customScheduledRestoreInterval != oldValue)
        }
    }

    @Published var useCustomScheduledRestoreInterval: Bool {
        didSet {
            UserDefaults.standard.set(useCustomScheduledRestoreInterval, forKey: "useCustomScheduledRestoreInterval")
            rescheduleIfRunning(changed: useCustomScheduledRestoreInterval != oldValue)
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
            rescheduleIfRunning(changed: enableAutoRestoreOnUpdate != oldValue)
        }
    }

    @Published var autoRestoreCheckInterval: Int {
        didSet {
            UserDefaults.standard.set(autoRestoreCheckInterval, forKey: "autoRestoreCheckInterval")
            rescheduleIfRunning(changed: autoRestoreCheckInterval != oldValue)
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
    private var isRunning = false
    private let timerQueue = DispatchQueue(label: "com.iconchanger.backgroundservice.timers", qos: .utility)

    private init() {
        self.runInBackground = false
        self.showInDock = true
        self.showInMenuBar = true
        self.enableAppearanceIconSwitching = false
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

        self.enableAppearanceIconSwitching = UserDefaults.standard.bool(
            forKey: "enableAppearanceIconSwitching"
        )

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

        if let raw = UserDefaults.standard.object(forKey: "launchBehavior") as? Int,
           let behavior = LaunchBehavior(rawValue: raw) {
            self.launchBehavior = behavior
        }

        self.launchAtLogin = (SMAppService.mainApp.status == .enabled)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSetupHealthDidChange),
            name: .setupHealthDidChange,
            object: nil
        )
    }

    private func updateLoginItem() {
        let diagnosticsContext = DiagnosticsContext(
            operation: .permission,
            source: .system
        )
        let timer = DiagnosticsTimer()
        do {
            if launchAtLogin {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            DiagnosticsLogger.shared.log(
                .operation,
                phase: "login_item.updated",
                context: diagnosticsContext,
                durationMilliseconds: timer.elapsedMilliseconds,
                details: [
                    "enabled": String(launchAtLogin),
                    "status": String(describing: SMAppService.mainApp.status),
                ]
            )
        } catch {
            logger.error("Failed to update login item: \(error.localizedDescription)")
            DiagnosticsLogger.shared.log(
                .failure,
                phase: "login_item.update_failed",
                context: diagnosticsContext,
                durationMilliseconds: timer.elapsedMilliseconds,
                details: DiagnosticsLogger.errorDetails(error)
            )
        }
    }

    var shouldLaunchHidden: Bool {
        launchAtLogin && launchBehavior == .hidden && runInBackground
    }

    func startBackgroundService() {
        let diagnosticsContext = DiagnosticsContext(
            operation: .background,
            source: .system
        )
        guard !isRunning else {
            DiagnosticsLogger.shared.log(
                .skipped,
                phase: "background_service.already_running",
                context: diagnosticsContext
            )
            return
        }
        isRunning = true

        if showInMenuBar {
            setupStatusBar()
        }

        requestNotificationPermission()
        setupTimers()

        runInBackground = true
        DiagnosticsLogger.shared.log(
            .operation,
            phase: "background_service.started",
            context: diagnosticsContext,
            details: [
                "menu_bar_enabled": String(showInMenuBar),
                "dock_enabled": String(showInDock),
            ]
        )
    }

    private func requestNotificationPermission() {
        let diagnosticsContext = DiagnosticsContext(
            operation: .permission,
            source: .system
        )
        let timer = DiagnosticsTimer()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                self.logger.error("Error requesting notification permission: \(error.localizedDescription)")
                DiagnosticsLogger.shared.log(
                    .failure,
                    phase: "notification_permission.failed",
                    context: diagnosticsContext,
                    durationMilliseconds: timer.elapsedMilliseconds,
                    details: DiagnosticsLogger.errorDetails(error)
                )
            } else {
                DiagnosticsLogger.shared.log(
                    granted ? .operation : .failure,
                    phase: "notification_permission.completed",
                    context: diagnosticsContext,
                    durationMilliseconds: timer.elapsedMilliseconds,
                    details: ["granted": String(granted)]
                )
            }
        }
    }

    func stopBackgroundService() {
        let diagnosticsContext = DiagnosticsContext(
            operation: .background,
            source: .system
        )
        isRunning = false

        if let item = statusItem {
            NSStatusBar.system.removeStatusItem(item)
            statusItem = nil
        }

        cancelTimer(&scheduledRestoreTimer)
        cancelTimer(&updateCheckTimer)
        cancelTimer(&fetchCacheCleanupTimer)

        NSApp.setActivationPolicy(.regular)
        runInBackground = false
        DiagnosticsLogger.shared.log(
            .operation,
            phase: "background_service.stopped",
            context: diagnosticsContext
        )
    }

    private func setupStatusBar() {
        if statusItem == nil {
            statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

            if let button = statusItem?.button {
                let health = SetupMonitor.shared.health
                button.image = NSImage(
                    systemSymbolName: health.statusSymbolName,
                    accessibilityDescription: health.statusDescription
                )
                button.contentTintColor = health.needsAttention ? .systemOrange : nil
            }

            updateStatusMenu()
        }
    }

    @objc private func handleSetupHealthDidChange() {
        let health = SetupMonitor.shared.health
        if let button = statusItem?.button {
            button.image = NSImage(
                systemSymbolName: health.statusSymbolName,
                accessibilityDescription: health.statusDescription
            )
            button.contentTintColor = health.needsAttention ? .systemOrange : nil
        }
        updateStatusMenu()
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
        let setupHealth = SetupMonitor.shared.health
        appInfoItem.image = NSImage(systemSymbolName: setupHealth.statusSymbolName, accessibilityDescription: nil)
        appInfoItem.isEnabled = false
        menu.addItem(appInfoItem)

        let setupStatusItem = NSMenuItem(
            title: setupHealth.statusDescription,
            action: setupHealth.needsAttention ? #selector(openMainWindow(_:)) : nil,
            keyEquivalent: ""
        )
        setupStatusItem.image = NSImage(
            systemSymbolName: setupHealth.statusSymbolName,
            accessibilityDescription: nil
        )
        setupStatusItem.target = setupHealth.needsAttention ? self : nil
        setupStatusItem.isEnabled = setupHealth.needsAttention
        menu.addItem(setupStatusItem)

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

    /// Re-synchronizes observable service state after configuration import.
    func reloadPersistentSettingsAfterImport() {
        let defaults = UserDefaults.standard

        runInBackground = defaults.bool(forKey: "runInBackground")
        showInDock = defaults.object(forKey: "showInDock") as? Bool ?? true
        showInMenuBar = defaults.object(forKey: "showInMenuBar") as? Bool ?? true
        if !showInDock && !showInMenuBar {
            showInMenuBar = true
        }
        enableAppearanceIconSwitching = defaults.bool(forKey: "enableAppearanceIconSwitching")
        enableScheduledRestore = defaults.bool(forKey: "enableScheduledRestore")
        scheduledRestoreInterval = max(1, defaults.integer(forKey: "scheduledRestoreInterval"))
        customScheduledRestoreInterval = max(1, defaults.integer(forKey: "customScheduledRestoreInterval"))
        useCustomScheduledRestoreInterval = defaults.bool(forKey: "useCustomScheduledRestoreInterval")
        enableAutoRestoreOnUpdate = defaults.bool(forKey: "enableAutoRestoreOnUpdate")
        autoRestoreCheckInterval = max(1, defaults.integer(forKey: "autoRestoreCheckInterval"))
        if let raw = defaults.object(forKey: "launchBehavior") as? Int,
           let behavior = LaunchBehavior(rawValue: raw) {
            launchBehavior = behavior
        }

        if runInBackground {
            if !isRunning {
                startBackgroundService()
            } else {
                if showInMenuBar {
                    setupStatusBar()
                } else if let item = statusItem {
                    NSStatusBar.system.removeStatusItem(item)
                    statusItem = nil
                }
                setupTimers()
            }
        } else if isRunning {
            stopBackgroundService()
        }
        updateDockVisibility()
        updateStatusMenu()
    }

    @objc func toggleMenuBarVisibility() {
        showInMenuBar.toggle()

        if showInMenuBar {
            setupStatusBar()
        } else {
            if let item = statusItem {
                NSStatusBar.system.removeStatusItem(item)
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
        updateStatusMenu()
    }

    @objc func toggleAutoRestoreOnUpdate() {
        enableAutoRestoreOnUpdate.toggle()
        updateStatusMenu()
    }

    @objc func toggleCustomRestoreInterval() {
        useCustomScheduledRestoreInterval.toggle()
        updateStatusMenu()
    }

    @objc func setRestoreInterval(_ sender: NSMenuItem) {
        guard let interval = sender.representedObject as? Int else { return }
        scheduledRestoreInterval = interval
        useCustomScheduledRestoreInterval = false
        updateStatusMenu()
    }

    @objc func setCheckInterval(_ sender: NSMenuItem) {
        guard let interval = sender.representedObject as? Int else { return }
        autoRestoreCheckInterval = interval
        updateStatusMenu()
    }

    private func rescheduleIfRunning(changed: Bool) {
        guard changed, isRunning else { return }
        setupTimers()
        updateStatusMenu()
    }

    func setupTimers() {
        let diagnosticsContext = DiagnosticsContext(
            operation: .background,
            source: .system
        )
        cancelTimer(&scheduledRestoreTimer)
        cancelTimer(&updateCheckTimer)
        cancelTimer(&fetchCacheCleanupTimer)

        if enableScheduledRestore {
            let intervalHours = getActiveRestoreInterval()
            let intervalSeconds = TimeInterval(intervalHours * 3600)
            let delay = BackgroundSchedulePolicy.nextDelay(
                interval: intervalSeconds,
                lastRun: lastScheduledRestore,
                minimumDelay: 60
            )

            scheduledRestoreTimer = makeOneShotThenRepeatingTimer(
                initialDelay: delay,
                repeatingInterval: intervalSeconds
            ) { [weak self] in
                DispatchQueue.main.async { self?.checkScheduledRestore() }
            }
        }

        if enableAutoRestoreOnUpdate {
            let timeInterval = Double(autoRestoreCheckInterval * 60)
            let delay = BackgroundSchedulePolicy.nextDelay(
                interval: timeInterval,
                lastRun: lastUpdateCheck,
                minimumDelay: 1
            )
            updateCheckTimer = makeOneShotThenRepeatingTimer(
                initialDelay: delay,
                repeatingInterval: timeInterval
            ) { [weak self] in
                DispatchQueue.main.async { self?.checkForAppUpdates() }
            }
        }

        if IconFetchCacheManager.shared.getCacheCount() > 0 {
            fetchCacheCleanupTimer = makeRepeatingTimer(interval: Self.fetchCacheCleanupInterval) { [weak self] in
                DispatchQueue.main.async { self?.cleanupFetchCache() }
            }
        }
        DiagnosticsLogger.shared.log(
            .operation,
            phase: "background_timers.configured",
            context: diagnosticsContext,
            details: [
                "scheduled_restore_enabled": String(enableScheduledRestore),
                "scheduled_restore_interval_hours": String(getActiveRestoreInterval()),
                "update_detection_enabled": String(enableAutoRestoreOnUpdate),
                "update_check_interval_minutes": String(autoRestoreCheckInterval),
                "fetch_cache_cleanup_enabled": String(
                    IconFetchCacheManager.shared.getCacheCount() > 0
                ),
            ]
        )
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
        let diagnosticsContext = DiagnosticsContext(
            operation: .background,
            source: .scheduled
        )
        guard enableScheduledRestore else {
            DiagnosticsLogger.shared.log(
                .skipped,
                phase: "scheduled_restore.disabled",
                context: diagnosticsContext
            )
            return
        }

        let interval = getActiveRestoreInterval()
        let timeInterval = TimeInterval(interval * 3600)
        let nextRestoreTime = lastScheduledRestore.addingTimeInterval(timeInterval)

        if Date() >= nextRestoreTime {
            DiagnosticsLogger.shared.log(
                .operation,
                phase: "scheduled_restore.due",
                context: diagnosticsContext
            )
            performScheduledRestore()
        } else {
            DiagnosticsLogger.shared.log(
                .skipped,
                phase: "scheduled_restore.not_due",
                context: diagnosticsContext,
                details: [
                    "seconds_until_due": String(
                        max(0, Int(nextRestoreTime.timeIntervalSinceNow))
                    )
                ]
            )
        }
    }

    @objc func checkForAppUpdates() {
        let diagnosticsContext = DiagnosticsContext(
            operation: .background,
            source: .appUpdate
        )
        let timer = DiagnosticsTimer()
        guard enableAutoRestoreOnUpdate else {
            DiagnosticsLogger.shared.log(
                .skipped,
                phase: "app_update_check.disabled",
                context: diagnosticsContext
            )
            return
        }
        DiagnosticsLogger.shared.log(
            .operation,
            phase: "app_update_check.start",
            context: diagnosticsContext,
            details: [
                "cached_app_count": String(
                    IconCacheManager.shared.getCachedIconsCount()
                )
            ]
        )

        Task {
            do {
                let updatedApps = try await checkCachedAppsForUpdates()
                DiagnosticsLogger.shared.log(
                    .step,
                    phase: "app_update_check.scan_completed",
                    context: diagnosticsContext,
                    details: ["updated_app_count": String(updatedApps.count)]
                )

                if !updatedApps.isEmpty {
                    try await restoreUpdatedApps(updatedApps)
                    showUpdateNotification(appCount: updatedApps.count)
                } else {
                    DiagnosticsLogger.shared.log(
                        .skipped,
                        phase: "app_update_check.no_updates",
                        context: diagnosticsContext
                    )
                }

                await MainActor.run {
                    lastUpdateCheck = Date()
                }
                DiagnosticsLogger.shared.log(
                    .operation,
                    phase: "app_update_check.completed",
                    context: diagnosticsContext,
                    durationMilliseconds: timer.elapsedMilliseconds,
                    details: ["updated_app_count": String(updatedApps.count)]
                )
            } catch {
                logger.error("Error checking for app updates: \(error.localizedDescription)")
                DiagnosticsLogger.shared.log(
                    .failure,
                    phase: "app_update_check.failed",
                    context: diagnosticsContext,
                    durationMilliseconds: timer.elapsedMilliseconds,
                    details: DiagnosticsLogger.errorDetails(error)
                )
                handleBackgroundSetupFailure()
            }
        }
    }

    private func performScheduledRestore() {
        let diagnosticsContext = DiagnosticsContext(
            operation: .background,
            source: .scheduled
        )
        let timer = DiagnosticsTimer()
        DiagnosticsLogger.shared.log(
            .operation,
            phase: "scheduled_restore.start",
            context: diagnosticsContext
        )
        Task {
            do {
                let result = try await iconManager.restoreAllCachedIcons(
                    allowRepair: false,
                    source: .scheduled
                )

                await MainActor.run {
                    lastScheduledRestore = Date()
                    updateStatusMenu()
                    setupTimers()
                }

                showRestoreNotification()
                DiagnosticsLogger.shared.log(
                    .operation,
                    phase: "scheduled_restore.completed",
                    context: diagnosticsContext,
                    durationMilliseconds: timer.elapsedMilliseconds,
                    details: [
                        "restored": String(result.restored),
                        "skipped_not_installed": String(result.skippedNotInstalled),
                        "failed": String(result.failed.count),
                    ]
                )
            } catch {
                logger.error("Scheduled restore failed: \(error.localizedDescription)")
                DiagnosticsLogger.shared.log(
                    .failure,
                    phase: "scheduled_restore.failed",
                    context: diagnosticsContext,
                    durationMilliseconds: timer.elapsedMilliseconds,
                    details: DiagnosticsLogger.errorDetails(error)
                )
                handleBackgroundSetupFailure()
            }
        }
    }

    private func handleBackgroundSetupFailure() {
        SetupMonitor.shared.check { [weak self] health in
            guard health.needsAttention else { return }
            self?.showSetupFailureNotification(health: health)
        }
    }

    private func showSetupFailureNotification(health: SetupHealth) {
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("IconChanger Needs Attention", comment: "Setup notification title")
        content.body = String(
            format: NSLocalizedString("%@. Open IconChanger to repair setup.", comment: "Setup notification body"),
            health.statusDescription
        )
        content.sound = UNNotificationSound.default
        content.userInfo = ["action": "openSetup"]

        let request = UNNotificationRequest(
            identifier: "iconchanger.setup.needed",
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                self.logger.error("Error showing setup notification: \(error.localizedDescription)")
            }
        }
    }

    @objc func restoreCachedIcons() {
        Task {
            do {
                let _ = try await iconManager.restoreAllCachedIcons()
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

        let updatedApps: [AppItem] = cachedIcons.compactMap { cache in
            let appPath = cache.appPath
            guard FileManager.default.fileExists(atPath: appPath) else { return nil }

            let attributes = try? FileManager.default.attributesOfItem(atPath: appPath)
            let modificationDate = attributes?[.modificationDate] as? Date
            guard CachedAppUpdatePolicy.hasUpdate(
                cachedVersion: cache.appVersion,
                currentVersion: IconCache.currentVersion(for: appPath),
                cachedAt: cache.timestamp,
                modifiedAt: modificationDate
            ) else { return nil }

            return AppItem(
                name: cache.appName,
                url: URL(fileURLWithPath: appPath),
                originalAppInfo: nil
            )
        }

        return updatedApps
    }

    private func restoreUpdatedApps(_ apps: [AppItem]) async throws {
        var restored = 0
        for app in apps {
            if try await iconManager.restoreCachedIcon(
                for: app,
                allowRepair: false,
                refreshDock: false,
                source: .appUpdate
            ) {
                restored += 1
            }
        }
        if restored > 0 {
            _ = await DockRefreshService.refreshTwice()
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
        IconFetchCacheManager.shared.clearExpiredCache(olderThan: Self.fetchCacheMaxAge)
    }
}
