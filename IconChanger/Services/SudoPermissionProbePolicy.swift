enum SudoPermissionProbeResult: Equatable {
    case authorized
    case permissionMissing
    case helperFailed(String)
}

enum SudoPermissionProbePolicy {
    static func classify(exitStatus: Int32, output: String) -> SudoPermissionProbeResult {
        guard exitStatus != 0 else { return .authorized }

        let normalized = output.lowercased()
        let permissionMarkers = [
            "a password is required",
            "no tty present",
            "not allowed to execute",
            "may not run sudo",
            "not in the sudoers file"
        ]

        if permissionMarkers.contains(where: normalized.contains) {
            return .permissionMissing
        }

        return .helperFailed(output)
    }
}
