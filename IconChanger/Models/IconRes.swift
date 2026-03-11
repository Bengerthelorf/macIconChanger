//
//  IconRes.swift
//  IconChanger
//

import Foundation

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

        guard icnsUrl.scheme == "https" || icnsUrl.scheme == "http" else {
            return nil
        }

        guard lowResPngUrl.scheme == "https" || lowResPngUrl.scheme == "http" else {
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

