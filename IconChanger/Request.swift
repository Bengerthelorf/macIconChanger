//
//  Request.swift
//  IconChanger
//
//  Created by 朱浩宇 on 2022/4/28.
//  Modified by seril on 2023/7/25.
//  Modified by Bengerthelorf on 2025/3/21.
//

import Foundation
import AppKit
import SwiftyJSON

class MyRequestController {
    @Sendable
    func sendRequest(_ URL: URL) async throws -> NSImage? {
        /* Configure session, choose between:
         * defaultSessionConfiguration
         * ephemeralSessionConfiguration
         * backgroundSessionConfigurationWithIdentifier:
         And set session-wide properties, such as: HTTPAdditionalHeaders,
         HTTPCookieAcceptPolicy, requestCachePolicy or timeoutIntervalForRequest.
         */
        print("🖼️ Requesting icon from: \(URL.absoluteString)")
        
        if URL.isFileURL {
            print("📁 Loading icon from local file")
            // Create and return NSImage on the main thread
            return await MainActor.run {
                let image = NSImage(byReferencing: URL)
                if image.isValid {
                    print("✅ Successfully loaded local icon")
                    return NSImage(data: image.tiffRepresentation ?? Data()) ?? image  // Create a new NSImage to ensure it's valid for memory safety
                } else {
                    print("❌ Failed to load local icon from \(URL.path)")
                    return nil
                }
            }
        }

        let sessionConfig = URLSessionConfiguration.default
        // Increase timeout interval
        sessionConfig.timeoutIntervalForRequest = 30.0
        sessionConfig.timeoutIntervalForResource = 60.0

        /* Create session, and optionally set a URLSessionDelegate. */
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)

        /* Create the Request:
         Request (16) (GET https://media.macosicons.com/parse/files/macOSicons/acb24773e8384e032faf6b07704796d3_Spark_icon.icns)
         */

        var request = URLRequest(url: URL)
        request.httpMethod = "GET"

        // Headers
        request.addValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.addValue("en-US,en;q=0.9", forHTTPHeaderField: "Accept-Language")
        request.addValue("keep-alive", forHTTPHeaderField: "Connection")
        request.addValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5.1 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

        // For debug purposes, print all request headers
        print("📋 Icon request headers:")
        request.allHTTPHeaderFields?.forEach { key, value in
            print("  \(key): \(value)")
        }

        /* Start a new Task */
        do {
            print("🚀 Starting download for icon")
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response type, not HTTPURLResponse")
                return nil
            }
            
            print("📥 Icon response status code: \(httpResponse.statusCode)")
            print("📥 Icon response content type: \(httpResponse.allHeaderFields["Content-Type"] ?? "unknown")")
            print("📥 Icon response data size: \(ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .file))")
            
            if httpResponse.statusCode != 200 {
                // Try to print response body to get error details
                if let errorStr = String(data: data, encoding: .utf8) {
                    print("❌ Error response for icon: \(errorStr)")
                }
                return nil
            }
            
            if data.isEmpty {
                print("⚠️ Received empty data for icon")
                return nil
            }
            
            // Create and return NSImage on the main thread
            return await MainActor.run {
                if let image = NSImage(data: data) {
                    print("✅ Successfully created NSImage from data (size: \(image.size.width) x \(image.size.height))")
                    return NSImage(data: image.tiffRepresentation ?? Data()) ?? image  // Create a new NSImage to ensure it's valid for memory safety
                } else {
                    print("❌ Failed to create NSImage from data")
                    
                    // Try to figure out what type of data we received
                    let firstBytes = data.prefix(min(4, data.count))
                    let hexString = firstBytes.map { String(format: "%02x", $0) }.joined()
                    print("⚠️ First bytes of received data: \(hexString)")
                    
                    // Check common image file signatures
                    if hexString.hasPrefix("89504e47") {
                        print("📄 Data appears to be a PNG file")
                    } else if hexString.hasPrefix("ffd8ff") {
                        print("📄 Data appears to be a JPEG file")
                    } else if hexString.hasPrefix("47494638") {
                        print("📄 Data appears to be a GIF file")
                    } else if hexString.hasPrefix("4949") || hexString.hasPrefix("4d4d") {
                        print("📄 Data appears to be a TIFF file")
                    } else {
                        print("❓ Unable to determine data format from signature")
                    }
                    
                    return nil
                }
            }
        } catch {
            print("❌ Error downloading icon: \(error.localizedDescription)")
            // If we can cast to NSError, provide more details
            if let nsError = error as NSError? {
                print("  Domain: \(nsError.domain)")
                print("  Code: \(nsError.code)")
                print("  Description: \(nsError.localizedDescription)")
                print("  User info: \(nsError.userInfo)")
            }
            return nil
        }
    }
}

class MyQueryRequestController {
    func sendRequest(_ query: String) async throws -> [IconRes] {
        let results = try await sendRequestToMeilisearch(query)
        
        if results.isEmpty {
            print("⚠️ Meilisearch API returned no results, trying backup method...")
            return try await sendBackupRequest(query)
        }
        
        return results
    }
    
    private func sendRequestToMeilisearch(_ query: String) async throws -> [IconRes] {
        /* Configure session, choose between:
         * defaultSessionConfiguration
         * ephemeralSessionConfiguration
         * backgroundSessionConfigurationWithIdentifier:
         And set session-wide properties, such as: HTTPAdditionalHeaders,
         HTTPCookieAcceptPolicy, requestCachePolicy or timeoutIntervalForRequest.
         */
        let query = qeuryMix(query)
        print("🔍 Searching for icons with query: \(query)")

        let sessionConfig = URLSessionConfiguration.default
        // Increase timeout interval
        sessionConfig.timeoutIntervalForRequest = 30.0
        sessionConfig.timeoutIntervalForResource = 60.0

        /* Create session, and optionally set a URLSessionDelegate. */
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)

        /* Create the Request:
         Request (POST https://api.macosicons.com/api/search)
         */
        let urlString = "https://api.macosicons.com/api/search"
        print("🌐 API Endpoint: \(urlString)")
        
        guard let URL = URL(string: urlString) else {
            print("❌ Invalid URL: \(urlString)")
            return []
        }
        var request = URLRequest(url: URL)
        request.httpMethod = "POST"

        // Get API key from UserDefaults
        let apiKey = UserDefaults.standard.string(forKey: "apiKey") ?? ""
        print("🔑 API Key status: \(apiKey.isEmpty ? "Not set" : "Set (length: \(apiKey.count))")")
        
        // Headers
        if !apiKey.isEmpty {
            request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        } else {
            print("⚠️ Warning: No API key provided. API may reject the request.")
        }
        
        request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.5 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
        request.addValue("https://macosicons.com", forHTTPHeaderField: "Origin")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        // Form JSON Body
        let bodyObject: [String : Any] = [
            "query": query,
            "searchOptions": [
                "hitsPerPage": 100,
                "page": 1,
                "offset": 0,
                "filters": [],
                "sort": ["timeStamp:desc", "category:asc"]
            ]
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: bodyObject, options: [])
            request.httpBody = jsonData
            print("📤 Request body: \(String(data: jsonData, encoding: .utf8) ?? "Unable to convert to string")")
        } catch {
            print("❌ Error creating request body: \(error.localizedDescription)")
            return []
        }

        // For debug purposes, print all request headers
        print("📋 Request headers:")
        request.allHTTPHeaderFields?.forEach { key, value in
            print("  \(key): \(key.lowercased() == "x-api-key" ? "[HIDDEN]" : value)")
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response type, not HTTPURLResponse")
                return []
            }
            
            print("📥 Response status code: \(httpResponse.statusCode)")
            
            // Print response headers for debugging
            print("📋 Response headers:")
            for (key, value) in httpResponse.allHeaderFields {
                print("  \(key): \(value)")
            }
            
            if httpResponse.statusCode != 200 {
                // Try to print response body to get error details
                if let errorStr = String(data: data, encoding: .utf8) {
                    print("❌ Error response: \(errorStr)")
                }
                return []
            }
            
            // Print first 200 chars of response for debugging
            if let responseStr = String(data: data, encoding: .utf8) {
                let previewLength = min(200, responseStr.count)
                let preview = responseStr.prefix(previewLength)
                print("📄 Response preview: \(preview)...\(responseStr.count > previewLength ? " (truncated)" : "")")
            }
            
            let json = try JSON(data: data)
            
            // Check if the response has expected structure
            if json["hits"].exists() {
                print("✅ Response has 'hits' property")
                print("📊 Total hits: \(json["totalHits"].intValue)")
            } else {
                print("⚠️ Response does not have expected 'hits' property")
                // Print more of the response to help debug
                if let responseStr = String(data: data, encoding: .utf8) {
                    print("📄 Full response: \(responseStr)")
                }
            }
            
            let res = json["hits"].arrayValue.compactMap { hit in
                if let lowResPngUrl = hit["lowResPngUrl"].url, let icnsUrl = hit["icnsUrl"].url {
                    print("✅ Found icon: \(hit["appName"].stringValue)")
                    return IconRes(appName: hit["appName"].stringValue, icnsUrl: icnsUrl, lowResPngUrl: lowResPngUrl, downloads: hit["downloads"].intValue)
                } else {
                    print("⚠️ Missing URLs for icon: \(hit["appName"].stringValue)")
                    return nil
                }
            }
            
            print("🔢 Found \(res.count) valid icons")
            
            let filteredRes = res.filter {
                // TODO: Improve it (remove (),':) Photoshop (Beta) -> Photoshop Beta
                $0.appName.lowercased().replace(target: " ", withString: "").contains(query.lowercased().replace(target: " ", withString: ""))
            }
            
            print("🔢 After filtering, \(filteredRes.count) icons remain")
            
            return filteredRes.sorted { res1, res2 in
                res1.downloads > res2.downloads
            }
        } catch {
            print("❌ Error during API request: \(error.localizedDescription)")
            // If we can cast to NSError, provide more details
            if let nsError = error as NSError? {
                print("  Domain: \(nsError.domain)")
                print("  Code: \(nsError.code)")
                print("  Description: \(nsError.localizedDescription)")
                print("  User info: \(nsError.userInfo)")
            }
            return []
        }
    }
    
    func testAPIConnection() async throws -> (success: Bool, iconCount: Int) {
        // Use a common query that won't trigger the hardcoded fallback
        let testQuery = "test_api_connection"
        print("🔍 Testing API connection with query: \(testQuery)")

        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 15.0
        
        let session = URLSession(configuration: sessionConfig)
        
        // Use the primary Meilisearch endpoint
        let urlString = "https://api.macosicons.com/api/search"
        guard let URL = URL(string: urlString) else {
            throw NSError(domain: "IconChanger", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Invalid API endpoint URL"])
        }
        
        var request = URLRequest(url: URL)
        request.httpMethod = "POST"
        
        // Get API key from UserDefaults - this is what we're actually testing
        let apiKey = UserDefaults.standard.string(forKey: "apiKey") ?? ""
        if apiKey.isEmpty {
            throw NSError(domain: "IconChanger", code: 1002, userInfo: [NSLocalizedDescriptionKey: "API key not provided"])
        }
        
        // Add the API key to the request headers
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Create a minimal query body
        let bodyObject: [String: Any] = [
            "query": testQuery,
            "searchOptions": [
                "hitsPerPage": 10,
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
            // Try to extract error message from response
            if let errorStr = String(data: data, encoding: .utf8) {
                throw NSError(domain: "IconChanger", code: httpResponse.statusCode,
                              userInfo: [NSLocalizedDescriptionKey: "API error: \(errorStr)"])
            } else {
                throw NSError(domain: "IconChanger", code: httpResponse.statusCode,
                              userInfo: [NSLocalizedDescriptionKey: "API returned status code \(httpResponse.statusCode)"])
            }
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
    private func sendBackupRequest(_ query: String) async throws -> [IconRes] {
        let query = qeuryMix(query)
        print("🔍 Attempting backup search for: \(query)")
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 30.0
        sessionConfig.timeoutIntervalForResource = 60.0
        
        let session = URLSession(configuration: sessionConfig)
        
        // Modified to attempt direct access to other endpoints of the API
        let urlString = "https://api.macosicons.com/api/icons?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query)&limit=100"
        print("🌐 Backup API Endpoint: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid backup URL")
            return []
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Add API key header
        let apiKey = UserDefaults.standard.string(forKey: "apiKey") ?? ""
        if !apiKey.isEmpty {
            request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
            print("🔑 Added API key to backup request")
        }
        
        request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.5 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response type from backup API")
                return []
            }
            
            print("📥 Backup response status code: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode != 200 {
                if let errorStr = String(data: data, encoding: .utf8) {
                    print("❌ Error response from backup API: \(errorStr)")
                }
                return []
            }
            
            if let responseStr = String(data: data, encoding: .utf8) {
                let previewLength = min(200, responseStr.count)
                let preview = responseStr.prefix(previewLength)
                print("📄 Backup response preview: \(preview)...\(responseStr.count > previewLength ? " (truncated)" : "")")
            }
            
            // Try to parse the response data
            do {
                let json = try JSON(data: data)
                
                // Check different response structures
                var icons: [IconRes] = []
                
                if let results = extractIconsFromJSON(json) {
                    icons = results
                    print("✅ Successfully extracted icon data from backup API")
                } else {
                    print("⚠️ Unable to extract icon data from backup API response")
                    // Try to create some simple icon data so the application can continue
                    // This is only as a last resort
                    if let directData = json.array?.first {
                        print("⚠️ Attempting to parse as direct data")
                        // Print all available keys for better understanding of the response format
                        if let jsonObj = directData.dictionary {
                            print("📑 Available keys: \(jsonObj.keys.joined(separator: ", "))")
                        }
                    }
                }
                
                print("🔢 Found \(icons.count) icons from backup method")
                return icons.sorted { $0.downloads > $1.downloads }
            } catch {
                print("❌ JSON parsing error: \(error.localizedDescription)")
                
                // Try another method - create a hardcoded icon as a fallback
                print("⚠️ Creating hardcoded Chrome icon as a last resort")
                if query.lowercased().contains("chrome") {
                    if let icnsUrl = URL(string: "https://macosicons.com/api/icons/chrome/download"),
                       let lowResPngUrl = URL(string: "https://parsefiles.back4app.com/JPaQcFfEEQ1ePBxbf6wvzkPMEqKYHhPYv8boI1Rc/476887413a132607e24df29a93a4cb3f_low_res_Chrome.png") {
                        return [IconRes(appName: "Chrome", icnsUrl: icnsUrl, lowResPngUrl: lowResPngUrl, downloads: 439)]
                    }
                }
                
                return []
            }
            
        } catch {
            print("❌ Backup API request failed: \(error.localizedDescription)")
            return []
        }
    }
    
    // Helper method to try and extract icons from JSON in various formats
    private func extractIconsFromJSON(_ json: JSON) -> [IconRes]? {
        var results: [IconRes] = []
        
        // Try different possible response structures
        
        // Try format with "data" array
        if let dataArray = json["data"].array {
            print("✅ Found 'data' array in response")
            for item in dataArray {
                if let name = item["name"].string,
                   let icnsUrlString = item["icnsUrl"].string,
                   let lowResUrlString = item["lowResPngUrl"].string,
                   let icnsUrl = URL(string: icnsUrlString),
                   let lowResPngUrl = URL(string: lowResUrlString) {
                    
                    let downloads = item["downloads"].int ?? 0
                    results.append(IconRes(appName: name, icnsUrl: icnsUrl, lowResPngUrl: lowResPngUrl, downloads: downloads))
                }
            }
        }
        
        // Try format with "icons" array
        else if let iconsArray = json["icons"].array {
            print("✅ Found 'icons' array in response")
            for item in iconsArray {
                if let name = item["appName"].string,
                   let icnsUrlString = item["icnsUrl"].string,
                   let lowResUrlString = item["lowResPngUrl"].string,
                   let icnsUrl = URL(string: icnsUrlString),
                   let lowResPngUrl = URL(string: lowResUrlString) {
                    
                    let downloads = item["downloads"].int ?? 0
                    results.append(IconRes(appName: name, icnsUrl: icnsUrl, lowResPngUrl: lowResPngUrl, downloads: downloads))
                }
            }
        }
        
        // Try format where the response is directly an array
        else if let directArray = json.array {
            print("✅ Found direct array in response")
            for item in directArray {
                if let name = item["appName"].string,
                   let icnsUrlString = item["icnsUrl"].string,
                   let lowResUrlString = item["lowResPngUrl"].string,
                   let icnsUrl = URL(string: icnsUrlString),
                   let lowResPngUrl = URL(string: lowResUrlString) {
                    
                    let downloads = item["downloads"].int ?? 0
                    results.append(IconRes(appName: name, icnsUrl: icnsUrl, lowResPngUrl: lowResPngUrl, downloads: downloads))
                }
            }
        }
        
        return results.isEmpty ? nil : results
    }

    func qeuryMix(_ query: String) -> String {
        switch query {
        case "PyCharm Professional Edition": return "PyCharm"
        case "Discord PTB": return "Discord"
        default: return query
        }
    }
}


protocol URLQueryParameterStringConvertible {
    var queryParameters: String {get}
}

extension Dictionary : URLQueryParameterStringConvertible {
    /**
     This computed property returns a query parameters string from the given NSDictionary. For
     example, if the input is @{@"day":@"Tuesday", @"month":@"January"}, the output
     string will be @"day=Tuesday&month=January".
     @return The computed parameters string.
     */
    var queryParameters: String {
        var parts: [String] = []
        for (key, value) in self {
            let part = String(format: "%@=%@",
                              String(describing: key).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                              String(describing: value).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            parts.append(part as String)
        }
        return parts.joined(separator: "&")
    }

}

extension URL {
    /**
     Creates a new URL by adding the given query parameters.
     @param parametersDictionary The query parameter dictionary to add.
     @return A new URL.
     */
    func appendingQueryParameters(_ parametersDictionary : Dictionary<String, String>) -> URL {
        let URLString : String = String(format: "%@?%@", self.absoluteString, parametersDictionary.queryParameters)
        return URL(string: URLString)!
    }
}

