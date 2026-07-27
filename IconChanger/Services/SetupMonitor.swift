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
    private var checkGeneration = 0

    private init() {}

    func check(completion: ((SetupHealth) -> Void)? = nil) {
        checkGeneration += 1
        let generation = checkGeneration
        publish(.checking)

        guard FolderPermission.shared.hasPermission else {
            finish(.needsFolderPermission, generation: generation, completion: completion)
            return
        }

        DispatchQueue.global(qos: .utility).async {
            let iconManager = IconManager.shared
            let setupStatus = iconManager.checkSetupStatus()
            let result: SetupHealth

            switch setupStatus {
            case .completed:
                switch iconManager.appManagementStatus() {
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
                result = .needsSudoersPermission
            case .unknownError(let message):
                result = .error(message)
            }

            DispatchQueue.main.async {
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
        publish(result)
        completion?(result)
    }

    private func publish(_ newHealth: SetupHealth) {
        guard health != newHealth else { return }
        health = newHealth
        NotificationCenter.default.post(name: .setupHealthDidChange, object: self)
    }
}
