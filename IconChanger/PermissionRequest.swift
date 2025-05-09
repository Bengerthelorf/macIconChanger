//
//  PermissionRequest.swift
//  IconChanger
//
//  Created by seril on 7/25/23.
//  Modified by Bengerthelorf on 3/21/25.
//

import SwiftUI
import Combine

struct PermissionList: Identifiable {
    let bookmarkedURL: String
    var path: String {
        return URL(string: bookmarkedURL)?.path ?? ""
    }
    let id = UUID()
}

class FolderPermission: ObservableObject {
    static let shared = FolderPermission()

    @Published var permissions: [PermissionList] = []

    var bookmarkData: Data? {
        didSet {
            UserDefaults.standard.set(bookmarkData, forKey: "bookmarkData")
        }
    }
    var url: URL?

    var hasPermission: Bool {
        hasPermissionForApplicationsFolder()
    }

    init() {
        if let bookmarkData = UserDefaults.standard.data(forKey: "bookmarkData") {
            self.bookmarkData = bookmarkData
            do {
                let url = try accessBookmark(bookmarkData)
                self.url = url
                permissions.append(PermissionList(bookmarkedURL: url.absoluteString))
            } catch {
                print("Error accessing bookmark:", error)
            }
        }
    }

    func check() {
//        print(permissions)
        if !hasPermission {
            add()
        }
    }

    func add() {
        let openPanel = NSOpenPanel()
        openPanel.directoryURL = URL(fileURLWithPath: "/Applications")
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = false
        openPanel.allowsMultipleSelection = false
        openPanel.begin { (result) in
            if result == .OK {
                self.addBookmark(openPanel.url)
            }
        }
    }

    func addBookmark(_ url: URL?) {
        guard let url = url else { return }
        if permissions.contains(where: { $0.bookmarkedURL == url.absoluteString }) {
            // The folder has already been added.
            return
        }
        self.url = url
        do {
            let bookmark = try createBookmark(from: url)
            bookmarkData = bookmark
            permissions.append(PermissionList(bookmarkedURL: url.absoluteString))
        } catch {
            print("Error creating bookmark:", error)
        }
    }

    func hasPermissionForApplicationsFolder() -> Bool {
        let safariAppURL = URL(fileURLWithPath: "/Applications/Safari.app/Contents/Info.plist")
        let fileManager = FileManager.default
        return fileManager.isReadableFile(atPath: safariAppURL.path)
    }

    // Create a security bookmark
    func createBookmark(from url: URL) throws -> Data {
        let bookmarkData = try url.bookmarkData(options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil)
        return bookmarkData
    }

    // Use a security bookmark
    func accessBookmark(_ bookmarkData: Data) throws -> URL {
        var isStale = false
        let bookmarkedURL = try URL(resolvingBookmarkData: bookmarkData,
                options: .withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &isStale)

        if isStale {
            // The bookmark data is outdated and needs to be recreated
            // ...
        }

        if !bookmarkedURL.startAccessingSecurityScopedResource() {
            // No permission to access the resource
            // ...
        }

        return bookmarkedURL
    }

    func removeBookmark() {
        guard !permissions.isEmpty else { return }
        permissions.removeLast()
        if let lastBookmark = permissions.last {
            bookmarkData = lastBookmark.bookmarkedURL.data(using: .utf8)
        } else {
            bookmarkData = nil
        }
    }
}
