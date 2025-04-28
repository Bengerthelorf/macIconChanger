//
//  ContentView.swift
//  IconChanger
//
//  Created by 朱浩宇 on 2022/4/27.
//

import SwiftUI
import os
import LaunchPadManagerDBHelper

struct ContentView: View {
    @StateObject var folderPermission = FolderPermission.shared
    @StateObject var iconManager = IconManager.shared
    @State private var setupState: SetupState = .checking
    @State private var showSetupAlert = false
    @State private var setupAlertTitle = "Setup Information"
    @State private var setupInstructions = ""

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ContentView")

    enum SetupState {
        case checking
        case needsPermission
        case needsHelperFiles(missingFiles: [String])
        case needsSudoersSetup
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
                          .resizable().scaledToFit().frame(width: 40, height: 40).foregroundColor(.red)
                          .padding(.bottom, 5)
                     Text("Manual Setup Required")
                         .font(.title2.bold())
                     Text("IconChanger needs permission to run its helper script with administrator privileges to change icons.\nThis requires a manual configuration")
                          .multilineTextAlignment(.center)
                          .foregroundColor(.secondary)
                         .padding(.horizontal)
                     Button("Show Setup Instructions") {
                         setupAlertTitle = "Sudoers Setup Instructions"
                         showSetupAlert = true
                     }
                     .padding(.top)
                     Button("Retry Setup Check") {
                          setupState = .checking
                          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                              checkFullSetup()
                          }
                     }
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
            logger.log("ContentView appeared. Initializing setup check.")
            checkFullSetup()
        }
        .onChange(of: folderPermission.hasPermission) { hasPermission in
             logger.log("Folder permission changed to: \(hasPermission). Re-checking setup.")
             checkFullSetup()
        }
        // MARK: - Updated Alert
        .alert(setupAlertTitle, isPresented: $showSetupAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(setupInstructions)
        }
         .onChange(of: iconManager.needsSetupCheck) { needsCheck in
              if needsCheck {
                   logger.log("Triggering setup check from IconManager.")
                   checkFullSetup()
                   DispatchQueue.main.async {
                        iconManager.needsSetupCheck = false
                   }
              }
         }

    }

    func checkFullSetup() {
        logger.log("Starting checkFullSetup...")
        setupState = .checking

        if !folderPermission.hasPermission {
            logger.log("Folder permission missing.")
            setupState = .needsPermission
            return
        }
        logger.log("Folder permission granted.")

        iconManager.ensureHelperFilesCopied()

        let detailedStatus = iconManager.checkSetupStatus()
        logger.log("Detailed setup status result: \(String(describing: detailedStatus))")

        switch detailedStatus {
        case .completed:
            logger.log("Setup check complete and successful.")
            setupState = .completed
        case .helperFilesMissing(let missingFiles):
            logger.error("Setup check failed: Helper files missing.")
            prepareSetupInstructions(for: detailedStatus)
            setupState = .needsHelperFiles(missingFiles: missingFiles)
        case .sudoersPermissionMissing:
            logger.error("Setup check failed: Sudoers permission missing.")
            prepareSetupInstructions(for: detailedStatus)
            setupState = .needsSudoersSetup
        case .unknownError(let message):
             logger.error("Setup check failed with unknown error: \(message)")
             setupState = .error(message)
        }
    }

    func prepareSetupInstructions(for status: SetupStatus) {
        let helperPath = IconManager.shared.helperScriptURL.path
        _ = ProcessInfo.processInfo.userName

        switch status {
        case .sudoersPermissionMissing:
            logger.log("Preparing sudoers setup instructions.")
            let formatString = NSLocalizedString("sudoers_instructions_format", comment: "Instructions for sudoers setup, %@ is the helper script path")
            setupInstructions = String(format: formatString, helperPath)

        case .helperFilesMissing(let missingFiles):
             logger.log("Preparing helper files missing instructions.")
            let formatString = NSLocalizedString("helper_files_missing_instructions_format", comment: "Instructions when helper files are missing. First %@ is list of files, second %@ is expected path.")
            setupInstructions = String(format: formatString, missingFiles.joined(separator: "\n"), IconManager.shared.helperDirectoryURL.path)

        default:
             logger.log("Preparing generic setup instructions for status: \(String(describing: status))")
            let formatString = NSLocalizedString("unexpected_setup_issue_format", comment: "Generic setup error message. First %@ is the status description, second %@ is the helper path.")
            setupInstructions = String(format: formatString, String(describing: status), helperPath)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
           // .environmentObject(FolderPermission())
           // .environmentObject(IconManager())
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
    }

    func openLocationService(for type: SystemServiceType) {
        let url = URL(string: type.rawValue)!
        NSWorkspace.shared.open(url)
    }
}
