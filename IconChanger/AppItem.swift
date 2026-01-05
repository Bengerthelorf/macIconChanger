//
//  AppItem.swift
//  IconChanger
//
//  Created by Antigravity on 2026/01/01.
//

import Foundation
import LaunchPadManagerDBHelper

struct AppItem: Identifiable, Hashable {
    let id: URL
    let name: String
    let url: URL
    let originalAppInfo: LaunchPadManagerDBHelper.AppInfo?
    
    // Conformance to Hashable based on URL
    static func == (lhs: AppItem, rhs: AppItem) -> Bool {
        lhs.url == rhs.url
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
}
