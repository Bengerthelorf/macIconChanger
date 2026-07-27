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

enum LegacySudoersPolicy {
    static func legacyHelperPath(homeDirectory: String) -> String {
        "\(homeDirectory)/.iconchanger/helper.sh"
    }

    static func containsLegacyRule(in sudoListOutput: String, homeDirectory: String) -> Bool {
        let legacyPath = legacyHelperPath(homeDirectory: homeDirectory)
        return sudoListOutput.split(whereSeparator: \.isNewline).contains { line in
            line.contains("NOPASSWD:") && line.contains(legacyPath)
        }
    }

    static func exactLegacyLines(username: String, homeDirectory: String) -> [String] {
        let legacyPath = legacyHelperPath(homeDirectory: homeDirectory)
        return [
            "ALL ALL=(ALL) NOPASSWD: \(legacyPath)",
            "\(username) ALL=(ALL) NOPASSWD: \(legacyPath)",
        ]
    }
}
