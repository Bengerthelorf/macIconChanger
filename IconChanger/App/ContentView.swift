//
//  ContentView.swift
//  IconChanger
//

import SwiftUI
import os
import LaunchPadManagerDBHelper

struct ContentView: View {
    @StateObject var folderPermission = FolderPermission.shared
    @StateObject var iconManager = IconManager.shared
    @State private var setupState: SetupState = .checking
    @State private var showSetupOKAlert = false
    @State private var isConfiguring = false
    @State private var configError: String?

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ContentView")

    enum SetupState {
        case checking
        case needsPermission
        case needsHelperFiles(missingFiles: [String])
        case needsSudoersSetup
        case needsAppManagement
        case completed
        case error(String)
    }

    var body: some View {
        Group {
            switch setupState {
            case .checking:
                VStack {
                    Text("Checking Setup...")
                        .font(.title)
                    ProgressView().padding()
                }

            case .needsPermission:
                 VStack {
                     Text("We Need Access to /Applications")
                         .font(.largeTitle.bold())
                         .padding()
                     VStack(alignment: .leading) {
                         Text("1. A dialog will appear requesting access to /Applications")
                         Text("2. Please choose /Applications and click OK")
                         Text("3. If no dialog appears, you might need to grant access manually in System Settings > Privacy & Security > Files and Folders")
                     }
                     .multilineTextAlignment(.leading)
                     .padding(.bottom)

                     Button("Request / Check Access") {
                         folderPermission.add()
                         DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                              checkFullSetup()
                         }
                     }
                     .padding()
                 }

            case .needsHelperFiles(let missingFiles):
                 VStack {
                     Image(systemName: "exclamationmark.triangle.fill")
                         .resizable().scaledToFit().frame(width: 40, height: 40).foregroundColor(.orange)
                         .padding(.bottom)
                     Text("Helper Files Missing")
                         .font(.title2.bold())
                     Text(String(format: NSLocalizedString("helper_files_missing_message_format", comment: "Message shown when helper files are missing. %@ is the list of files."), missingFiles.joined(separator: "\n")))                         .multilineTextAlignment(.center)
                         .foregroundColor(.secondary)
                         .padding()
                      Button("Retry Setup Check") {
                           setupState = .checking
                           iconManager.ensureHelperFilesCopied()
                           DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                               checkFullSetup()
                           }
                      }
                      .padding(.top)
                 }
                 .padding()

            case .needsSudoersSetup:
                 VStack(spacing: 15) {
                      Image(systemName: "lock.shield.fill")
                          .resizable().scaledToFit().frame(width: 40, height: 40).foregroundColor(.orange)
                          .padding(.bottom, 5)
                     Text("Permission Setup")
                         .font(.title2.bold())
                     Text("IconChanger needs administrator privileges to change app icons.\nClick the button below and enter your password to complete setup.")
                          .multilineTextAlignment(.center)
                          .foregroundColor(.secondary)
                         .padding(.horizontal)

                     if isConfiguring {
                         ProgressView("Configuring...")
                             .padding(.top)
                     } else {
                         Button {
                             configError = nil
                             isConfiguring = true
                             DispatchQueue.global(qos: .userInitiated).async {
                                 do {
                                     try iconManager.configureSudoers()
                                     DispatchQueue.main.async {
                                         isConfiguring = false
                                         checkFullSetup()
                                     }
                                 } catch {
                                     DispatchQueue.main.async {
                                         isConfiguring = false
                                         configError = error.localizedDescription
                                     }
                                 }
                             }
                         } label: {
                             Label("Configure Permissions", systemImage: "lock.open.fill")
                         }
                         .controlSize(.large)
                         .padding(.top)
                     }

                     if let configError {
                         Text(configError)
                             .foregroundColor(.red)
                             .font(.caption)
                             .multilineTextAlignment(.center)
                             .padding(.horizontal)
                     }
                 }
                 .padding()


            case .needsAppManagement:
                 VStack(spacing: 15) {
                      Image(systemName: "app.badge.checkmark")
                          .resizable().scaledToFit().frame(width: 40, height: 40).foregroundColor(.orange)
                          .padding(.bottom, 5)
                     Text("App Management Permission")
                         .font(.title2.bold())
                     Text("IconChanger needs App Management permission to modify app icons.\nPlease enable it in System Settings, then come back and click the button below.")
                          .multilineTextAlignment(.center)
                          .foregroundColor(.secondary)
                         .padding(.horizontal)

                     Button {
                         iconManager.requestAppManagementPermission { granted in
                             if granted {
                                 checkFullSetup()
                             }
                         }
                     } label: {
                         Label("Request Permission", systemImage: "lock.open.fill")
                     }
                     .controlSize(.large)
                     .padding(.top, 5)

                     Button {
                         NSWorkspace.shared.openLocationService(for: .appManagement)
                     } label: {
                         Label("Open System Settings", systemImage: "gear")
                     }
                     .controlSize(.large)

                     Button {
                         checkFullSetup()
                     } label: {
                         Label("I've Enabled It", systemImage: "checkmark.circle")
                     }
                     .controlSize(.large)
                 }
                 .padding()

            case .completed:
                IconList()

            case .error(let errorMessage):
                 VStack {
                     Image(systemName: "exclamationmark.triangle.fill")
                         .resizable()
                         .scaledToFit()
                         .frame(width: 50, height: 50)
                         .foregroundColor(.red)
                     Text("Setup Error")
                         .font(.largeTitle.bold())
                         .padding(.bottom, 5)
                     Text(errorMessage)
                         .foregroundColor(.secondary)
                         .multilineTextAlignment(.center)
                         .padding(.horizontal)
                 }
            }
        }
        .onAppear {
            checkFullSetup()
        }
        .onChange(of: folderPermission.hasPermission) { _ in
             checkFullSetup()
        }
         .onChange(of: iconManager.needsSetupCheck) { needsCheck in
              if needsCheck {
                   let previousState = setupState
                   checkFullSetup()
                   if case .completed = previousState, case .completed = setupState {
                       showSetupOKAlert = true
                   }
                   DispatchQueue.main.async {
                        iconManager.needsSetupCheck = false
                   }
              }
         }
         .alert("Setup Status", isPresented: $showSetupOKAlert) {
             Button("OK", role: .cancel) { }
         } message: {
             Text("Everything is set up correctly.")
         }

    }

    func checkFullSetup() {
        setupState = .checking

        if !folderPermission.hasPermission {
            setupState = .needsPermission
            return
        }

        iconManager.ensureHelperFilesCopied()

        let detailedStatus = iconManager.checkSetupStatus()
        logger.debug("Setup status: \(String(describing: detailedStatus))")

        switch detailedStatus {
        case .completed:
            switch iconManager.appManagementStatus() {
            case .authorized, .unknown:
                setupState = .completed
            case .denied, .notDetermined:
                setupState = .needsAppManagement
            }
        case .helperFilesMissing(let missingFiles):
            logger.error("Helper files missing")
            setupState = .needsHelperFiles(missingFiles: missingFiles)
        case .sudoersPermissionMissing:
            logger.error("Sudoers permission missing")
            setupState = .needsSudoersSetup
        case .unknownError(let message):
             logger.error("Setup error: \(message)")
             setupState = .error(message)
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension NSWorkspace {

    enum SystemServiceType: String {
        case privacy = "x-apple.systempreferences:com.apple.preference.security?Privacy"
        case camera = "x-apple.systempreferences:com.apple.preference.security?Privacy_Camera"
        case microphone = "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone"
        case location = "x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices"
        case contacts = "x-apple.systempreferences:com.apple.preference.security?Privacy_Contacts"
        case calendars = "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars"
        case reminders = "x-apple.systempreferences:com.apple.preference.security?Privacy_Reminders"
        case photos = "x-apple.systempreferences:com.apple.preference.security?Privacy_Photos"
        case fullDisk = "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"
        case appManagement = "x-apple.systempreferences:com.apple.preference.security?Privacy_AppBundles"
    }

    func openLocationService(for type: SystemServiceType) {
        guard let url = URL(string: type.rawValue) else { return }
        NSWorkspace.shared.open(url)
    }
}
