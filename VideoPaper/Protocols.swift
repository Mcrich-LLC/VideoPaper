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
    var `previewImage-900x580`: String { get set }
    var pointsOfInterest: [String : String] { get set }
    var includeInShuffle: Bool { get set }
    var `url-4K-SDR-240FPS`: String { get set }
    var subcategories: [String] { get }
    var preferredOrder: Int { get set }
    var categories: [String] { get }
    var thumbnailImage: NSImage? { get }
    var videoItem: AVPlayerItem? { get }
}

protocol Category: Identifiable, Equatable {
    var id: UUID { get }
    var localizedNameKey: String { get set }
    var previewImage: String { get set }
    var localizedDescriptionKey: String { get set }
    var preferredOrder: Int { get set }
    var subcategories: [JsonCategory]? { get set }
    var representativeAssetID: String { get set }
}
