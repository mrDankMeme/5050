//
//  RemoteImageCache.swift
//  TrueScan
//

import Foundation
import UIKit

final class RemoteImageCache {

    static let shared = RemoteImageCache()

    private let memory = NSCache<NSURL, UIImage>()
    private let ioQueue = DispatchQueue(label: "remote.image.cache.io", qos: .utility)

    private let folderURL: URL

    private init() {
        memory.countLimit = 400
        memory.totalCostLimit = 80 * 1024 * 1024 // ~80MB

        let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        folderURL = base.appendingPathComponent("remote_image_cache_v1", isDirectory: true)

        if !FileManager.default.fileExists(atPath: folderURL.path) {
            try? FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
        }
    }

    func image(for url: URL) -> UIImage? {
        let key = url as NSURL
        if let img = memory.object(forKey: key) {
            return img
        }

        let file = fileURL(for: url)
        if let data = try? Data(contentsOf: file),
           let img = UIImage(data: data) {
            memory.setObject(img, forKey: key, cost: data.count)
            return img
        }

        return nil
    }

    func store(_ image: UIImage, for url: URL) {
        let key = url as NSURL

        let cost = (image.cgImage?.bytesPerRow ?? 0) * (image.cgImage?.height ?? 0)
        memory.setObject(image, forKey: key, cost: max(cost, 1))

        ioQueue.async { [folderURL] in
            let file = self.fileURL(for: url)
            guard let data = image.pngData() else { return }
            try? data.write(to: file, options: [.atomic])
        }
    }

    private func fileURL(for url: URL) -> URL {
        let name = sha256(url.absoluteString)
        return folderURL.appendingPathComponent(name).appendingPathExtension("png")
    }

    private func sha256(_ string: String) -> String {
        
        
        let data = Data(string.utf8)
        var hash = UInt64(1469598103934665603) 
        for b in data {
            hash ^= UInt64(b)
            hash &*= 1099511628211
        }
        return String(format: "%016llx", hash)
    }
}
