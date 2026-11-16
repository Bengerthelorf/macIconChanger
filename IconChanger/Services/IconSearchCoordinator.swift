import Foundation

enum IconSearchCoordinator {
    static func queries(appName: String, fileName: String, bundleName: String?, alias: String?, isFolder: Bool) -> [String] {
        let names = isFolder
            ? [alias, "folder \(appName)", appName]
            : [alias, appName, fileName, bundleName]
        var seen = Set<String>()
        return names.compactMap { name in
            guard let name else { return nil }
            let query = IconSearchPolicy.normalizedQuery(name)
            guard !query.isEmpty, seen.insert(query).inserted else { return nil }
            return query
        }
    }

    static func fetch(
        queries: [String],
        extendedSearch: Bool,
        request: (String) async throws -> IconSearchResult
    ) async throws -> IconSearchResult {
        var icons: [IconRes] = []
        var firstError: Error?
        var isComplete = true
        for query in queries {
            try Task.checkCancellation()
            do {
                let response = try await request(query)
                isComplete = isComplete && response.isComplete
                let results = IconSearchPolicy.rankAndDeduplicate(response.icons, queries: [query])
                icons.append(contentsOf: results)
                if !extendedSearch && IconSearchPolicy.hasStrongMatch(results, query: query) { break }
            } catch is CancellationError {
                throw CancellationError()
            } catch {
                if firstError == nil { firstError = error }
            }
        }
        try Task.checkCancellation()
        if icons.isEmpty, let firstError { throw firstError }
        return IconSearchResult(
            icons: IconSearchPolicy.rankAndDeduplicate(icons, queries: queries),
            isComplete: isComplete && firstError == nil
        )
    }
}
