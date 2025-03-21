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
    
    // 图标是否有效（可以正常加载）
    var isValidIcon: Bool = true
    
    // 添加一个唯一标识符
    var id: String {
        return lowResPngUrl.absoluteString
    }
    
    init(appName: String, icnsUrl: URL, lowResPngUrl: URL, downloads: Int) {
        self.appName = appName
        self.icnsUrl = icnsUrl
        self.lowResPngUrl = lowResPngUrl
        self.downloads = downloads
    }
    
    // 由于转为类，需要实现Hashable协议的方法
    static func == (lhs: IconRes, rhs: IconRes) -> Bool {
        return lhs.lowResPngUrl == rhs.lowResPngUrl
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(lowResPngUrl)
    }
}

