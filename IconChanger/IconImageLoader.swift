//
//  IconImageLoader.swift
//  IconChanger
//
//  Created by Snaix on 10/17/25.
//

import Foundation
import AppKit

/// Shared image loader with in-memory caching and request de-duplication.
final class IconImageLoader {
    static let shared = IconImageLoader()

    private let cache = NSCache<NSURL, NSImage>()
    private let session: URLSession
    private var inFlightTasks: [NSURL: Task<NSImage?, Error>] = [:]
    private let lock = NSLock()

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 20
        configuration.timeoutIntervalForResource = 40
        configuration.requestCachePolicy = .returnCacheDataElseLoad

        // Give URLSession its own cache so repeated scrolls hit disk/memory instead of network.
        configuration.urlCache = URLCache(
            memoryCapacity: 50 * 1024 * 1024,
            diskCapacity: 200 * 1024 * 1024,
            diskPath: "IconImageLoaderCache"
        )

        session = URLSession(configuration: configuration)

        cache.countLimit = 256
        cache.totalCostLimit = 60 * 1024 * 1024
    }

    func image(for url: URL) async throws -> NSImage? {
        let nsURL = url as NSURL

        if let cachedImage = cache.object(forKey: nsURL) {
            return cachedImage
        }

        lock.lock()
        if let existingTask = inFlightTasks[nsURL] {
            lock.unlock()
            return try await existingTask.value
        }

        let task = Task<NSImage?, Error> { [weak self] in
            guard let self = self else { return nil }
            if url.isFileURL {
                return self.loadLocalImage(from: url)
            } else {
                return try await self.downloadImage(from: url)
            }
        }

        inFlightTasks[nsURL] = task
        lock.unlock()

        do {
            let image = try await task.value
            finish(taskFor: nsURL, with: image)
            return image
        } catch {
            finish(taskFor: nsURL, with: nil)
            throw error
        }
    }

    private func finish(taskFor url: NSURL, with image: NSImage?) {
        lock.lock()
        inFlightTasks.removeValue(forKey: url)
        lock.unlock()

        if let image {
            cache.setObject(image, forKey: url, cost: imageCacheCost(for: image))
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
        guard let tiffData = image.tiffRepresentation else {
            return image
        }

        guard let representation = NSBitmapImageRep(data: tiffData) else {
            return image
        }

        let detachedImage = NSImage(size: representation.size)
        detachedImage.addRepresentation(representation)
        return detachedImage
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
        cache.countLimit = 512
        cache.totalCostLimit = 40 * 1024 * 1024
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

    private func cacheCost(for image: NSImage) -> Int {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return 1
        }
        return Int(cgImage.width * cgImage.height * 4)
    }
}
