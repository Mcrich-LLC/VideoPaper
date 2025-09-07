//
//  Protocols.swift
//  VideoPaper
//
//  Created by Testy McTestface on 9/7/25.
//

import Foundation
import AppKit
import AVFoundation

protocol Asset: Identifiable, Equatable {
    var id: UUID { get }
    var showInTopLevel: Bool { get set }
    var shotID: String { get }
    var localizedNameKey: String { get set }
    var accessibilityLabel: String { get set }
    var previewImage: String { get set }
    var pointsOfInterest: [String : String] { get set }
    var includeInShuffle: Bool { get set }
    var videoURL: String { get set }
    var subcategories: [String] { get }
    var preferredOrder: Int { get set }
    var categories: [String] { get }
    var thumbnailImage: NSImage? { get }
    var videoItem: AVPlayerItem? { get }
}

extension Asset {
    var thumbnailImage: NSImage? {
        guard let previewImageURL = URL(string: previewImage), let data = try? Data(contentsOf: previewImageURL) else {
            return nil
        }
        
        return NSImage(data: data)
    }
    
    var videoItem: AVPlayerItem? {
        guard let videoUrl = URL(string: videoURL) else {
            return nil
        }
        
        let player = AVPlayerItem(url: videoUrl)
        return player
    }
}

protocol Category: Identifiable, Equatable {
    var id: UUID { get }
    var localizedNameKey: String { get set }
    var previewImage: String { get set }
    var localizedDescriptionKey: String { get set }
    var preferredOrder: Int { get set }
    var subcategories: [Self]? { get set }
    var representativeAssetID: String { get set }
}
