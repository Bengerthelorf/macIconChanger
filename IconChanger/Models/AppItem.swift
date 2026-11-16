//
//  AppItem.swift
//  IconChanger
//

import Foundation
import LaunchPadManagerDBHelper

struct AppItem: Identifiable, Hashable {
    let name: String
    let url: URL
    let originalAppInfo: LaunchPadManagerDBHelper.AppInfo?
    let id: String
    let comparisonPath: String
    let searchNames: [String]

    init(
        name: String,
        url: URL,
        originalAppInfo: LaunchPadManagerDBHelper.AppInfo?,
        discovery: AppDiscoveryPolicy.Application? = nil
    ) {
        self.name = name
        self.url = url
        self.originalAppInfo = originalAppInfo
        self.id = url.universalPath()
        self.comparisonPath = discovery?.comparisonPath ?? id
        self.searchNames = [name] + (discovery?.names ?? [url.lastPathComponent])
    }
    
    var displayPath: String {
        return url.deletingLastPathComponent().displayPath()
    }
    
    static func == (lhs: AppItem, rhs: AppItem) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
