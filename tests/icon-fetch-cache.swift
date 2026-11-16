import Foundation

enum AppPaths {
    static var iconFetchCacheFile: URL { fatalError("The test must use its isolated cache file.") }
}

enum DiagnosticsOperation { case cache }
enum DiagnosticsSource { case manual, startup, scheduled }
enum DiagnosticsKind { case operation, step, performance, failure, skipped }

struct DiagnosticsContext {
    init(
        operation: DiagnosticsOperation,
        source: DiagnosticsSource = .manual,
        appName: String? = nil,
        iconKind: String? = nil,
        iconPath: String? = nil
    ) {}
}

struct DiagnosticsTimer {
    var elapsedMilliseconds: Double { 0 }
}

struct DiagnosticsLogger {
    static let shared = DiagnosticsLogger()
    static func errorDetails(_ error: Error) -> [String: String] { [:] }

    func log(
        _ kind: DiagnosticsKind,
        phase: String,
        context: DiagnosticsContext,
        durationMilliseconds: Double? = nil,
        details: [String: String] = [:]
    ) {}
}

@main
enum IconFetchCacheTests {
    static func main() throws {
        let cacheFile = URL(fileURLWithPath: CommandLine.arguments[1])
            .appendingPathComponent("search-cache.json")
        let suiteName = "IconChanger.IconFetchCacheTests.\(UUID())"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let editor = makeIcon("Editor")
        let alternate = makeIcon("Editor Alternate")
        let legacyKey = "editor|all"
        let legacyEntry = IconFetchCacheEntry(
            cacheKey: legacyKey,
            icons: [CachedIconRes.from(editor)],
            timestamp: Date(),
            lastAccessTime: Date()
        )
        try write([legacyKey: legacyEntry], to: cacheFile)

        let plan = ["editor", "editor beta"]
        let cache = IconFetchCacheManager(persistentCacheFileURL: cacheFile, defaults: defaults)
        require(cache.getCachedIcons(queries: ["editor"], style: "all") == nil, "legacy name keys should miss")
        cache.cacheIcons([alternate, editor], queries: plan, style: "all")
        cache.cacheIcons([editor], queries: plan, style: "all", extendedSearch: true)
        cache.cacheIcons([editor], queries: plan, style: "dark")
        cache.cacheIcons([editor], queries: ["a|b", "c"], style: "all")
        require(cache.getCachedIcons(queries: ["a", "b|c"], style: "all") == nil, "query delimiters must not collide")
        require(cache.getCachedIcons(queries: ["editor"], style: "all") == nil, "adding a fallback query changes cache identity")
        require(cache.getCachedIcons(queries: Array(plan.reversed()), style: "all") == nil, "query order changes cache identity")
        require(cache.getCachedIcons(queries: plan, style: "all") == [alternate, editor], "cached ranking order should be preserved")
        require(cache.getCachedIcons(queries: plan, style: "all", extendedSearch: true) == [editor], "search modes with identical plans must be isolated")
        require(cache.getCachedIcons(queries: plan, style: "dark") == [editor], "styles must be isolated")

        cache.cacheIcons([], queries: ["empty"], style: "all")
        cache.cacheIcons([], queries: ["old empty"], style: "all")
        cache.cacheIcons([makeIcon("Old Positive")], queries: ["old positive"], style: "all")
        require(cache.getCachedIcons(queries: ["empty"], style: "all") == [], "a fresh empty result is a cache hit")

        let entries = try JSONDecoder().decode(
            [String: IconFetchCacheEntry].self,
            from: Data(contentsOf: cacheFile)
        )
        require(entries[legacyKey]?.icons.first?.appName == editor.appName, "mixed cache files should retain decodable legacy entries")
        let emptyKeys = entries.filter { $0.value.icons.isEmpty }.map(\.key)
        require(emptyKeys.count == 2, "fresh and expired empty cases must be distinct entries")
        let expiredEmptyKey = emptyKeys.first { $0.contains("old empty") }!
        let expiredEntries = entries.mapValues { entry in
            let age: TimeInterval
            if entry.cacheKey == expiredEmptyKey {
                age = 6 * 60
            } else if entry.icons.first?.appName == "Old Positive" {
                age = 25 * 60 * 60
            } else {
                return entry
            }
            return IconFetchCacheEntry(
                cacheKey: entry.cacheKey,
                icons: entry.icons,
                timestamp: Date().addingTimeInterval(-age),
                lastAccessTime: Date()
            )
        }
        try write(expiredEntries, to: cacheFile)

        let reloaded = IconFetchCacheManager(persistentCacheFileURL: cacheFile, defaults: defaults)
        require(reloaded.getCachedIcons(queries: plan, style: "all") == [alternate, editor], "results must survive a disk reload in rank order")
        require(reloaded.getCachedIcons(queries: ["editor"], style: "all") == nil, "legacy scope must remain isolated after reloading")
        require(reloaded.getCachedIcons(queries: ["empty"], style: "all") == [], "fresh empty results must survive disk reload")
        require(reloaded.getCachedIcons(queries: ["old empty"], style: "all") == nil, "recently accessed empty entries must expire based on creation time")
        require(reloaded.getCachedIcons(queries: ["old positive"], style: "all") == nil, "recently accessed positive entries must expire based on creation time")

        let cleanup = IconFetchCacheManager(persistentCacheFileURL: cacheFile, defaults: defaults)
        require(cleanup.clearExpiredCache(olderThan: 10 * 60) == 3, "cleanup should purge both stale entries and legacy keys")
        let cleanedEntries = try JSONDecoder().decode(
            [String: IconFetchCacheEntry].self,
            from: Data(contentsOf: cacheFile)
        )
        require(cleanedEntries[legacyKey] == nil && cleanedEntries.count == expiredEntries.count - 3, "cleanup must persist the remaining cache")

        defaults.set(false, forKey: "cacheAPIResults")
        let memoryOnly = IconFetchCacheManager(persistentCacheFileURL: cacheFile, defaults: defaults)
        require(memoryOnly.getCachedIcons(queries: plan, style: "all") == nil, "disabled persistence should skip reading disk")
        let beforeMemoryOnlyWrite = try Data(contentsOf: cacheFile)
        memoryOnly.cacheIcons([editor], queries: ["local"], style: "all")
        require(memoryOnly.getCachedIcons(queries: ["local"], style: "all") == [editor], "disabled persistence should still cache in memory")
        let afterMemoryOnlyWrite = try Data(contentsOf: cacheFile)
        require(beforeMemoryOnlyWrite == afterMemoryOnlyWrite, "disabled persistence should skip writing disk")

        print("PASS: icon search cache separates query plans, modes, and styles and expires old results")
    }

    private static func makeIcon(_ name: String) -> IconRes {
        let base = URL(string: "https://example.invalid/icons")!.appendingPathComponent(name)
        return IconRes(
            appName: name,
            icnsUrl: base.appendingPathExtension("icns"),
            lowResPngUrl: base.appendingPathExtension("png"),
            downloads: 1
        )!
    }

    private static func write(_ entries: [String: IconFetchCacheEntry], to file: URL) throws {
        try JSONEncoder().encode(entries).write(to: file, options: .atomic)
    }

    private static func require(_ condition: Bool, _ message: String) {
        guard condition else {
            fputs("FAIL: \(message)\n", stderr)
            exit(1)
        }
    }
}
