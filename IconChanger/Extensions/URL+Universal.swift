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
        // URL.path is already decoded. Decoding it again changes literal %xx
        // names and can redirect an icon write to a different sibling.
        return self.path
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
