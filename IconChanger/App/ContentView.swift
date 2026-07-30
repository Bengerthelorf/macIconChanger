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
    @State private var showManagedCompatibilityAlert = false
    @State private var showManualModeAlert = false
    @State private var hasPresentedManualModeAlert = false
    @State private var showPermissionRepairError = false

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

            case .manualMode:
                IconList()

            case .needsLegacyPermissionCleanup:
                 VStack(spacing: 15) {
                     Image(systemName: "exclamationmark.shield.fill")
                         .resizable()
                         .scaledToFit()
                         .frame(width: 40, height: 40)
                         .foregroundColor(.orange)
                         .padding(.bottom, 5)
                     Text("Permission Cleanup Required")
                         .font(.title2.bold())
                     Text("An older IconChanger version left an administrator rule pointing to a user-writable helper. Repair permissions to remove only that legacy rule and keep the current protected helper.")
                         .multilineTextAlignment(.center)
                         .foregroundColor(.secondary)
                         .padding(.horizontal)

                     if isConfiguring {
                         ProgressView("Cleaning Up...")
                             .padding(.top)
                     } else {
                         Button {
                             configurePermissions()
                         } label: {
                             Label("Repair Permissions", systemImage: "wrench.and.screwdriver.fill")
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
            presentManualModeAlertIfNeeded(setupMonitor.health)
            checkFullSetup()
        }
        .onChange(of: setupMonitor.health) { health in
            presentManualModeAlertIfNeeded(health)
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
        .alert(
            "Managed Mac Compatibility",
            isPresented: $showManagedCompatibilityAlert
        ) {
            Button("Use Manual Mode", role: .cancel) {}
            Button("Install Compatibility Rule") {
                configurePermissions(allowManagedCompatibility: true)
            }
        } message: {
            Text("This Mac does not apply IconChanger's validated /etc/sudoers.d rule. Compatibility mode adds one marked rule to /etc/sudoers for the fixed, root-owned helper only. The complete file is validated before it replaces the current configuration.")
        }
        .alert(
            "Background Automation Paused",
            isPresented: $showManualModeAlert
        ) {
            Button("Continue in Manual Mode", role: .cancel) {}
            Button("Repair Permissions") {
                configurePermissions()
            }
        } message: {
            Text("Manual icon changes are still available and will request administrator approval when needed. Scheduled restore, update restore, and automatic appearance changes remain paused until permanent helper permission is repaired.")
        }
        .alert(
            "Unable to Repair Permissions",
            isPresented: $showPermissionRepairError
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(configError ?? "An unknown permission error occurred.")
        }

    }

    func checkFullSetup() {
        setupMonitor.check { health in
            presentManualModeAlertIfNeeded(health)
        }
    }

    private func presentManualModeAlertIfNeeded(_ health: SetupHealth) {
        if case .manualMode = health, !hasPresentedManualModeAlert {
            hasPresentedManualModeAlert = true
            showManualModeAlert = true
        }
    }

    private func repairHelperFiles() {
        DispatchQueue.global(qos: .userInitiated).async {
            iconManager.ensureHelperFilesCopied()
            DispatchQueue.main.async {
                checkFullSetup()
            }
        }
    }

    private func configurePermissions(allowManagedCompatibility: Bool = false) {
        configError = nil
        isConfiguring = true
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let result = try iconManager.configureSudoers(
                    allowManagedCompatibility: allowManagedCompatibility
                )
                DispatchQueue.main.async {
                    isConfiguring = false
                    switch result {
                    case .configured:
                        checkFullSetup()
                    case .managedCompatibilityRequired:
                        showManagedCompatibilityAlert = true
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    isConfiguring = false
                    configError = error.localizedDescription
                    showPermissionRepairError = true
                }
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
