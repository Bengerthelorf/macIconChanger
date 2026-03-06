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

            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .scaledToFit()
                .frame(width: 96, height: 96)

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

            HStack(spacing: 8) {
                if let avatarImage {
                    Image(nsImage: avatarImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 24, height: 24)
                        .clipShape(Circle())
                }
                Text("Made by Bengerthelorf & contributors")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            await loadAvatar()
        }
    }

    private func loadAvatar() async {
        guard let url = URL(string: "https://github.com/Bengerthelorf.png?size=48") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = NSImage(data: data) {
                await MainActor.run { avatarImage = image }
            }
        } catch {}
    }
}
