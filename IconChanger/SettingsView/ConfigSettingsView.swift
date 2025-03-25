//
//  ConfigSettingsView.swift
//  IconChanger
//
//  Created by Bengerthelorf on 2025/03/27.
//

import SwiftUI

struct ConfigSettingsView: View {
    @State private var isExporting = false
    @State private var isImporting = false
    @State private var showConfirmation = false
    @State private var confirmationMessage = ""
    @State private var confirmationTitle = ""
    @State private var isSuccess = true
    
    // Statistics
    private var aliasCount: Int {
        AliasNames.getAll().count
    }
    
    private var cachedIconsCount: Int {
        IconCacheManager.shared.getCachedIconsCount()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header section
            HStack {
                Image(systemName: "square.and.arrow.up.on.square")
                    .font(.title2)
                    .foregroundColor(.blue)
                Text("Import & Export")
                    .font(.title2)
                    .fontWeight(.medium)
            }
            .padding(.top, 10)
            .padding(.bottom, 5)
            
            // Configuration statistics
            VStack(alignment: .leading, spacing: 12) {
                Text("Current Configuration")
                    .font(.headline)
                    .padding(.bottom, 4)
                
                HStack(spacing: 20) {
                    StatBox(
                        icon: "text.quote",
                        title: "App Aliases",
                        value: "\(aliasCount)",
                        color: .blue
                    )
                    
                    StatBox(
                        icon: "photo.on.rectangle",
                        title: "Cached Icons",
                        value: "\(cachedIconsCount)",
                        color: .green
                    )
                }
                .padding(.bottom, 10)
            }
            .padding(.horizontal, 5)
            
            Divider()
                .padding(.vertical, 5)
            
            // Action buttons
            HStack(spacing: 20) {
                Button(action: {
                    // 同时为GUI和CLI导出
                    if let _ = ConfigManager.shared.exportConfigurationForCLI() {
                        ConfigManager.shared.showExportDialog()
                    }
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .font(.body)
                        Text("Export Configuration")
                            .padding(.leading, 4)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(aliasCount == 0 && cachedIconsCount == 0)
                
                Button(action: {
                    ConfigManager.shared.showImportDialog()
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                            .font(.body)
                        Text("Import Configuration")
                            .padding(.leading, 4)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 5)
            
            Divider()
                .padding(.vertical, 5)
            
            // Information section
            VStack(alignment: .leading, spacing: 12) {
                Text("About Configuration Files")
                    .font(.headline)
                    .padding(.bottom, 4)
                
                InfoRow(
                    icon: "info.circle",
                    text: "Export your aliases and icon cache for backup or to use on another Mac"
                )
                
                InfoRow(
                    icon: "info.circle",
                    text: "Import will only add new items, never replace or remove existing ones"
                )
                
                InfoRow(
                    icon: "info.circle",
                    text: "Command line configuration is available with 'iconchanger' tool"
                )
            }
            .padding(.horizontal, 5)
            
            Spacer()
        }
        .padding()
        .background(Color(NSColor.textBackgroundColor).opacity(0.5))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert(isPresented: $showConfirmation) {
            Alert(
                title: Text(confirmationTitle),
                message: Text(confirmationMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            // 检查是否有通过CLI导入的配置需要处理
            ConfigManager.shared.checkForCLIImports()
        }
    }
}

// Helper view for configuration statistics
struct StatBox: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

// Helper view for information rows
struct InfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            Text(text)
                .font(.callout)
                .foregroundColor(.secondary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 4)
    }
}
