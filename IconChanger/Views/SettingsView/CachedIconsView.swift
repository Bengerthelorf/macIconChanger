//
//  CachedIconsView.swift
//  IconChanger
//
//  Created by Bengerthelorf on 2025/03/23.
//

import SwiftUI
import LaunchPadManagerDBHelper

struct CachedIconsView: View {
    @StateObject private var iconManager = IconManager.shared
    @State private var cachedIcons: [IconCache] = []
    @State private var selectedIconIds: Set<String> = []
    @State private var isRestoring = false
    @State private var restoreError: Error? = nil
    @State private var showRestoreSuccess = false
    @State private var showDeleteConfirmation = false

    private var isAllSelected: Bool {
        !cachedIcons.isEmpty && selectedIconIds.count == cachedIcons.count
    }

    var body: some View {
        VStack {
            if cachedIcons.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "archivebox")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                        .padding(.bottom, 10)

                    Text("No cached icons found")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Text("Icons will be cached automatically when you apply them to apps")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(cachedIcons, selection: $selectedIconIds) { cache in
                    CachedIconRow(cache: cache)
                    .padding(.vertical, 4)
                    .contextMenu {
                        Button {
                            restoreSingleIcon(cache)
                        } label: {
                            Label("Restore This Icon", systemImage: "arrow.clockwise")
                        }

                        Divider()

                        Button(role: .destructive) {
                            removeCachedIcon(cache)
                        } label: {
                            Label("Remove from Cache", systemImage: "trash")
                        }
                    }
                }

                HStack {
                    Button {
                        restoreAllIcons()
                    } label: {
                        Label("Restore All", systemImage: "arrow.clockwise")
                    }
                    .disabled(cachedIcons.isEmpty || isRestoring)

                    Spacer()

                    Button {
                        restoreSelected()
                    } label: {
                        Label("Restore Selected", systemImage: "arrow.clockwise.circle")
                    }
                    .disabled(selectedIconIds.isEmpty || isRestoring)

                    Spacer()

                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label(
                            isAllSelected ? "Clear All Cache" : "Remove Selected",
                            systemImage: "trash"
                        )
                    }
                    .disabled(selectedIconIds.isEmpty)
                }
                .padding()
            }
        }
        .onAppear {
            loadCachedIcons()
        }
        .sheet(isPresented: $isRestoring) {
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .padding(.bottom, 10)

                Text("Restoring icons...")
                    .font(.headline)

                if let error = restoreError {
                    Text("Error: \(error.localizedDescription)")
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
        .alert("Icons Restored", isPresented: $showRestoreSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Custom icons have been successfully restored.")
        }
        .confirmationDialog(
            isAllSelected
                ? "Are you sure you want to clear all \(cachedIcons.count) cached icons?"
                : "Are you sure you want to remove \(selectedIconIds.count) selected icon(s) from the cache?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button(isAllSelected ? "Clear All Cache" : "Remove Selected", role: .destructive) {
                if isAllSelected {
                    clearCache()
                } else {
                    removeSelectedIcons()
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This action cannot be undone. You will need to re-apply icons to cache them again.")
        }
    }

    private func loadCachedIcons() {
        cachedIcons = IconCacheManager.shared.getAllCachedIcons()
            .sorted { $0.timestamp > $1.timestamp }
    }

    private func restoreSingleIcon(_ cache: IconCache) {
        Task {
            isRestoring = true
            restoreError = nil

            do {
                let appPath = cache.appPath
                let iconURL = IconCacheManager.cacheDirectory.appendingPathComponent(cache.iconFileName)

                if FileManager.default.fileExists(atPath: appPath) &&
                   FileManager.default.fileExists(atPath: iconURL.path) {

                    if let image = NSImage(contentsOf: iconURL),
                       let appInfo = iconManager.apps.first(where: { $0.url.universalPath() == appPath }) {
                        try await iconManager.setIconWithoutCaching(image, app: appInfo)

                        await MainActor.run {
                            isRestoring = false
                            showRestoreSuccess = true
                        }
                    } else {
                        await MainActor.run {
                            restoreError = NSError(domain: "IconChanger", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not load icon or app no longer exists"])
                            isRestoring = false
                        }
                    }
                } else {
                    await MainActor.run {
                        restoreError = NSError(domain: "IconChanger", code: 2, userInfo: [NSLocalizedDescriptionKey: "App or cached icon file no longer exists"])
                        isRestoring = false
                    }
                }
            } catch {
                await MainActor.run {
                    restoreError = error
                    isRestoring = false
                }
            }
        }
    }

    private func restoreSelected() {
        guard !selectedIconIds.isEmpty else { return }

        let selectedCaches = cachedIcons.filter { selectedIconIds.contains($0.id) }

        Task {
            isRestoring = true
            restoreError = nil

            var failedApps: [(String, Error)] = []

            for cache in selectedCaches {
                do {
                    let appPath = cache.appPath
                    let iconURL = IconCacheManager.cacheDirectory.appendingPathComponent(cache.iconFileName)

                    if FileManager.default.fileExists(atPath: appPath) &&
                       FileManager.default.fileExists(atPath: iconURL.path) {

                        if let image = NSImage(contentsOf: iconURL),
                           let appInfo = iconManager.apps.first(where: { $0.url.universalPath() == appPath }) {
                            try await iconManager.setIconWithoutCaching(image, app: appInfo)
                        }
                    }
                } catch {
                    failedApps.append((cache.appName, error))
                }
            }

            await MainActor.run {
                isRestoring = false

                if failedApps.isEmpty {
                    showRestoreSuccess = true
                } else {
                    restoreError = RestoreError.someFailed(failed: failedApps)
                }
            }
        }
    }

    private func restoreAllIcons() {
        Task {
            isRestoring = true
            restoreError = nil

            do {
                try await iconManager.restoreAllCachedIcons()

                await MainActor.run {
                    isRestoring = false
                    showRestoreSuccess = true
                }
            } catch {
                await MainActor.run {
                    restoreError = error
                    isRestoring = false
                }
            }
        }
    }

    private func removeCachedIcon(_ cache: IconCache) {
        IconCacheManager.shared.removeCachedIcon(for: cache.appPath)
        loadCachedIcons()
    }

    private func removeSelectedIcons() {
        for id in selectedIconIds {
            if let cache = cachedIcons.first(where: { $0.id == id }) {
                IconCacheManager.shared.removeCachedIcon(for: cache.appPath)
            }
        }
        selectedIconIds.removeAll()
        loadCachedIcons()
    }

    private func clearCache() {
        IconCacheManager.shared.clearCache()
        selectedIconIds.removeAll()
        cachedIcons = []
    }
}

/// Row view that loads the cached icon image asynchronously to avoid blocking the main thread.
private struct CachedIconRow: View {
    let cache: IconCache
    @State private var image: NSImage?

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        HStack(spacing: 16) {
            Group {
                if let image {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFit()
                } else {
                    Image(systemName: "questionmark.square")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 40, height: 40)
            .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                Text(cache.appName)
                    .font(.headline)

                HStack {
                    Image(systemName: "clock")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    Text(Self.dateFormatter.string(from: cache.timestamp))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .task(id: cache.id) {
            let url = IconCacheManager.cacheDirectory.appendingPathComponent(cache.iconFileName)
            let loaded = await Task.detached(priority: .utility) { () -> Data? in
                try? Data(contentsOf: url)
            }.value
            if let data = loaded {
                image = NSImage(data: data)
            }
        }
    }
}
