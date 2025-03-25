//
//  CLISettingView.swift
//  IconChanger
//
//  Created by Zane on 3/26/25.
//

import SwiftUI

struct CLISettingsView: View {
    @ObservedObject private var cliManager = CLIManager.shared
    @State private var showHelp = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Title section
            HStack {
                Image(systemName: "terminal")
                    .font(.title2)
                    .foregroundColor(.blue)
                Text("Command Line Tool")
                    .font(.title2)
                    .fontWeight(.medium)
            }
            .padding(.top, 10)
            .padding(.bottom, 5)
            
            // Status section
            HStack {
                Image(systemName: cliManager.isInstalled ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(cliManager.isInstalled ? .green : .red)
                Text(cliManager.isInstalled ? "CLI Tool is installed" : "CLI Tool is not installed")
                    .font(.headline)
            }
            .padding(.bottom, 5)
            
            // Installation path
            HStack {
                Text("Installation Path:")
                Text(cliManager.installLocation)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 10)
            
            // Install/Uninstall button
            HStack(spacing: 15) {
                Button(action: {
                    if cliManager.isInstalled {
                        cliManager.uninstallCLI()
                    } else {
                        cliManager.installCLI()
                    }
                }) {
                    HStack {
                        Image(systemName: cliManager.isInstalled ? "trash" : "square.and.arrow.down")
                        Text(cliManager.isInstalled ? "Uninstall CLI Tool" : "Install CLI Tool")
                    }
                    .frame(minWidth: 150)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 15)
                }
                .buttonStyle(BorderedButtonStyle())
                .disabled(cliManager.isInstalling)
                
                if cliManager.isInstalling {
                    ProgressView()
                        .scaleEffect(0.8)
                        .padding(.leading, 5)
                }
            }
            
            // Error message
            if let error = cliManager.lastError {
                Text("Error: \(error)")
                    .font(.callout)
                    .foregroundColor(.red)
                    .padding(.top, 5)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Divider()
                .padding(.vertical, 10)
            
            // Usage instructions
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Usage Information")
                        .font(.headline)
                    
                    Button(action: { showHelp.toggle() }) {
                        Image(systemName: showHelp ? "chevron.up" : "chevron.down")
                            .font(.caption)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                
                if showHelp {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("The IconChanger CLI tool provides command-line access to import and export configurations.")
                            .font(.callout)
                            .foregroundColor(.secondary)
                        
                        Group {
                            Text("Import a configuration:")
                                .font(.caption)
                                .fontWeight(.bold)
                            
                            Text("iconchanger import /path/to/config.json")
                                .font(.system(.caption, design: .monospaced))
                                .padding(.horizontal, 10)
                                .foregroundColor(.secondary)
                        }
                        
                        Group {
                            Text("Export a configuration:")
                                .font(.caption)
                                .fontWeight(.bold)
                            
                            Text("iconchanger export /path/to/save/config.json")
                                .font(.system(.caption, design: .monospaced))
                                .padding(.horizontal, 10)
                                .foregroundColor(.secondary)
                        }
                        
                        Group {
                            Text("Important Note:")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                            
                            Text("You must first export a configuration from the app before using the CLI export command.")
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .foregroundColor(.secondary)
                            Text("After importing with CLI, restart the app to see the changes take effect.")
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.leading, 10)
                }
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}
