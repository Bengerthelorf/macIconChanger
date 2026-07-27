import Foundation

@main
enum SudoPermissionProbeTests {
    static func main() {
        assertEqual(
            SudoPermissionProbePolicy.classify(exitStatus: 0, output: ""),
            .authorized,
            "a successful helper self-test proves the exact rule is usable"
        )
        assertEqual(
            SudoPermissionProbePolicy.classify(
                exitStatus: 1,
                output: "sudo: a password is required"
            ),
            .permissionMissing,
            "a non-interactive password prompt means NOPASSWD is unavailable"
        )
        assertEqual(
            SudoPermissionProbePolicy.classify(
                exitStatus: 1,
                output: "sudo: user is not allowed to execute this command"
            ),
            .permissionMissing,
            "an explicit sudo denial requires permission setup"
        )
        assertEqual(
            SudoPermissionProbePolicy.classify(
                exitStatus: 1,
                output: "/usr/local/lib/iconchanger/helper.sh: internal validation failed"
            ),
            .helperFailed("/usr/local/lib/iconchanger/helper.sh: internal validation failed"),
            "a helper failure must not be mistaken for valid permission"
        )
        precondition(
            LegacySudoersPolicy.containsLegacyRule(
                in: """
                User snaix may run:
                    (ALL) NOPASSWD: /Users/snaix/.iconchanger/helper.sh
                """,
                homeDirectory: "/Users/snaix"
            )
        )
        precondition(
            !LegacySudoersPolicy.containsLegacyRule(
                in: "(ALL) NOPASSWD: /usr/local/lib/iconchanger/helper.sh",
                homeDirectory: "/Users/snaix"
            )
        )
        assertEqual(
            LegacySudoersPolicy.exactLegacyLines(
                username: "snaix",
                homeDirectory: "/Users/snaix"
            ),
            [
                "ALL ALL=(ALL) NOPASSWD: /Users/snaix/.iconchanger/helper.sh",
                "snaix ALL=(ALL) NOPASSWD: /Users/snaix/.iconchanger/helper.sh",
            ],
            "cleanup must target only the two historical rules"
        )

        print("PASS: sudo permission checks distinguish authorization from helper failures")
    }

    private static func assertEqual<T: Equatable>(
        _ actual: T,
        _ expected: T,
        _ message: String
    ) {
        guard actual == expected else {
            fputs("FAIL: \(message); expected \(expected), got \(actual)\n", stderr)
            exit(1)
        }
    }
}
