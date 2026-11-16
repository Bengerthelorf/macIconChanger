//
//  Request.swift
//  IconChanger
//

import Foundation
import CoreFoundation
import CryptoKit
import os

private actor RequestDeduplicator {
    struct Key: Hashable {
        let query: String
        let style: IconStyle
        let explicitKey: String?
    }

    private var inflight: [Key: Task<IconSearchResult, Error>] = [:]

    /// Atomically returns an existing task or stores a new one.
    func deduplicate(
        for key: Key, create: @Sendable () -> Task<IconSearchResult, Error>
    ) -> (task: Task<IconSearchResult, Error>, isNew: Bool) {
        if let existing = inflight[key] {
            return (existing, false)
        }
        let task = create()
        inflight[key] = task
        return (task, true)
    }

    func remove(_ key: Key) {
        inflight.removeValue(forKey: key)
    }
}

// MARK: - API Error Types

enum APIError: Error, LocalizedError {
    case rateLimitExceeded(used: Int, limit: Int)
    case requestTimeout
    case apiKeyMissing
    case httpError(statusCode: Int, message: String)
    case noResults
    case networkError(String)

    var isNonRetryable: Bool {
        switch self {
        case .rateLimitExceeded, .apiKeyMissing, .noResults:
            return true
        case .httpError(let status, _):
            return (400..<500).contains(status) && status != 408
        default:
            return false
        }
    }

    var errorDescription: String? {
        switch self {
        case .rateLimitExceeded(let used, let limit):
            return String(format: NSLocalizedString("Monthly API query limit reached (%d/%d). Resets on the 1st of next month.", comment: "API rate limit error"), used, limit)
        case .requestTimeout:
            return NSLocalizedString("Request timed out. Check your network connection or increase the timeout in Settings.", comment: "API timeout error")
        case .apiKeyMissing:
            return NSLocalizedString("API key not configured. Add your macosicons.com API key in Settings.", comment: "API key missing error")
        case .httpError(let statusCode, let message):
            if statusCode == 429 {
                return NSLocalizedString("Too many requests. The API server is rate-limiting you. Try again later.", comment: "API 429 error")
            }
            return String(format: NSLocalizedString("API error (HTTP %d): %@", comment: "API HTTP error"), statusCode, message)
        case .noResults:
            return NSLocalizedString("No icons found for this search.", comment: "API no results")
        case .networkError(let message):
            return String(format: NSLocalizedString("Network error: %@", comment: "Network error"), message)
        }
    }
}

// MARK: - API Usage Tracker

class APIUsageTracker {
    static let shared = APIUsageTracker()

    private let legacyCountKey = "com.iconchanger.apiQueryCount"
    private let countsKey = "com.iconchanger.apiKeyQueryCounts"
    private let resetDateKey = "com.iconchanger.apiQueryResetDate"
    private let lock = NSLock()

    var currentCount: Int {
        lock.lock()
        defer { lock.unlock() }
        let currentKey = IconRemoteRequestPolicy.normalizedAPIKey(APIKeyManager.pickKey())
        let counts = currentCounts(selectedKey: currentKey)
        return currentKey.map { counts[Self.identity($0), default: 0] } ?? 0
    }

    var monthlyLimit: Int {
        let stored = UserDefaults.standard.integer(forKey: "apiMonthlyLimit")
        return stored > 0 ? stored : 50
    }

    var remaining: Int {
        max(0, monthlyLimit - currentCount)
    }

    /// Reserves quota for the key used by this HTTP request.
    func authorizeRequest(explicitKey: String?, excluding exhaustedKeys: Set<String> = []) throws -> String {
        lock.lock()
        defer { lock.unlock() }

        let selectedKey = IconRemoteRequestPolicy.normalizedAPIKey(APIKeyManager.pickKey())
        let keys: [String]
        if let explicitKey {
            guard let key = IconRemoteRequestPolicy.normalizedAPIKey(explicitKey) else {
                throw APIError.apiKeyMissing
            }
            keys = [key]
        } else {
            let configured = APIKeyManager.allKeys.compactMap(IconRemoteRequestPolicy.normalizedAPIKey)
            guard !configured.isEmpty else { throw APIError.apiKeyMissing }
            let start = configured.firstIndex(where: { $0 == selectedKey }) ?? 0
            keys = Array(configured[start...]) + Array(configured[..<start])
        }

        let limit = monthlyLimit
        var counts = currentCounts(selectedKey: selectedKey)
        let candidates = keys.filter { !exhaustedKeys.contains($0) }
        guard let key = candidates.first(where: { counts[Self.identity($0), default: 0] < limit }) else {
            let used = candidates.first.map { counts[Self.identity($0), default: 0] } ?? limit
            throw APIError.rateLimitExceeded(used: used, limit: limit)
        }

        counts[Self.identity(key), default: 0] += 1
        UserDefaults.standard.set(counts, forKey: countsKey)
        if explicitKey == nil && key != selectedKey {
            for _ in keys {
                APIKeyManager.rotateToNextKey()
                if IconRemoteRequestPolicy.normalizedAPIKey(APIKeyManager.pickKey()) == key { break }
            }
        }
        return key
    }

    func resetCount() {
        lock.lock()
        defer { lock.unlock() }
        let selectedKey = IconRemoteRequestPolicy.normalizedAPIKey(APIKeyManager.pickKey())
        var counts = currentCounts(selectedKey: selectedKey)
        if let selectedKey { counts.removeValue(forKey: Self.identity(selectedKey)) }
        UserDefaults.standard.set(counts, forKey: countsKey)
    }

    private func currentCounts(selectedKey: String?) -> [String: Int] {
        let defaults = UserDefaults.standard
        let lastReset = defaults.object(forKey: resetDateKey) as? Date ?? .distantPast
        if !Calendar.current.isDate(lastReset, equalTo: Date(), toGranularity: .month) {
            defaults.removeObject(forKey: legacyCountKey)
            defaults.removeObject(forKey: countsKey)
            defaults.set(Date(), forKey: resetDateKey)
        }
        var counts = defaults.dictionary(forKey: countsKey) as? [String: Int] ?? [:]
        if let selectedKey, let legacyCount = defaults.object(forKey: legacyCountKey) as? Int {
            counts[Self.identity(selectedKey), default: 0] += max(0, legacyCount)
            defaults.set(counts, forKey: countsKey)
            defaults.removeObject(forKey: legacyCountKey)
        }
        return counts
    }

    private static func identity(_ key: String) -> String {
        Data(SHA256.hash(data: Data(key.utf8))).base64EncodedString()
    }
}

class MyQueryRequestController {
    static let shared = MyQueryRequestController()

    private static let apiBaseURL = "https://api.macosicons.com/api"
    private static let searchHitsPerPage = 50
    private static let sufficientSearchResults = 8
    private static let testHitsPerPage = 10
    private static let backupSearchLimit = 50

    private let session: URLSession
    private let logger: Logger
    private let dedup = RequestDeduplicator()

    private var retryCount: Int {
        UserDefaults.standard.integer(forKey: "apiRetryCount")
    }

    init(session: URLSession? = nil) {
        self.session = session ?? MyQueryRequestController.makeSession()
        self.logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "IconChanger", category: "Network")
    }

    private static func makeSession() -> URLSession {
        let timeout = UserDefaults.standard.double(forKey: "apiTimeoutSeconds")
        let effectiveTimeout = timeout > 0 ? timeout : 15.0

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = effectiveTimeout
        configuration.timeoutIntervalForResource = effectiveTimeout * 2
        configuration.httpMaximumConnectionsPerHost = 4
        configuration.requestCachePolicy = .reloadRevalidatingCacheData
        configuration.urlCache = URLCache(
            memoryCapacity: 5 * 1024 * 1024,
            diskCapacity: 30 * 1024 * 1024,
            diskPath: "IconQueryCache"
        )
        return URLSession(configuration: configuration)
    }

    func sendRequest(_ query: String, style: IconStyle = .all, apiKey: String? = nil) async throws -> IconSearchResult {
        let query = IconSearchPolicy.normalizedQuery(query)
        guard !query.isEmpty else { return IconSearchResult(icons: []) }
        try Task.checkCancellation()

        let diagnosticsContext = DiagnosticsContext(operation: .network)
        let diagnosticsTimer = DiagnosticsTimer()
        DiagnosticsLogger.shared.log(
            .operation,
            phase: "icon_search.start",
            context: diagnosticsContext,
            details: [
                "query_length": String(query.count),
                "style": style.displayName,
                "retry_count": String(retryCount),
            ]
        )

        let key = RequestDeduplicator.Key(query: query, style: style, explicitKey: apiKey)
        let (task, isNew) = await dedup.deduplicate(for: key) { [self] in
            Task<IconSearchResult, Error> {
                try await search(query, style: style, apiKey: apiKey)
            }
        }

        if !isNew {
            DiagnosticsLogger.shared.log(
                .step,
                phase: "icon_search.request_deduplicated",
                context: diagnosticsContext
            )
        }

        do {
            let results = try await task.value
            if isNew { await dedup.remove(key) }
            DiagnosticsLogger.shared.log(
                .operation,
                phase: "icon_search.completed",
                context: diagnosticsContext,
                durationMilliseconds: diagnosticsTimer.elapsedMilliseconds,
                details: ["result_count": String(results.icons.count), "is_complete": String(results.isComplete)]
            )
            return results
        } catch {
            if isNew { await dedup.remove(key) }
            DiagnosticsLogger.shared.log(
                .failure,
                phase: "icon_search.failed",
                context: diagnosticsContext,
                durationMilliseconds: diagnosticsTimer.elapsedMilliseconds,
                details: diagnosticDetails(for: error)
            )
            throw error
        }
    }

    private func diagnosticDetails(for error: Error) -> [String: String] {
        var details = DiagnosticsLogger.errorDetails(error)
        guard let apiError = error as? APIError else { return details }
        switch apiError {
        case .rateLimitExceeded(let used, let limit):
            details["error_kind"] = "rate_limit_exceeded"
            details["used"] = String(used)
            details["limit"] = String(limit)
        case .requestTimeout:
            details["error_kind"] = "request_timeout"
        case .apiKeyMissing:
            details["error_kind"] = "api_key_missing"
        case .httpError(let statusCode, _):
            details["error_kind"] = "http_error"
            details["http_status"] = String(statusCode)
        case .noResults:
            details["error_kind"] = "no_results"
        case .networkError:
            details["error_kind"] = "network_error"
        }
        return details
    }
    
    private func search(_ query: String, style: IconStyle, apiKey: String?) async throws -> IconSearchResult {
        let first = try await searchPage(query, style: style, page: 1, apiKey: apiKey)
        var results = IconSearchPolicy.rankAndDeduplicate(first.icons, queries: [query])
        if results.count < Self.sufficientSearchResults && first.hasAnotherPage {
            do {
                let second = try await searchPage(query, style: style, page: 2, apiKey: apiKey)
                results = IconSearchPolicy.rankAndDeduplicate(results + second.icons, queries: [query])
            } catch is CancellationError {
                throw CancellationError()
            } catch where !results.isEmpty {
                logger.debug("Returning first-page results after a later page failed: \(error.localizedDescription, privacy: .public)")
                return IconSearchResult(icons: results, isComplete: false)
            }
        }

        if !results.isEmpty { return IconSearchResult(icons: results) }
        let backup = try await sendBackupRequest(query, style: style, apiKey: apiKey)
        return IconSearchResult(icons: IconSearchPolicy.rankAndDeduplicate(backup, queries: [query]))
    }

    private func searchPage(
        _ query: String, style: IconStyle, page: Int, apiKey: String?
    ) async throws -> (icons: [IconRes], hasAnotherPage: Bool) {
        var request = URLRequest(url: URL(string: "\(Self.apiBaseURL)/search")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let options: [String: Any] = [
            "hitsPerPage": Self.searchHitsPerPage,
            "page": page,
            "filters": style.filterQuery.map { [$0] } ?? [],
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: ["query": query, "searchOptions": options])

        guard let data = try await requestData(request, apiKey: apiKey),
              let response = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let hits = response["hits"] as? [Any] else {
            throw APIError.networkError("Invalid search response: expected a hits array.")
        }
        let totalPages = Self.integer(response["totalPages"])
        let totalHits = Self.integer(response["totalHits"])
        let responseLimit = Self.integer(response["limit"]).flatMap {
            (1...Self.searchHitsPerPage).contains($0) ? $0 : nil
        } ?? Self.searchHitsPerPage
        let hasAnotherPage = totalPages.map { $0 > page }
            ?? totalHits.map { $0 > page * responseLimit }
            ?? false
        return (Self.decodeIcons(hits, style: style, requireStyleMetadata: false), hasAnotherPage)
    }

    private func sendBackupRequest(_ query: String, style: IconStyle, apiKey: String?) async throws -> [IconRes] {
        var components = URLComponents(string: "\(Self.apiBaseURL)/icons")!
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "limit", value: String(Self.backupSearchLimit)),
        ]
        // Form-style decoders otherwise treat literal plus signs as spaces.
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        guard let url = components.url else {
            throw APIError.networkError("Invalid backup search URL")
        }

        guard let data = try await requestData(URLRequest(url: url), apiKey: apiKey, notFoundIsEmpty: true) else {
            return []
        }
        let response = try? JSONSerialization.jsonObject(with: data)
        let dictionary = response as? [String: Any]
        guard let hits = dictionary?["data"] as? [Any]
            ?? dictionary?["icons"] as? [Any]
            ?? response as? [Any] else {
            throw APIError.networkError("Invalid backup search response: expected an icons array.")
        }
        return Self.decodeIcons(hits, style: style, requireStyleMetadata: true)
    }

    private static func decodeIcons(_ hits: [Any], style: IconStyle, requireStyleMetadata: Bool) -> [IconRes] {
        hits.compactMap { value in
            guard let hit = value as? [String: Any],
                  let name = hit["appName"] as? String ?? hit["name"] as? String,
                  let icon = (hit["icnsUrl"] as? String).flatMap(URL.init(string:)),
                  let preview = (hit["lowResPngUrl"] as? String).flatMap(URL.init(string:)) else {
                return nil
            }
            if style == .liquidGlass && (requireStyleMetadata || hit["isLiquidGlass"] != nil) {
                guard let isLiquidGlass = hit["isLiquidGlass"] as? NSNumber,
                      CFGetTypeID(isLiquidGlass) == CFBooleanGetTypeID(),
                      isLiquidGlass.boolValue else {
                    return nil
                }
            }
            return IconRes(appName: name, icnsUrl: icon, lowResPngUrl: preview, downloads: integer(hit["downloads"]) ?? 0)
        }
    }

    private static func integer(_ value: Any?) -> Int? {
        (value as? Int) ?? (value as? String).flatMap(Int.init)
    }

    private func requestData(
        _ request: URLRequest, apiKey: String?, notFoundIsEmpty: Bool = false
    ) async throws -> Data? {
        var retries = 0
        var exhaustedKeys = Set<String>()
        var lastRateError: APIError?
        let maxRetries = max(0, retryCount)

        while true {
            try Task.checkCancellation()
            let key: String
            do {
                key = try APIUsageTracker.shared.authorizeRequest(explicitKey: apiKey, excluding: exhaustedKeys)
            } catch {
                if let lastRateError { throw lastRateError }
                throw error
            }

            do {
                let (data, response) = try await readResponse(request, apiKey: key)
                if response.statusCode == 404 && notFoundIsEmpty { return nil }
                guard response.statusCode == 200 else {
                    let message = Self.extractAPIMessage(from: data) ?? "HTTP \(response.statusCode)"
                    throw APIError.httpError(statusCode: response.statusCode, message: message)
                }
                return data
            } catch is CancellationError {
                throw CancellationError()
            } catch let error as APIError {
                if case .httpError(statusCode: 429, _) = error, apiKey == nil {
                    exhaustedKeys.insert(key)
                    lastRateError = error
                    continue
                }
                guard !error.isNonRetryable, retries < maxRetries else { throw error }
                retries += 1
                try await Task.sleep(nanoseconds: UInt64(retries) * 500_000_000)
            }
        }
    }

    private func readResponse(_ request: URLRequest, apiKey: String) async throws -> (Data, HTTPURLResponse) {
        var request = request
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await session.data(for: request)
            guard let response = response as? HTTPURLResponse else {
                throw APIError.networkError("Invalid response from server")
            }
            return (data, response)
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as URLError where error.code == .cancelled {
            throw CancellationError()
        } catch let error as URLError where error.code == .timedOut {
            throw APIError.requestTimeout
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error.localizedDescription)
        }
    }

    func testAPIConnection(apiKey: String? = nil) async throws -> (success: Bool, iconCount: Int) {
        let diagnosticsContext = DiagnosticsContext(operation: .network)
        let diagnosticsTimer = DiagnosticsTimer()
        let testQuery = "test_api_connection"
        logger.debug("Testing API connectivity.")
        DiagnosticsLogger.shared.log(
            .operation,
            phase: "api_connection_test.start",
            context: diagnosticsContext,
            details: ["using_explicit_key": String(apiKey != nil)]
        )

        do {
            let urlString = "\(Self.apiBaseURL)/search"
            guard let URL = URL(string: urlString) else {
                throw NSError(domain: "IconChanger", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Invalid API endpoint URL"])
            }

            var request = URLRequest(url: URL)
            request.httpMethod = "POST"

            guard let resolvedKey = IconRemoteRequestPolicy.normalizedAPIKey(
                apiKey ?? KeychainHelper.load(key: "apiKey") ?? ""
            ) else {
                throw NSError(domain: "IconChanger", code: 1002, userInfo: [NSLocalizedDescriptionKey: "API key not provided"])
            }

            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
            let bodyObject: [String: Any] = [
                "query": testQuery,
                "searchOptions": [
                    "hitsPerPage": Self.testHitsPerPage,
                    "page": 1,
                    "sort": ["timeStamp:desc"]
                ]
            ]
        
            let jsonData = try JSONSerialization.data(withJSONObject: bodyObject, options: [])
            request.httpBody = jsonData

            let key = try APIUsageTracker.shared.authorizeRequest(explicitKey: resolvedKey)
            let (data, httpResponse) = try await readResponse(request, apiKey: key)

            if httpResponse.statusCode != 200 {
                let message = Self.extractAPIMessage(from: data) ?? "HTTP \(httpResponse.statusCode)"
                throw NSError(domain: "IconChanger", code: httpResponse.statusCode,
                              userInfo: [NSLocalizedDescriptionKey: message])
            }
        
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let hits = json["hits"] as? [Any] else {
                throw NSError(domain: "IconChanger", code: 1004,
                              userInfo: [NSLocalizedDescriptionKey: "Invalid API response format"])
            }

            let iconCount = hits.count
            DiagnosticsLogger.shared.log(
                .operation,
                phase: "api_connection_test.completed",
                context: diagnosticsContext,
                durationMilliseconds: diagnosticsTimer.elapsedMilliseconds,
                details: [
                    "http_status": String(httpResponse.statusCode),
                    "result_count": String(iconCount),
                ]
            )
            return (true, iconCount)
        } catch {
            var details = DiagnosticsLogger.errorDetails(error)
            let nsError = error as NSError
            if (100...599).contains(nsError.code) {
                details["http_status"] = String(nsError.code)
            }
            DiagnosticsLogger.shared.log(
                .failure,
                phase: "api_connection_test.failed",
                context: diagnosticsContext,
                durationMilliseconds: diagnosticsTimer.elapsedMilliseconds,
                details: details
            )
            throw error
        }
    }
    
    private static func extractAPIMessage(from data: Data) -> String? {
        guard let response = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        return response["message"] as? String ?? response["statusMessage"] as? String
    }
}
