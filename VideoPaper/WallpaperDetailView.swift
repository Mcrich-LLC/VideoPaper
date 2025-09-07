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
    @State private var isShowingThumbnailFileImporter = false
    @State private var errorAlertItem: Error?
    
    @Environment(JsonWallpaperCoordinator.self) var jsonWallpaperCoordinator
    
    var isShowingErrorAlert: Binding<Bool> {
        Binding {
            errorAlertItem != nil
        } set: { newValue in
            if !newValue {
                errorAlertItem = nil
            }
        }

    }
    
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
                    
                    Divider()
                    
                    HStack {
                        if let image = boundItem.thumbnailImage {
                            Image(nsImage: image)
                                .resizable()
                                .aspectRatio(1, contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        Button("Change Image") {
                            isShowingThumbnailFileImporter.toggle()
                        }
                        .fileImporter(isPresented: $isShowingThumbnailFileImporter, allowedContentTypes: [.image, .png, .jpeg, .jpeg]) { result in
                            switch result {
                            case .success(let success):
                                boundItem.previewImage = success.absoluteString
                            case .failure(let failure):
                                print(failure)
                                errorAlertItem = failure
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            Spacer()
        }
        .padding(.horizontal)
        .alert("Uh Oh", isPresented: isShowingErrorAlert, presenting: errorAlertItem) { _ in
            Button("Ok") {}
        } message: { error in
            Text(error.localizedDescription)
        }
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
