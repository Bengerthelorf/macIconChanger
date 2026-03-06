//
//  SettingView.swift
//  IconChanger
//
//  Created by 朱浩宇 on 2022/4/28.
//  Modified by Bengerthelorf on 2025/3/21.
//  Modified to add background service on 2025/3/23.
//  Modified to add configuration import/export on 2025/3/25.
//

import SwiftUI

// Language manager and related types
enum AppLanguage: String, CaseIterable, Identifiable {
    case system = "system"
    case english = "en"
    case french = "fr"
    case japanese = "ja"
    case chinese_simplified = "zh-Hans"
    case chinese_traditional = "zh-Hant"

    var id: String { self.rawValue }

    var displayName: String {
        switch self {
        case .system:
            return NSLocalizedString("System Default", comment: "Language selection")
        case .english:
            return NSLocalizedString("English", comment: "Language selection")
        case .french:
            return NSLocalizedString("French", comment: "Language selection")
        case .japanese:
            return NSLocalizedString("Japanese", comment: "Language selection")
        case .chinese_simplified:
            return NSLocalizedString("Simplified Chinese", comment: "Language selection")
        case .chinese_traditional:
            return NSLocalizedString("Traditional Chinese", comment: "Language selection")
        }
    }

    var locale: Locale {
        switch self {
        case .system:
            return Locale.current
        case .english:
            return Locale(identifier: "en")
        case .french:
            return Locale(identifier: "fr")
        case .japanese:
            return Locale(identifier: "ja")
        case .chinese_simplified:
            return Locale(identifier: "zh-Hans")
        case .chinese_traditional:
            return Locale(identifier: "zh-Hant")
        }
    }
}

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()

    @AppStorage("appLanguage") private var storedLanguage: String = AppLanguage.system.rawValue

    @Published var currentLanguage: AppLanguage {
        didSet {
            if oldValue != currentLanguage {
                applyLanguage()
            }
        }
    }

    private init() {
        let language = AppLanguage(rawValue: UserDefaults.standard.string(forKey: "appLanguage") ?? AppLanguage.system.rawValue) ?? .system
        self.currentLanguage = language
        applyLanguage()
    }

    private func applyLanguage() {
        storedLanguage = currentLanguage.rawValue

        if currentLanguage != .system {
            UserDefaults.standard.set([currentLanguage.rawValue], forKey: "AppleLanguages")
        } else {
            UserDefaults.standard.removeObject(forKey: "AppleLanguages")
        }

        UserDefaults.standard.synchronize()
    }
}

struct LanguageSettingsView: View {
    @ObservedObject private var languageManager = LanguageManager.shared
    @State private var showRestartAlert = false

    var body: some View {
        Form {
            Section {
                Picker(NSLocalizedString("Language", comment: "Settings section title"), selection: Binding(
                    get: { self.languageManager.currentLanguage },
                    set: { newValue in
                        self.languageManager.currentLanguage = newValue
                        self.showRestartAlert = true
                    }
                )) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(language.displayName).tag(language)
                    }
                }
                .pickerStyle(RadioGroupPickerStyle())
                .labelsHidden()
            } header: {
                Label(NSLocalizedString("Language", comment: "Settings section title"), systemImage: "globe")
            } footer: {
                Label(NSLocalizedString("Changes will take full effect after restarting the app", comment: "Language settings instruction"), systemImage: "info.circle")
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

struct SettingsView: View {
    var body: some View {
        TabView {
            ApplicationSettingsView()
                .tabItem {
                    Label("Application", systemImage: "app")
                }

            CachedIconsView()
                .tabItem {
                    Label("Icon Cache", systemImage: "arrow.triangle.2.circlepath")
                }

            BackgroundSettingsView()
                .tabItem {
                    Label("Background", systemImage: "clock.arrow.circlepath")
                }

            APISettingsView()
                .tabItem {
                    Label(NSLocalizedString("API", comment: "Settings tab"), systemImage: "bolt")
                }

            ConfigSettingsView()
                .tabItem {
                    Label("Configuration", systemImage: "square.and.arrow.up.on.square")
                }

            CLISettingsView()
                .tabItem {
                    Label("Command Line", systemImage: "terminal")
                }

            LanguageSettingsView()
                .tabItem {
                    Label(NSLocalizedString("Language", comment: "Settings tab"), systemImage: "globe")
                }
        }
        .padding()
        .frame(width: 600, height: 500)
    }
}
