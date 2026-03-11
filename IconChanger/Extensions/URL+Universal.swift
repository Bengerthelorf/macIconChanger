//
//  URL+Universal.swift
//  IconChanger
//

import Foundation

extension URL {
    func universalappending(path: String) -> Self {
        return self.appendingPathComponent(path)
    }

    func universalPath() -> String {
        return self.path.removingPercentEncoding ?? self.path
    }
    
    func displayPath() -> String {
        let path = universalPath()
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        if path == home {
            return "~"
        }
        if path.hasPrefix(home + "/") {
            return "~" + path.dropFirst(home.count)
        }
        return path
    }

    init(universalFilePath: String) {
        self.init(fileURLWithPath: universalFilePath)
    }
}
