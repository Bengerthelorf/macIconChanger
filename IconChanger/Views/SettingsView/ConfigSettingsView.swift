//
//  ConfigSettingsView.swift
//  IconChanger
//
//  Created by Bengerthelorf on 2025/03/27.
//

import SwiftUI

struct ConfigSettingsView: View {
    @State private var showConfirmation = false
    @State private var confirmationMessage = ""
    @State private var confirmationTitle = ""

    private var aliasCount: Int {
        AliasNames.getAll().count
    }

    private var cachedIconsCount: Int {
        IconCacheManager.shared.getCachedIconsCount()
    }

    var body: some View {
        Form {
            Section {
                LabeledContent {
                    Text("\(aliasCount)")
                        .monospacedDigit()
                        .foregroundColor(.secondary)
                } label: {
                    Label("App Aliases", systemImage: "text.quote")
                }

                LabeledContent {
                    Text("\(cachedIconsCount)")
                        .monospacedDigit()
                        .foregroundColor(.secondary)
                } label: {
                    Label("Cached Icons", systemImage: "photo.on.rectangle")
                }
            } header: {
                Label("Current Configuration", systemImage: "info.circle")
            }

            Section {
                Button {
                    if let _ = ConfigManager.shared.exportConfigurationForCLI() {
                        ConfigManager.shared.showExportDialog()
                    }
                } label: {
                    Label("Export Configuration", systemImage: "square.and.arrow.up")
                }
                .disabled(aliasCount == 0 && cachedIconsCount == 0)

                Button {
                    ConfigManager.shared.showImportDialog()
                } label: {
                    Label("Import Configuration", systemImage: "square.and.arrow.down")
                }
            } header: {
                Label("Actions", systemImage: "square.and.arrow.up.on.square")
            } footer: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Export your aliases and icon cache for backup or to use on another Mac.")
                    Text("Import will only add new items, never replace or remove existing ones.")
                    Text("Command line configuration is available with the 'iconchanger' tool.")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .formStyle(.grouped)
        .alert(isPresented: $showConfirmation) {
            Alert(
                title: Text(confirmationTitle),
                message: Text(confirmationMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            ConfigManager.shared.checkForCLIImports()
        }
    }
}
