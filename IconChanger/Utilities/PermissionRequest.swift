//
//  PermissionRequest.swift
//  IconChanger
//

import SwiftUI
import Combine
import os

struct PermissionList: Identifiable {
    let bookmarkedURL: URL
    let originalURLString: String
    var path: String {
        if let url = URL(string: originalURLString) {
            return url.path
        }
        return bookmarkedURL.path
    }
    var displayPath: String {
        return URL(fileURLWithPath: path).displayPath()
    }
    let id = UUID()
}

class FolderPermission: ObservableObject {
    static let shared = FolderPermission()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "IconChanger", category: "FolderPermission")

    @Published var permissions: [PermissionList] = []

    // Key: URL absolute string, Value: Bookmark Data
    private var bookmarks: [String: Data] {
        get {
            UserDefaults.standard.dictionary(forKey: "folderBookmarks") as? [String: Data] ?? [:]
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "folderBookmarks")
        }
    }

    var hasPermission: Bool {
        !permissions.isEmpty
    }

    init() {
        restoreBookmarks()
    }

    private func restoreBookmarks() {
        var validPermissions: [PermissionList] = []
        var validBookmarks: [String: Data] = [:]
        
        for (urlString, data) in bookmarks {
            do {
                var isStale = false
                let url = try URL(resolvingBookmarkData: data,
                                  options: .withSecurityScope,
                                  relativeTo: nil,
                                  bookmarkDataIsStale: &isStale)
                
                if isStale {
                    // Bookmark is stale, try to recreate it
                    if url.startAccessingSecurityScopedResource() {
                        let newData = try createBookmark(from: url)
                        validBookmarks[urlString] = newData
                        validPermissions.append(PermissionList(bookmarkedURL: url, originalURLString: urlString))
                    }
                } else {
                    if url.startAccessingSecurityScopedResource() {
                        validBookmarks[urlString] = data
                        validPermissions.append(PermissionList(bookmarkedURL: url, originalURLString: urlString))
                    }
                }
            } catch {
                logger.error("Error restoring bookmark for \(urlString): \(error.localizedDescription)")
            }
        }
        
        self.bookmarks = validBookmarks
        self.permissions = validPermissions
    }

    func add() {
        let openPanel = NSOpenPanel()
        openPanel.directoryURL = URL(fileURLWithPath: "/Applications")
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = false
        openPanel.allowsMultipleSelection = false
        openPanel.begin { (result) in
            if result == .OK, let url = openPanel.url {
                self.addBookmark(url)
            }
        }
    }

    func addBookmark(_ url: URL) {
        let urlString = url.absoluteString
        
        // Check if already exists
        if permissions.contains(where: { $0.originalURLString == urlString }) {
            return
        }
        
        do {
            let data = try createBookmark(from: url)
            var currentBookmarks = bookmarks
            currentBookmarks[urlString] = data
            bookmarks = currentBookmarks
            
            permissions.append(PermissionList(bookmarkedURL: url, originalURLString: urlString))
            
            objectWillChange.send()
            IconManager.shared.refresh()
        } catch {
            logger.error("Error creating bookmark for \(urlString): \(error.localizedDescription)")
        }
    }
    
    func removeBookmark(id: UUID) {
        guard let index = permissions.firstIndex(where: { $0.id == id }) else { return }
        let permission = permissions[index]
        
        permissions.remove(at: index)
        
        var currentBookmarks = bookmarks
        currentBookmarks.removeValue(forKey: permission.bookmarkedURL.absoluteString)
        bookmarks = currentBookmarks
        
        permission.bookmarkedURL.stopAccessingSecurityScopedResource()
        IconManager.shared.refresh()
    }

    func createBookmark(from url: URL) throws -> Data {
        let bookmarkData = try url.bookmarkData(options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil)
        return bookmarkData
    }
}
