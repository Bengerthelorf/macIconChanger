import Foundation

@main
enum AppDiscoveryTests {
    static func main() throws {
        let fileManager = FileManager.default
        let fixture = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
        let root = fixture.appendingPathComponent("Applications")
        let nested = root.appendingPathComponent("Developer")
        let app = nested.appendingPathComponent("Renamed.app")
        let copy = root.appendingPathComponent("Other Copy.app")
        let boundary = root.appendingPathComponent("one/two/three/four/Boundary.app")
        let deep = root.appendingPathComponent("one/two/three/four/five/Too Deep.app")
        let embedded = app.appendingPathComponent("Contents/Helpers/Embedded.app")
        let hidden = root.appendingPathComponent(".hidden/Hidden.app")
        let missing = fixture.appendingPathComponent("Mounted Later")
        let fake = root.appendingPathComponent("Fake.app")
        let malformed = root.appendingPathComponent("Malformed.app")
        let symlink = root.appendingPathComponent("Link.app")

        for url in [app, copy, boundary, deep, embedded, hidden] {
            try createBundle(at: url)
        }
        try Data().write(to: fake)
        try fileManager.createDirectory(at: malformed, withIntermediateDirectories: false)
        try fileManager.createSymbolicLink(at: symlink, withDestinationURL: app)

        var failures: [URL] = []
        let found = AppDiscoveryPolicy.scan(roots: [root, nested, missing]) { url, _ in
            failures.append(url)
        }
        // Foundation can enumerate /var and /tmp through their /private paths.
        let expected = [app, copy, boundary]
        let expectedPaths = expected.map(AppDiscoveryPolicy.comparisonPath)
        require(Set(found.map(\.comparisonPath)) == Set(expectedPaths),
                """
                scan yields valid bundles including distinct installations with the same ID
                Fixture: \(fixture.path)
                Expected: \(expected.map(\.path))
                Found: \(found.map { $0.url.path })
                Scan errors: \(failures.map(\.path))
                """)
        require(found.count == 3, "overlapping roots do not repeat an application")
        require(failures.map(AppDiscoveryPolicy.comparisonPath).contains(AppDiscoveryPolicy.comparisonPath(for: missing)),
                "missing root did not report a read failure: \(missing.path), errors: \(failures.map(\.path))")
        for rejected in [fake, malformed, symlink, hidden, embedded, missing] {
            require(AppDiscoveryPolicy.application(at: rejected) == nil,
                    "unusable discovery record rejected: \(rejected.lastPathComponent)")
        }

        let aliasRoot = fixture.appendingPathComponent("Alias")
        try fileManager.createSymbolicLink(at: aliasRoot, withDestinationURL: root)
        let pathVariant = aliasRoot.appendingPathComponent("Developer/Renamed.app")
        let merged = AppDiscoveryPolicy.uniqueByPath([pathVariant, app, copy], path: AppDiscoveryPolicy.comparisonPath)
        require(merged.map(\.path) == [pathVariant.path, copy.path],
                "merging path variants keeps the first write target and distinct installs")

        let appComparisonPath = AppDiscoveryPolicy.comparisonPath(for: app)
        let metadata = found.first { $0.comparisonPath == appComparisonPath }!
        let fields = ["Renamed", "Workspace Editor"] + metadata.names
        let queries = [" Café  \n 示  ", "EDITOR com.example.fixture", "Fixture Workspace", app.path]
        for query in queries {
            require(AppSidebarQuery(query).matches(fields: fields, path: app.path),
                    "localized display name, alias, bundle identifier and full paths can match: \(query)")
        }
        require(!AppSidebarQuery("Workspace unrelated").matches(fields: fields, path: app.path),
                "every search term must match")
        require(AppSidebarQuery("   \n ").isEmpty, "blank search leaves the category unfiltered")
        require(AppSidebarQuery("project.v2").matches(fields: ["Project.v2"], path: "/tmp/Project.v2"),
                "dotted folder names retain their suffix")
        print("PASS: app discovery validates candidates, merges roots and searches indexed names")
    }

    private static func createBundle(at appURL: URL) throws {
        let contents = appURL.appendingPathComponent("Contents")
        let executables = contents.appendingPathComponent("MacOS")
        try FileManager.default.createDirectory(at: executables, withIntermediateDirectories: true)
        let executable = executables.appendingPathComponent("Fixture")
        try Data("#!/bin/sh\nexit 0\n".utf8).write(to: executable)
        try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: executable.path)
        let info = [
            "CFBundleIdentifier": "com.example.fixture",
            "CFBundleDisplayName": "Café 示例",
            "CFBundleName": "Fixture",
            "CFBundlePackageType": "APPL",
            "CFBundleExecutable": "Fixture"
        ]
        let data = try PropertyListSerialization.data(fromPropertyList: info, format: .xml, options: 0)
        try data.write(to: contents.appendingPathComponent("Info.plist"))
    }

    private static func require(_ condition: @autoclosure () -> Bool, _ message: String) {
        guard condition() else {
            FileHandle.standardError.write(Data("FAIL: \(message)\n".utf8))
            exit(1)
        }
    }
}
