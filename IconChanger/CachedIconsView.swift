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
                    HStack(spacing: 16) {
                        let iconURL = IconCacheManager.cacheDirectory.appendingPathComponent(cache.iconFileName)
                        if let image = NSImage(contentsOf: iconURL) {
                            Image(nsImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .cornerRadius(8)
                        } else {
                            Image(systemName: "questionmark.square")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(cache.appName)
                                .font(.headline)
                            
                            HStack {
                                Image(systemName: "clock")
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                                Text(formatDate(cache.timestamp))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
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
                        clearCache()
                    } label: {
                        Label("Clear Cache", systemImage: "trash")
                    }
                    .disabled(cachedIcons.isEmpty)
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
    }
    
    private func loadCachedIcons() {
        cachedIcons = IconCacheManager.shared.getAllCachedIcons()
            .sorted { $0.timestamp > $1.timestamp } // Sort by most recently applied
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
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
    
    private func clearCache() {
        IconCacheManager.shared.clearCache()
        cachedIcons = []
    }
}
