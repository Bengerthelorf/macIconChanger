import Foundation

enum ProbeError: Error { case offline }

@main
enum SearchCoordinatorTests {
    static func main() async throws {
        let url = URL(string: "https://example.com/icon.png")!
        let hit = IconRes(appName: "WeChat", icnsUrl: url, lowResPngUrl: url, downloads: 10)!
        let queries = IconSearchCoordinator.queries(appName: "微信", fileName: "WeChat", bundleName: "WeChat", alias: nil, isFolder: false)
        precondition(queries == ["微信", "wechat"])
        let aliasQueries = IconSearchCoordinator.queries(appName: "Discord PTB", fileName: "Discord PTB", bundleName: nil, alias: "Discord", isFolder: false)
        precondition(aliasQueries == ["discord"])
        precondition(IconSearchCoordinator.queries(appName: "Projects.v2", fileName: "Projects.v2", bundleName: nil, alias: "folder", isFolder: true).first == "folder")

        var calls: [String] = []
        let fallback = try await IconSearchCoordinator.fetch(queries: queries, extendedSearch: false) { query in
            calls.append(query)
            return IconSearchResult(icons: query == "wechat" ? [hit] : [])
        }
        precondition(calls == queries && fallback.icons.count == 1 && fallback.isComplete)
        calls = []
        let unrelated = IconRes(appName: "QQ Music", icnsUrl: url, lowResPngUrl: url, downloads: 999)!
        let filteredFallback = try await IconSearchCoordinator.fetch(queries: queries, extendedSearch: false) { query in
            calls.append(query)
            return IconSearchResult(icons: query == "wechat" ? [hit] : [unrelated])
        }
        precondition(calls == queries && filteredFallback.icons.first?.appName == "WeChat")
        calls = []
        _ = try await IconSearchCoordinator.fetch(queries: ["wechat", "微信"], extendedSearch: false) { query in
            calls.append(query)
            return IconSearchResult(icons: [hit])
        }
        precondition(calls == ["wechat"], "Basic search should stop once it has usable results")
        calls = []
        let suggestions = try await IconSearchCoordinator.fetch(queries: ["notes", "apple notes"], extendedSearch: false) { query in
            calls.append(query)
            let name = query == "notes" ? "Votes" : "Apple Notes"
            let iconURL = URL(string: "https://example.com/\(calls.count).png")!
            return IconSearchResult(icons: [IconRes(appName: name, icnsUrl: iconURL, lowResPngUrl: iconURL, downloads: 10)!])
        }
        precondition(calls.count == 2 && suggestions.icons.first?.appName == "Apple Notes")
        for failedQuery in queries {
            let partial = try await IconSearchCoordinator.fetch(queries: queries, extendedSearch: true) { query in
                if query == failedQuery { throw ProbeError.offline }
                return IconSearchResult(icons: [IconRes(appName: query, icnsUrl: url, lowResPngUrl: url, downloads: 10)!])
            }
            precondition(partial.icons.count == 1 && !partial.isComplete, "A failed alternate must preserve successful hits without caching partial results")
        }
        do {
            _ = try await IconSearchCoordinator.fetch(queries: queries, extendedSearch: true) { query in
                if query == "wechat" { throw ProbeError.offline }
                return IconSearchResult(icons: [])
            }
            fatalError("Empty partial searches must retain the actionable error")
        } catch ProbeError.offline {}
        do {
            _ = try await IconSearchCoordinator.fetch(queries: queries, extendedSearch: false) { query in
                if query == "wechat" { throw ProbeError.offline }
                return IconSearchResult(icons: [unrelated])
            }
            fatalError("Unrelated hits must not suppress an alternate request error")
        } catch ProbeError.offline {}
        do {
            _ = try await IconSearchCoordinator.fetch(queries: queries, extendedSearch: true) { _ in
                throw CancellationError()
            }
            fatalError("Cancellation must propagate")
        } catch is CancellationError {}
        let partialPage = try await IconSearchCoordinator.fetch(queries: ["wechat"], extendedSearch: false) { _ in
            IconSearchResult(icons: [hit], isComplete: false)
        }
        precondition(partialPage.icons.count == 1 && !partialPage.isComplete, "Later page failure must not become a complete cache entry")
        let empty = try await IconSearchCoordinator.fetch(queries: queries, extendedSearch: true) { _ in IconSearchResult(icons: []) }
        precondition(empty.icons.isEmpty && empty.isComplete)
        print("PASS: alternate query planning, bounded fallback, partial success and cancellation")
    }
}
