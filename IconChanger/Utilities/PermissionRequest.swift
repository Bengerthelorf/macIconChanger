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
        let diagnosticsContext = DiagnosticsContext(
            operation: .permission,
            source: .startup
        )
        let timer = DiagnosticsTimer()
        let storedBookmarkCount = bookmarks.count
        DiagnosticsLogger.shared.log(
            .operation,
            phase: "folder_bookmarks_restore.start",
            context: diagnosticsContext,
            details: ["stored_count": String(storedBookmarkCount)]
        )
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
                        DiagnosticsLogger.shared.log(
                            .step,
                            phase: "folder_bookmark.refreshed_stale",
                            context: DiagnosticsContext(
                                operation: .permission,
                                operationID: diagnosticsContext.operationID,
                                source: .startup,
                                appName: url.lastPathComponent,
                                appPath: url.path
                            )
                        )
                    } else {
                        DiagnosticsLogger.shared.log(
                            .failure,
                            phase: "folder_bookmark.security_scope_denied",
                            context: DiagnosticsContext(
                                operation: .permission,
                                operationID: diagnosticsContext.operationID,
                                source: .startup,
                                appName: url.lastPathComponent,
                                appPath: url.path
                            )
                        )
                    }
                } else {
                    if url.startAccessingSecurityScopedResource() {
                        validBookmarks[urlString] = data
                        validPermissions.append(PermissionList(bookmarkedURL: url, originalURLString: urlString))
                    } else {
                        DiagnosticsLogger.shared.log(
                            .failure,
                            phase: "folder_bookmark.security_scope_denied",
                            context: DiagnosticsContext(
                                operation: .permission,
                                operationID: diagnosticsContext.operationID,
                                source: .startup,
                                appName: url.lastPathComponent,
                                appPath: url.path
                            )
                        )
                    }
                }
            } catch {
                logger.error("Error restoring bookmark for \(urlString): \(error.localizedDescription)")
                DiagnosticsLogger.shared.log(
                    .failure,
                    phase: "folder_bookmark.restore_failed",
                    context: diagnosticsContext,
                    details: DiagnosticsLogger.errorDetails(error)
                )
            }
        }
        
        self.bookmarks = validBookmarks
        self.permissions = validPermissions
        DiagnosticsLogger.shared.log(
            .operation,
            phase: "folder_bookmarks_restore.completed",
            context: diagnosticsContext,
            durationMilliseconds: timer.elapsedMilliseconds,
            details: [
                "valid_count": String(validPermissions.count),
                "discarded_count": String(max(0, storedBookmarkCount - validPermissions.count)),
            ]
        )
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
            } else {
                DiagnosticsLogger.shared.log(
                    .skipped,
                    phase: "folder_permission_picker.cancelled",
                    context: DiagnosticsContext(operation: .permission)
                )
            }
        }
    }

    func addBookmark(_ url: URL) {
        let urlString = url.absoluteString
        
        // Check if already exists
        if permissions.contains(where: { $0.originalURLString == urlString }) {
            DiagnosticsLogger.shared.log(
                .skipped,
                phase: "folder_bookmark.already_exists",
                context: DiagnosticsContext(
                    operation: .permission,
                    appName: url.lastPathComponent,
                    appPath: url.path
                )
            )
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
            DiagnosticsLogger.shared.log(
                .operation,
                phase: "folder_bookmark.added",
                context: DiagnosticsContext(
                    operation: .permission,
                    appName: url.lastPathComponent,
                    appPath: url.path
                )
            )
        } catch {
            logger.error("Error creating bookmark for \(urlString): \(error.localizedDescription)")
            DiagnosticsLogger.shared.log(
                .failure,
                phase: "folder_bookmark.add_failed",
                context: DiagnosticsContext(
                    operation: .permission,
                    appName: url.lastPathComponent,
                    appPath: url.path
                ),
                details: DiagnosticsLogger.errorDetails(error)
            )
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
        DiagnosticsLogger.shared.log(
            .operation,
            phase: "folder_bookmark.removed",
            context: DiagnosticsContext(
                operation: .permission,
                appName: permission.bookmarkedURL.lastPathComponent,
                appPath: permission.path
            )
        )
    }

    func createBookmark(from url: URL) throws -> Data {
        let bookmarkData = try url.bookmarkData(options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil)
        return bookmarkData
    }
}
