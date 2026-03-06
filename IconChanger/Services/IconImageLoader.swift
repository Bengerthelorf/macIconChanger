//
//  IconImageLoader.swift
//  IconChanger
//
//  Created by Snaix on 10/17/25.
//

import Foundation
@preconcurrency import AppKit

/// Wrapper to safely pass NSImage across concurrency boundaries.
private struct SendableImage: @unchecked Sendable {
    let image: NSImage?
}

/// Shared image loader with in-memory caching and request de-duplication.
actor IconImageLoader {
    static let shared = IconImageLoader()

    private let cache = NSCache<NSURL, NSImage>()
    private let session: URLSession
    private var inFlightTasks: [NSURL: Task<SendableImage, Error>] = [:]

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        configuration.timeoutIntervalForResource = 30
        configuration.requestCachePolicy = .returnCacheDataElseLoad

        // Rely on NSCache for in-memory; use modest URLSession disk cache only.
        configuration.urlCache = URLCache(
            memoryCapacity: 10 * 1024 * 1024,
            diskCapacity: 100 * 1024 * 1024,
            diskPath: "IconImageLoaderCache"
        )

        session = URLSession(configuration: configuration)

        cache.countLimit = 150
        cache.totalCostLimit = 30 * 1024 * 1024
    }

    func image(for url: URL) async throws -> NSImage? {
        let nsURL = url as NSURL

        if let cachedImage = cache.object(forKey: nsURL) {
            return cachedImage
        }

        if let existingTask = inFlightTasks[nsURL] {
            return try await existingTask.value.image
        }

        let task = Task<SendableImage, Error> {
            let img = try await self.fetchImage(for: url)
            return SendableImage(image: img)
        }

        inFlightTasks[nsURL] = task

        do {
            let result = try await task.value
            finish(taskFor: nsURL, with: result.image)
            return result.image
        } catch {
            finish(taskFor: nsURL, with: nil)
            throw error
        }
    }

    private func finish(taskFor url: NSURL, with image: NSImage?) {
        inFlightTasks.removeValue(forKey: url)

        if let image {
            cache.setObject(image, forKey: url, cost: imageCacheCost(for: image))
        }
    }

    private func fetchImage(for url: URL) async throws -> NSImage? {
        if url.isFileURL {
            return loadLocalImage(from: url)
        } else {
            return try await downloadImage(from: url)
        }
    }

    private func downloadImage(from url: URL) async throws -> NSImage? {
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode,
              !data.isEmpty else {
            return nil
        }

        return makeDetachedImage(from: data)
    }

    private func loadLocalImage(from url: URL) -> NSImage? {
        let image = NSImage(byReferencing: url)
        guard image.isValid else { return nil }
        return detach(image: image)
    }

    private func makeDetachedImage(from data: Data) -> NSImage? {
        guard let image = NSImage(data: data) else {
            return nil
        }
        return detach(image: image)
    }

    private func detach(image: NSImage) -> NSImage? {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return image
        }
        let rep = NSBitmapImageRep(cgImage: cgImage)
        rep.size = image.size
        let detached = NSImage(size: rep.size)
        detached.addRepresentation(rep)
        return detached
    }

    /// Drop all in-memory cached images to reduce memory footprint (e.g. when entering background).
    func purgeMemoryCache() {
        cache.removeAllObjects()
    }

    private func imageCacheCost(for image: NSImage) -> Int {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return 1
        }

        let bytesPerPixel = 4
        return Int(cgImage.width * cgImage.height * bytesPerPixel)
    }
}

/// Caches NSWorkspace thumbnails for application bundles to avoid repeated disk lookups.
final class AppIconCache {
    static let shared = AppIconCache()

    private let cache = NSCache<NSURL, NSImage>()

    private init() {
        cache.countLimit = 200
        cache.totalCostLimit = 20 * 1024 * 1024
    }

    func icon(for appURL: URL) -> NSImage {
        let key = appURL as NSURL
        if let cached = cache.object(forKey: key) {
            return cached
        }

        let icon = NSWorkspace.shared.icon(forFile: appURL.path)
        cache.setObject(icon, forKey: key, cost: cacheCost(for: icon))
        return icon
    }

    func remove(for appURL: URL) {
        let key = appURL as NSURL
        cache.removeObject(forKey: key)
    }

    func removeAll() {
        cache.removeAllObjects()
    }

    private func cacheCost(for image: NSImage) -> Int {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return 1
        }
        return Int(cgImage.width * cgImage.height * 4)
    }
}
