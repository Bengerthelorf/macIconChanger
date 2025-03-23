//
//  SettingView.swift
//  IconChanger
//
//  Created by 朱浩宇 on 2022/4/28.
//  Modified by Bengerthelorf on 2025/3/21.
//

import SwiftUI

// Language manager and related types
enum AppLanguage: String, CaseIterable, Identifiable {
    case system = "system"
    case english = "en"
    case french = "fr"
    case chinese = "zh-Hans"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .system:
            return NSLocalizedString("System Default", comment: "Language selection")
        case .english:
            return NSLocalizedString("English", comment: "Language selection")
        case .french:
            return NSLocalizedString("French", comment: "Language selection")
        case .chinese:
            return NSLocalizedString("Chinese", comment: "Language selection")
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
        case .chinese:
            return Locale(identifier: "zh-Hans")
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
        // 先初始化存储属性
        let language = AppLanguage(rawValue: UserDefaults.standard.string(forKey: "appLanguage") ?? AppLanguage.system.rawValue) ?? .system
        self.currentLanguage = language
        
        // 然后才能安全地调用方法
        applyLanguage()
    }
    
    private func applyLanguage() {
        // 更新存储的语言值
        storedLanguage = currentLanguage.rawValue
        
        // Set the app's preferred languages based on the selected language
        if currentLanguage != .system {
            UserDefaults.standard.set([currentLanguage.rawValue], forKey: "AppleLanguages")
        } else {
            // Reset to system default
            UserDefaults.standard.removeObject(forKey: "AppleLanguages")
        }
        
        // Force update
        UserDefaults.standard.synchronize()
    }
}

// Definition of LanguageSettingsView within this file
struct LanguageSettingsView: View {
    @ObservedObject private var languageManager = LanguageManager.shared
    @State private var showRestartAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "globe")
                    .font(.title2)
                    .foregroundColor(.blue)
                Text(NSLocalizedString("Language", comment: "Settings section title"))
                    .font(.title2)
                    .fontWeight(.medium)
            }
            .padding(.top, 10)
            .padding(.bottom, 5)
            
            // 现代化的Picker选择器
            Picker("", selection: Binding(
                get: { self.languageManager.currentLanguage },
                set: { newValue in
                    self.languageManager.currentLanguage = newValue
                    self.showRestartAlert = true
                }
            )) {
                ForEach(AppLanguage.allCases) { language in
                    HStack(spacing: 12) {
                        languageFlag(for: language)
                            .frame(width: 24, height: 24)
                        Text(language.displayName)
                            .font(.body)
                    }
                    .tag(language)
                    .padding(.vertical, 4)
                }
            }
            .pickerStyle(RadioGroupPickerStyle())
            .padding(.leading, 5)
            
            Divider()
                .padding(.vertical, 5)
            
            // 信息说明
            HStack(spacing: 10) {
                Image(systemName: "info.circle")
                    .foregroundColor(.blue)
                Text(NSLocalizedString("Changes will take full effect after restarting the app", comment: "Language settings instruction"))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 4)
            .padding(.horizontal, 5)
            
            Spacer()
        }
        .padding()
        .background(Color(NSColor.textBackgroundColor).opacity(0.5))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert(isPresented: $showRestartAlert) {
            Alert(
                title: Text(NSLocalizedString("Language Changed", comment: "Language alert title")),
                message: Text(NSLocalizedString("The language has been changed. For the best experience, please restart the application.", comment: "Language alert message")),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // 为每种语言生成对应的图标
    @ViewBuilder
    private func languageFlag(for language: AppLanguage) -> some View {
        switch language {
        case .system:
            Image(systemName: "gearshape.fill")
                .foregroundColor(.gray)
                .font(.title3)
        case .english:
            Image(systemName: "globe.americas.fill")
                .foregroundColor(.blue)
                .font(.title3)
        case .french:
            Image(systemName: "globe.europe.africa.fill")
                .foregroundColor(.blue)
                .font(.title3)
        case .chinese:
            Image(systemName: "globe.asia.australia.fill")
                .foregroundColor(.blue)
                .font(.title3)
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
            
            // Add our new CachedIconsView tab
            CachedIconsView()
                .tabItem {
                    Label("Icon Cache", systemImage: "arrow.triangle.2.circlepath")
                }
            
            APISettingsView()
                .tabItem {
                    Label(NSLocalizedString("Api", comment: "Settings tab"), systemImage: "bolt")
                }
            
//            LanguageSettingsView()
//                .tabItem {
//                    Label(NSLocalizedString("Language", comment: "Settings tab"), systemImage: "globe")
//                }
        }
        .padding()
        .frame(width: 550, height: 450)
    }
}


