//
//  CachedIconsView.swift
//  IconChanger
//

import SwiftUI

private struct CachedIconDisplayItem: Identifiable {
    let appPath: String
    let appName: String
    let timestamp: Date
    let cache: IconCache?
    let appearanceConfiguration: AppearanceIconConfiguration?

    var id: String { appPath }

    func iconURL(for appearance: IconAppearance) -> URL? {
        guard let fileName = appearanceConfiguration?.fileName(for: appearance) else {
            return nil
        }
        return AppPaths.appearanceIconsDirectory.appendingPathComponent(fileName)
    }
}

struct CachedIconsView: View {
    @StateObject private var iconManager = IconManager.shared
    @State private var items: [CachedIconDisplayItem] = []
    @State private var selection: Set<IconCacheSelectionTarget> = []
    @State private var isRestoring = false
    @State private var restoreError: Error?
    @State private var showRestoreSuccess = false
    @State private var showDeleteConfirmation = false

    private var isAllSelected: Bool {
        !items.isEmpty && items.allSatisfy {
            selection.contains(.application($0.appPath))
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            if items.isEmpty {
                emptyState
            } else {
                cacheList
                actionBar
            }
        }
        .onAppear(perform: loadItems)
        .onReceive(
            NotificationCenter.default.publisher(for: .appearanceIconStoreDidChange)
        ) { _ in
            loadItems()
        }
        .sheet(isPresented: $isRestoring) {
            restoreProgress
        }
        .alert("Icons Restored", isPresented: $showRestoreSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Custom icons have been successfully restored.")
        }
        .confirmationDialog(
            deleteConfirmationTitle,
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button(
                isAllSelected ? "Clear All Cache" : "Remove Selected",
                role: .destructive
            ) {
                if isAllSelected {
                    clearCache()
                } else {
                    removeSelected()
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This action cannot be undone. Removed icons must be assigned again.")
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "archivebox")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
                .padding(.bottom, 10)

            Text("No cached icons found")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("Applied icons and Light/Dark icon choices appear here.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var cacheList: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Text("Application")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Light")
                    .frame(width: 54)
                Text("Dark")
                    .frame(width: 54)
            }
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.horizontal, 18)
            .padding(.bottom, 5)

            List(items) { item in
                CachedIconRow(
                    item: item,
                    appSelected: selection.contains(.application(item.appPath)),
                    lightSelected: selection.contains(.appearance(item.appPath, .light)),
                    darkSelected: selection.contains(.appearance(item.appPath, .dark)),
                    onSelectApplication: {
                        selection = IconAppearancePolicy.toggling(
                            .application(item.appPath),
                            in: selection
                        )
                    },
                    onSelectAppearance: { appearance in
                        selection = IconAppearancePolicy.toggling(
                            .appearance(item.appPath, appearance),
                            in: selection
                        )
                    },
                    onRestore: {
                        restore(item: item, appearance: nil)
                    },
                    onRemove: {
                        removeApplication(item.appPath)
                    }
                )
                .padding(.vertical, 3)
            }
        }
    }

    private var actionBar: some View {
        HStack {
            Button {
                restoreAllIcons()
            } label: {
                Label("Restore All", systemImage: "arrow.clockwise")
            }
            .disabled(items.allSatisfy { $0.cache == nil } || isRestoring)

            Spacer()

            Button {
                restoreSelected()
            } label: {
                Label("Restore Selected", systemImage: "arrow.clockwise.circle")
            }
            .disabled(selection.isEmpty || isRestoring)

            Spacer()

            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Label(
                    isAllSelected ? "Clear All Cache" : "Remove Selected",
                    systemImage: "trash"
                )
            }
            .disabled(selection.isEmpty)
        }
        .padding()
    }

    private var restoreProgress: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .padding(.bottom, 10)

            Text("Restoring icons...")
                .font(.headline)

            if let restoreError {
                Text("Error: \(restoreError.localizedDescription)")
                    .foregroundColor(.red)
                    .padding()
                    .multilineTextAlignment(.center)
            }

            Button("Cancel") {
                isRestoring = false
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 20)
        }
        .padding(30)
        .frame(width: 300, height: 200)
    }

    private var deleteConfirmationTitle: String {
        if isAllSelected {
            return String(
                format: NSLocalizedString(
                    "Are you sure you want to clear all %lld cached applications?",
                    comment: "Clear all icon caches confirmation"
                ),
                items.count
            )
        }
        return String(
            format: NSLocalizedString(
                "Are you sure you want to remove %lld selected cache item(s)?",
                comment: "Remove selected icon cache entries confirmation"
            ),
            selection.count
        )
    }

    private func loadItems() {
        let caches = IconCacheManager.shared.getAllCachedIcons()
        let configurations = AppearanceIconStore.shared.getAllConfigurations()
        let cacheByPath = Dictionary(uniqueKeysWithValues: caches.map { ($0.appPath, $0) })
        let configurationByPath = Dictionary(
            uniqueKeysWithValues: configurations.map { ($0.appPath, $0) }
        )
        let allPaths = Set(cacheByPath.keys).union(configurationByPath.keys)

        items = allPaths.map { appPath in
            let cache = cacheByPath[appPath]
            let configuration = configurationByPath[appPath]
            return CachedIconDisplayItem(
                appPath: appPath,
                appName: cache?.appName
                    ?? configuration?.appName
                    ?? URL(fileURLWithPath: appPath).deletingPathExtension().lastPathComponent,
                timestamp: max(
                    cache?.timestamp ?? Date.distantPast,
                    configuration?.updatedAt ?? Date.distantPast
                ),
                cache: cache,
                appearanceConfiguration: configuration
            )
        }
        .sorted { $0.timestamp > $1.timestamp }

        let validPaths = Set(items.map(\.appPath))
        selection = Set(selection.filter { target in
            guard validPaths.contains(target.appPath) else { return false }
            switch target {
            case .application:
                return true
            case .appearance(let appPath, let appearance):
                return configurationByPath[appPath]?.fileName(for: appearance) != nil
            }
        })
    }

    private func restoreAllIcons() {
        Task {
            isRestoring = true
            restoreError = nil

            do {
                let result = try await iconManager.restoreAllCachedIcons()
                isRestoring = false
                if result.failed.isEmpty {
                    showRestoreSuccess = true
                } else {
                    restoreError = RestoreError.someFailed(failed: result.failed)
                }
            } catch {
                restoreError = error
                isRestoring = false
            }
        }
    }

    private func restoreSelected() {
        let targets = selection
        guard !targets.isEmpty else { return }

        Task {
            isRestoring = true
            restoreError = nil
            var failed: [(String, Error)] = []

            for target in targets {
                guard let item = items.first(where: { $0.appPath == target.appPath }) else {
                    continue
                }
                do {
                    switch target {
                    case .application:
                        if let cache = item.cache {
                            try await restore(cache: cache)
                        } else if let current = currentAppearanceForRestore(item) {
                            try await restore(item: item, appearance: current)
                        }
                    case .appearance(_, let appearance):
                        try await restore(item: item, appearance: appearance)
                    }
                } catch {
                    failed.append((item.appName, error))
                }
            }

            isRestoring = false
            if failed.isEmpty {
                showRestoreSuccess = true
            } else {
                restoreError = RestoreError.someFailed(failed: failed)
            }
        }
    }

    private func restore(item: CachedIconDisplayItem, appearance: IconAppearance?) {
        Task {
            isRestoring = true
            restoreError = nil
            do {
                if let appearance {
                    try await restore(item: item, appearance: appearance)
                } else if let cache = item.cache {
                    try await restore(cache: cache)
                } else if let current = currentAppearanceForRestore(item) {
                    try await restore(item: item, appearance: current)
                } else {
                    throw RestoreError.iconFileNotFound(item.appName)
                }
                isRestoring = false
                showRestoreSuccess = true
            } catch {
                restoreError = error
                isRestoring = false
            }
        }
    }

    private func restore(cache: IconCache) async throws {
        let iconURL = IconCacheManager.cacheDirectory.appendingPathComponent(
            cache.iconFileName
        )
        guard let image = NSImage(contentsOf: iconURL) else {
            throw RestoreError.iconFileNotFound(cache.appName)
        }
        try await iconManager.setIconWithoutCaching(
            image,
            app: try appItem(path: cache.appPath, name: cache.appName)
        )
    }

    private func restore(
        item: CachedIconDisplayItem,
        appearance: IconAppearance
    ) async throws {
        guard let iconURL = item.iconURL(for: appearance),
              let image = NSImage(contentsOf: iconURL) else {
            throw RestoreError.iconFileNotFound(item.appName)
        }
        try await iconManager.setIconWithoutCaching(
            image,
            app: try appItem(path: item.appPath, name: item.appName)
        )
        AppearanceIconStore.shared.markApplied(appearance, for: item.appPath)
    }

    private func appItem(path: String, name: String) throws -> AppItem {
        guard FileManager.default.fileExists(atPath: path) else {
            throw RestoreError.appNotFound(name)
        }
        if let existing = iconManager.apps.first(where: { $0.url.universalPath() == path }) {
            return existing
        }
        return AppItem(
            name: name,
            url: URL(fileURLWithPath: path),
            originalAppInfo: nil
        )
    }

    private func currentAppearanceForRestore(
        _ item: CachedIconDisplayItem
    ) -> IconAppearance? {
        let current = SystemAppearanceMonitor.shared.currentAppearance
        if item.iconURL(for: current) != nil {
            return current
        }
        return IconAppearance.allCases.first { item.iconURL(for: $0) != nil }
    }

    private func removeApplication(_ appPath: String) {
        IconCacheManager.shared.removeCachedIcon(for: appPath)
        AppearanceIconStore.shared.removeConfiguration(for: appPath)
        selection = selection.filter { $0.appPath != appPath }
        loadItems()
    }

    private func removeSelected() {
        for target in selection {
            switch target {
            case .application(let appPath):
                IconCacheManager.shared.removeCachedIcon(for: appPath)
                AppearanceIconStore.shared.removeConfiguration(for: appPath)
            case .appearance(let appPath, let appearance):
                AppearanceIconStore.shared.removeSlot(
                    for: appPath,
                    appearance: appearance
                )
            }
        }
        selection.removeAll()
        loadItems()
    }

    private func clearCache() {
        IconCacheManager.shared.clearCache()
        AppearanceIconStore.shared.clearAll()
        selection.removeAll()
        items = []
    }
}

private struct CachedIconRow: View {
    let item: CachedIconDisplayItem
    let appSelected: Bool
    let lightSelected: Bool
    let darkSelected: Bool
    let onSelectApplication: () -> Void
    let onSelectAppearance: (IconAppearance) -> Void
    let onRestore: () -> Void
    let onRemove: () -> Void

    @State private var cachedImage: NSImage?
    @State private var lightImage: NSImage?
    @State private var darkImage: NSImage?

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        HStack(spacing: 10) {
            Button(action: onSelectApplication) {
                HStack(spacing: 12) {
                    iconPreview(image: cachedImage, fallbackSystemImage: "app")
                        .frame(width: 40, height: 40)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.appName)
                            .font(.headline)
                            .lineLimit(1)

                        Label(
                            Self.dateFormatter.string(from: item.timestamp),
                            systemImage: "clock"
                        )
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    }

                    Spacer(minLength: 4)
                }
                .padding(5)
                .background(selectionBackground(selected: appSelected))
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            appearanceSlot(.light, image: lightImage, selected: lightSelected)
            appearanceSlot(.dark, image: darkImage, selected: darkSelected)
        }
        .contextMenu {
            Button(action: onRestore) {
                Label("Restore This Icon", systemImage: "arrow.clockwise")
            }

            Divider()

            Button(role: .destructive, action: onRemove) {
                Label("Remove Application Cache", systemImage: "trash")
            }
        }
        .task(id: item.id + String(item.timestamp.timeIntervalSinceReferenceDate)) {
            async let cached = loadImage(
                item.cache.map {
                    IconCacheManager.cacheDirectory.appendingPathComponent($0.iconFileName)
                }
            )
            async let light = loadImage(item.iconURL(for: .light))
            async let dark = loadImage(item.iconURL(for: .dark))
            (cachedImage, lightImage, darkImage) = await (cached, light, dark)
        }
    }

    private func appearanceSlot(
        _ appearance: IconAppearance,
        image: NSImage?,
        selected: Bool
    ) -> some View {
        Button {
            onSelectAppearance(appearance)
        } label: {
            VStack(spacing: 2) {
                iconPreview(image: image, fallbackSystemImage: appearance.systemImage)
                    .frame(width: 32, height: 32)
                Text(appearance.displayName)
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
            }
            .frame(width: 50, height: 50)
            .background(selectionBackground(selected: selected))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(image == nil)
        .help(
            image == nil
                ? String(
                    format: NSLocalizedString(
                        "No %@ icon assigned",
                        comment: "Missing appearance icon tooltip"
                    ),
                    appearance.displayName
                )
                : String(
                    format: NSLocalizedString(
                        "Select %@ icon",
                        comment: "Appearance icon selection tooltip"
                    ),
                    appearance.displayName
                )
        )
    }

    private func iconPreview(
        image: NSImage?,
        fallbackSystemImage: String
    ) -> some View {
        Group {
            if let image {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: fallbackSystemImage)
                    .resizable()
                    .scaledToFit()
                    .padding(6)
                    .foregroundColor(.secondary)
            }
        }
        .background(Color.secondary.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func selectionBackground(selected: Bool) -> some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(selected ? Color.accentColor.opacity(0.2) : Color.clear)
            .overlay {
                if selected {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.accentColor.opacity(0.7), lineWidth: 1)
                }
            }
    }

    private func loadImage(_ url: URL?) async -> NSImage? {
        guard let url else { return nil }
        let data = await Task.detached(priority: .utility) {
            try? Data(contentsOf: url)
        }.value
        return data.flatMap(NSImage.init(data:))
    }
}
