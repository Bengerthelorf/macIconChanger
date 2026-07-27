//
//  IconRes.swift
//  IconChanger
//

import Foundation

enum RemoteImagePolicy {
    static let maxResponseBytes = 20 * 1024 * 1024

    static func acceptsRemoteURL(_ url: URL) -> Bool {
        url.scheme?.lowercased() == "https" &&
            url.user == nil &&
            url.password == nil
    }

    static func acceptsContentLength(_ length: Int64) -> Bool {
        length < 0 || length <= Int64(maxResponseBytes)
    }
}

class IconRes: Identifiable, Hashable {
    let appName: String
    let icnsUrl: URL
    let lowResPngUrl: URL
    let downloads: Int
    
    var isValidIcon: Bool = true

    var id: String {
        return lowResPngUrl.absoluteString
    }
    
    init?(appName: String, icnsUrl: URL, lowResPngUrl: URL, downloads: Int) {
        guard !appName.isEmpty else {
            return nil
        }

        guard RemoteImagePolicy.acceptsRemoteURL(icnsUrl) else {
            return nil
        }

        guard RemoteImagePolicy.acceptsRemoteURL(lowResPngUrl) else {
            return nil
        }

        guard downloads >= 0 else {
            return nil
        }

        self.appName = appName
        self.icnsUrl = icnsUrl
        self.lowResPngUrl = lowResPngUrl
        self.downloads = downloads
    }
    
    static func == (lhs: IconRes, rhs: IconRes) -> Bool {
        return lhs.lowResPngUrl == rhs.lowResPngUrl
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(lowResPngUrl)
    }
}
