//
//  IconList.swift
//  IconChanger
//

import SwiftUI
import LaunchPadManagerDBHelper

enum AppFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case dock = "Dock"
    case customized = "Customized"
    case notCustomized = "Not Customized"
    case folders = "Folders"

    var id: String { rawValue }
}

/// Holds the Dock layout: pinned apps (ordered) + running-only apps, with running state.
struct DockLayout: Equatable {
    var pinnedPaths: [String] = []         // ordered pinned app paths
    var runningPaths: Set<String> = []     // all currently running app paths
    var runningOnlyOrdered: [String] = []  // running-but-not-pinned, in launch order
    var allPaths: Set<String> = []         // union for filtering
}

struct IconList: View {
    @StateObject private var iconManager = IconManager.shared
    @StateObject private var folderManager = FolderManager.shared
    @AppStorage("showCustomIconBadge") private var showCustomIconBadge = true
    @AppStorage("dockPreviewMode") private var dockPreviewMode: String = "dockOnly"
    @AppStorage("dockPreviewWallpaper") private var dockPreviewWallpaper = true

    @State var selectedApp: AppItem? = nil

    @State var searchText: String = ""
    @State var setAlias: String?
    @State private var appToRestore: AppItem?
    @State private var restoreError: String?
    @State private var appFilter: AppFilter = .all
    @State private var dockLayout = DockLayout()
    @State private var customizedPaths: Set<String> = []
    @State private var dockBarHeight: CGFloat = 0

    private var shouldShowDockPreview: Bool {
        appFilter != .folders && (dockPreviewMode == "always" || appFilter == .dock)
    }

    private var availableFilters: [AppFilter] {
        if dockPreviewMode == "always" {
            return AppFilter.allCases.filter { $0 != .dock }
        }
        return AppFilter.allCases.map { $0 }
    }

    private var filteredApps: [AppItem] {
        if appFilter == .folders {
            return folderManager.folders.filter { folder in
                searchText.isEmpty || folder.name.localizedStandardContains(searchText)
            }
        }

        return iconManager.apps.filter { app in
            let matchesSearch = searchText.isEmpty || app.name.localizedStandardContains(searchText)
            guard matchesSearch else { return false }

            switch appFilter {
            case .all:
                return true
            case .dock:
                return dockLayout.allPaths.contains(app.id)
            case .customized:
                return customizedPaths.contains(app.id)
            case .notCustomized:
                return !customizedPaths.contains(app.id)
            case .folders:
                return false // handled above
            }
        }
    }

    private func recomputeCustomizedPaths() {
        var paths = Set<String>()
        for app in iconManager.apps {
            let path = app.id
            if iconManager.hasCustomIcon(app: app)
                || IconCacheManager.shared.getIconCache(for: path) != nil {
                paths.insert(path)
            }
        }
        customizedPaths = paths
    }

    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            List(selection: $selectedApp) {
                if appFilter == .folders {
                    Button {
                        folderManager.addFolderViaPanel()
                    } label: {
                        Label("Add Folder", systemImage: "plus.circle")
                    }
                    .buttonStyle(.borderless)
                    .padding(.vertical, 4)
                }

                ForEach(filteredApps, id: \.id) { app in
                    IconView(app: app, refreshTrigger: iconManager.iconRefreshTrigger,
                             isCustomized: showCustomIconBadge && customizedPaths.contains(app.id),
                             isFolder: appFilter == .folders)
                        .tag(app)
                        .contextMenu {
                            if appFilter == .folders {
                                Button("Copy the Name") {
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(app.name, forType: .string)
                                }

                                Button("Show in Finder") {
                                    NSWorkspace.shared.activateFileViewerSelecting([app.url])
                                }

                                Button("Restore Default Icon") {
                                    appToRestore = app
                                }

                                Divider()

                                Button("Remove Folder", role: .destructive) {
                                    if selectedApp?.id == app.id {
                                        selectedApp = nil
                                    }
                                    folderManager.removeFolder(at: app.id)
                                }
                            } else {
                                Button("Copy the Name") {
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(app.name, forType: .string)
                                }

                                Menu("Path") {
                                    Button("Copy") {
                                        NSPasteboard.general.clearContents()
                                        NSPasteboard.general.setString(app.url.universalPath(), forType: .string)
                                    }

                                    Button("Copy the Path Name") {
                                        NSPasteboard.general.clearContents()
                                        NSPasteboard.general.setString(app.url.deletingPathExtension().lastPathComponent, forType: .string)
                                    }

                                    Button("Show in the Finder") {
                                        NSWorkspace.shared.activateFileViewerSelecting([app.url])
                                    }
                                }

                                Button("Set the Alias") {
                                    setAlias = app.url.deletingPathExtension().lastPathComponent
                                }

                                Button("Restore Default Icon") {
                                    appToRestore = app
                                }

                                Button("Escape Squircle Jail") {
                                    do {
                                        try iconManager.escapeSquircleJail(for: app)
                                    } catch {
                                        restoreError = error.localizedDescription
                                    }
                                }

                                if let original = app.originalAppInfo {
                                    Button("Remove the Icon from the Launchpad") {
                                        do {
                                            try LaunchPadManagerDBHelper().removeApp(original)
                                        } catch {
                                            restoreError = error.localizedDescription
                                        }
                                    }
                                }
                            }
                    }
                }
            }
                    .listStyle(.sidebar)
                    .frame(minWidth: 200, idealWidth: 300)
                    .modifier(HideSidebarToggle())
        } detail: {
            ZStack(alignment: .top) {
                // Wallpaper layer — ignores safe area, stays fixed when sidebar toggles
                if shouldShowDockPreview, dockPreviewWallpaper, dockBarHeight > 0 {
                    DockPreviewWallpaper(barHeight: dockBarHeight)
                        .ignoresSafeArea(edges: .leading)
                }

                // Content layer — respects safe area, moves with sidebar
                VStack(spacing: 0) {
                    if shouldShowDockPreview {
                        DockPreviewBar(
                            allApps: iconManager.apps,
                            dockLayout: dockLayout,
                            refreshTrigger: iconManager.iconRefreshTrigger,
                            appFilter: appFilter,
                            customizedPaths: customizedPaths,
                            onSelectApp: { app in selectedApp = app }
                        )
                        .background(
                            GeometryReader { geo in
                                Color.clear.preference(key: DockBarHeightKey.self, value: geo.size.height)
                            }
                        )
                    }

                    if let app = selectedApp {
                        ChangeView(setPath: app)
                            .id(app.id)
                    } else {
                        Spacer()
                        if appFilter == .folders && folderManager.folders.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "folder.badge.plus")
                                    .font(.system(size: 40))
                                    .foregroundColor(.secondary)
                                Text("No folders added yet")
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                                Button("Add Folder") {
                                    folderManager.addFolderViaPanel()
                                }
                            }
                        } else if !shouldShowDockPreview {
                            Text(appFilter == .folders
                                 ? "Select a folder to customize its icon"
                                 : "Select an app to see its details")
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                }
            }
            .onPreferenceChange(DockBarHeightKey.self) { dockBarHeight = $0 }
        }
        .navigationSplitViewStyle(.prominentDetail)

                .sheet(item: $setAlias) {
                    SetAliasNameView(raw: $0, lastText: AliasName.getName(for: $0) ?? "")
                }
                .searchable(text: $searchText)
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        Picker("Filter", selection: $appFilter) {
                            ForEach(availableFilters) { filter in
                                Text(NSLocalizedString(filter.rawValue, comment: "App filter option"))
                                    .tag(filter)
                            }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: appFilter) { newFilter in
                            if newFilter == .dock || dockPreviewMode == "always" {
                                dockLayout = Self.loadDockLayout()
                            }
                        }
                        .onChange(of: dockPreviewMode) { _ in
                            if appFilter == .dock && dockPreviewMode == "always" {
                                appFilter = .all
                            }
                        }
                    }

                    ToolbarItem(placement: .automatic) {
                        Button {
                            iconManager.iconRefreshTrigger = UUID()
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                        .help("Refresh Icon Display")
                        .keyboardShortcut("r", modifiers: .command)
                    }

                    ToolbarItem(placement: .automatic) {
                        Menu {
                            Button {
                                iconManager.refresh()
                            } label: {
                                Label("Refresh App List", systemImage: "arrow.triangle.2.circlepath")
                            }

                            Button {
                                iconManager.needsSetupCheck = true
                            } label: {
                                Label("Check Setup Status", systemImage: "stethoscope")
                            }

                            Button {
                                Self.refreshDock()
                            } label: {
                                Label("Refresh Dock", systemImage: "dock.rectangle")
                            }

                            Divider()

                            Button {
                                Task {
                                    do {
                                        try await iconManager.restoreAllCachedIcons()
                                        let alert = NSAlert()
                                        alert.messageText = NSLocalizedString("Icons Restored", comment: "Alert title")
                                        alert.informativeText = NSLocalizedString("All cached custom icons have been successfully restored.", comment: "Alert body")
                                        alert.alertStyle = .informational
                                        alert.addButton(withTitle: NSLocalizedString("OK", comment: "Alert button"))
                                        alert.runModal()
                                    } catch {
                                        let alert = NSAlert()
                                        alert.messageText = NSLocalizedString("Error Restoring Icons", comment: "Alert title")
                                        alert.informativeText = error.localizedDescription
                                        alert.alertStyle = .critical
                                        alert.addButton(withTitle: NSLocalizedString("OK", comment: "Alert button"))
                                        alert.runModal()
                                    }
                                }
                            } label: {
                                Label("Restore Cached Icons", systemImage: "arrow.clockwise")
                            }

                            Divider()

                            Button {
                                Task {
                                    do {
                                        let result = try await iconManager.escapeSquircleJailAll()
                                        let alert = NSAlert()
                                        alert.alertStyle = .informational
                                        alert.addButton(withTitle: NSLocalizedString("OK", comment: "Alert button"))
                                        if result.processed == 0 && result.failed.isEmpty {
                                            alert.messageText = NSLocalizedString("No Apps to Process", comment: "Alert title")
                                            alert.informativeText = NSLocalizedString("All apps already have custom icons or could not be processed.", comment: "Alert body")
                                        } else {
                                            alert.messageText = NSLocalizedString("Squircle Jail Escape Complete", comment: "Alert title")
                                            let msg = String(format: NSLocalizedString("%d apps escaped, %d skipped, %d failed.", comment: "Escape jail result"), result.processed, result.skipped, result.failed.count)
                                            alert.informativeText = msg
                                        }
                                        alert.runModal()
                                    } catch {
                                        let alert = NSAlert()
                                        alert.messageText = NSLocalizedString("Escape Failed", comment: "Alert title")
                                        alert.informativeText = error.localizedDescription
                                        alert.alertStyle = .critical
                                        alert.addButton(withTitle: NSLocalizedString("OK", comment: "Alert button"))
                                        alert.runModal()
                                    }
                                }
                            } label: {
                                Label("Escape Squircle Jail (All Apps)", systemImage: "square.dashed")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
                .toolbarBackground(.hidden, for: .windowToolbar)
                .onAppear {
                    iconManager.refresh()
                    if shouldShowDockPreview || appFilter == .dock {
                        dockLayout = Self.loadDockLayout()
                    }
                }
                .onChange(of: dockPreviewMode) { newMode in
                    if newMode == "always" {
                        dockLayout = Self.loadDockLayout()
                    }
                }
                .onChange(of: iconManager.iconRefreshTrigger) { _ in
                    AppIconCache.shared.removeAll()
                    recomputeCustomizedPaths()
                }
                .onChange(of: iconManager.apps) { _ in
                    recomputeCustomizedPaths()
                }
                .confirmationDialog("Restore Default Icon", isPresented: Binding(
                    get: { appToRestore != nil },
                    set: { if !$0 { appToRestore = nil } }
                )) {
                    Button("Restore", role: .destructive) {
                        if let app = appToRestore {
                            do {
                                try iconManager.removeIcon(from: app)
                            } catch {
                                restoreError = error.localizedDescription
                            }
                        }
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("This will remove the custom icon and restore the original icon for \(appToRestore?.name ?? "").")
                }
                .alert("Restore Failed", isPresented: Binding(
                    get: { restoreError != nil },
                    set: { if !$0 { restoreError = nil } }
                )) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(IconList.friendlyErrorMessage(restoreError ?? ""))
                }
    }

    static func friendlyErrorMessage(_ raw: String) -> String {
        if raw.contains("permission") || raw.contains("权限") {
            return NSLocalizedString("This app may be protected by macOS. Try closing the app first, or the app may not support icon changes.", comment: "Permission error explanation")
        }
        return raw
    }

    /// Reads the full Dock layout: pinned apps (ordered) + running apps.
    static func loadDockLayout() -> DockLayout {
        var layout = DockLayout()

        // 1. Pinned (persistent) apps — ordered as they appear in Dock
        let plistPath = NSHomeDirectory() + "/Library/Preferences/com.apple.dock.plist"
        if let dict = NSDictionary(contentsOfFile: plistPath),
           let persistentApps = dict["persistent-apps"] as? [[String: Any]] {
            for app in persistentApps {
                if let tileData = app["tile-data"] as? [String: Any],
                   let fileData = tileData["file-data"] as? [String: Any],
                   let urlString = fileData["_CFURLString"] as? String,
                   let url = URL(string: urlString) {
                    let path = url.scheme == "file" ? url.path : urlString
                    let normalized = path.hasSuffix("/") ? String(path.dropLast()) : path
                    layout.pinnedPaths.append(normalized)
                }
            }
        }

        // 2. Currently running GUI apps (ordered by runningApplications array ≈ launch order)
        let pinnedSet = Set(layout.pinnedPaths)
        for app in NSWorkspace.shared.runningApplications {
            guard app.activationPolicy == .regular,
                  let bundleURL = app.bundleURL else { continue }
            let path = bundleURL.path
            let normalized = path.hasSuffix("/") ? String(path.dropLast()) : path
            layout.runningPaths.insert(normalized)
            if !pinnedSet.contains(normalized) {
                layout.runningOnlyOrdered.append(normalized)
            }
        }

        // 3. Union for filtering
        layout.allPaths = pinnedSet.union(layout.runningPaths)

        return layout
    }

    /// Restarts the Dock process to force icon refresh.
    static func refreshDock() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/killall")
        task.arguments = ["Dock"]
        try? task.run()
    }
}

struct IconView: View {
    let app: AppItem
    let refreshTrigger: UUID
    var isCustomized: Bool = false
    var isFolder: Bool = false
    @State private var icon: NSImage?

    var body: some View {
        HStack {
            ZStack(alignment: .bottomTrailing) {
                Group {
                    if let icon {
                        Image(nsImage: icon)
                            .resizable()
                            .scaledToFit()
                    } else {
                        Image(nsImage: isFolder
                              ? NSWorkspace.shared.icon(for: .folder)
                              : NSWorkspace.shared.icon(for: .applicationBundle))
                            .resizable()
                            .scaledToFit()
                            .opacity(0.3)
                    }
                }
                .frame(width: 32, height: 32)

                if isCustomized {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(.green, Color(.windowBackgroundColor))
                        .offset(x: 2, y: 2)
                }
            }

            Text(app.name)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .task(id: app.url) {
            await loadIcon()
        }
        .onAppear {
            if icon == nil, let cached = AppIconCache.shared.cachedIcon(for: app.url) {
                icon = cached
            }
        }
        .onChange(of: refreshTrigger) { _ in
            Task { await loadIcon() }
        }
    }

    private func loadIcon() async {
        if let cached = AppIconCache.shared.cachedIcon(for: app.url) {
            icon = cached
            return
        }
        let url = app.url
        let loaded = await Task.detached(priority: .userInitiated) {
            if isFolder {
                return NSWorkspace.shared.icon(forFile: url.path)
            }
            return AppIconCache.shared.icon(for: url)
        }.value
        icon = loaded
    }
}

// MARK: - Dock Glass Effect

struct HideSidebarToggle: ViewModifier {
    func body(content: Content) -> some View {
        if #available(macOS 14.0, *) {
            content.toolbar(removing: .sidebarToggle)
        } else {
            content
        }
    }
}

/// Applies Liquid Glass on macOS 26+, falls back to ultraThinMaterial on older versions.
struct DockGlassModifier: ViewModifier {
    @AppStorage("dockGlassIntensity") private var intensity: Double = 0.5

    private let shape = RoundedRectangle(cornerRadius: 22, style: .continuous)

    func body(content: Content) -> some View {
        if #available(macOS 26, *) {
            content
                .glassEffect(
                    .regular.tint(Color.white.opacity(intensity * 0.6)),
                    in: shape
                )
        } else {
            content
                .background(shape.fill(.ultraThinMaterial))
                .overlay(shape.strokeBorder(Color.white.opacity(0.2), lineWidth: 0.5))
        }
    }
}

// MARK: - Wallpaper Loader

final class WallpaperLoader: ObservableObject {
    static let shared = WallpaperLoader()
    @Published var wallpaperImage: NSImage?

    private var observers: [NSObjectProtocol] = []

    private init() {
        loadWallpaper()
        observers.append(
            NSWorkspace.shared.notificationCenter.addObserver(
                forName: NSWorkspace.didActivateApplicationNotification,
                object: nil, queue: .main
            ) { [weak self] notification in
                guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
                      app.bundleIdentifier == Bundle.main.bundleIdentifier else { return }
                self?.loadWallpaper()
            }
        )
        observers.append(
            NSWorkspace.shared.notificationCenter.addObserver(
                forName: NSWorkspace.activeSpaceDidChangeNotification,
                object: nil, queue: .main
            ) { [weak self] _ in
                self?.loadWallpaper()
            }
        )
    }

    deinit {
        for observer in observers {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
        }
    }

    func loadWallpaper() {
        if let captured = Self.captureDesktopWindow() {
            wallpaperImage = captured
            return
        }
        if let screen = NSScreen.main,
           let url = NSWorkspace.shared.desktopImageURL(for: screen),
           let image = NSImage(contentsOf: url) {
            wallpaperImage = image
            return
        }
        wallpaperImage = nil
    }

    /// Captures the actual rendered desktop by finding the Dock's desktop picture window.
    private static func captureDesktopWindow() -> NSImage? {
        guard let screen = NSScreen.main else { return nil }
        guard let windowList = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]] else { return nil }

        for info in windowList {
            let owner = info[kCGWindowOwnerName as String] as? String ?? ""
            let layer = info[kCGWindowLayer as String] as? Int ?? 0

            guard owner == "Dock", layer <= -2_000_000_000 else { continue }
            guard let windowID = info[kCGWindowNumber as String] as? Int else { continue }

            if let cgImage = CGWindowListCreateImage(
                screen.frame,
                .optionIncludingWindow,
                CGWindowID(windowID),
                [.bestResolution]
            ) {
                return NSImage(cgImage: cgImage, size: screen.frame.size)
            }
        }
        return nil
    }
}

// MARK: - Dock Preview

struct DockBarHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct DockPreviewWallpaper: View {
    let barHeight: CGFloat
    @StateObject private var wallpaperLoader = WallpaperLoader.shared

    var body: some View {
        GeometryReader { geo in
            if let wallpaper = wallpaperLoader.wallpaperImage {
                let bleed: CGFloat = 50
                let fullW = geo.size.width
                let safeLeading = geo.safeAreaInsets.leading
                let detailW = fullW - safeLeading
                let totalW = fullW + bleed * 2
                let totalH = barHeight + bleed * 2
                let screenAspect = wallpaper.size.width / wallpaper.size.height
                let imgW = totalW
                let imgH = imgW / screenAspect

                Image(nsImage: wallpaper)
                    .resizable()
                    .frame(width: imgW, height: imgH)
                    .frame(width: totalW, height: totalH)
                    .clipped()
                    .mask(
                        RoundedRectangle(cornerRadius: 12)
                            .frame(width: detailW, height: barHeight)
                            .blur(radius: 30)
                            .frame(width: totalW, height: totalH)
                            .offset(x: safeLeading / 2)
                    )
                    .position(x: fullW / 2, y: barHeight / 2)
            }
        }
        .frame(height: barHeight)
        .allowsHitTesting(false)
    }
}

struct DockPreviewBar: View {
    let allApps: [AppItem]
    let dockLayout: DockLayout
    let refreshTrigger: UUID
    var appFilter: AppFilter = .all
    var customizedPaths: Set<String> = []
    var onSelectApp: ((AppItem) -> Void)?

    private func shouldShow(_ app: AppItem) -> Bool {
        switch appFilter {
        case .customized:
            return customizedPaths.contains(app.id)
        case .notCustomized:
            return !customizedPaths.contains(app.id)
        default:
            return true
        }
    }

    private var resolvedApps: (pinned: [AppItem], runningOnly: [AppItem]) {
        let lookup = Dictionary(allApps.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        return (
            pinned: dockLayout.pinnedPaths.compactMap { lookup[$0] }.filter { shouldShow($0) },
            runningOnly: dockLayout.runningOnlyOrdered.compactMap { lookup[$0] }.filter { shouldShow($0) }
        )
    }

    var body: some View {
        let apps = resolvedApps
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Dock Preview")
                    .font(.headline)
                Spacer()
                Button {
                    IconList.refreshDock()
                } label: {
                    Label("Refresh Dock", systemImage: "arrow.clockwise")
                        .font(.caption)
                }
                .buttonStyle(.borderless)
                .help("Restart the Dock to refresh all icons")
            }

            if apps.pinned.isEmpty && apps.runningOnly.isEmpty {
                Text("No Dock apps found")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(apps.pinned) { app in
                            DockPreviewIcon(
                                app: app,
                                refreshTrigger: refreshTrigger,
                                isRunning: dockLayout.runningPaths.contains(app.id)
                            )
                            .onTapGesture { onSelectApp?(app) }
                            .padding(.horizontal, 6)
                        }

                        if !apps.pinned.isEmpty && !apps.runningOnly.isEmpty {
                            RoundedRectangle(cornerRadius: 1)
                                .fill(Color.secondary.opacity(0.3))
                                .frame(width: 2, height: 48)
                                .padding(.horizontal, 8)
                        }

                        ForEach(apps.runningOnly) { app in
                            DockPreviewIcon(
                                app: app,
                                refreshTrigger: refreshTrigger,
                                isRunning: true
                            )
                            .onTapGesture { onSelectApp?(app) }
                            .padding(.horizontal, 6)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                }
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .modifier(DockGlassModifier())
            }
        }
        .padding()
        .padding()
    }
}

struct DockPreviewIcon: View {
    let app: AppItem
    let refreshTrigger: UUID
    var isRunning: Bool = false
    @State private var icon: NSImage?
    @State private var hasCustom: Bool = false

    var body: some View {
        VStack(spacing: 2) {
            ZStack(alignment: .bottomTrailing) {
                Group {
                    if let icon {
                        Image(nsImage: icon)
                            .resizable()
                            .scaledToFit()
                    } else {
                        Image(nsImage: NSWorkspace.shared.icon(for: .applicationBundle))
                            .resizable()
                            .scaledToFit()
                            .opacity(0.3)
                    }
                }
                .frame(width: 48, height: 48)

                if hasCustom {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.green, Color(.windowBackgroundColor))
                        .offset(x: 2, y: 2)
                }
            }

            Text(app.name)
                .font(.caption2)
                .lineLimit(1)
                .frame(width: 56)
                .multilineTextAlignment(.center)

            Circle()
                .fill(isRunning ? Color.primary.opacity(0.6) : Color.clear)
                .frame(width: 4, height: 4)
        }
        .contentShape(Rectangle())
        .task(id: app.url) { await loadIcon() }
        .onChange(of: refreshTrigger) { _ in Task { await loadIcon() } }
    }

    private func loadIcon() async {
        let url = app.url
        let appId = app.id
        if let cached = AppIconCache.shared.cachedIcon(for: url) {
            icon = cached
            hasCustom = IconCacheManager.shared.getIconCache(for: appId) != nil
            return
        }
        let (loaded, isCached) = await Task.detached(priority: .userInitiated) {
            let img = AppIconCache.shared.icon(for: url)
            let cached = IconCacheManager.shared.getIconCache(for: appId) != nil
            return (img, cached)
        }.value
        icon = loaded
        hasCustom = isCached
    }
}

extension String: @retroactive Identifiable {
    public var id: String {
        self
    }
}

