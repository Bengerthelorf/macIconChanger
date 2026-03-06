//
//  AppItem.swift
//  IconChanger
//
//  Created by Antigravity on 2026/01/01.
//

import Foundation
import LaunchPadManagerDBHelper

struct AppItem: Identifiable, Hashable {
    let name: String
    let url: URL
    let originalAppInfo: LaunchPadManagerDBHelper.AppInfo?
    
    var id: String {
        return url.universalPath()
    }
    
    var displayPath: String {
        return url.deletingLastPathComponent().displayPath()
    }
    
    // Conformance to Hashable based on path string
    static func == (lhs: AppItem, rhs: AppItem) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
