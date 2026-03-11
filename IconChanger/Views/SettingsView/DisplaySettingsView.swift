//
//  DisplaySettingsView.swift
//  IconChanger
//

import SwiftUI

struct DisplaySettingsView: View {
    @AppStorage("showCustomIconBadge") private var showCustomIconBadge = true
    @AppStorage("dockGlassIntensity") private var dockGlassIntensity: Double = 0.5
    @AppStorage("dockPreviewMode") private var dockPreviewMode: String = "dockOnly"
    @AppStorage("appAppearance") private var appAppearance: String = AppAppearance.system.rawValue
    @StateObject private var languageManager = LanguageManager.shared
    @State private var showRestartAlert = false

    var body: some View {
        Form {
            // MARK: - Appearance
            Section {
                Picker(selection: Binding(
                    get: { AppAppearance(rawValue: appAppearance) ?? .system },
                    set: { newValue in
                        appAppearance = newValue.rawValue
                        AppAppearance.apply(newValue)
                    }
                )) {
                    ForEach(AppAppearance.allCases) { option in
                        Text(option.displayName).tag(option)
                    }
                } label: {
                    Label(NSLocalizedString("Appearance", comment: "Display setting"), systemImage: "circle.lefthalf.filled")
                }
                .pickerStyle(.segmented)

                Toggle(isOn: $showCustomIconBadge) {
                    Label(NSLocalizedString("Show Custom Icon Badge", comment: "Display setting"), systemImage: "checkmark.circle.fill")
                }
            } header: {
                Label(NSLocalizedString("Appearance", comment: "Settings section"), systemImage: "paintbrush")
            } footer: {
                Text(NSLocalizedString("Show a green checkmark badge on apps with custom icons in the sidebar.", comment: "Display setting description"))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            // MARK: - Dock Preview
            Section {
                Picker(selection: $dockPreviewMode) {
                    Text(NSLocalizedString("Only When Dock Filter", comment: "Dock preview option")).tag("dockOnly")
                    Text(NSLocalizedString("Always", comment: "Dock preview option")).tag("always")
                } label: {
                    Label(NSLocalizedString("Dock Preview", comment: "Display setting"), systemImage: "dock.rectangle")
                }

                if #available(macOS 26, *) {
                    Slider(value: $dockGlassIntensity, in: 0...1, step: 0.1) {
                        Label(NSLocalizedString("Dock Glass Intensity", comment: "Display setting"), systemImage: "cube.transparent")
                    } minimumValueLabel: {
                        Image(systemName: "circle.dotted")
                            .foregroundColor(.secondary)
                    } maximumValueLabel: {
                        Image(systemName: "cube.transparent.fill")
                            .foregroundColor(.secondary)
                    }
                }
            } header: {
                Label(NSLocalizedString("Dock Preview", comment: "Settings section"), systemImage: "dock.rectangle")
            }

            // MARK: - Language
            Section {
                Picker(NSLocalizedString("Language", comment: "Settings section title"), selection: Binding(
                    get: { languageManager.currentLanguage },
                    set: { newValue in
                        languageManager.currentLanguage = newValue
                        showRestartAlert = true
                    }
                )) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(language.displayName).tag(language)
                    }
                }
            } header: {
                Label(NSLocalizedString("Language", comment: "Settings section title"), systemImage: "globe")
            } footer: {
                Label(NSLocalizedString("Changes will take full effect after restarting the app", comment: "Language settings instruction"), systemImage: "info.circle")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .formStyle(.grouped)
        .alert(isPresented: $showRestartAlert) {
            Alert(
                title: Text(NSLocalizedString("Language Changed", comment: "Language alert title")),
                message: Text(NSLocalizedString("The language has been changed. For the best experience, please restart the application.", comment: "Language alert message")),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
