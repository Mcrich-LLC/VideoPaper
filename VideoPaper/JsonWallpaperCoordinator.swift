//
//  JsonWallpaperCoordinator.swift
//  VideoPaper
//
//  Created by Testy McTestface on 9/6/25.
//

import Foundation
import Playgrounds
import AppKit
import AVFoundation

@Observable
final class JsonWallpaperCoordinator {
    private(set) var jsonObject: JsonObject?
    var categories: [JsonCategory] {
        get {
            jsonObject?.categories ?? []
        }
        set {
            jsonObject?.categories = newValue
        }
    }
    var filteredCategories: [JsonCategory] {
        get {
            categories.filter({ $0.localizedNameKey.lowercased().contains("custom") })
        }
        set {
            let oldFiltered = categories.filter({ $0.localizedNameKey.lowercased().contains("custom") })
            for oldFilter in oldFiltered where !newValue.contains(where: { $0.id == oldFilter.id }){
                categories.removeAll(where: { $0.id == oldFilter.id })
            }
            
            for category in newValue {
                guard let index = categories.firstIndex(where: { $0.id == category.id }) else {
                    categories.append(category)
                    continue
                }
                categories[index] = category
            }
        }
    }
    
    var assets: [JsonAsset] {
        get {
            jsonObject?.assets ?? []
        }
        set {
            jsonObject?.assets = newValue
        }
    }
    
    var filteredAssets: [JsonAsset] {
        get {
            assets.filter { asset in
                asset.categories.contains { catString in
                    filteredCategories.contains(where: { $0.id.uuidString == catString })
                }
            }
        }
        set {
            let oldFiltered = assets.filter { asset in
                asset.categories.contains { catString in
                    filteredCategories.contains(where: { $0.id.uuidString == catString })
                }
            }
            for oldFilter in oldFiltered where !newValue.contains(where: { $0.id == oldFilter.id }){
                assets.removeAll(where: { $0.id == oldFilter.id })
            }
            
            for asset in newValue {
                guard let index = assets.firstIndex(where: { $0.id == asset.id }) else {
                    assets.append(asset)
                    continue
                }
                assets[index] = asset
            }
        }
    }
    
    nonisolated private let wallpaperFolderURL: URL = {
        let homeURL = FileManager.default.homeDirectoryForCurrentUser
        let userLibraryURL = homeURL.appending(path: "Library")
        let jsonURL = userLibraryURL.appending(path: "Application Support/com.apple.wallpaper/aerials")
        return jsonURL
    }()
    
    @ObservationIgnored
    nonisolated var jsonURL: URL {
        wallpaperFolderURL.appending(path: "manifest/entries.json")
    }
    
    @ObservationIgnored
    nonisolated var wallpaperThumbnailFolderURL: URL {
        wallpaperFolderURL.appending(path: "thumbnails")
    }
    
    @ObservationIgnored
    nonisolated var wallpaperVideosFolderURL: URL {
        wallpaperFolderURL.appending(path: "videos")
    }
    
    func fetchData() throws {
        let data = try Data(contentsOf: jsonURL)
        let object = try JSONDecoder().decode(JsonObject.self, from: data)
        
        self.jsonObject = object
    }
    
    func saveData() throws {
        let saveObject = jsonObject
        
        let data = try JSONEncoder().encode(saveObject)
        try data.write(to: jsonURL)
        
        for asset in filteredAssets {
            guard let previewImageUrl = URL(string: asset.previewImage),
                  let videoUrl = URL(string: asset.`url-4K-SDR-240FPS`)
            else {
                continue
            }
            
            let cachePreviewImageURL = wallpaperThumbnailFolderURL.appending(path: "\(asset.id.uuidString).\(previewImageUrl.pathExtension)")
            let cacheVideoURL = wallpaperVideosFolderURL.appending(path: "\(asset.id.uuidString).\(videoUrl.pathExtension)")
            
            try? FileManager.default.removeItem(at: cachePreviewImageURL)
            try? FileManager.default.removeItem(at: cacheVideoURL)
            
            try FileManager.default.copyItem(at: previewImageUrl, to: cachePreviewImageURL)
            try FileManager.default.copyItem(at: videoUrl, to: cacheVideoURL)
        }
    }
    
    func deleteAsset(_ asset: JsonAsset) throws {
        filteredAssets.removeAll(where: { $0.id == asset.id })
        if let previewImageUrl = URL(string: asset.previewImage) {
            let cachePreviewImageURL = wallpaperThumbnailFolderURL.appending(path: "\(asset.id.uuidString).\(previewImageUrl.pathExtension)")
            try? FileManager.default.removeItem(at: cachePreviewImageURL)
        }
        if let videoUrl = URL(string: asset.`url-4K-SDR-240FPS`) {
            let cacheVideoURL = wallpaperVideosFolderURL.appending(path: "\(asset.id.uuidString).\(videoUrl.pathExtension)")
            try? FileManager.default.removeItem(at: cacheVideoURL)
        }
        try saveData()
    }
    
    func createBlankAsset() throws -> UUID {
        guard let category = filteredCategories.last,
              let subcategories = category.subcategories?.last
        else {
            throw JsonWallpaperError.invalidStructure
        }
        let asset = JsonAsset(id: UUID(), showInTopLevel: true, shotID: UUID().uuidString, localizedNameKey: "Custom Wallpaper", accessibilityLabel: "Custom Wallpaper", previewImage: "", `previewImage-900x580`: "", pointsOfInterest: [:], includeInShuffle: false, `url-4K-SDR-240FPS`: "", subcategories: [subcategories.id.uuidString], preferredOrder: filteredAssets.count+1, categories: [category.id.uuidString])
        filteredAssets.append(asset)
        
        return asset.id
    }
}

enum JsonWallpaperError: Error {
    case invalidStructure
}

struct JsonObject: Codable {
    let version: Int
    let localizationVersion: String
    let initialAssetCount: Int
    var categories: [JsonCategory]
    var assets: [JsonAsset]
}

struct JsonCategory: Codable, Identifiable {
    let id: UUID
    let localizedNameKey: String
    let previewImage: String
    let localizedDescriptionKey: String
    let preferredOrder: Int
    let subcategories: [JsonCategory]?
    let representativeAssetID: String
}

struct JsonAsset: Codable, Asset {
    let id: UUID
    let showInTopLevel: Bool
    let shotID: String
    let localizedNameKey: String
    let accessibilityLabel: String
    var previewImage: String
    var `previewImage-900x580`: String
    let pointsOfInterest: [String : String]
    let includeInShuffle: Bool
    var `url-4K-SDR-240FPS`: String
    let subcategories: [String]
    let preferredOrder: Int
    let categories: [String]

    var thumbnailImage: NSImage? {
        guard let previewImageURL = URL(string: previewImage), let data = try? Data(contentsOf: previewImageURL) else {
            return nil
        }
        
        return NSImage(data: data)
    }
    
    var videoItem: AVPlayerItem? {
        guard let videoUrl = URL(string: `url-4K-SDR-240FPS`) else {
            return nil
        }
        
        let player = AVPlayerItem(url: videoUrl)
        return player
    }
}

protocol Asset: Identifiable, Equatable {
    var id: UUID { get }
    var showInTopLevel: Bool { get }
    var shotID: String { get }
    var localizedNameKey: String { get }
    var accessibilityLabel: String { get }
    var previewImage: String { get set }
    var `previewImage-900x580`: String { get set }
    var pointsOfInterest: [String : String] { get }
    var includeInShuffle: Bool { get }
    var `url-4K-SDR-240FPS`: String { get set }
    var subcategories: [String] { get }
    var preferredOrder: Int { get }
    var categories: [String] { get }
    var thumbnailImage: NSImage? { get }
    var videoItem: AVPlayerItem? { get }
}
