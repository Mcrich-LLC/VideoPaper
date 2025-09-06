//
//  WallpaperDetailView.swift
//  VideoPaper
//
//  Created by Testy McTestface on 9/6/25.
//

import SwiftUI
import AVKit

struct WallpaperDetailView<A: Asset>: View {
    @Binding var boundItem: A
    
    var body: some View {
        VStack {
            if let videoItem = boundItem.videoItem {
                AVPlayerControllerRepresented(player: videoItem)
                    .aspectRatio(1, contentMode: .fit)
                    .disabled(true)
                    .clipShape(RoundedRectangle(cornerRadius: 26))
            }
             
            GroupBox {
                VStack(alignment: .leading) {
                    Text(boundItem.localizedNameKey)
                }
                .frame(maxWidth: .infinity)
            }
            Spacer()
        }
        .padding(.horizontal)
    }
}

private struct AVPlayerControllerRepresented : NSViewRepresentable {
    var player : AVPlayer
    
    func makeNSView(context: Context) -> AVPlayerView {
        let view = AVPlayerView()
        view.controlsStyle = .none
        view.videoGravity = .resizeAspectFill
        view.player = player
        return view
    }
    
    func updateNSView(_ nsView: AVPlayerView, context: Context) {
        
    }
}
