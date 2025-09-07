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
    let onDelete: (() -> Void)?
    @State private var isShowingThumbnailFileImporter = false
    @State private var errorAlertItem: Error?
    
    @Environment(JsonWallpaperCoordinator.self) var jsonWallpaperCoordinator
    @State var isShowingSavedInlineMessage = false
    @State var editableItem: A
    
    init(boundItem: Binding<A>, onDelete: (() -> Void)?) {
        self._boundItem = boundItem
        self.onDelete = onDelete
        self.editableItem = boundItem.wrappedValue
    }
    
    var body: some View {
        VStack {
            WallpaperVideoPlayer(boundItem: $boundItem)
            GroupBox {
                VStack(alignment: .leading) {
                    TextField("Name", text: $editableItem.localizedNameKey)
                        .padding(.leading, 1)
                        .onChange(of: editableItem.localizedNameKey) { _, newValue in
                            editableItem.accessibilityLabel = newValue
                        }
                        .textFieldStyle(.plain)
                    
                    Divider()
                    
                    HStack {
                        if let image = boundItem.thumbnailImage {
                            Image(nsImage: image)
                                .resizable()
                                .aspectRatio(1, contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        Button("\(boundItem.thumbnailImage == nil ? "Set" : "Change") Image") {
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
            
            GroupBox {
                if isShowingSavedInlineMessage {
                    Label("Saved", systemImage: "checkmark")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                        .foregroundStyle(.white)
                        .background(Color.accentColor, in: ConcentricRectangle())
                } else {
                    HStack {
                        if let onDelete {
                            Button(role: .destructive) {
                                onDelete()
                            } label: {
                                Label("Delete", systemImage: "trash")
                                    .frame(maxWidth: .infinity)
                            }
                            .tint(.red)
                        }
                        
                        Button {
                            saveProperties()
                            isShowingSavedInlineMessage = true
                        } label: {
                            Label("Save", systemImage: "checkmark")
                                .frame(maxWidth: .infinity)
                        }
                        .disabled(boundItem.`url-4K-SDR-240FPS`.isEmpty || boundItem.previewImage.isEmpty || boundItem == editableItem)
                        .tint(.accentColor)
                    }
                }
            }
            Spacer()
        }
        .padding(.horizontal)
        .alert(for: $errorAlertItem)
        .onChange(of: boundItem, { oldValue, newValue in
            guard oldValue.id != newValue.id else { return }
            if oldValue.`url-4K-SDR-240FPS`.isEmpty || oldValue.previewImage.isEmpty {
                if let oldValue = oldValue as? JsonAsset {
                    try? jsonWallpaperCoordinator.deleteAsset(oldValue)
                }
            }
        })
        .onDisappear(perform: {
            if boundItem.`url-4K-SDR-240FPS`.isEmpty || boundItem.previewImage.isEmpty {
                if let boundItem = boundItem as? JsonAsset {
                    try? jsonWallpaperCoordinator.deleteAsset(boundItem)
                }
            }
        })
        .onChange(of: isShowingSavedInlineMessage) { _, newValue in
            guard newValue else {
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                isShowingSavedInlineMessage = false
            }
        }
        .onChange(of: boundItem, { _, newValue in
            guard editableItem != newValue else {
                return
            }
            editableItem = newValue
        })
        .animation(.default, value: isShowingSavedInlineMessage)
    }
    
    func saveProperties() {
        boundItem.localizedNameKey = editableItem.localizedNameKey
        boundItem.accessibilityLabel = editableItem.accessibilityLabel
        boundItem.preferredOrder = editableItem.preferredOrder
        boundItem.includeInShuffle = editableItem.includeInShuffle
        boundItem.pointsOfInterest = editableItem.pointsOfInterest
        boundItem.showInTopLevel = editableItem.showInTopLevel
        try? jsonWallpaperCoordinator.saveData()
    }
}

struct WallpaperVideoPlayer<A: Asset>: View {
    @Binding var boundItem: A
    @State private var isHovering = false
    @State private var isShowingVideoImporter = false
    @State private var errorAlertItem: Error?
    
    @State var videoItem: AVPlayerItem?
    @Environment(JsonWallpaperCoordinator.self) var jsonWallpaperCoordinator
    
    var body: some View {
        Group {
            if let videoItem {
                Button {
                    isShowingVideoImporter.toggle()
                } label: {
                    AVPlayerControllerRepresented(playerItem: videoItem)
                        .aspectRatio(1, contentMode: .fit)
                        .disabled(true)
                        .overlay(content: {
                            if isHovering {
                                Color.black.opacity(0.01) // Fix selectable area bug
                            }
                        })
                        .overlay(alignment: .bottom, content: {
                            if isHovering {
                                Text("Edit")
                                    .frame(maxWidth: .infinity)
                                    .foregroundStyle(.white)
                                    .frame(height: 50)
                                    .background(LinearGradient(colors: [.primary, .clear], startPoint: .bottom, endPoint: .top))
                            }
                        })
                        .clipShape(RoundedRectangle(cornerRadius: 26))
                        .onHover { isHovering in
                            self.isHovering = isHovering
                        }
                }
            } else {
                Button {
                    isShowingVideoImporter.toggle()
                } label: {
                    RoundedRectangle(cornerRadius: 26)
                        .aspectRatio(1, contentMode: .fit)
                        .overlay {
                            Text("Upload Video")
                        }
                }
            }
        }
        .fileImporter(isPresented: $isShowingVideoImporter, allowedContentTypes: [.quickTimeMovie]) { result in
            switch result {
            case .success(let success):
                boundItem.`url-4K-SDR-240FPS` = success.absoluteString
                updateVideo()
            case .failure(let failure):
                print(failure)
                errorAlertItem = failure
            }
        }
        .alert(for: $errorAlertItem)
        .buttonStyle(.plain)
        .onChange(of: boundItem.id, initial: true) {
            videoItem = boundItem.videoItem
        }
    }
    
    func updateVideo() {
        let videoItem = boundItem.videoItem
        self.videoItem = videoItem
        Task {
            if let url = try await generateThumbnail() {
                boundItem.previewImage = url.absoluteString
            }
            try jsonWallpaperCoordinator.saveData()
        }
    }

    func generateThumbnail(at time: CMTime = CMTime(seconds: 0, preferredTimescale: 600)) async throws -> URL? {
        guard let videoItem else { return nil }
        let generator = AVAssetImageGenerator(asset: videoItem.asset)
        generator.appliesPreferredTrackTransform = true
        
        let (cgImage, _) = try await generator.image(at: time)
        let nsImage = NSImage(cgImage: cgImage, size: .zero)
        
        // Convert NSImage to PNG data
        guard let tiffData = nsImage.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let pngData = bitmap.representation(using: .png, properties: [:]) else {
            return nil
        }
        
        // Ensure subdirectory for your app exists
        let appDir = URL.applicationSupportDirectory
        
        // Save thumbnail
        let fileURL = appDir.appendingPathComponent("\(boundItem.id.uuidString).png")
        try pngData.write(to: fileURL)
        
        return fileURL
    }
}

private struct AVPlayerControllerRepresented: NSViewRepresentable {
    let playerItem: AVPlayerItem
    
    func makeNSView(context: Context) -> AVPlayerView {
        let view = AVPlayerView()
        view.controlsStyle = .none
        view.videoGravity = .resizeAspectFill
        
        // Use AVQueuePlayer for looping
        let queuePlayer = AVQueuePlayer()
        view.player = queuePlayer
        
        // Attach looper
        let looper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        context.coordinator.looper = looper // retain looper
        
        queuePlayer.volume = 0
        queuePlayer.isMuted = false
        queuePlayer.play()
        
        return view
    }
    
    func updateNSView(_ nsView: AVPlayerView, context: Context) {
        guard let queuePlayer = nsView.player as? AVQueuePlayer else { return }
        
        // If current item isn’t matching, reset looper
        if (nsView.player?.currentItem?.asset as? AVURLAsset)?.url != (playerItem.asset as? AVURLAsset)?.url {
            nsView.player?.replaceCurrentItem(with: playerItem)
            let looper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
            context.coordinator.looper = looper
            queuePlayer.play()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var looper: AVPlayerLooper?
    }
}

