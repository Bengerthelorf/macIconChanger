//
//  FolderManager.swift
//  IconChanger
//

import Foundation
import AppKit

@MainActor class FolderManager: ObservableObject {
    static let shared = FolderManager()

    private let storageKey = "com.iconchanger.userFolders"
    private let bookmarkKey = "com.iconchanger.folderBookmarks"
    @Published var folders: [AppItem] = []

    init() {
        loadFolders()
    }

    private func loadFolders() {
        guard let bookmarks = UserDefaults.standard.dictionary(forKey: bookmarkKey) as? [String: Data] else { return }

        var resolved: [AppItem] = []
        var validBookmarks: [String: Data] = [:]

        for (path, bookmarkData) in bookmarks {
            var isStale = false
            guard let url = try? URL(resolvingBookmarkData: bookmarkData,
                                     options: .withSecurityScope,
                                     relativeTo: nil,
                                     bookmarkDataIsStale: &isStale) else { continue }

            guard url.startAccessingSecurityScopedResource() else { continue }

            let name = url.lastPathComponent
            let item = AppItem(name: name, url: url, originalAppInfo: nil)
            resolved.append(item)

            if isStale {
                if let newBookmark = try? url.bookmarkData(options: .withSecurityScope,
                                                           includingResourceValuesForKeys: nil,
                                                           relativeTo: nil) {
                    validBookmarks[path] = newBookmark
                }
            } else {
                validBookmarks[path] = bookmarkData
            }
        }

        folders = resolved.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }

        UserDefaults.standard.set(validBookmarks, forKey: bookmarkKey)
    }

    func addFolder(url: URL) -> Bool {
        let path = url.universalPath()

        let alreadyExists = folders.contains { $0.id == path }

        if alreadyExists { return false }

        guard let bookmarkData = try? url.bookmarkData(options: .withSecurityScope,
                                                        includingResourceValuesForKeys: nil,
                                                        relativeTo: nil) else { return false }

        var bookmarks = (UserDefaults.standard.dictionary(forKey: bookmarkKey) as? [String: Data]) ?? [:]
        bookmarks[path] = bookmarkData
        UserDefaults.standard.set(bookmarks, forKey: bookmarkKey)

        let name = url.lastPathComponent
        let item = AppItem(name: name, url: url, originalAppInfo: nil)

        folders.append(item)
        folders.sort { $0.name.localizedStandardCompare($1.name) == .orderedAscending }

        return true
    }

    func removeFolder(at path: String) {
        if let item = folders.first(where: { $0.id == path }) {
            item.url.stopAccessingSecurityScopedResource()
        }
        folders.removeAll { $0.id == path }

        var bookmarks = (UserDefaults.standard.dictionary(forKey: bookmarkKey) as? [String: Data]) ?? [:]
        bookmarks.removeValue(forKey: path)
        UserDefaults.standard.set(bookmarks, forKey: bookmarkKey)
    }

    func addFolderViaPanel() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = true
        panel.message = NSLocalizedString("Select folders to customize their icons", comment: "Folder picker message")
        panel.begin { [weak self] response in
            guard response == .OK else { return }
            for url in panel.urls {
                _ = self?.addFolder(url: url)
            }
        }
    }
}
