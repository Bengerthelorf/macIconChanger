//
//  SetupMonitor.swift
//  IconChanger
//

import Combine
import Foundation

extension Notification.Name {
    static let setupHealthDidChange = Notification.Name("IconChanger.setupHealthDidChange")
}

@MainActor
final class SetupMonitor: ObservableObject {
    static let shared = SetupMonitor()

    @Published private(set) var health: SetupHealth = .checking
    @Published private(set) var isChecking = false
    private var checkQueue = SetupCheckQueue()
    private var completions: [(SetupHealth) -> Void] = []
    private var checkGeneration = 0

    private init() {}

    func check(
        source: DiagnosticsSource = .system,
        completion: ((SetupHealth) -> Void)? = nil
    ) {
#if DEBUG
        if UIReviewMode.isEnabled {
            let state = ProcessInfo.processInfo.environment["ICONCHANGER_UI_REVIEW_HEALTH"]
            let reviewHealth: SetupHealth = state == "manual" ? .manualMode
                : state == "missing" ? .missingHelperFiles(["helper.sh"])
                : .ready
            publish(reviewHealth)
            completion?(reviewHealth)
            return
        }
        if ProcessInfo.processInfo.environment["ICONCHANGER_PREVIEW_MANUAL_MODE"] == "1" {
            publish(.manualMode)
            completion?(.manualMode)
            return
        }
#endif
        if let completion { completions.append(completion) }
        guard checkQueue.request() else { return }
        isChecking = true
        checkGeneration += 1
        let generation = checkGeneration
        let diagnosticsContext = DiagnosticsContext(
            operation: .setup,
            source: source
        )
        let timer = DiagnosticsTimer()
        DiagnosticsLogger.shared.log(
            .operation,
            phase: "setup_health_check.start",
            context: diagnosticsContext,
            details: [
                "folder_permission_count": String(FolderPermission.shared.permissions.count)
            ]
        )
        // Rechecking must not tear down an existing browsing session.
        if !health.allowsIconBrowsing { publish(.checking) }

        guard FolderPermission.shared.hasPermission else {
            DiagnosticsLogger.shared.log(
                .failure,
                phase: "setup_health_check.folder_permission_missing",
                context: diagnosticsContext,
                durationMilliseconds: timer.elapsedMilliseconds
            )
            finish(.needsFolderPermission, generation: generation, completion: completion)
            return
        }

        DispatchQueue.global(qos: .utility).async {
            let iconManager = IconManager.shared
            let setupStatus = iconManager.checkSetupStatus(
                diagnosticsContext: diagnosticsContext
            )
            let result: SetupHealth
            var details = [
                "setup_status": Self.setupStatusName(setupStatus)
            ]

            switch setupStatus {
            case .completed:
                let appManagementStatus = iconManager.appManagementStatus()
                details["app_management_status"] =
                    Self.appManagementStatusName(appManagementStatus)
                switch appManagementStatus {
                case .authorized, .unknown:
                    result = .ready
                case .denied, .notDetermined:
                    result = .needsAppManagementPermission
                }
            case .helperFilesMissing(let missingFiles):
                result = .missingHelperFiles(missingFiles)
            case .helperFilesOutdated:
                result = .outdatedHelperFiles
            case .sudoersPermissionMissing:
                let appManagementStatus = iconManager.appManagementStatus()
                details["app_management_status"] =
                    Self.appManagementStatusName(appManagementStatus)
                switch appManagementStatus {
                case .authorized, .unknown:
                    result = .manualMode
                case .denied, .notDetermined:
                    result = .needsAppManagementPermission
                }
            case .legacySudoersPermissionPresent:
                result = .needsLegacyPermissionCleanup
            case .unknownError(let message):
                result = .error(message)
            }

            DispatchQueue.main.async {
                DiagnosticsLogger.shared.log(
                    result.needsAttention ? .failure : .operation,
                    phase: "setup_health_check.completed",
                    context: diagnosticsContext,
                    durationMilliseconds: timer.elapsedMilliseconds,
                    details: details
                )
                self.finish(result, generation: generation, completion: completion)
            }
        }
    }

    private func finish(
        _ result: SetupHealth,
        generation: Int,
        completion: ((SetupHealth) -> Void)?
    ) {
        guard generation == checkGeneration else { return }
        if checkQueue.finish() {
            isChecking = false
            check()
            return
        }
        publish(result)
        isChecking = false
        let callbacks = completions
        completions.removeAll()
        callbacks.forEach { $0(result) }
    }

    private func publish(_ newHealth: SetupHealth) {
        guard health != newHealth else { return }
        health = newHealth
        NotificationCenter.default.post(name: .setupHealthDidChange, object: self)
    }

    nonisolated private static func setupStatusName(_ status: SetupStatus) -> String {
        switch status {
        case .completed:
            return "completed"
        case .helperFilesMissing:
            return "helper_files_missing"
        case .helperFilesOutdated:
            return "helper_files_outdated"
        case .sudoersPermissionMissing:
            return "sudoers_permission_missing"
        case .legacySudoersPermissionPresent:
            return "legacy_sudoers_permission_present"
        case .unknownError:
            return "unknown_error"
        }
    }

    nonisolated private static func appManagementStatusName(
        _ status: IconManager.AppManagementStatus
    ) -> String {
        switch status {
        case .authorized:
            return "authorized"
        case .denied:
            return "denied"
        case .notDetermined:
            return "not_determined"
        case .unknown:
            return "unknown"
        }
    }
}
