//
//  BackgroundSettingsView.swift
//  IconChanger
//

import SwiftUI
import UserNotifications

struct BackgroundSettingsView: View {
    @StateObject private var backgroundService = BackgroundService.shared

    private let intervalOptions = [
        (1, "Every Hour"),
        (3, "Every 3 Hours"),
        (6, "Every 6 Hours"),
        (12, "Every 12 Hours"),
        (24, "Every Day"),
        (48, "Every 2 Days"),
        (72, "Every 3 Days"),
        (0, "Custom...")
    ]

    private let checkIntervalOptions = [
        (5, "Every 5 Minutes"),
        (15, "Every 15 Minutes"),
        (30, "Every 30 Minutes"),
        (60, "Every Hour"),
        (120, "Every 2 Hours"),
        (0, "Custom...")
    ]

    @State private var showCustomRestoreIntervalDialog = false
    @State private var temporaryCustomRestoreInterval: String = ""
    @State private var showCustomCheckIntervalDialog = false
    @State private var temporaryCustomCheckInterval: String = ""

    var body: some View {
        Form {
            Section {
                Toggle("Launch at Login", isOn: $backgroundService.launchAtLogin)

                if backgroundService.launchAtLogin {
                    Picker("Launch Behavior", selection: $backgroundService.launchBehavior) {
                        Text("Open Main Window").tag(BackgroundService.LaunchBehavior.openWindow)
                        Text("Start Hidden").tag(BackgroundService.LaunchBehavior.hidden)
                    }

                    if backgroundService.launchBehavior == .hidden && !backgroundService.runInBackground {
                        Label("\"Start Hidden\" requires \"Run in Background\" to be enabled.", systemImage: "exclamationmark.triangle")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            } header: {
                Label("Login", systemImage: "power")
            }

            Section {
                Toggle("Run in Background", isOn: $backgroundService.runInBackground)
                    .onChange(of: backgroundService.runInBackground) { newValue in
                        if newValue {
                            backgroundService.startBackgroundService()
                        } else {
                            backgroundService.stopBackgroundService()
                        }
                    }
            } header: {
                Label("Background Service", systemImage: "clock.arrow.circlepath")
            }

            if backgroundService.runInBackground {
                Section {
                    Toggle("Show in Menu Bar", isOn: $backgroundService.showInMenuBar)
                        .onChange(of: backgroundService.showInMenuBar) { _ in
                            handleVisibilityChange()
                        }
                    Toggle("Show in Dock", isOn: $backgroundService.showInDock)
                        .onChange(of: backgroundService.showInDock) { _ in
                            handleVisibilityChange()
                        }
                } header: {
                    Label("App Visibility", systemImage: "eye")
                }

                Section {
                    Toggle("Restore Icons on Schedule", isOn: $backgroundService.enableScheduledRestore)

                    if backgroundService.enableScheduledRestore {
                        Picker("Interval", selection: Binding(
                            get: {
                                backgroundService.useCustomScheduledRestoreInterval ? 0 : backgroundService.scheduledRestoreInterval
                            },
                            set: { newValue in
                                if newValue == 0 {
                                    temporaryCustomRestoreInterval = "\(backgroundService.customScheduledRestoreInterval)"
                                    showCustomRestoreIntervalDialog = true
                                } else {
                                    backgroundService.scheduledRestoreInterval = newValue
                                    backgroundService.useCustomScheduledRestoreInterval = false
                                    backgroundService.setupTimers()
                                }
                            }
                        )) {
                            ForEach(intervalOptions, id: \.0) { option in
                                Text(option.1).tag(option.0)
                            }
                        }

                        if backgroundService.useCustomScheduledRestoreInterval {
                            LabeledContent("Custom Interval") {
                                HStack(spacing: 6) {
                                    Text(backgroundService.formatInterval(backgroundService.customScheduledRestoreInterval))
                                        .foregroundColor(.blue)
                                    Button {
                                        temporaryCustomRestoreInterval = "\(backgroundService.customScheduledRestoreInterval)"
                                        showCustomRestoreIntervalDialog = true
                                    } label: {
                                        Image(systemName: "pencil.circle")
                                    }
                                    .buttonStyle(.borderless)
                                }
                            }
                        }

                        if backgroundService.lastScheduledRestore != Date.distantPast {
                            LabeledContent("Last Restore") {
                                Text(formatDate(backgroundService.lastScheduledRestore))
                                    .foregroundColor(.secondary)
                            }
                        }

                        LabeledContent("Next Restore") {
                            Text(calculateNextRestoreTime())
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Label("Scheduled Restoration", systemImage: "calendar.badge.clock")
                }

                Section {
                    Toggle("Restore Icons When Apps Update", isOn: $backgroundService.enableAutoRestoreOnUpdate)

                    if backgroundService.enableAutoRestoreOnUpdate {
                        Picker("Check Interval", selection: Binding(
                            get: {
                                checkIntervalOptions.contains(where: { $0.0 == backgroundService.autoRestoreCheckInterval }) ?
                                backgroundService.autoRestoreCheckInterval : 0
                            },
                            set: { newValue in
                                if newValue == 0 {
                                    temporaryCustomCheckInterval = "\(backgroundService.autoRestoreCheckInterval)"
                                    showCustomCheckIntervalDialog = true
                                } else {
                                    backgroundService.autoRestoreCheckInterval = newValue
                                    backgroundService.setupTimers()
                                }
                            }
                        )) {
                            ForEach(checkIntervalOptions, id: \.0) { option in
                                Text(option.1).tag(option.0)
                            }
                        }

                        if !checkIntervalOptions.dropLast().contains(where: { $0.0 == backgroundService.autoRestoreCheckInterval }) {
                            LabeledContent("Custom Interval") {
                                HStack(spacing: 6) {
                                    Text(backgroundService.formatMinuteInterval(backgroundService.autoRestoreCheckInterval))
                                        .foregroundColor(.blue)
                                    Button {
                                        temporaryCustomCheckInterval = "\(backgroundService.autoRestoreCheckInterval)"
                                        showCustomCheckIntervalDialog = true
                                    } label: {
                                        Image(systemName: "pencil.circle")
                                    }
                                    .buttonStyle(.borderless)
                                }
                            }
                        }

                        if backgroundService.lastUpdateCheck != Date.distantPast {
                            LabeledContent("Last Check") {
                                Text(formatDate(backgroundService.lastUpdateCheck))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } header: {
                    Label("App Update Detection", systemImage: "arrow.triangle.2.circlepath")
                } footer: {
                    if backgroundService.enableAutoRestoreOnUpdate {
                        Text("The app will monitor your cached applications for updates and automatically restore their custom icons when updates are detected.")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                Section {
                    LabeledContent {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Running")
                                .foregroundColor(.secondary)
                        }
                    } label: {
                        Text("Service Status")
                    }

                    if IconCacheManager.shared.getCachedIconsCount() > 0 {
                        LabeledContent("Cached Icons") {
                            Text("\(IconCacheManager.shared.getCachedIconsCount()) ready for restoration")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .formStyle(.grouped)
        .sheet(isPresented: $showCustomRestoreIntervalDialog) {
            customRestoreIntervalDialog
        }
        .sheet(isPresented: $showCustomCheckIntervalDialog) {
            customCheckIntervalDialog
        }
    }

    private var customRestoreIntervalDialog: some View {
        VStack(spacing: 20) {
            Text("Set Custom Restoration Interval")
                .font(.headline)

            HStack {
                TextField("Hours", text: $temporaryCustomRestoreInterval)
                    .frame(width: 80)
                    .textFieldStyle(.roundedBorder)
                Text("hours")
            }

            Text("Enter a custom interval (in hours) for automatic icon restoration.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 20) {
                Button("Cancel") {
                    showCustomRestoreIntervalDialog = false
                }

                Button("Save") {
                    if let hours = Int(temporaryCustomRestoreInterval), hours > 0 {
                        backgroundService.customScheduledRestoreInterval = hours
                        backgroundService.useCustomScheduledRestoreInterval = true
                        backgroundService.setupTimers()
                    }
                    showCustomRestoreIntervalDialog = false
                }
                .keyboardShortcut(.defaultAction)
                .disabled((Int(temporaryCustomRestoreInterval) ?? 0) <= 0)
            }
        }
        .padding()
        .frame(width: 350, height: 200)
    }

    private var customCheckIntervalDialog: some View {
        VStack(spacing: 20) {
            Text("Set Custom Check Interval")
                .font(.headline)

            HStack {
                TextField("Minutes", text: $temporaryCustomCheckInterval)
                    .frame(width: 80)
                    .textFieldStyle(.roundedBorder)
                Text("minutes")
            }

            Text("Enter a custom interval (in minutes) for checking app updates.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 20) {
                Button("Cancel") {
                    showCustomCheckIntervalDialog = false
                }

                Button("Save") {
                    if let minutes = Int(temporaryCustomCheckInterval), minutes > 0 {
                        backgroundService.autoRestoreCheckInterval = minutes
                        backgroundService.setupTimers()
                    }
                    showCustomCheckIntervalDialog = false
                }
                .keyboardShortcut(.defaultAction)
                .disabled((Int(temporaryCustomCheckInterval) ?? 0) <= 0)
            }
        }
        .padding()
        .frame(width: 350, height: 200)
    }

    private static let shortDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .short
        return f
    }()

    private func formatDate(_ date: Date) -> String {
        Self.shortDateFormatter.string(from: date)
    }

    private func calculateNextRestoreTime() -> String {
        guard backgroundService.enableScheduledRestore && backgroundService.lastScheduledRestore != Date.distantPast else {
            return NSLocalizedString("Not scheduled", comment: "Status when no restore is scheduled")
        }

        let interval = backgroundService.useCustomScheduledRestoreInterval ?
            backgroundService.customScheduledRestoreInterval : backgroundService.scheduledRestoreInterval

        let nextRestoreDate = backgroundService.lastScheduledRestore.addingTimeInterval(TimeInterval(interval * 3600))
        return Self.shortDateFormatter.string(from: nextRestoreDate)
    }

    private func handleVisibilityChange() {
        if !backgroundService.showInMenuBar && !backgroundService.showInDock {
            DispatchQueue.main.async {
                backgroundService.showInMenuBar = true
            }

            let alert = NSAlert()
            alert.messageText = NSLocalizedString("Visibility Required", comment: "Alert title")
            alert.informativeText = NSLocalizedString("IconChanger needs to be visible in either the menu bar or the dock when running in the background.", comment: "Alert body")
            alert.alertStyle = .informational
            alert.addButton(withTitle: NSLocalizedString("OK", comment: "Alert button"))
            alert.runModal()
        }
    }
}
