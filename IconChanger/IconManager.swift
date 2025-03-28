//
//  IconManager.swift
//  IconChanger
//
//  Created by 朱浩宇 on 2022/4/27.
//  Modified by Bengerthelorf on 2025/3/21.
//

import SwiftUI
import SwiftyJSON
import LaunchPadManagerDBHelper

class IconManager: ObservableObject {
    static let shared = IconManager()

    @Published var icons = [(String, String)]()
    @Published var apps: [LaunchPadManagerDBHelper.AppInfo] = []

    init() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(refresh), name: NSWindow.didBecomeKeyNotification, object: nil)

        do {
            let helper = try LaunchPadManagerDBHelper()

            apps = try helper.getAllAppInfos().sorted(by: { info1, info2 in
                info1.name.compare(info2.name) == .orderedAscending
            })

        } catch {
            print(error)
        }
    }

    @objc func refresh() {
        Task {
            do {
                let helper = try LaunchPadManagerDBHelper()
                let sortedApps = try helper.getAllAppInfos().sorted(by: { info1, info2 in
                    info1.name.compare(info2.name) == .orderedAscending
                })
                
                await MainActor.run {
                    apps = sortedApps
                }
            } catch {
                print(error)
            }
        }
    }

    func installHelperTool() throws {
        guard let fileiconBundlePath = Bundle.main.path(forResource: "fileicon", ofType: nil) else {
            fatalError("Cannot get the sh file path")
        }
        guard let helperBundlePath = Bundle.main.path(forResource: "helper", ofType: "sh") else {
            fatalError("Cannot get the sh file path")
        }
        guard let installHelperBundlePath = Bundle.main.path(forResource: "installHelper", ofType: "sh") else {
            fatalError("Cannot get the sh file path")
        }

        let fileiconPath = URL.documents.universalappending(path: "fileicon")
        let helperPath = URL.documents.universalappending(path: "helper.sh")

        if FileManager.default.fileExists(atPath: fileiconPath.universalPath()) {
            try FileManager.default.removeItem(at: fileiconPath)
        }

        if FileManager.default.fileExists(atPath: helperPath.universalPath()) {
            try FileManager.default.removeItem(at: helperPath)
        }

        try FileManager.default.copyItem(at: URL(universalFilePath: fileiconBundlePath), to: fileiconPath)
        try FileManager.default.copyItem(at: URL(universalFilePath: helperBundlePath), to: helperPath)

        try setContent(URL(universalFilePath: installHelperBundlePath), replacement: ["path": helperPath.universalPath(), "fileicon": fileiconPath.universalPath()]) {
            NSAppleScript(source: "do shell script \"chmod +x '\(installHelperBundlePath)' && sudo '\(installHelperBundlePath)'\" with administrator " + "privileges")!.executeAndReturnError(nil)
        }
    }

    static func saveImage(_ image: NSImage, atUrl url: URL) {
        guard
                let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)
        else {
            return
        } // TODO: handle error
        let newRep = NSBitmapImageRep(cgImage: cgImage)
        newRep.size = image.size // if you want the same size
        guard
                let pngData = newRep.representation(using: .png, properties: [:])
        else {
            return
        } // TODO: handle error
        do {
            try pngData.write(to: url)
        } catch {
            print("error saving: \(error)")
        }
    }

    func setContent(_ path: URL, replacement: [String: String], run: () throws -> () = {
    }) throws {
        var content = try String(contentsOf: path, encoding: .utf8)
        let copy = content

        for (key, value) in replacement {
            content = content.replace(target: "%\(key)", withString: value)
        }

        try content.write(to: path, atomically: true, encoding: .utf8)

        print(content)

        try run()

        try copy.write(to: path, atomically: true, encoding: .utf8)
    }

    func setImage(_ image: NSImage, app: LaunchPadManagerDBHelper.AppInfo) throws {
        // First, cache the icon
        _ = try IconCacheManager.shared.cacheIcon(image: image, for: app.url.universalPath(), appName: app.name)
        
        // Then follow the original process to set the icon
        let imageURL = URL.documents.universalappending(path: "icon.png")
        #if DEBUG
        print(imageURL)
        #endif

        if FileManager.default.fileExists(atPath: imageURL.universalPath()) {
            try FileManager.default.removeItem(at: imageURL)
        }

        Self.saveImage(image, atUrl: imageURL)

        let helperPath = URL.documents.universalappending(path: "helper.sh")
        let fileiconPath = URL.documents.universalappending(path: "fileicon")

        try setContent(helperPath, replacement: ["fileicon": fileiconPath.universalPath(),
                                                "app": app.url.universalPath(),
                                                "image": imageURL.universalPath()]) {
            try runHelperTool()
        }
    }

    // Set an icon without caching it (used during restoration)
    func setIconWithoutCaching(_ image: NSImage, app: LaunchPadManagerDBHelper.AppInfo) async throws {
        let imageURL = URL.documents.universalappending(path: "icon.png")
        
        if FileManager.default.fileExists(atPath: imageURL.universalPath()) {
            try FileManager.default.removeItem(at: imageURL)
        }
        
        Self.saveImage(image, atUrl: imageURL)

        let helperPath = URL.documents.universalappending(path: "helper.sh")
        let fileiconPath = URL.documents.universalappending(path: "fileicon")

        try setContent(helperPath, replacement: ["fileicon": fileiconPath.universalPath(),
                                                "app": app.url.universalPath(),
                                                "image": imageURL.universalPath()]) {
            try runHelperTool()
        }
    }

    // Restore all cached icons
    func restoreAllCachedIcons() async throws {
        let cachedIcons = IconCacheManager.shared.getAllCachedIcons()
        var failedApps: [(String, Error)] = []
        
        for cache in cachedIcons {
            do {
                let appPath = cache.appPath
                let iconURL = IconCacheManager.cacheDirectory.appendingPathComponent(cache.iconFileName)
                
                // Check if the app and icon still exist
                if FileManager.default.fileExists(atPath: appPath) &&
                FileManager.default.fileExists(atPath: iconURL.path) {
                    
                    // Load the icon image
                    if let image = NSImage(contentsOf: iconURL) {
                        if let appInfo = apps.first(where: { $0.url.universalPath() == appPath }) {
                            // Set the icon (without re-caching to avoid duplication)
                            try await setIconWithoutCaching(image, app: appInfo)
                        } else {
                            throw RestoreError.appNotFound(cache.appName)
                        }
                    } else {
                        throw RestoreError.iconFileNotFound(cache.appName)
                    }
                } else if !FileManager.default.fileExists(atPath: appPath) {
                    // App no longer exists, remove from cache
                    IconCacheManager.shared.removeCachedIcon(for: appPath)
                } else if !FileManager.default.fileExists(atPath: iconURL.path) {
                    // Icon file missing, remove from cache
                    IconCacheManager.shared.removeCachedIcon(for: appPath)
                }
            } catch {
                failedApps.append((cache.appName, error))
            }
        }
        
        if !failedApps.isEmpty {
            throw RestoreError.someFailed(failed: failedApps)
        }
    }

    func findSearchedImage(_ search: String) -> [LaunchPadManagerDBHelper.AppInfo] {
        apps.filter {
            $0.name.lowercased().contains(search.lowercased()) || $0.url.deletingPathExtension().lastPathComponent.lowercased().contains(search.lowercased())
        }
    }

    func getIconInPath(_ url: URL) -> [URL] {
        let url = url.appendingPathComponent("Contents").appendingPathComponent("Resources")
        let file = (try? FileManager.default.contentsOfDirectory(atPath: url.path)) ?? [String]()
        return file.filter {
                    $0.contains(".icns")
                }
                .map {
                    url.appendingPathComponent($0).path
                }
                .map {
                    URL(fileURLWithPath: $0)
                }
    }

    func getNameFromURL(_ url: String) -> String {
        let count = "https://media.macosicons.com/parse/files/macOSicons/81c998bdc590f1d6998187d39f6ea1d2".count
        let endCount = url.count - ".icns".count

        return String(url[count..<endCount] ?? "")
    }

    func getIcons(_ app: LaunchPadManagerDBHelper.AppInfo) async throws -> [IconRes] {
        let appName = app.name
        let urlName = app.url.deletingPathExtension().lastPathComponent
        let bundleName = try getAppBundleName(app)
        let aliasName = AliasName.getName(for: app.url.deletingPathExtension().lastPathComponent)

        var res = [IconRes]()

        res.append(contentsOf: try await MyQueryRequestController().sendRequest(appName))
        res.append(contentsOf: try await MyQueryRequestController().sendRequest(urlName))

        if let bundleName {
            res.append(contentsOf: try await MyQueryRequestController().sendRequest(bundleName))
        }

        if let aliasName {
            res.append(contentsOf: try await MyQueryRequestController().sendRequest(aliasName))
        }

        return Set(res).map {
            $0
        }
    }

    func getAppBundleName(_ app: LaunchPadManagerDBHelper.AppInfo) throws -> String? {
        let plistURL = app.url.universalappending(path: "Contents").universalappending(path: "Info.plist")
        let plist = (try? NSDictionary(contentsOf: plistURL, error: ())) as? Dictionary<String, AnyObject>

        return (plist?["CFBundleDisplayName"] as? String) ?? (plist?["CFBundleName"] as? String)
    }

    func runHelperTool() throws {
        let helperToolURL = URL.documents.universalappending(path: "helper.sh")
        try Self.safeShell("sudo \(helperToolURL.universalPath())")
    }

    @discardableResult
    static func safeShell(_ command: String) throws -> String {
        let task = Process()
        let pipe = Pipe()

        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        task.standardInput = nil

        try task.run()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!

        return output
    }
}

extension LaunchPadManagerDBHelper.AppInfo: @retroactive Identifiable {
    public var id: URL {
        url
    }
}

extension String {
    func replace(target: String, withString: String) -> String {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
}
