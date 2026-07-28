import Foundation

private func expect(_ condition: @autoclosure () -> Bool, _ message: String) {
    guard condition() else {
        fputs("FAIL: \(message)\n", stderr)
        exit(1)
    }
}

@main
enum ConfigurationArchiveTests {
    static func main() throws {
        let legacy = """
        {
          "appAliases": [{"appName": "Example", "aliasName": "Demo"}],
          "cachedIcons": [],
          "version": "1.0",
          "exportDate": 0
        }
        """.data(using: .utf8)!
        let decodedLegacy = try JSONDecoder().decode(
            AppConfigurationArchive.self,
            from: legacy
        )
        expect(decodedLegacy.version == "1.0", "legacy version should be preserved")
        expect(decodedLegacy.appearanceIcons.isEmpty, "legacy archives need empty appearance data")

        let light = Data(repeating: 1, count: 32)
        let dark = Data(repeating: 2, count: 32)
        let archive = AppConfigurationArchive(
            appearanceIcons: [
                AppearanceIconConfigurationArchive(
                    appPath: "/Applications/Example.app",
                    appName: "Example",
                    lightIconData: light,
                    darkIconData: dark
                )
            ],
            settings: [
                "enabled": .bool(true),
                "count": .int(2),
                "ratio": .double(0.5),
                "name": .string("Example")
            ]
        )
        let roundTrip = try JSONDecoder().decode(
            AppConfigurationArchive.self,
            from: JSONEncoder().encode(archive)
        )
        expect(roundTrip == archive, "v3 appearance archive should round-trip")
        expect(
            ConfigurationArchivePolicy.validatesSizeLimits(archive),
            "small icon archive should pass size validation"
        )

        var oversized = archive
        oversized.appearanceIcons[0].darkIconData = Data(
            repeating: 0,
            count: ConfigurationArchivePolicy.maximumIconBytes + 1
        )
        expect(
            !ConfigurationArchivePolicy.validatesSizeLimits(oversized),
            "oversized icon data must be rejected before import"
        )

        let encodedURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("iconchanger-archive-\(UUID().uuidString).json")
        try JSONEncoder().encode(archive).write(to: encodedURL)
        defer { try? FileManager.default.removeItem(at: encodedURL) }
        expect(
            ConfigurationArchivePolicy.validatesEncodedFileSize(encodedURL),
            "encoded archive should pass file-size validation before loading"
        )

        print("PASS: configuration archives preserve appearance icons and legacy compatibility")
    }
}
