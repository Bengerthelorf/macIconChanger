//
//  IconRes.swift
//  IconChanger
//
//  Created by 朱浩宇 on 2022/12/18.
//  Modified by Bengerthelorf on 2025/3/21.
//

import Foundation

class IconRes: Identifiable, Hashable {
    let appName: String
    let icnsUrl: URL
    let lowResPngUrl: URL
    let downloads: Int
    
    // Whether the icon is valid (can be loaded normally)
    var isValidIcon: Bool = true
    
    // Add a unique identifier
    var id: String {
        return lowResPngUrl.absoluteString
    }
    
    init?(appName: String, icnsUrl: URL, lowResPngUrl: URL, downloads: Int) {
        // Validate that appName is not empty
        guard !appName.isEmpty else {
            print("⚠️ IconRes init failed: appName is empty")
            return nil
        }

        // Validate that URLs have valid schemes
        guard icnsUrl.scheme == "https" || icnsUrl.scheme == "http" else {
            print("⚠️ IconRes init failed: icnsUrl has invalid scheme: \(icnsUrl.scheme ?? "nil")")
            return nil
        }

        guard lowResPngUrl.scheme == "https" || lowResPngUrl.scheme == "http" else {
            print("⚠️ IconRes init failed: lowResPngUrl has invalid scheme: \(lowResPngUrl.scheme ?? "nil")")
            return nil
        }

        // Validate that downloads is non-negative
        guard downloads >= 0 else {
            print("⚠️ IconRes init failed: downloads is negative: \(downloads)")
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

