//
//  WallpaperDetailView.swift
//  VideoPaper
//
//  Created by Testy McTestface on 9/6/25.
//

import SwiftUI

struct WallpaperDetailView<A: Asset>: View {
    @Binding var boundItem: A
    
    var body: some View {
        Text(boundItem.localizedNameKey)
    }
}
