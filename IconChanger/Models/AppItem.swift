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

    init(name: String, url: URL, originalAppInfo: LaunchPadManagerDBHelper.AppInfo?) {
        self.name = name
        self.url = url
        self.originalAppInfo = originalAppInfo
        self.id = url.universalPath()
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
