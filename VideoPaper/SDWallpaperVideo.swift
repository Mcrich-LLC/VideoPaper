//
//  SDWallpaperVideo.swift
//  VideoPaper
//
//  Created by Testy McTestface on 9/6/25.
//

import Foundation
import SwiftData

@Model
final class SDWallpaperVideo {
    @Attribute(.externalStorage) var video: Data
    @Attribute(.externalStorage) var thumbnail: Data
    
    init(video: Data, thumbnail: Data) {
        self.video = video
        self.thumbnail = thumbnail
    }
}
