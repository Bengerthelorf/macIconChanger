import Foundation

enum KeychainHelper {
    static func load(key: String) -> String? {
        switch key {
        case "apiKey": return "fixture-key"
        case "t2k": return "[\"fixture-extra\"]"
        default: return nil
        }
    }

    static func save(key: String, value: String) {}
}

enum AppPaths {
    static let applicationSupportRoot = FileManager.default.temporaryDirectory
}

private final class FixtureURLProtocol: URLProtocol {
    struct SearchRequest: Equatable {
        let method: String
        let query: String
        let page: Int
        let filters: [String]

        init(method: String, query: String, page: Int = 0, filters: [String] = []) {
            self.method = method
            self.query = query
            self.page = page
            self.filters = filters
        }
    }

    static var requestLog: [SearchRequest] = []
    static var keyLog: [String] = []
    static var response: (SearchRequest) -> (Int, [String: Any]) = { _ in (200, ["hits": []]) }

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        let method = request.httpMethod ?? ""
        let search: SearchRequest

        if method == "POST" {
            var body = request.httpBody ?? Data()
            if let stream = request.httpBodyStream {
                stream.open()
                defer { stream.close() }
                var bytes = [UInt8](repeating: 0, count: 1024)
                while stream.hasBytesAvailable {
                    let size = stream.read(&bytes, maxLength: bytes.count)
                    guard size > 0 else { break }
                    body.append(contentsOf: bytes.prefix(size))
                }
            }
            let json = (try? JSONSerialization.jsonObject(with: body)) as? [String: Any]
            let options = json?["searchOptions"] as? [String: Any]
            search = .init(
                method: method,
                query: json?["query"] as? String ?? "",
                page: options?["page"] as? Int ?? 0,
                filters: options?["filters"] as? [String] ?? []
            )
        } else {
            let items = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)?.queryItems
            search = .init(method: method, query: items?.first(where: { $0.name == "q" })?.value ?? "")
        }

        Self.requestLog.append(search)
        Self.keyLog.append(request.value(forHTTPHeaderField: "x-api-key") ?? "")
        let (status, json) = Self.response(search)
        let response = HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: try! JSONSerialization.data(withJSONObject: json))
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

@main
struct IconSearchTests {
    private static var failures: [String] = []

    static func main() async throws {
        defer {
            for key in [
                "apiMonthlyLimit", "apiRetryCount", "t2e", "t2ki",
                "com.iconchanger.apiQueryCount", "com.iconchanger.apiQueryResetDate", "com.iconchanger.apiKeyQueryCounts",
            ] {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
        UserDefaults.standard.set(50, forKey: "apiMonthlyLimit")
        UserDefaults.standard.set(0, forKey: "apiRetryCount")

        for (variant, query, title) in [
            ("discord ptb", "discord", "Discord"),
            ("  pycharm\t professional edition ", "pycharm", "PyCharm"),
        ] {
            useFixture { request in (200, request.method == "POST" ? ["hits": [hit(title)]] : ["icons": []]) }
            let names = try await search(variant).map(\.appName)
            expect(names == [title], "\(variant) finds \(title)")
            expect(log == [.init(method: "POST", query: query, page: 1)], "\(variant) normalizes before the request")
        }

        useFixture { _ in (200, ["hits": [hit("Archiver", downloads: 900), hit("Arc Browser", downloads: 300), hit("Arc", downloads: 10), hit("Arc", downloads: 10)]]) }
        let ranked = try await search("Arc").map(\.appName)
        expect(ranked == ["Arc", "Arc Browser"], "exact short name outranks whole-word broader results and excludes unrelated prefixes")

        useFixture { _ in (200, ["hits": [hit("Visual-Studio Code"), hit("Visual Studio Code")]]) }
        let multiword = try await search("Visual   Studio Code").map(\.appName)
        expect(multiword == ["Visual Studio Code", "Visual-Studio Code"], "normalize whitespace and prioritize exact multiword names")

        useFixture { _ in (200, ["hits": [hit("Slack")]]) }
        let typo = try await search("Slak").map(\.appName)
        expect(typo == ["Slack"], "retain single-edit long-name matches from upstream")

        useFixture { _ in (200, ["hits": [hit("Votes")]]) }
        let weak = try await search("notes")
        useFixture { _ in (200, ["hits": [hit("Apple Notes")]]) }
        let strong = try await search("apple notes")
        let suggestions = IconSearchPolicy.rankAndDeduplicate(weak + strong, queries: ["notes", "apple notes"])
        expect(!IconSearchPolicy.hasStrongMatch(weak, query: "notes"), "a typo suggestion does not complete the search")
        expect(IconSearchPolicy.hasStrongMatch(strong, query: "apple notes") && suggestions.map(\.appName) == ["Apple Notes", "Votes"], "an exact alternate outranks the typo suggestion")

        useFixture { request in
            if request.method == "POST" { return (200, ["hits": []]) }
            return (200, ["icons": [
                hit("A&B Unverified"),
                hit("A&B Classic", glass: false),
                hit("Irrelevant", glass: true),
                hit("A&B", glass: true),
            ]])
        }
        let glass = try await search("A&B", style: .liquidGlass).map(\.appName)
        expect(glass == ["A&B"], "backup enforces Liquid Glass metadata and relevance")
        expect(log == [
            .init(method: "POST", query: "a&b", page: 1, filters: ["isLiquidGlass = true"]),
            .init(method: "GET", query: "a&b"),
        ], "backup preserves query delimiters")
        expect(APIUsageTracker.shared.currentCount == 2, "backup request consumes quota")

        useFixture { request in
            request.method == "POST" ? (200, ["hits": []]) : (200, ["icons": [hit("C++")]])
        }
        let plus = try await search("C++").map(\.appName)
        expect(plus == ["C++"] && log.last?.query == "c++", "backup preserves literal plus signs")

        useFixture { request in
            let hits = request.page == 1 ? [hit("Archiver")] : [hit("Arc")]
            return (200, ["hits": hits, "totalPages": 9])
        }
        let paged = try await search("Arc").map(\.appName)
        expect(paged == ["Arc"], "qualified results on page 2 are discoverable")
        expect(log.map(\.page) == [1, 2], "automatically loads at most one extra page")
        expect(APIUsageTracker.shared.currentCount == 2, "second page consumes quota")

        useFixture { request in
            let hits = request.page == 1 ? [hit("Archiver")] : [hit("Arc")]
            return (200, ["hits": hits, "totalHits": 20, "limit": 10])
        }
        let providerPageSize = try await search("Arc")
        expect(providerPageSize.map(\.appName) == ["Arc"] && log.map(\.page) == [1, 2], "uses the provider's page size with totalHits when totalPages is absent")

        useFixture { request in
            let hits = (1...12).map { hit("Arc \($0)") }
            return (200, ["hits": hits, "totalPages": 9])
        }
        let sufficient = try await search("Arc")
        expect(sufficient.count == 12 && log.map(\.page) == [1], "a useful first page does not spend quota on later pages")

        useFixture { request in
            request.page == 1 ? (200, ["hits": [hit("Arc")], "totalPages": 2]) : (503, ["message": "Fixture failure"])
        }
        let partial = try await request("Arc")
        expect(partial.icons.map(\.appName) == ["Arc"] && !partial.isComplete && log.map(\.page) == [1, 2], "preserves earlier results and marks them incomplete if a later page fails")

        UserDefaults.standard.set(1, forKey: "apiMonthlyLimit")
        useFixture { _ in (200, ["hits": []]) }
        do {
            _ = try await search("Fixture")
            expect(false, "exhausted quota is reported before backup")
        } catch APIError.rateLimitExceeded {
            expect(log.count == 1, "no backup request dispatched after quota exhausted")
        }

        UserDefaults.standard.set(50, forKey: "apiMonthlyLimit")
        UserDefaults.standard.set(2, forKey: "apiRetryCount")
        useFixture { _ in
            log.count == 1 ? (503, ["message": "Retry fixture"]) : (200, ["hits": [hit("Arc")]])
        }
        let retried = try await search("Arc")
        expect(retried.map(\.appName) == ["Arc"] && log.count == 2, "transient error retries the request")
        expect(APIUsageTracker.shared.currentCount == 2, "retry consumes quota")

        useFixture { request in
            if request.method == "POST" { return (200, ["hits": []]) }
            return log.count == 2 ? (503, ["message": "Retry backup"]) : (200, ["icons": [hit("Arc")]])
        }
        let backupRetry = try await search("Arc")
        expect(backupRetry.map(\.appName) == ["Arc"] && log.map(\.method) == ["POST", "GET", "GET"], "retries the failed backup without repeating the primary")
        expect(APIUsageTracker.shared.currentCount == 3, "counts the backup retry")

        useFixture { _ in (403, ["message": "Wrong credentials"]) }
        do {
            _ = try await search("Arc")
            expect(false, "HTTP 403 throws")
        } catch APIError.httpError(let status, _) {
            expect(status == 403 && log.count == 1, "HTTP 403 does not retry")
        }

        useFixture { _ in (200, ["unrecognized": []]) }
        do {
            _ = try await search("Arc")
            expect(false, "invalid response shape is not a valid empty result")
        } catch APIError.networkError {
            expect(log.allSatisfy { $0.method == "POST" }, "invalid primary response does not become backup hits")
        }

        try await checkKeyAccounting()

        if !failures.isEmpty {
            for failure in failures { print("FAIL: \(failure)") }
            exit(1)
        }
        print("PASS: online icon matching, filtering, paging, recovery and request allowance")
    }

    private static func hit(_ name: String, downloads: Int = 10, glass: Bool? = nil) -> [String: Any] {
        let path = Data(name.utf8).base64EncodedString().replacingOccurrences(of: "/", with: "_")
        var hit: [String: Any] = [
            "appName": name,
            "icnsUrl": "https://fixture.invalid/\(path).icns",
            "lowResPngUrl": "https://fixture.invalid/\(path).png",
            "downloads": downloads,
        ]
        if let glass { hit["isLiquidGlass"] = glass }
        return hit
    }

    private static var log: [FixtureURLProtocol.SearchRequest] { FixtureURLProtocol.requestLog }
    private static var keyLog: [String] { FixtureURLProtocol.keyLog }

    private static func useFixture(resetQuota: Bool = true, _ response: @escaping (FixtureURLProtocol.SearchRequest) -> (Int, [String: Any])) {
        FixtureURLProtocol.requestLog = []
        FixtureURLProtocol.keyLog = []
        FixtureURLProtocol.response = response
        if resetQuota { APIUsageTracker.shared.resetCount() }
    }

    private static func search(_ query: String, style: IconStyle = .all) async throws -> [IconRes] {
        try await request(query, style: style).icons
    }

    private static func request(_ query: String, style: IconStyle = .all, apiKey: String? = nil) async throws -> IconSearchResult {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [FixtureURLProtocol.self]
        let session = URLSession(configuration: configuration)
        defer { session.finishTasksAndInvalidate() }
        return try await MyQueryRequestController(session: session).sendRequest(query, style: style, apiKey: apiKey)
    }

    private static func checkKeyAccounting() async throws {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "t2e")
        defaults.set(0, forKey: "t2ki")
        defaults.set(1, forKey: "apiMonthlyLimit")
        defaults.set(0, forKey: "apiRetryCount")
        defaults.removeObject(forKey: "com.iconchanger.apiKeyQueryCounts")
        defaults.set(1, forKey: "com.iconchanger.apiQueryCount")
        defaults.set(Date(), forKey: "com.iconchanger.apiQueryResetDate")
        expect(APIUsageTracker.shared.currentCount == 1, "migrates the current-month counter for the selected key")
        useFixture(resetQuota: false) { _ in (200, ["hits": [hit("Arc")]]) }
        _ = try await request("Arc")
        expect(keyLog == ["fixture-extra"] && APIUsageTracker.shared.currentCount == 1, "local exhaustion reserves and sends the alternate key")
        do {
            _ = try await request("Arc")
            expect(false, "previously exhausted keys do not regain allowance")
        } catch APIError.rateLimitExceeded {
            expect(keyLog == ["fixture-extra"], "exhausted keys never dispatch an HTTP request")
        }

        defaults.removeObject(forKey: "com.iconchanger.apiKeyQueryCounts")
        defaults.set(0, forKey: "t2ki")
        useFixture { _ in
            keyLog == ["fixture-key"] ? (429, ["message": "Provider limit"]) : (200, ["hits": [hit("Arc")]])
        }
        _ = try await request("Arc")
        expect(keyLog == ["fixture-key", "fixture-extra"] && APIUsageTracker.shared.currentCount == 1, "provider 429 moves to a separately counted alternate key")
        defaults.set(0, forKey: "t2ki")
        expect(APIUsageTracker.shared.currentCount == 1, "the initial 429 also consumes that key's local allowance")

        useFixture { _ in (200, ["hits": [hit("Arc")]]) }
        _ = try await request("Arc", apiKey: "explicit-fixture")
        expect(keyLog == ["explicit-fixture"] && APIUsageTracker.shared.currentCount == 0, "an explicit key's estimate is isolated from the selected key")
        do {
            _ = try await request("Arc", apiKey: "explicit-fixture")
            expect(false, "explicit key does not rotate when locally exhausted")
        } catch APIError.rateLimitExceeded {
            expect(keyLog == ["explicit-fixture"], "explicit exhaustion never dispatches a managed key")
        }
    }

    private static func expect(_ condition: @autoclosure () -> Bool, _ message: String) {
        if !condition() { failures.append(message) }
    }
}
