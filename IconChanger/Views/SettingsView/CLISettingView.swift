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
        Form {
            Section {
                LabeledContent {
                    HStack(spacing: 6) {
                        Image(systemName: cliManager.isInstalled ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(cliManager.isInstalled ? .green : .red)
                        Text(cliManager.isInstalled ? "Installed" : "Not Installed")
                    }
                } label: {
                    Text("Status")
                }

                LabeledContent("Installation Path") {
                    Text(cliManager.installLocation)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.secondary)
                        .textSelection(.enabled)
                }
            } header: {
                Label("Command Line Tool", systemImage: "terminal")
            }

            Section {
                HStack(spacing: 12) {
                    Button(role: cliManager.isInstalled ? .destructive : nil) {
                        if cliManager.isInstalled {
                            cliManager.uninstallCLI()
                        } else {
                            cliManager.installCLI()
                        }
                    } label: {
                        Label(
                            cliManager.isInstalled ? "Uninstall CLI Tool" : "Install CLI Tool",
                            systemImage: cliManager.isInstalled ? "trash" : "square.and.arrow.down"
                        )
                    }
                    .disabled(cliManager.isInstalling)

                    if cliManager.isInstalling {
                        ProgressView()
                            .controlSize(.small)
                    }
                }

                if let error = cliManager.lastError {
                    Label("Error: \(error)", systemImage: "exclamationmark.triangle")
                        .foregroundColor(.red)
                }
            }

            Section {
                DisclosureGroup("Usage Information", isExpanded: $showHelp) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("The IconChanger CLI tool provides command-line access to import and export configurations.")
                            .foregroundColor(.secondary)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Import a configuration:")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("iconchanger import /path/to/config.json")
                                .font(.system(.callout, design: .monospaced))
                                .foregroundColor(.secondary)
                                .textSelection(.enabled)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Export a configuration:")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("iconchanger export /path/to/save/config.json")
                                .font(.system(.callout, design: .monospaced))
                                .foregroundColor(.secondary)
                                .textSelection(.enabled)
                        }

                        Text("You must first export a configuration from the app before using the CLI export command. After importing with CLI, restart the app to see changes.")
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 6)
                }
            } header: {
                Label("Usage", systemImage: "book")
            }
        }
        .formStyle(.grouped)
    }
}
