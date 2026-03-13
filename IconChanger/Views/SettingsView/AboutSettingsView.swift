//
//  AboutSettingsView.swift
//  IconChanger
//

import SwiftUI
import Sparkle

struct AboutSettingsView: View {
    private let updater: SPUUpdater
    @State private var avatarImage: NSImage?
    @State private var fetchTask: Task<Void, Never>?
    private static var memoryCache: NSImage?
    @AppStorage("developerOptionsEnabled") private var developerOptionsEnabled = false
    @State private var versionTapCount = 0
    @State private var showDevUnlocked = false
    @State private var showCopied = false
    @State private var copiedWorkItem: DispatchWorkItem?
    @State private var devUnlockedWorkItem: DispatchWorkItem?

    init(updater: SPUUpdater) {
        self.updater = updater
    }

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
    }

    private var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
    }

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            ZStack(alignment: .bottomTrailing) {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 96, height: 96)

                if let avatarImage {
                    Image(nsImage: avatarImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(.white, lineWidth: 2))
                        .shadow(radius: 2)
                        .rotationEffect(.degrees(20))
                        .offset(x: 6, y: 6)
                }
            }

            Text("IconChanger")
                .font(.title.bold())

            Text(showDevUnlocked ? "Developer Options Enabled" : showCopied ? "Copied!" : "Version \(appVersion) (\(buildNumber))")
                .foregroundColor(showDevUnlocked ? .accentColor : showCopied ? .green : .secondary)
                .animation(.easeInOut, value: showDevUnlocked)
                .animation(.easeInOut, value: showCopied)
                .onTapGesture {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString("IconChanger \(appVersion) (\(buildNumber))", forType: .string)
                    copiedWorkItem?.cancel()
                    showCopied = true
                    let item = DispatchWorkItem { showCopied = false }
                    copiedWorkItem = item
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: item)

                    if developerOptionsEnabled { return }
                    if NSApp.currentEvent?.modifierFlags.contains(.option) == true {
                        unlockDeveloperOptions()
                    } else {
                        versionTapCount += 1
                        if versionTapCount >= 7 {
                            unlockDeveloperOptions()
                        }
                    }
                }
                .help("Click to copy version")

            VStack(spacing: 6) {
                Link("GitHub Repository", destination: URL(string: "https://github.com/Bengerthelorf/macIconChanger")!)
                Link("macosicons.com", destination: URL(string: "https://macosicons.com")!)
            }
            .font(.callout)

            CheckForUpdatesView(updater: updater)
                .padding(.top, 4)

            Spacer()

            Text("Made by Bengerthelorf & contributors")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            loadAvatar()
        }
        .onDisappear {
            fetchTask?.cancel()
            fetchTask = nil
        }
    }

    private func unlockDeveloperOptions() {
        developerOptionsEnabled = true
        devUnlockedWorkItem?.cancel()
        showDevUnlocked = true
        let item = DispatchWorkItem { showDevUnlocked = false }
        devUnlockedWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: item)
    }

    // MARK: - Avatar Caching (memory + disk + bundled asset)

    private static let avatarCacheURL: URL = {
        let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
            .appendingPathComponent(Bundle.main.bundleIdentifier ?? "com.zhuhaoyu.IconChanger", isDirectory: true)
        try? FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
        return cacheDir.appendingPathComponent("avatar.png")
    }()

    private static let cacheMaxAge: TimeInterval = 86400 // 24 hours

    private func loadAvatar() {
        // 1. Memory cache (instant)
        if let cached = Self.memoryCache {
            avatarImage = cached
            if Self.isDiskCacheStale {
                fetchTask = Task { await fetchAndCacheAvatar() }
            }
            return
        }

        // 2. Disk cache
        let cacheURL = Self.avatarCacheURL
        if FileManager.default.fileExists(atPath: cacheURL.path),
           let data = try? Data(contentsOf: cacheURL),
           let image = NSImage(data: data) {
            Self.memoryCache = image
            avatarImage = image
            if Self.isDiskCacheStale {
                fetchTask = Task { await fetchAndCacheAvatar() }
            }
            return
        }

        // 3. Bundled fallback from Assets.xcassets
        if let bundled = NSImage(named: "AuthorAvatar") {
            avatarImage = bundled
        }

        // 4. Network fetch
        fetchTask = Task { await fetchAndCacheAvatar() }
    }

    private static var isDiskCacheStale: Bool {
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: avatarCacheURL.path),
              let modified = attrs[.modificationDate] as? Date else {
            return true
        }
        return Date().timeIntervalSince(modified) >= cacheMaxAge
    }

    private func fetchAndCacheAvatar() async {
        guard let url = URL(string: "https://github.com/Bengerthelorf.png?size=64") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            try Task.checkCancellation()
            if let image = NSImage(data: data) {
                Self.memoryCache = image
                try? data.write(to: Self.avatarCacheURL, options: .atomic)
                avatarImage = image
            }
        } catch {}
    }
}
