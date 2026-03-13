//
//  Request.swift
//  IconChanger
//

import Foundation
import AppKit
import SwiftyJSON
import os

class MyRequestController {
    @Sendable
    func sendRequest(_ url: URL) async throws -> NSImage? {
        try await IconImageLoader.shared.image(for: url)
    }
}

private actor RequestDeduplicator {
    private var inflight: [String: Task<[IconRes], Error>] = [:]

    /// Atomically returns an existing task or stores a new one.
    func deduplicate(for key: String, create: @Sendable () -> Task<[IconRes], Error>) -> (task: Task<[IconRes], Error>, isNew: Bool) {
        if let existing = inflight[key] {
            return (existing, false)
        }
        let task = create()
        inflight[key] = task
        return (task, true)
    }

    func remove(_ key: String) {
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
        case .rateLimitExceeded, .apiKeyMissing:
            return true
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

    private let countKey = "com.iconchanger.apiQueryCount"
    private let resetDateKey = "com.iconchanger.apiQueryResetDate"
    private let lock = NSLock()

    var currentCount: Int {
        lock.lock()
        defer { lock.unlock() }
        resetIfNewMonth()
        return UserDefaults.standard.integer(forKey: countKey)
    }

    var monthlyLimit: Int {
        let stored = UserDefaults.standard.integer(forKey: "apiMonthlyLimit")
        return stored > 0 ? stored : 50
    }

    var remaining: Int {
        max(0, monthlyLimit - currentCount)
    }

    func canMakeRequest() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        resetIfNewMonth()
        if UserDefaults.standard.integer(forKey: countKey) < monthlyLimit {
            return true
        }
        if APIKeyManager.allKeys.count > 1 {
            APIKeyManager.rotateToNextKey()
            UserDefaults.standard.set(0, forKey: countKey)
            return true
        }
        return false
    }

    func recordRequest() {
        lock.lock()
        resetIfNewMonth()
        let current = UserDefaults.standard.integer(forKey: countKey)
        UserDefaults.standard.set(current + 1, forKey: countKey)
        lock.unlock()
    }

    func resetCount() {
        lock.lock()
        UserDefaults.standard.set(0, forKey: countKey)
        UserDefaults.standard.set(Date(), forKey: resetDateKey)
        lock.unlock()
    }

    private func resetIfNewMonth() {
        let lastReset = UserDefaults.standard.object(forKey: resetDateKey) as? Date ?? Date.distantPast
        let calendar = Calendar.current
        if !calendar.isDate(lastReset, equalTo: Date(), toGranularity: .month) {
            UserDefaults.standard.set(0, forKey: countKey)
            UserDefaults.standard.set(Date(), forKey: resetDateKey)
        }
    }
}

class MyQueryRequestController {
    static let shared = MyQueryRequestController()

    private static let apiBaseURL = "https://api.macosicons.com/api"
    private static let searchHitsPerPage = 50
    private static let testHitsPerPage = 10
    private static let backupSearchLimit = 50

    private let session: URLSession
    private let logger: Logger
    private let dedup = RequestDeduplicator()

    private var retryCount: Int {
        UserDefaults.standard.integer(forKey: "apiRetryCount")
    }

    private var timeoutSeconds: Double {
        let stored = UserDefaults.standard.double(forKey: "apiTimeoutSeconds")
        return stored > 0 ? stored : 15.0
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
        configuration.httpShouldUsePipelining = true
        return URLSession(configuration: configuration)
    }

    func sendRequest(_ query: String, style: IconStyle = .all, apiKey: String? = nil) async throws -> [IconRes] {
        guard APIUsageTracker.shared.canMakeRequest() else {
            throw APIError.rateLimitExceeded(
                used: APIUsageTracker.shared.currentCount,
                limit: APIUsageTracker.shared.monthlyLimit
            )
        }

        let resolvedKey = apiKey ?? APIKeyManager.pickKey()
        let key = "\(query)|\(style.displayName)"

        let (task, isNew) = await dedup.deduplicate(for: key) { [self] in
            Task<[IconRes], Error> {
                let maxAttempts = max(1, self.retryCount + 1)
                var lastError: Error?

                for attempt in 1...maxAttempts {
                    do {
                        let results = try await self.sendRequestToMeilisearch(query, style: style, apiKey: resolvedKey)
                        if results.isEmpty {
                            self.logger.debug("Meilisearch returned no results for '\(query, privacy: .public)'. Trying backup API.")
                            return try await self.sendBackupRequest(query, style: style, apiKey: resolvedKey)
                        }
                        return results
                    } catch is CancellationError {
                        throw CancellationError()
                    } catch let error as APIError where error.isNonRetryable {
                        throw error
                    } catch {
                        lastError = error
                        if attempt < maxAttempts {
                            self.logger.debug("Attempt \(attempt) failed for '\(query, privacy: .public)': \(error.localizedDescription, privacy: .public). Retrying...")
                            try await Task.sleep(nanoseconds: UInt64(attempt) * 500_000_000)
                        }
                    }
                }
                throw lastError ?? APIError.networkError("Unknown error")
            }
        }

        if !isNew {
            logger.debug("Deduplicating request for '\(query, privacy: .public)'")
        }

        defer { if isNew { Task { await dedup.remove(key) } } }

        let results = try await task.value
        APIUsageTracker.shared.recordRequest()
        return results
    }
    
    private func sendRequestToMeilisearch(_ query: String, style: IconStyle, apiKey: String) async throws -> [IconRes] {
        let query = queryMix(query)
        logger.debug("Search '\(query, privacy: .public)' style=\(style.displayName, privacy: .public)")

        let session = self.session
        let urlString = "\(Self.apiBaseURL)/search"

        guard let URL = URL(string: urlString) else {
            logger.error("Invalid search URL.")
            throw APIError.networkError("Invalid search URL")
        }
        var request = URLRequest(url: URL)
        request.httpMethod = "POST"

        if apiKey.isEmpty {
            logger.warning("API key not configured; search request may be rejected.")
        }

        if !apiKey.isEmpty {
            request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        var filters: [String] = []
        if let styleFilter = style.filterQuery {
            filters.append(styleFilter)
            logger.debug("Applying style filter '\(styleFilter, privacy: .public)'")
        }

        let bodyObject: [String : Any] = [
            "query": query,
            "searchOptions": [
                "hitsPerPage": Self.searchHitsPerPage,
                "page": 1,
                "offset": 0,
                "filters": filters,
                "sort": ["timeStamp:desc", "category:asc"]
            ]
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: bodyObject, options: [])
            request.httpBody = jsonData
        } catch {
            logger.error("Failed to encode search request body: \(error.localizedDescription, privacy: .public)")
            throw APIError.networkError("Failed to encode request: \(error.localizedDescription)")
        }

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                logger.error("Search response was not HTTP.")
                throw APIError.networkError("Invalid response from server")
            }

            if httpResponse.statusCode != 200 {
                let errorMsg = Self.extractAPIMessage(from: data) ?? "HTTP \(httpResponse.statusCode)"
                logger.error("Search request failed (\(httpResponse.statusCode)): \(errorMsg, privacy: .public)")
                throw APIError.httpError(statusCode: httpResponse.statusCode, message: errorMsg)
            }

            let json = try JSON(data: data)

            // Check if the response has expected structure
            if json["hits"].exists() {
                logger.debug("Received \(json["hits"].arrayValue.count) hits for '\(query, privacy: .public)'")
            } else {
                logger.warning("Search response missing 'hits' for '\(query, privacy: .public)'")
            }

            let res = json["hits"].arrayValue.compactMap { hit in
                if let lowResPngUrl = hit["lowResPngUrl"].url, let icnsUrl = hit["icnsUrl"].url {
                    return IconRes(appName: hit["appName"].stringValue, icnsUrl: icnsUrl, lowResPngUrl: lowResPngUrl, downloads: hit["downloads"].intValue)
                } else {
                    logger.debug("Search hit missing URLs for '\(hit["appName"].stringValue, privacy: .public)'")
                    return nil
                }
            }

            let queryWords = query.lowercased().split(separator: " ").map(String.init)
            let filteredRes = res.filter { icon in
                let name = icon.appName.lowercased()
                return queryWords.allSatisfy { name.contains($0) }
            }
            logger.debug("Returning \(filteredRes.count) icons after filtering for '\(query, privacy: .public)'")

            return filteredRes.sorted { res1, res2 in
                res1.downloads > res2.downloads
            }
        } catch let error as APIError {
            throw error
        } catch {
            logger.error("Search request error: \(error.localizedDescription, privacy: .public)")
            let nsError = error as NSError
            logger.debug("Search error details domain=\(nsError.domain, privacy: .public) code=\(nsError.code, privacy: .public)")
            if nsError.code == NSURLErrorTimedOut {
                throw APIError.requestTimeout
            }
            throw APIError.networkError(error.localizedDescription)
        }
    }
    
    func testAPIConnection(apiKey: String? = nil) async throws -> (success: Bool, iconCount: Int) {
        let testQuery = "test_api_connection"
        logger.debug("Testing API connectivity.")

        let session = self.session

        let urlString = "\(Self.apiBaseURL)/search"
        guard let URL = URL(string: urlString) else {
            throw NSError(domain: "IconChanger", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Invalid API endpoint URL"])
        }

        var request = URLRequest(url: URL)
        request.httpMethod = "POST"

        let resolvedKey = apiKey ?? KeychainHelper.load(key: "apiKey") ?? ""
        if resolvedKey.isEmpty {
            throw NSError(domain: "IconChanger", code: 1002, userInfo: [NSLocalizedDescriptionKey: "API key not provided"])
        }

        request.addValue(resolvedKey, forHTTPHeaderField: "x-api-key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Create a minimal query body
        let bodyObject: [String: Any] = [
            "query": testQuery,
            "searchOptions": [
                "hitsPerPage": Self.testHitsPerPage,
                "page": 1,
                "sort": ["timeStamp:desc"]
            ]
        ]
        
        // Convert body to JSON data
        let jsonData = try JSONSerialization.data(withJSONObject: bodyObject, options: [])
        request.httpBody = jsonData
        
        // Make the request
        let (data, response) = try await session.data(for: request)
        
        // Check response status code
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "IconChanger", code: 1003, userInfo: [NSLocalizedDescriptionKey: "Invalid response type"])
        }
        
        // Check if the status code indicates success
        if httpResponse.statusCode != 200 {
            let message = Self.extractAPIMessage(from: data) ?? "HTTP \(httpResponse.statusCode)"
            throw NSError(domain: "IconChanger", code: httpResponse.statusCode,
                          userInfo: [NSLocalizedDescriptionKey: message])
        }
        
        // Parse the response
        let json = try JSON(data: data)
        
        // Check if the response has the expected structure
        guard json["hits"].exists() else {
            throw NSError(domain: "IconChanger", code: 1004,
                          userInfo: [NSLocalizedDescriptionKey: "Invalid API response format"])
        }
        
        // Count the icons
        let iconCount = json["hits"].arrayValue.count
        
        // Return success and icon count
        return (true, iconCount)
    }
    
    // Backup method using a different approach to search the site
    private func sendBackupRequest(_ query: String, style: IconStyle, apiKey: String) async throws -> [IconRes] {
        let query = queryMix(query)
        logger.debug("Running backup search for '\(query, privacy: .public)', style=\(style.displayName, privacy: .public)")

        let session = self.session

        let urlString = "\(Self.apiBaseURL)/icons?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query)&limit=\(Self.backupSearchLimit)"

        guard let url = URL(string: urlString) else {
            logger.error("Invalid backup search URL")
            throw APIError.networkError("Invalid backup search URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        if !apiKey.isEmpty {
            request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        }
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                logger.error("Backup search response was not HTTP.")
                throw APIError.networkError("Invalid response from backup server")
            }

            if httpResponse.statusCode == 404 {
                logger.debug("Backup search returned 404 for '\(query, privacy: .public)' — no results.")
                return []
            }

            if httpResponse.statusCode != 200 {
                let errorMsg = Self.extractAPIMessage(from: data) ?? "HTTP \(httpResponse.statusCode)"
                logger.error("Backup search failed (\(httpResponse.statusCode)): \(errorMsg, privacy: .public)")
                throw APIError.httpError(statusCode: httpResponse.statusCode, message: errorMsg)
            }

            let json = try JSON(data: data)

            var icons: [IconRes] = []

            if let results = extractIconsFromJSON(json) {
                icons = results
            } else {
                logger.warning("Backup search could not extract icon data.")
                if let directData = json.array?.first {
                    if let jsonObj = directData.dictionary {
                        logger.debug("Backup search response keys: \(jsonObj.keys.joined(separator: ", "), privacy: .public)")
                    }
                }
            }
            return icons.sorted { $0.downloads > $1.downloads }
        } catch let error as APIError {
            throw error
        } catch {
            logger.error("Backup search request failed: \(error.localizedDescription, privacy: .public)")
            let nsError = error as NSError
            if nsError.code == NSURLErrorTimedOut {
                throw APIError.requestTimeout
            }
            throw APIError.networkError(error.localizedDescription)
        }
    }
    
    // Helper method to try and extract icons from JSON in various formats
    private func extractIconsFromJSON(_ json: JSON) -> [IconRes]? {
        var results: [IconRes] = []
        
        // Try different possible response structures
        
        // Try format with "data" array
        if let dataArray = json["data"].array {
            logger.debug("Backup response contained 'data' array.")
            for item in dataArray {
                if let name = item["name"].string,
                   let icnsUrlString = item["icnsUrl"].string,
                   let lowResUrlString = item["lowResPngUrl"].string,
                   let icnsUrl = URL(string: icnsUrlString),
                   let lowResPngUrl = URL(string: lowResUrlString) {
                    
                    let downloads = item["downloads"].int ?? 0
                    if let icon = IconRes(appName: name, icnsUrl: icnsUrl, lowResPngUrl: lowResPngUrl, downloads: downloads) {
                        results.append(icon)
                    }
                }
            }
        }
        
        // Try format with "icons" array
        else if let iconsArray = json["icons"].array {
            logger.debug("Backup response contained 'icons' array.")
            for item in iconsArray {
                if let name = item["appName"].string,
                   let icnsUrlString = item["icnsUrl"].string,
                   let lowResUrlString = item["lowResPngUrl"].string,
                   let icnsUrl = URL(string: icnsUrlString),
                   let lowResPngUrl = URL(string: lowResUrlString) {
                    
                    let downloads = item["downloads"].int ?? 0
                    if let icon = IconRes(appName: name, icnsUrl: icnsUrl, lowResPngUrl: lowResPngUrl, downloads: downloads) {
                        results.append(icon)
                    }
                }
            }
        }
        
        // Try format where the response is directly an array
        else if let directArray = json.array {
            logger.debug("Backup response was a direct array.")
            for item in directArray {
                if let name = item["appName"].string,
                   let icnsUrlString = item["icnsUrl"].string,
                   let lowResUrlString = item["lowResPngUrl"].string,
                   let icnsUrl = URL(string: icnsUrlString),
                   let lowResPngUrl = URL(string: lowResUrlString) {
                    
                    let downloads = item["downloads"].int ?? 0
                    if let icon = IconRes(appName: name, icnsUrl: icnsUrl, lowResPngUrl: lowResPngUrl, downloads: downloads) {
                        results.append(icon)
                    }
                }
            }
        }
        
        return results.isEmpty ? nil : results
    }

    /// Extract a clean "message" string from a JSON API error response body.
    private static func extractAPIMessage(from data: Data) -> String? {
        guard let json = try? JSON(data: data) else { return nil }
        return json["message"].string ?? json["statusMessage"].string
    }

    func queryMix(_ query: String) -> String {
        switch query {
        case "PyCharm Professional Edition": return "PyCharm"
        case "Discord PTB": return "Discord"
        default: return query
        }
    }
}

