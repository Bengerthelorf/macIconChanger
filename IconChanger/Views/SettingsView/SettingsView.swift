//
//  SettingView.swift
//  IconChanger
//

import SwiftUI
import Sparkle

// Language manager and related types
enum AppLanguage: String, CaseIterable, Identifiable {
    case system = "system"
    case english = "en"
    case french = "fr"
    case german = "de"
    case spanish = "es"
    case portuguese = "pt"
    case italian = "it"
    case russian = "ru"
    case dutch = "nl"
    case turkish = "tr"
    case polish = "pl"
    case arabic = "ar"
    case thai = "th"
    case vietnamese = "vi"
    case indonesian = "id"
    case ukrainian = "uk"
    case swedish = "sv"
    case danish = "da"
    case norwegian = "nb"
    case finnish = "fi"
    case czech = "cs"
    case hungarian = "hu"
    case greek = "el"
    case romanian = "ro"
    case hindi = "hi"
    case malay = "ms"
    case japanese = "ja"
    case korean = "ko"
    case chinese_simplified = "zh-Hans"
    case chinese_traditional = "zh-Hant"
    case chinese_hongkong = "zh-HK"

    var id: String { self.rawValue }

    var displayName: String {
        switch self {
        case .system:
            return NSLocalizedString("System Default", comment: "Language selection")
        case .english:
            return NSLocalizedString("English", comment: "Language selection")
        case .french:
            return NSLocalizedString("French", comment: "Language selection")
        case .german:
            return NSLocalizedString("German", comment: "Language selection")
        case .spanish:
            return NSLocalizedString("Spanish", comment: "Language selection")
        case .portuguese:
            return NSLocalizedString("Portuguese", comment: "Language selection")
        case .italian:
            return NSLocalizedString("Italian", comment: "Language selection")
        case .russian:
            return NSLocalizedString("Russian", comment: "Language selection")
        case .dutch:
            return NSLocalizedString("Dutch", comment: "Language selection")
        case .turkish:
            return NSLocalizedString("Turkish", comment: "Language selection")
        case .polish:
            return NSLocalizedString("Polish", comment: "Language selection")
        case .arabic:
            return NSLocalizedString("Arabic", comment: "Language selection")
        case .thai:
            return NSLocalizedString("Thai", comment: "Language selection")
        case .vietnamese:
            return NSLocalizedString("Vietnamese", comment: "Language selection")
        case .indonesian:
            return NSLocalizedString("Indonesian", comment: "Language selection")
        case .ukrainian:
            return NSLocalizedString("Ukrainian", comment: "Language selection")
        case .swedish:
            return NSLocalizedString("Swedish", comment: "Language selection")
        case .danish:
            return NSLocalizedString("Danish", comment: "Language selection")
        case .norwegian:
            return NSLocalizedString("Norwegian", comment: "Language selection")
        case .finnish:
            return NSLocalizedString("Finnish", comment: "Language selection")
        case .czech:
            return NSLocalizedString("Czech", comment: "Language selection")
        case .hungarian:
            return NSLocalizedString("Hungarian", comment: "Language selection")
        case .greek:
            return NSLocalizedString("Greek", comment: "Language selection")
        case .romanian:
            return NSLocalizedString("Romanian", comment: "Language selection")
        case .hindi:
            return NSLocalizedString("Hindi", comment: "Language selection")
        case .malay:
            return NSLocalizedString("Malay", comment: "Language selection")
        case .japanese:
            return NSLocalizedString("Japanese", comment: "Language selection")
        case .korean:
            return NSLocalizedString("Korean", comment: "Language selection")
        case .chinese_simplified:
            return NSLocalizedString("Simplified Chinese", comment: "Language selection")
        case .chinese_traditional:
            return NSLocalizedString("Traditional Chinese", comment: "Language selection")
        case .chinese_hongkong:
            return NSLocalizedString("Chinese (Hong Kong)", comment: "Language selection")
        }
    }

    var locale: Locale {
        Locale(identifier: rawValue == "system" ? Locale.current.identifier : rawValue)
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
    @StateObject private var languageManager = LanguageManager.shared
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

struct SettingsView: View {
    let updater: SPUUpdater

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

            DisplaySettingsView()
                .tabItem {
                    Label("Display", systemImage: "eye")
                }

            AdvancedSettingsView()
                .tabItem {
                    Label("Advanced", systemImage: "gearshape.2")
                }

            AboutSettingsView(updater: updater)
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .padding()
        .frame(width: 500, height: 500)
    }
}
