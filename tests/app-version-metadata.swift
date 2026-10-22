import Foundation

@main
enum AppVersionMetadataTests {
    static func main() throws {
        let fileManager = FileManager.default
        let root = fileManager.temporaryDirectory.appendingPathComponent(
            "iconchanger-version-metadata-\(UUID().uuidString)",
            isDirectory: true
        )
        defer { try? fileManager.removeItem(at: root) }
        let app = root.appendingPathComponent("Example.app", isDirectory: true)

        try writeBundle(at: app, version: "100", shortVersion: "1.0")
        assertEqual(IconCache.currentVersion(for: app.path), "100", "initial build")

        try writeBundle(at: app, version: "101", shortVersion: "1.1")
        let updatedVersion = IconCache.currentVersion(for: app.path)
        assertEqual(updatedVersion, "101", "a running process must read an updated Info.plist")
        guard CachedAppUpdatePolicy.hasUpdate(
            cachedVersion: "100",
            currentVersion: updatedVersion,
            cachedAt: Date(),
            modifiedAt: nil
        ) else {
            fail("an on-disk build change must reach app update detection")
        }

        let replacement = root.appendingPathComponent("Replacement.app", isDirectory: true)
        try writeBundle(at: replacement, version: "102", shortVersion: "1.2")
        try fileManager.moveItem(at: app, to: root.appendingPathComponent("Previous.app"))
        try fileManager.moveItem(at: replacement, to: app)
        assertEqual(IconCache.currentVersion(for: app.path), "102", "replacement apps at the same path")

        try writeBundle(at: app, version: "  \n", shortVersion: " 2.0 ")
        assertEqual(IconCache.currentVersion(for: app.path), "2.0", "short version fallback")

        let infoPlist = app.appendingPathComponent("Contents/Info.plist")
        try Data("invalid plist".utf8).write(to: infoPlist, options: .atomic)
        assertEqual(IconCache.currentVersion(for: app.path), nil, "invalid metadata")
        try fileManager.removeItem(at: infoPlist)
        assertEqual(IconCache.currentVersion(for: app.path), nil, "missing metadata")

        print("PASS: app update detection reads fresh bundle versions in the same process")
    }

    private static func writeBundle(
        at app: URL,
        version: String,
        shortVersion: String
    ) throws {
        let contents = app.appendingPathComponent("Contents", isDirectory: true)
        try FileManager.default.createDirectory(at: contents, withIntermediateDirectories: true)
        let plist: [String: Any] = [
            "CFBundleIdentifier": "homes.snaix.iconchanger.version-metadata-test",
            "CFBundleName": "Example",
            "CFBundlePackageType": "APPL",
            "CFBundleVersion": version,
            "CFBundleShortVersionString": shortVersion,
        ]
        let data = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
        try data.write(to: contents.appendingPathComponent("Info.plist"), options: .atomic)
    }

    private static func assertEqual(_ actual: String?, _ expected: String?, _ message: String) {
        guard actual == expected else {
            fail("\(message); expected \(expected ?? "nil"), got \(actual ?? "nil")")
        }
    }

    private static func fail(_ message: String) -> Never {
        fputs("FAIL: \(message)\n", stderr)
        exit(1)
    }
}
