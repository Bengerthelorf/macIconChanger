import Foundation

enum AppDiscoveryPolicy {
    struct Application {
        let url: URL
        let names: [String]
        let comparisonPath: String
    }

    static func comparisonPath(for url: URL) -> String {
        url.resolvingSymlinksInPath().standardizedFileURL.path
    }

    static func uniqueByPath<Item>(_ items: [Item], path: (Item) -> String) -> [Item] {
        var seen = Set<String>()
        return items.filter { seen.insert(path($0)).inserted }
    }

    static func application(at url: URL) -> Application? {
        // Keep the same .app suffix accepted by the icon-writing helper.
        guard url.isFileURL, url.pathExtension == "app",
              !url.pathComponents.dropLast().contains(where: {
                  $0.hasPrefix(".") || $0.lowercased().hasSuffix(".app")
              }),
              let values = try? url.resourceValues(forKeys: [.isDirectoryKey, .isSymbolicLinkKey, .isHiddenKey]),
              values.isDirectory == true, values.isSymbolicLink == false, values.isHidden != true,
              let bundle = Bundle(url: url), let bundleID = bundle.bundleIdentifier, !bundleID.isEmpty else {
            return nil
        }

        let names = [
            url.lastPathComponent,
            url.deletingPathExtension().lastPathComponent,
            bundle.localizedInfoDictionary?["CFBundleDisplayName"] as? String,
            bundle.localizedInfoDictionary?["CFBundleName"] as? String,
            bundle.infoDictionary?["CFBundleDisplayName"] as? String,
            bundle.infoDictionary?["CFBundleName"] as? String,
            bundleID,
        ].compactMap { $0 }
        return Application(url: url, names: names, comparisonPath: comparisonPath(for: url))
    }

    static func scan(roots: [URL], onError: @escaping (URL, Error) -> Void) -> [Application] {
        let fileManager = FileManager.default
        var apps: [Application] = []
        let roots = uniqueByPath(roots, path: comparisonPath)

        for root in roots {
            guard let entries = fileManager.enumerator(
                at: root,
                includingPropertiesForKeys: [.isDirectoryKey, .isSymbolicLinkKey, .isHiddenKey],
                options: [.skipsHiddenFiles, .skipsPackageDescendants],
                errorHandler: { url, error in
                    onError(url, error)
                    return true
                }
            ) else { continue }

            for case let url as URL in entries {
                if entries.level >= 5 { entries.skipDescendants() }
                guard url.pathExtension == "app" else { continue }
                entries.skipDescendants()
                if let app = application(at: url) { apps.append(app) }
            }
        }
        return uniqueByPath(apps, path: \.comparisonPath)
    }
}

struct AppSidebarQuery {
    private let terms: [String]
    private let includesPath: Bool

    init(_ query: String) {
        terms = query.split(whereSeparator: \.isWhitespace).map(String.init)
        includesPath = query.contains("/")
    }

    var isEmpty: Bool { terms.isEmpty }

    func matches(fields: [String], path: String) -> Bool {
        let searchableFields = includesPath ? fields + [path] : fields
        return terms.allSatisfy { term in
            searchableFields.contains { $0.localizedStandardContains(term) }
        }
    }
}
