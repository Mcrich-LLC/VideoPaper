//
//  JsonWallpaperCoordinator.swift
//  VideoPaper
//
//  Created by Testy McTestface on 9/6/25.
//

import Foundation
import Playgrounds
import AppKit

@Observable
final class JsonWallpaperCoordinator {
    private var jsonObject: JsonObject?
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
            for category in newValue {
                guard let index = categories.firstIndex(where: { $0.id == category.id }) else { continue }
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
            for asset in newValue {
                guard let index = assets.firstIndex(where: { $0.id == asset.id }) else { continue }
                assets[index] = asset
            }
        }
    }
    
    nonisolated private let wallpaperFolderURL: URL = {
        let homeURL = FileManager.default.homeDirectoryForCurrentUser
        let userLibraryURL = homeURL.appending(path: "Library")
        let jsonURL = userLibraryURL.appending(path: "Application Support/com.apple.wallpaper/aerials/manifest")
        return jsonURL
    }()
    
    @ObservationIgnored
    nonisolated var jsonURL: URL {
        wallpaperFolderURL.appending(path: "entries.json")
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
    }
}

private struct JsonObject: Codable {
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

struct JsonAsset: Codable, Identifiable {
    let id: UUID
    let showInTopLevel: Bool
    let shotID: String
    let localizedNameKey: String
    let accessibilityLabel: String
    let previewImage: String
    let `previewImage-900x580`: String
    let pointsOfInterest: [String : String]
    let includeInShuffle: Bool
    let `url-4K-SDR-240FPS`: URL
    let subcategories: [String]
    let preferredOrder: Int
    let categories: [String]
    
    var thumbnailImage: NSImage? {
        guard let previewImageURL = URL(string: previewImage), let data = try? Data(contentsOf: previewImageURL) else {
            return nil
        }
        
        return NSImage(data: data)
    }
}
