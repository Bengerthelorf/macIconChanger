//
//  IconChangerApp.swift
//  IconChanger
//
//  Created by 朱浩宇 on 2022/4/27.
//  Modified by seril on 2023/7/25.
//

import SwiftUI
import Sparkle

@main
struct IconChangerApp: App {
    @StateObject var folderPermission = FolderPermission.shared
    private let updaterController: SPUStandardUpdaterController

    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var backgroundService = BackgroundService.shared
    @StateObject private var cliManager = CLIManager.shared

    init() {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("--install-cli") {
            Task {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                CLIManager.shared.installCLI()
            }
        }

        updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
        migrateAPIKeyToKeychain()
        setupDefaultAliasNames()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: folderPermission.hasPermission ? 900 : 500,
                       minHeight: folderPermission.hasPermission ? 500 : 300)
                .animation(.easeInOut, value: folderPermission.hasPermission)
                .onAppear {
                    cliManager.checkInstallation()
                    ConfigManager.shared.checkForCLIImports()
                }
        }
        .commands {
            CommandGroup(after: .appInfo) {
                CheckForUpdatesView(updater: updaterController.updater)
            }

            CommandGroup(after: .windowSize) {
                Menu("Background Service") {
                    Toggle("Run in Background", isOn: $backgroundService.runInBackground)
                        .onChange(of: backgroundService.runInBackground) { newValue in
                            if newValue {
                                backgroundService.startBackgroundService()
                            } else {
                                backgroundService.stopBackgroundService()
                            }
                        }

                    if backgroundService.runInBackground {
                        Divider()

                        Button("Restore All Cached Icons") {
                            Task {
                                try? await IconManager.shared.restoreAllCachedIcons()
                            }
                        }

                        Divider()

                        Toggle("Show in Menu Bar", isOn: $backgroundService.showInMenuBar)
                            .disabled(!backgroundService.runInBackground)

                        Toggle("Show in Dock", isOn: $backgroundService.showInDock)
                            .disabled(!backgroundService.runInBackground)
                    }
                }
            }

            CommandGroup(replacing: .help) {
                Button("IconChanger Help") {
                    if let url = URL(string: "https://bengerthelorf.github.io/macIconChanger/") {
                        NSWorkspace.shared.open(url)
                    }
                }
                .keyboardShortcut("?", modifiers: .command)
            }

            CommandGroup(after: .appSettings) {
                Menu("Command Line Tool") {
                    if cliManager.isInstalled {
                        Button("Uninstall CLI Tool") {
                            cliManager.uninstallCLI()
                        }
                    } else {
                        Button("Install CLI Tool") {
                            cliManager.installCLI()
                        }
                    }
                }
            }
        }

        Settings {
            SettingsView(updater: updaterController.updater)
        }
    }

    private func migrateAPIKeyToKeychain() {
        let defaults = UserDefaults.standard
        if let key = defaults.string(forKey: "apiKey"), !key.isEmpty {
            KeychainHelper.save(key: "apiKey", value: key)
            defaults.removeObject(forKey: "apiKey")
        }
    }
}
