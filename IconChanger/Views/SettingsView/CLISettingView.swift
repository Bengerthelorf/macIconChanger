//
//  CLISettingView.swift
//  IconChanger
//
//  Created by Zane on 3/26/25.
//

import SwiftUI

struct CLISettingsView: View {
    @StateObject private var cliManager = CLIManager.shared
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
                        Text("The IconChanger CLI provides command-line access to manage app icons, aliases, and configurations.")
                            .foregroundColor(.secondary)

                        cliExample("Set a custom icon:", "iconchanger set-icon /Applications/App.app icon.png")
                        cliExample("Remove a custom icon:", "iconchanger remove-icon /Applications/App.app")
                        cliExample("Restore all cached icons:", "iconchanger restore")
                        cliExample("Show status:", "iconchanger status")
                        cliExample("List aliases & cached icons:", "iconchanger list")
                        cliExample("Import a configuration:", "iconchanger import config.json")
                        cliExample("Export a configuration:", "iconchanger export config.json")
                        cliExample("Validate a config file:", "iconchanger validate config.json")

                        Text("Run 'iconchanger --help' for full usage details.")
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

    private func cliExample(_ title: String, _ command: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
            Text(command)
                .font(.system(.callout, design: .monospaced))
                .foregroundColor(.secondary)
                .textSelection(.enabled)
        }
    }
}
