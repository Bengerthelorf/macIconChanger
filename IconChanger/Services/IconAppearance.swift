import AppKit
import Foundation
import OSLog

extension Notification.Name {
    static let appearanceIconStoreDidChange = Notification.Name("IconChanger.AppearanceIconStoreDidChange")
}

final class AppearanceIconStore {
    static let shared = AppearanceIconStore()

    private let directory: URL
    private let metadataURL: URL
    private let fileManager: FileManager
    private let logger = Logger(subsystem: AppPaths.bundleID, category: "AppearanceIconStore")
    private let lock = NSLock()
    private var configurations: [String: AppearanceIconConfiguration] = [:]

    init(
        directory: URL = AppPaths.appearanceIconsDirectory,
        metadataURL: URL = AppPaths.appearanceIconsMetadataFile,
        fileManager: FileManager = .default
    ) {
        self.directory = directory
        self.metadataURL = metadataURL
        self.fileManager = fileManager
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        load()
    }

    func getAllConfigurations() -> [AppearanceIconConfiguration] {
        lock.lock()
        defer { lock.unlock() }
        return Array(configurations.values)
    }

    func configuration(for appPath: String) -> AppearanceIconConfiguration? {
        lock.lock()
        defer { lock.unlock() }
        return configurations[appPath]
    }

    func iconURL(
        for appPath: String,
        appearance: IconAppearance
    ) -> URL? {
        lock.lock()
        defer { lock.unlock() }
        guard let fileName = configurations[appPath]?.fileName(for: appearance) else {
            return nil
        }
        return directory.appendingPathComponent(fileName)
    }

    @discardableResult
    func assign(
        image: NSImage,
        appPath: String,
        appName: String,
        appearance: IconAppearance
    ) throws -> AppearanceIconConfiguration {
        let newFileName = "\(UUID().uuidString).png"
        let newURL = directory.appendingPathComponent(newFileName)

        if let saveError = IconManager.saveImage(image, atUrl: newURL) {
            throw saveError
        }
        try? fileManager.setAttributes([.posixPermissions: 0o600], ofItemAtPath: newURL.path)

        lock.lock()
        var updated = configurations[appPath] ?? AppearanceIconConfiguration(
            appPath: appPath,
            appName: appName,
            lightIconFileName: nil,
            darkIconFileName: nil,
            lastAppliedAppearance: nil,
            updatedAt: Date()
        )
        let oldURL = updated.fileName(for: appearance).map {
            directory.appendingPathComponent($0)
        }
        updated.appName = appName
        updated.setFileName(newFileName, for: appearance)
        updated.lastAppliedAppearance = nil
        updated.updatedAt = Date()

        var snapshot = configurations
        snapshot[appPath] = updated

        do {
            try persist(snapshot)
            configurations = snapshot
            lock.unlock()
        } catch {
            lock.unlock()
            try? fileManager.removeItem(at: newURL)
            throw error
        }

        if let oldURL, oldURL != newURL {
            try? fileManager.removeItem(at: oldURL)
        }
        notifyChange()
        return updated
    }

    func markApplied(_ appearance: IconAppearance, for appPath: String) {
        lock.lock()
        guard var configuration = configurations[appPath] else {
            lock.unlock()
            return
        }
        configuration.lastAppliedAppearance = appearance
        configuration.updatedAt = Date()
        var snapshot = configurations
        snapshot[appPath] = configuration
        do {
            try persist(snapshot)
            configurations = snapshot
            lock.unlock()
            notifyChange()
        } catch {
            lock.unlock()
            logger.error("Failed to persist applied appearance: \(error.localizedDescription, privacy: .public)")
        }
    }

    func resetAppliedAppearance(for appPath: String) {
        lock.lock()
        guard var configuration = configurations[appPath],
              configuration.lastAppliedAppearance != nil else {
            lock.unlock()
            return
        }
        configuration.lastAppliedAppearance = nil
        configuration.updatedAt = Date()
        var snapshot = configurations
        snapshot[appPath] = configuration
        do {
            try persist(snapshot)
            configurations = snapshot
            lock.unlock()
            notifyChange()
        } catch {
            lock.unlock()
            logger.error("Failed to reset applied appearance: \(error.localizedDescription, privacy: .public)")
        }
    }

    /// Adds only missing light/dark slots and never overwrites local choices.
    @discardableResult
    func importSlots(
        appPath: String,
        appName: String,
        lightIconData: Data?,
        darkIconData: Data?
    ) throws -> Int {
        let candidates: [(IconAppearance, NSImage)] = [
            lightIconData.flatMap(NSImage.init(data:)).map { (.light, $0) },
            darkIconData.flatMap(NSImage.init(data:)).map { (.dark, $0) }
        ].compactMap { $0 }
        guard !candidates.isEmpty else { return 0 }

        lock.lock()
        var updated = configurations[appPath] ?? AppearanceIconConfiguration(
            appPath: appPath,
            appName: appName,
            lightIconFileName: nil,
            darkIconFileName: nil,
            lastAppliedAppearance: nil,
            updatedAt: Date()
        )
        let missing = candidates.filter { updated.fileName(for: $0.0) == nil }
        lock.unlock()
        guard !missing.isEmpty else { return 0 }

        var written: [(IconAppearance, String, URL)] = []
        do {
            for (appearance, image) in missing {
                let fileName = "\(UUID().uuidString).png"
                let url = directory.appendingPathComponent(fileName)
                if let error = IconManager.saveImage(image, atUrl: url) {
                    throw error
                }
                try? fileManager.setAttributes([.posixPermissions: 0o600], ofItemAtPath: url.path)
                written.append((appearance, fileName, url))
            }

            lock.lock()
            updated = configurations[appPath] ?? AppearanceIconConfiguration(
                appPath: appPath,
                appName: appName,
                lightIconFileName: nil,
                darkIconFileName: nil,
                lastAppliedAppearance: nil,
                updatedAt: Date()
            )
            var accepted = 0
            for (appearance, fileName, _) in written where updated.fileName(for: appearance) == nil {
                updated.setFileName(fileName, for: appearance)
                accepted += 1
            }
            updated.appName = appName
            updated.lastAppliedAppearance = nil
            updated.updatedAt = Date()
            var snapshot = configurations
            snapshot[appPath] = updated
            do {
                try persist(snapshot)
                configurations = snapshot
                lock.unlock()
            } catch {
                lock.unlock()
                throw error
            }

            let acceptedNames = Set(IconAppearance.allCases.compactMap {
                updated.fileName(for: $0)
            })
            for (_, name, url) in written where !acceptedNames.contains(name) {
                try? fileManager.removeItem(at: url)
            }
            notifyChange()
            return accepted
        } catch {
            if lock.try() {
                lock.unlock()
            }
            for (_, _, url) in written {
                try? fileManager.removeItem(at: url)
            }
            throw error
        }
    }

    func removeSlot(for appPath: String, appearance: IconAppearance) {
        lock.lock()
        guard var configuration = configurations[appPath] else {
            lock.unlock()
            return
        }
        let fileURL = configuration.fileName(for: appearance).map {
            directory.appendingPathComponent($0)
        }
        configuration.setFileName(nil, for: appearance)
        configuration.lastAppliedAppearance = nil
        configuration.updatedAt = Date()

        var snapshot = configurations
        if configuration.isEmpty {
            snapshot.removeValue(forKey: appPath)
        } else {
            snapshot[appPath] = configuration
        }
        do {
            try persist(snapshot)
            configurations = snapshot
            lock.unlock()
            if let fileURL {
                try? fileManager.removeItem(at: fileURL)
            }
            notifyChange()
        } catch {
            lock.unlock()
            logger.error("Failed to remove appearance slot: \(error.localizedDescription, privacy: .public)")
        }
    }

    func removeConfiguration(for appPath: String) {
        lock.lock()
        guard let configuration = configurations[appPath] else {
            lock.unlock()
            return
        }
        let urls = IconAppearance.allCases.compactMap { appearance in
            configuration.fileName(for: appearance).map {
                directory.appendingPathComponent($0)
            }
        }
        var snapshot = configurations
        snapshot.removeValue(forKey: appPath)
        do {
            try persist(snapshot)
            configurations = snapshot
            lock.unlock()
            for url in urls {
                try? fileManager.removeItem(at: url)
            }
            notifyChange()
        } catch {
            lock.unlock()
            logger.error("Failed to remove appearance configuration: \(error.localizedDescription, privacy: .public)")
        }
    }

    func clearAll() {
        lock.lock()
        let urls = configurations.values.flatMap { configuration in
            IconAppearance.allCases.compactMap { appearance in
                configuration.fileName(for: appearance).map {
                    directory.appendingPathComponent($0)
                }
            }
        }
        do {
            try persist([:])
            configurations = [:]
            lock.unlock()
            for url in urls {
                try? fileManager.removeItem(at: url)
            }
            notifyChange()
        } catch {
            lock.unlock()
            logger.error("Failed to clear appearance configurations: \(error.localizedDescription, privacy: .public)")
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: metadataURL) else { return }
        do {
            let decoded = try JSONDecoder().decode(
                [String: AppearanceIconConfiguration].self,
                from: data
            )
            configurations = decoded
        } catch {
            logger.error("Failed to load appearance icon metadata: \(error.localizedDescription, privacy: .public)")
        }
    }

    private func persist(_ snapshot: [String: AppearanceIconConfiguration]) throws {
        let data = try JSONEncoder().encode(snapshot)
        try data.write(to: metadataURL, options: .atomic)
        try fileManager.setAttributes([.posixPermissions: 0o600], ofItemAtPath: metadataURL.path)
    }

    private func notifyChange() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .appearanceIconStoreDidChange, object: nil)
        }
    }
}

@MainActor
final class SystemAppearanceMonitor {
    static let shared = SystemAppearanceMonitor()

    private var distributedObserver: NSObjectProtocol?
    private var activationObserver: NSObjectProtocol?
    private var handler: ((IconAppearance) -> Void)?
    private(set) var currentAppearance: IconAppearance

    private init() {
        currentAppearance = SystemAppearanceMonitor.readAppearance()
    }

    func start(handler: @escaping (IconAppearance) -> Void) {
        stop()
        self.handler = handler
        currentAppearance = Self.readAppearance()

        distributedObserver = DistributedNotificationCenter.default().addObserver(
            forName: Notification.Name("AppleInterfaceThemeChangedNotification"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.refresh()
            }
        }

        activationObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.refresh()
            }
        }
    }

    func stop() {
        if let distributedObserver {
            DistributedNotificationCenter.default().removeObserver(distributedObserver)
        }
        if let activationObserver {
            NotificationCenter.default.removeObserver(activationObserver)
        }
        distributedObserver = nil
        activationObserver = nil
        handler = nil
    }

    func refresh() {
        let appearance = Self.readAppearance()
        currentAppearance = appearance
        handler?(appearance)
    }

    nonisolated static func readAppearance(
        globalDomain: [String: Any]? = nil
    ) -> IconAppearance {
        let domain = globalDomain ?? UserDefaults.standard.persistentDomain(
            forName: UserDefaults.globalDomain
        ) ?? [:]
        let style = domain["AppleInterfaceStyle"] as? String
        return style?.caseInsensitiveCompare("Dark") == .orderedSame ? .dark : .light
    }
}

enum DockRefreshService {
    static let intervalNanoseconds: UInt64 = 1_000_000_000

    static func refreshTwice(
        diagnosticsContext: DiagnosticsContext? = nil
    ) async -> Bool {
        let timer = DiagnosticsTimer()
        if let diagnosticsContext {
            DiagnosticsLogger.shared.log(
                .step,
                phase: "dock_refresh.start",
                context: diagnosticsContext
            )
        }
        let firstSucceeded = await restartOnce()
        guard !Task.isCancelled else { return false }
        try? await Task.sleep(nanoseconds: intervalNanoseconds)
        guard !Task.isCancelled else { return false }
        let secondSucceeded = await restartOnce()
        let succeeded = firstSucceeded && secondSucceeded
        if let diagnosticsContext {
            DiagnosticsLogger.shared.log(
                .performance,
                phase: succeeded ? "dock_refresh.finish" : "dock_refresh.partial_failure",
                context: diagnosticsContext,
                durationMilliseconds: timer.elapsedMilliseconds,
                details: [
                    "first_restart": String(firstSucceeded),
                    "second_restart": String(secondSucceeded),
                ]
            )
        }
        return succeeded
    }

    private static func restartOnce() async -> Bool {
        await Task.detached(priority: .utility) {
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/usr/bin/killall")
            task.arguments = ["Dock"]
            do {
                try task.run()
                task.waitUntilExit()
                return task.terminationStatus == 0
            } catch {
                return false
            }
        }.value
    }
}

@MainActor
final class IconAppearanceSwitchService: ObservableObject {
    static let shared = IconAppearanceSwitchService(
        store: .shared,
        monitor: .shared,
        iconManager: .shared
    )

    @Published private(set) var isSwitching = false
    @Published private(set) var failedApplicationCount = 0

    private let store: AppearanceIconStore
    private let monitor: SystemAppearanceMonitor
    private let iconManager: IconManager
    private let logger = Logger(subsystem: AppPaths.bundleID, category: "IconAppearanceSwitch")
    private var switchingEnabled = false
    private var switchTask: Task<Void, Never>?

    init(
        store: AppearanceIconStore,
        monitor: SystemAppearanceMonitor,
        iconManager: IconManager
    ) {
        self.store = store
        self.monitor = monitor
        self.iconManager = iconManager
    }

    func setEnabled(_ enabled: Bool) {
        guard switchingEnabled != enabled else {
            if enabled {
                scheduleSwitch(to: monitor.currentAppearance, debounce: false)
            }
            return
        }

        switchingEnabled = enabled
        if enabled {
            monitor.start { [weak self] appearance in
                self?.scheduleSwitch(to: appearance)
            }
            scheduleSwitch(to: monitor.currentAppearance, debounce: false)
        } else {
            monitor.stop()
            switchTask?.cancel()
            switchTask = nil
            isSwitching = false
            failedApplicationCount = 0
        }
    }

    func assign(
        image: NSImage,
        app: AppItem,
        appearance: IconAppearance
    ) async throws {
        let appPath = app.url.universalPath()
        let configuration = try store.assign(
            image: image,
            appPath: appPath,
            appName: app.name,
            appearance: appearance
        )

        guard switchingEnabled,
              configuration.isComplete,
              monitor.currentAppearance == appearance else {
            return
        }
        let iconURL = store.iconURL(for: appPath, appearance: appearance)
        try await iconManager.setIconWithoutCaching(
            image,
            app: app,
            diagnosticsOperation: .appearance,
            diagnosticsSource: .appearanceChange,
            diagnosticsIconKind: "appearance_\(appearance.rawValue)",
            diagnosticsIconPath: iconURL?.path
        )
        store.markApplied(appearance, for: appPath)
        let context = DiagnosticsContext(
            operation: .appearance,
            source: .appearanceChange,
            appName: app.name,
            appPath: appPath,
            iconKind: "appearance_\(appearance.rawValue)",
            iconPath: iconURL?.path
        )
        _ = await DockRefreshService.refreshTwice(diagnosticsContext: context)
    }

    func removeAppearanceConfiguration(for appPath: String) {
        store.removeConfiguration(for: appPath)
    }

    private func scheduleSwitch(to appearance: IconAppearance, debounce: Bool = true) {
        guard switchingEnabled else { return }
        switchTask?.cancel()
        switchTask = Task { [weak self] in
            if debounce {
                try? await Task.sleep(nanoseconds: 300_000_000)
            }
            guard !Task.isCancelled else { return }
            await self?.apply(appearance)
        }
    }

    private func apply(_ appearance: IconAppearance) async {
        guard SetupMonitor.shared.health.backgroundAutomationAvailable else {
            DiagnosticsLogger.shared.log(
                .skipped,
                phase: "appearance_batch.permission_paused",
                context: DiagnosticsContext(
                    operation: .appearance,
                    source: .appearanceChange,
                    iconKind: "appearance_\(appearance.rawValue)"
                ),
                details: ["permission_mode": "manual"]
            )
            return
        }
        isSwitching = true
        defer { isSwitching = false }

        let batchID = UUID()
        let batchContext = DiagnosticsContext(
            operation: .appearance,
            batchID: batchID,
            source: .appearanceChange,
            iconKind: "appearance_\(appearance.rawValue)"
        )
        let batchTimer = DiagnosticsTimer()
        DiagnosticsLogger.shared.log(
            .operation,
            phase: "appearance_batch.start",
            context: batchContext
        )

        var failures = 0
        var changedCount = 0
        let configurations = store.getAllConfigurations()

        for configuration in configurations {
            guard !Task.isCancelled else { return }
            let appContext = DiagnosticsContext(
                operation: .appearance,
                batchID: batchID,
                source: .appearanceChange,
                appName: configuration.appName,
                appPath: configuration.appPath,
                iconKind: "appearance_\(appearance.rawValue)"
            )
            guard let fileName = IconAppearancePolicy.iconFileName(
                for: appearance,
                configuration: configuration,
                switchingEnabled: switchingEnabled
            ) else {
                DiagnosticsLogger.shared.log(
                    .skipped,
                    phase: "appearance.no_change_needed",
                    context: appContext
                )
                continue
            }

            let appURL = URL(fileURLWithPath: configuration.appPath)
            let iconURL = AppPaths.appearanceIconsDirectory.appendingPathComponent(fileName)
            guard FileManager.default.fileExists(atPath: appURL.path) else {
                failures += 1
                DiagnosticsLogger.shared.log(
                    .failure,
                    phase: "appearance.app_not_installed",
                    context: appContext
                )
                continue
            }
            guard let image = NSImage(contentsOf: iconURL) else {
                failures += 1
                DiagnosticsLogger.shared.log(
                    .failure,
                    phase: "appearance.icon_unreadable",
                    context: appContext.withIcon(
                        kind: "appearance_\(appearance.rawValue)",
                        path: iconURL.path
                    )
                )
                continue
            }

            let app = AppItem(
                name: configuration.appName,
                url: appURL,
                originalAppInfo: nil
            )

            do {
                try await iconManager.setIconWithoutCaching(
                    image,
                    app: app,
                    allowRepair: false,
                    diagnosticsOperation: .appearance,
                    diagnosticsSource: .appearanceChange,
                    diagnosticsIconKind: "appearance_\(appearance.rawValue)",
                    diagnosticsIconPath: iconURL.path,
                    diagnosticsBatchID: batchID
                )
                store.markApplied(appearance, for: configuration.appPath)
                changedCount += 1
            } catch {
                failures += 1
                logger.error(
                    "Automatic appearance icon switch failed: \(error.localizedDescription, privacy: .public)"
                )
            }
        }

        failedApplicationCount = failures
        if changedCount > 0, !Task.isCancelled {
            let context = DiagnosticsContext(
                operation: .appearance,
                batchID: batchID,
                source: .appearanceChange,
                iconKind: "appearance_\(appearance.rawValue)"
            )
            _ = await DockRefreshService.refreshTwice(
                diagnosticsContext: context
            )
        }
        DiagnosticsLogger.shared.log(
            .operation,
            phase: "appearance_batch.completed",
            context: batchContext,
            durationMilliseconds: batchTimer.elapsedMilliseconds,
            details: [
                "changed": String(changedCount),
                "failed": String(failures),
                "total": String(configurations.count),
            ]
        )
    }
}
