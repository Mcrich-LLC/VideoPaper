//
//  SwiftData Models.swift
//  VideoPaper
//
//  Created by Testy McTestface on 9/6/25.
//

import Foundation
import SwiftData

@Model
final class SDWallpaperVideo: Asset {
    @Attribute(.externalStorage) var video: Data
    @Attribute(.externalStorage) var thumbnail: Data
    @Attribute(.unique) var id: UUID
    var showInTopLevel: Bool
    var shotID: String
    var localizedNameKey: String
    var accessibilityLabel: String
    var previewImage: String
    var pointsOfInterest: [String : String]
    var includeInShuffle: Bool
    var videoURL: String
    var subcategories: [String]
    var preferredOrder: Int
    var categories: [String]
    
    init(video: Data, thumbnail: Data, id: UUID, showInTopLevel: Bool, shotID: String, localizedNameKey: String, accessibilityLabel: String, previewImage: String, pointsOfInterest: [String : String], includeInShuffle: Bool, videoURL: String, subcategories: [String], preferredOrder: Int, categories: [String]) {
        self.video = video
        self.thumbnail = thumbnail
        self.id = id
        self.showInTopLevel = showInTopLevel
        self.shotID = shotID
        self.localizedNameKey = localizedNameKey
        self.accessibilityLabel = accessibilityLabel
        self.previewImage = previewImage
        self.pointsOfInterest = pointsOfInterest
        self.includeInShuffle = includeInShuffle
        self.videoURL = videoURL
        self.subcategories = subcategories
        self.preferredOrder = preferredOrder
        self.categories = categories
    }
    
    func asJson() -> JsonAsset {
        JsonAsset(id: id, showInTopLevel: showInTopLevel, shotID: shotID, localizedNameKey: localizedNameKey, accessibilityLabel: accessibilityLabel, previewImage: previewImage, `previewImage-900x580`: "", pointsOfInterest: pointsOfInterest, includeInShuffle: includeInShuffle, `url-4K-SDR-240FPS`: videoURL, subcategories: subcategories, preferredOrder: preferredOrder, categories: categories)
    }
}

@Model
final class SDCategory: Category {
    @Attribute(.unique) var id: UUID
    var localizedNameKey: String
    var previewImage: String
    var localizedDescriptionKey: String
    var preferredOrder: Int
    @Relationship(deleteRule: .cascade) var subcategories: [SDCategory]?
    var representativeAssetID: String
    
    init(id: UUID, localizedNameKey: String, previewImage: String, localizedDescriptionKey: String, preferredOrder: Int, subcategories: [SDCategory]?, representativeAssetID: String) {
        self.id = id
        self.localizedNameKey = localizedNameKey
        self.previewImage = previewImage
        self.localizedDescriptionKey = localizedDescriptionKey
        self.preferredOrder = preferredOrder
        self.subcategories = subcategories
        self.representativeAssetID = representativeAssetID
    }
    
    func asJson() -> JsonCategory {
        JsonCategory(id: id, localizedNameKey: localizedNameKey, previewImage: previewImage, localizedDescriptionKey: localizedDescriptionKey, preferredOrder: preferredOrder, representativeAssetID: representativeAssetID)
    }
}
