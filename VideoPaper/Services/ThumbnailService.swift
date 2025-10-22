//
//  ThumbnailService.swift
//  VideoPaper
//
//  Created by Matt Heaney on 22/10/2025.
//

import Foundation
import AVKit

class ThumbnailService {

    static let shared = ThumbnailService()
    private init() {}

    func generateThumbnail(for videoURL: String, at time: CMTime = CMTime(seconds: 0, preferredTimescale: 600)) async throws -> URL? {

        guard let videoURL = URL(string: videoURL) else {
            return nil // throw
        }

        let asset = AVURLAsset(url: videoURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true

        // Generate the thumbnail image
        let (cgImage, _) = try await generator.image(at: time)
        let nsImage = NSImage(cgImage: cgImage, size: .zero)

        // Convert NSImage to PNG data
        guard let tiffData = nsImage.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let pngData = bitmap.representation(using: .png, properties: [:]) else {
            return nil
        }

        // Ensure subdirectory for your app exists
        guard let appDir = getApplicationSupportDirectory() else { return nil }

        // Save thumbnail
        let fileURL = appDir.appendingPathComponent("\(UUID().uuidString).png")
        try pngData.write(to: fileURL)

        return fileURL
    }
}
