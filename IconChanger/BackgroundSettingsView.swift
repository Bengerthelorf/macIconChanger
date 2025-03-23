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
        (72, "Every 3 Days")
    ]
    
    var body: some View {
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
                    .onChange(of: backgroundService.runInBackground) {oldValue, newValue in
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
                        .onChange(of: backgroundService.showInMenuBar) {oldValue, newValue in
                            handleVisibilityChange()
                        }
                    
                    Toggle("Show in Dock", isOn: $backgroundService.showInDock)
                        .padding(.leading, 10)
                        .onChange(of: backgroundService.showInDock) {oldValue, newValue in
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
                        HStack {
                            Text("Interval:")
                                .padding(.leading, 20)
                            Picker("", selection: $backgroundService.scheduledRestoreInterval) {
                                ForEach(intervalOptions, id: \.0) { option in
                                    Text(option.1).tag(option.0)
                                }
                            }
                            .frame(width: 180)
                        }
                        
                        if backgroundService.lastScheduledRestore != Date.distantPast {
                            HStack {
                                Text("Last Restore:")
                                    .padding(.leading, 20)
                                Text(formatDate(backgroundService.lastScheduledRestore))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Divider()
                        .padding(.vertical, 4)
                    
                    // Auto-restore on app updates
                    Toggle("Restore Icons When Apps Update", isOn: $backgroundService.enableAutoRestoreOnUpdate)
                        .padding(.leading, 10)
                    
                    if backgroundService.enableAutoRestoreOnUpdate {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("The app will monitor your cached applications for updates and automatically restore their custom icons when updates are detected.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.leading, 20)
                            
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
            
            Spacer()
            
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.textBackgroundColor).opacity(0.5))
    }
    
    // Helper function to format dates
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
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
