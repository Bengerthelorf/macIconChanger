//
//  AboutSettingsView.swift
//  IconChanger
//

import SwiftUI
import Sparkle

struct AboutSettingsView: View {
    private let updater: SPUUpdater
    @State private var avatarImage: NSImage?

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

            Text("Version \(appVersion) (\(buildNumber))")
                .foregroundColor(.secondary)

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
        .task {
            await loadAvatar()
        }
    }

    private static let avatarURL = URL(string: "https://github.com/Bengerthelorf.png?size=64")!
    private static var cacheFileURL: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".iconchanger", isDirectory: true)
            .appendingPathComponent("avatar_cache.png")
    }

    private func loadAvatar() async {
        // 1. Show best available local image: disk cache > bundled fallback
        let local = Self.loadCachedAvatar() ?? Self.loadBundledAvatar()
        if let local {
            await MainActor.run { avatarImage = local }
        }

        // 2. Try to fetch fresh avatar in background to update cache
        do {
            let (data, response) = try await URLSession.shared.data(from: Self.avatarURL)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let image = NSImage(data: data) else { return }
            try? data.write(to: Self.cacheFileURL, options: .atomic)
            await MainActor.run { avatarImage = image }
        } catch {}
    }

    private static func loadCachedAvatar() -> NSImage? {
        guard FileManager.default.fileExists(atPath: cacheFileURL.path),
              let data = try? Data(contentsOf: cacheFileURL),
              let image = NSImage(data: data) else { return nil }
        return image
    }

    private static func loadBundledAvatar() -> NSImage? {
        guard let url = Bundle.main.url(forResource: "avatar_bengerthelorf", withExtension: "png"),
              let image = NSImage(contentsOf: url) else { return nil }
        return image
    }
}
