//
//  IconChangerApp.swift
//  IconChanger
//
//  Created by 朱浩宇 on 2022/4/27.
//  Modified by seril on 2023/7/25.
//  Modified to add background service on 2025/3/23.
//

import SwiftUI
import Sparkle

@main
struct IconChangerApp: App {
    @StateObject var folderPermission = FolderPermission.shared
    private let updaterController: SPUStandardUpdaterController
    
    // Add AppDelegate for handling background operations
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // Add state object for background service
    @StateObject private var backgroundService = BackgroundService.shared
    
    // 添加CLI管理器
    @StateObject private var cliManager = CLIManager.shared

    init() {
        // If you want to start the updater manually, pass false to startingUpdater and call .startUpdater() later
        // This is where you can also pass an updater delegate if you need one
        updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
        setupDefaultAliasNames()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: folderPermission.hasPermission ? 900 : 500, minHeight: folderPermission.hasPermission ? 500 : 300)
                .animation(.easeInOut, value: folderPermission.hasPermission)
                .onAppear {
                    // Check if background service should be running
                    if backgroundService.runInBackground {
                        backgroundService.startBackgroundService()
                    }
                    
                    // 检查CLI工具状态
                    cliManager.checkInstallation()
                    
                    // 检查是否有通过CLI导入的配置
                    ConfigManager.shared.checkForCLIImports()
                }
        }
        .commands {
            CommandGroup(after: .appInfo) {
                CheckForUpdatesView(updater: updaterController.updater)
            }
            
            // Add a new command group for background operations
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
            
            // 添加CLI工具菜单
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
            SettingsView()
        }
    }
}
