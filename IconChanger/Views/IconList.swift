//
//  IconList.swift
//  IconChanger
//
//  Created by 朱浩宇 on 2022/4/27.
//

import SwiftUI
import LaunchPadManagerDBHelper

enum AppFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case dock = "Dock"
    case customized = "Customized"
    case notCustomized = "Not Customized"

    var id: String { rawValue }
}

/// Holds the Dock layout: pinned apps (ordered) + running-only apps, with running state.
struct DockLayout {
    var pinnedPaths: [String] = []         // ordered pinned app paths
    var runningPaths: Set<String> = []     // all currently running app paths
    var runningOnlyOrdered: [String] = []  // running-but-not-pinned, in launch order
    var allPaths: Set<String> = []         // union for filtering
}

struct IconList: View {
    @ObservedObject var iconManager = IconManager.shared
    @AppStorage("showCustomIconBadge") private var showCustomIconBadge = true

    @State var selectedApp: AppItem? = nil

    @State var searchText: String = ""
    @State var setAlias: String?
    @State private var appToRestore: AppItem?
    @State private var restoreError: String?
    @State private var appFilter: AppFilter = .all
    @State private var dockLayout = DockLayout()
    @State private var customizedPaths: Set<String> = []

    private var filteredApps: [AppItem] {
        iconManager.apps.filter { app in
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
        NavigationView {
            List(selection: $selectedApp) {
                ForEach(filteredApps, id: \.id) { app in
                    NavigationLink(destination: dockDetailView(for: app),
                            tag: app,
                            selection: $selectedApp) {
                        IconView(app: app, refreshTrigger: iconManager.iconRefreshTrigger,
                                 isCustomized: showCustomIconBadge && customizedPaths.contains(app.id))
                    }
                            .contextMenu {
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
                    .listStyle(SidebarListStyle())
                    .frame(minWidth: 200, idealWidth: 300)

            VStack {
                if appFilter == .dock {
                    DockPreviewBar(
                        allApps: iconManager.apps,
                        dockLayout: dockLayout,
                        refreshTrigger: iconManager.iconRefreshTrigger,
                        onSelectApp: { app in selectedApp = app }
                    )
                }
                Spacer()
                if appFilter != .dock {
                    Text("Select an app to see its details")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }

                .sheet(item: $setAlias) {
                    SetAliasNameView(raw: $0, lastText: AliasName.getName(for: $0) ?? "")
                }
                .searchable(text: $searchText)
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        Picker("Filter", selection: $appFilter) {
                            ForEach(AppFilter.allCases) { filter in
                                Text(NSLocalizedString(filter.rawValue, comment: "App filter option"))
                                    .tag(filter)
                            }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: appFilter) { newFilter in
                            if newFilter == .dock {
                                dockLayout = Self.loadDockLayout()
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
                .onAppear {
                    iconManager.refresh()
                    dockLayout = Self.loadDockLayout()
                    recomputeCustomizedPaths()
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

    @ViewBuilder
    private func dockDetailView(for app: AppItem) -> some View {
        if appFilter == .dock {
            VStack(spacing: 0) {
                DockPreviewBar(
                    allApps: iconManager.apps,
                    dockLayout: dockLayout,
                    refreshTrigger: iconManager.iconRefreshTrigger,
                    onSelectApp: { selectedApp = $0 }
                )
                ChangeView(setPath: app)
            }
        } else {
            ChangeView(setPath: app)
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
                        Image(nsImage: NSWorkspace.shared.icon(for: .applicationBundle))
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
            AppIconCache.shared.icon(for: url)
        }.value
        icon = loaded
    }
}

// MARK: - Dock Preview

struct DockPreviewBar: View {
    let allApps: [AppItem]
    let dockLayout: DockLayout
    let refreshTrigger: UUID
    var onSelectApp: ((AppItem) -> Void)?

    private var resolvedApps: (pinned: [AppItem], runningOnly: [AppItem]) {
        let lookup = Dictionary(allApps.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        return (
            pinned: dockLayout.pinnedPaths.compactMap { lookup[$0] },
            runningOnly: dockLayout.runningOnlyOrdered.compactMap { lookup[$0] }
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
                    .padding(.horizontal, 4)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.bar)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.secondary.opacity(0.2), lineWidth: 1)
        )
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
        let (loaded, cached) = await Task.detached(priority: .userInitiated) {
            let img = NSWorkspace.shared.icon(forFile: url.path)
            let isCached = IconCacheManager.shared.getIconCache(for: appId) != nil
            return (img, isCached)
        }.value
        icon = loaded
        hasCustom = cached
    }
}

extension String: @retroactive Identifiable {
    public var id: String {
        self
    }
}

