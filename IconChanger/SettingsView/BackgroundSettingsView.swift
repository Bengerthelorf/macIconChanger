//
//  BackgroundSettingsView.swift
//  IconChanger
//
//  Created by Bengerthelorf on 2025/03/23.
//

import SwiftUI
import UserNotifications

struct BackgroundSettingsView: View {
    @ObservedObject private var backgroundService = BackgroundService.shared
    
    // Time interval options for scheduled restore
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
    
    // Time interval options for app update checks
    private let checkIntervalOptions = [
        (5, "Every 5 Minutes"),
        (15, "Every 15 Minutes"),
        (30, "Every 30 Minutes"),
        (60, "Every Hour"),
        (120, "Every 2 Hours"),
        (0, "Custom...")
    ]
    
    // State variables for custom intervals
    @State private var showCustomRestoreIntervalDialog = false
    @State private var temporaryCustomRestoreInterval: String = ""
    
    @State private var showCustomCheckIntervalDialog = false
    @State private var temporaryCustomCheckInterval: String = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Section header
                HStack {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.title2)
                        .foregroundColor(.blue)
                    Text("Background Service")
                        .font(.title2)
                        .fontWeight(.medium)
                }
                .padding(.bottom, 5)
                
                // Background mode section
                VStack(alignment: .leading, spacing: 16) {
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
                            .padding(.vertical, 4)
                        
                        // Visibility options
                        Text("App Visibility")
                            .font(.headline)
                            .padding(.top, 4)
                        
                        Toggle("Show in Menu Bar", isOn: $backgroundService.showInMenuBar)
                            .padding(.leading, 10)
                            .onChange(of: backgroundService.showInMenuBar) { newValue in
                                handleVisibilityChange()
                            }
                        
                        Toggle("Show in Dock", isOn: $backgroundService.showInDock)
                            .padding(.leading, 10)
                            .onChange(of: backgroundService.showInDock) { newValue in
                                handleVisibilityChange()
                            }
                        
                        Divider()
                            .padding(.vertical, 4)
                        
                        // Scheduled restoration
                        Text("Automatic Icon Restoration")
                            .font(.headline)
                            .padding(.top, 4)
                        
                        Toggle("Restore Icons on Schedule", isOn: $backgroundService.enableScheduledRestore)
                            .padding(.leading, 10)
                        
                        if backgroundService.enableScheduledRestore {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Interval:")
                                        .padding(.leading, 20)
                                    
                                    Picker("", selection: Binding(
                                        get: {
                                            backgroundService.useCustomScheduledRestoreInterval ? 0 : backgroundService.scheduledRestoreInterval
                                        },
                                        set: { newValue in
                                            if newValue == 0 {
                                                // User selected "Custom..."
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
                                            if option.0 == 0 {
                                                Text(option.1).tag(option.0)
                                            } else {
                                                Text(option.1).tag(option.0)
                                            }
                                        }
                                    }
                                    .frame(width: 180)
                                }
                                
                                // Display the custom interval if selected
                                if backgroundService.useCustomScheduledRestoreInterval {
                                    HStack {
                                        Text("Custom Interval:")
                                            .padding(.leading, 20)
                                        
                                        Text(backgroundService.formatInterval(backgroundService.customScheduledRestoreInterval))
                                            .foregroundColor(.blue)
                                        
                                        Button(action: {
                                            temporaryCustomRestoreInterval = "\(backgroundService.customScheduledRestoreInterval)"
                                            showCustomRestoreIntervalDialog = true
                                        }) {
                                            Image(systemName: "pencil")
                                                .font(.caption)
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                    }
                                }
                                
                                if backgroundService.lastScheduledRestore != Date.distantPast {
                                    HStack {
                                        Text("Last Restore:")
                                            .padding(.leading, 20)
                                        Text(formatDate(backgroundService.lastScheduledRestore))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Text("Next restore: \(calculateNextRestoreTime())")
                                    .padding(.leading, 20)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Divider()
                            .padding(.vertical, 4)
                        
                        // Auto-restore on app updates
                        Toggle("Restore Icons When Apps Update", isOn: $backgroundService.enableAutoRestoreOnUpdate)
                            .padding(.leading, 10)
                        
                        if backgroundService.enableAutoRestoreOnUpdate {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Check Interval:")
                                        .padding(.leading, 20)
                                    
                                    Picker("", selection: Binding(
                                        get: {
                                            checkIntervalOptions.contains(where: { $0.0 == backgroundService.autoRestoreCheckInterval }) ?
                                            backgroundService.autoRestoreCheckInterval : 0
                                        },
                                        set: { newValue in
                                            if newValue == 0 {
                                                // User selected "Custom..."
                                                temporaryCustomCheckInterval = "\(backgroundService.autoRestoreCheckInterval)"
                                                showCustomCheckIntervalDialog = true
                                            } else {
                                                backgroundService.autoRestoreCheckInterval = newValue
                                                backgroundService.setupTimers()
                                            }
                                        }
                                    )) {
                                        ForEach(checkIntervalOptions, id: \.0) { option in
                                            if option.0 == 0 {
                                                Text(option.1).tag(option.0)
                                            } else {
                                                Text(option.1).tag(option.0)
                                            }
                                        }
                                    }
                                    .frame(width: 180)
                                }
                                
                                // Display custom check interval if not in preset list
                                if !checkIntervalOptions.dropLast().contains(where: { $0.0 == backgroundService.autoRestoreCheckInterval }) {
                                    HStack {
                                        Text("Custom Check Interval:")
                                            .padding(.leading, 20)
                                        
                                        Text(backgroundService.formatMinuteInterval(backgroundService.autoRestoreCheckInterval))
                                            .foregroundColor(.blue)
                                        
                                        Button(action: {
                                            temporaryCustomCheckInterval = "\(backgroundService.autoRestoreCheckInterval)"
                                            showCustomCheckIntervalDialog = true
                                        }) {
                                            Image(systemName: "pencil")
                                                .font(.caption)
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                    }
                                }
                                
                                Text("The app will monitor your cached applications for updates and automatically restore their custom icons when updates are detected.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.leading, 20)
                                    .padding(.top, 4)
                                
                                if backgroundService.lastUpdateCheck != Date.distantPast {
                                    HStack {
                                        Text("Last Check:")
                                            .padding(.leading, 20)
                                        Text(formatDate(backgroundService.lastUpdateCheck))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer(minLength: 20)
                
                // Status info at bottom
                if backgroundService.runInBackground {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Background service is running")
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 8)
                    .padding(.horizontal)
                    
                    // Current stats
                    if IconCacheManager.shared.getCachedIconsCount() > 0 {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                            Text("\(IconCacheManager.shared.getCachedIconsCount()) cached icons ready for restoration")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(NSColor.textBackgroundColor).opacity(0.5))
        // Custom Restoration Interval Dialog
        .sheet(isPresented: $showCustomRestoreIntervalDialog) {
            customRestoreIntervalDialog
        }
        // Custom Check Interval Dialog
        .sheet(isPresented: $showCustomCheckIntervalDialog) {
            customCheckIntervalDialog
        }
    }
    
    // Dialog for custom restoration interval
    private var customRestoreIntervalDialog: some View {
        VStack(spacing: 20) {
            Text("Set Custom Restoration Interval")
                .font(.headline)
            
            HStack {
                TextField("Hours", text: $temporaryCustomRestoreInterval)
                    .frame(width: 80)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Text("hours")
            }
            
            Text("Enter a custom interval (in hours) for automatic icon restoration.")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
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
                .disabled(Int(temporaryCustomRestoreInterval) == nil || Int(temporaryCustomRestoreInterval)! <= 0)
            }
        }
        .padding()
        .frame(width: 350, height: 200)
    }
    
    // Dialog for custom check interval
    private var customCheckIntervalDialog: some View {
        VStack(spacing: 20) {
            Text("Set Custom Check Interval")
                .font(.headline)
            
            HStack {
                TextField("Minutes", text: $temporaryCustomCheckInterval)
                    .frame(width: 80)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Text("minutes")
            }
            
            Text("Enter a custom interval (in minutes) for checking app updates.")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
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
                .disabled(Int(temporaryCustomCheckInterval) == nil || Int(temporaryCustomCheckInterval)! <= 0)
            }
        }
        .padding()
        .frame(width: 350, height: 200)
    }
    
    // Helper function to format dates
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // Calculate next restore time
    private func calculateNextRestoreTime() -> String {
        guard backgroundService.enableScheduledRestore && backgroundService.lastScheduledRestore != Date.distantPast else {
            return "Not scheduled"
        }
        
        let interval = backgroundService.useCustomScheduledRestoreInterval ?
            backgroundService.customScheduledRestoreInterval : backgroundService.scheduledRestoreInterval
        
        let nextRestoreDate = backgroundService.lastScheduledRestore.addingTimeInterval(TimeInterval(interval * 3600))
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        return formatter.string(from: nextRestoreDate)
    }
    
    // Handle visibility changes to ensure at least one option is selected
    private func handleVisibilityChange() {
        if !backgroundService.showInMenuBar && !backgroundService.showInDock {
            // If both are off, turn the menu bar back on
            DispatchQueue.main.async {
                backgroundService.showInMenuBar = true
            }
            
            // Show an alert explaining why
            let alert = NSAlert()
            alert.messageText = "Visibility Required"
            alert.informativeText = "IconChanger needs to be visible in either the menu bar or the dock when running in the background."
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
}
