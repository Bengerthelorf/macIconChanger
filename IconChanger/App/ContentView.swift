//
//  ContentView.swift
//  IconChanger
//

import SwiftUI
import LaunchPadManagerDBHelper

struct ContentView: View {
    @StateObject var folderPermission = FolderPermission.shared
    @StateObject var iconManager = IconManager.shared
    @StateObject private var setupMonitor = SetupMonitor.shared
    @State private var showSetupOKAlert = false
    @State private var isConfiguring = false
    @State private var configError: String?

    var body: some View {
        Group {
            switch setupMonitor.health {
            case .checking:
                VStack {
                    Text("Checking Setup...")
                        .font(.title)
                    ProgressView().padding()
                }

            case .needsFolderPermission:
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

            case .missingHelperFiles(let missingFiles):
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
                           repairHelperFiles()
                      }
                      .padding(.top)
                 }
                 .padding()

            case .outdatedHelperFiles:
                 VStack(spacing: 15) {
                     Image(systemName: "exclamationmark.shield.fill")
                         .resizable().scaledToFit().frame(width: 40, height: 40).foregroundColor(.orange)
                         .padding(.bottom, 5)
                     Text("Helper Update Required")
                         .font(.title2.bold())
                     Text("The installed privileged helper does not match this version of IconChanger. Repair it before changing or restoring icons.")
                         .multilineTextAlignment(.center)
                         .foregroundColor(.secondary)
                         .padding(.horizontal)
                     Button {
                         repairHelperFiles()
                     } label: {
                         Label("Repair Helper Files", systemImage: "wrench.and.screwdriver.fill")
                     }
                     .controlSize(.large)
                     .padding(.top)
                 }
                 .padding()

            case .needsSudoersPermission:
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


            case .needsAppManagementPermission:
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

            case .ready:
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
                     Button("Retry") {
                         checkFullSetup()
                     }
                     .controlSize(.large)
                     .padding(.top)
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
                   let previousState = setupMonitor.health
                   SetupMonitor.shared.check { newState in
                       if case .ready = previousState, case .ready = newState {
                           showSetupOKAlert = true
                       }
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
        setupMonitor.check()
    }

    private func repairHelperFiles() {
        DispatchQueue.global(qos: .userInitiated).async {
            iconManager.ensureHelperFilesCopied()
            DispatchQueue.main.async {
                checkFullSetup()
            }
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
        case appManagement = "x-apple.systempreferences:com.apple.preference.security?Privacy_AppBundles"
    }

    func openLocationService(for type: SystemServiceType) {
        guard let url = URL(string: type.rawValue) else { return }
        NSWorkspace.shared.open(url)
    }
}
