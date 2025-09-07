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
    @State private var isShowingSavedInlineMessage = false
    @State private var editableItem: A
    @State private var forceImageUpdate = false
    
    init(boundItem: Binding<A>, onDelete: (() -> Void)?) {
        self._boundItem = boundItem
        self.onDelete = onDelete
        self.editableItem = boundItem.wrappedValue
    }
    
    var body: some View {
        ScrollView {
            VStack {
                WallpaperVideoPlayer(boundItem: $editableItem)
                GroupBox {
                    VStack(alignment: .leading) {
                        TextField("Name", text: $editableItem.localizedNameKey)
                            .padding(.leading, 1)
                            .onChange(of: editableItem.localizedNameKey) { _, newValue in
                                editableItem.accessibilityLabel = newValue
                            }
                            .textFieldStyle(.plain)
                        Divider()
                        Toggle("Pinned", isOn: $editableItem.showInTopLevel)
                        Toggle("Include in Shuffle", isOn: $editableItem.includeInShuffle)
                        
                        Divider()
                        
                        HStack {
                            if let image = editableItem.thumbnailImage {
                                Image(nsImage: image)
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fill)
                                    .frame(width: 50, height: 50)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            
                            Button("\(editableItem.thumbnailImage == nil ? "Set" : "Change") Image") {
                                isShowingThumbnailFileImporter.toggle()
                            }
                            .fileImporter(isPresented: $isShowingThumbnailFileImporter, allowedContentTypes: [.image, .png, .jpeg, .jpeg]) { result in
                                switch result {
                                case .success(let success):
                                    editableItem.previewImage = success.absoluteString
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
                        VStack {
                            HStack {
                                Button(role: .destructive) {
                                    editableItem = boundItem
                                } label: {
                                    Label("Discard", systemImage: "eraser")
                                        .frame(maxWidth: .infinity)
                                }
                                .disabled(boundItem == editableItem)
                                
                                Button {
                                    saveProperties()
                                    isShowingSavedInlineMessage = true
                                } label: {
                                    Label("Save", systemImage: "checkmark")
                                        .frame(maxWidth: .infinity)
                                }
                                .disabled(editableItem.videoURL.isEmpty || editableItem.previewImage.isEmpty || boundItem == editableItem)
                                .tint(.accentColor)
                            }
                            Divider()
                            if let onDelete {
                                Button(role: .destructive) {
                                    onDelete()
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                        .frame(maxWidth: .infinity)
                                }
                                .tint(.red)
                            }
                        }
                    }
                }
                Spacer()
            }
            .padding(.horizontal)
            .alert(for: $errorAlertItem)
            .onChange(of: boundItem, { oldValue, newValue in
                if oldValue.id != newValue.id {
                    if oldValue.videoURL.isEmpty || oldValue.previewImage.isEmpty {
                        if let oldValue = oldValue as? JsonAsset {
                            try? jsonWallpaperCoordinator.deleteAsset(oldValue)
                        }
                    }
                }
                
                if editableItem != newValue {
                    editableItem = newValue
                }
            })
            .onDisappear(perform: {
                if boundItem.videoURL.isEmpty || boundItem.previewImage.isEmpty {
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
            .animation(.default, value: isShowingSavedInlineMessage)
        }
    }
    
    func saveProperties() {
        boundItem.localizedNameKey = editableItem.localizedNameKey
        boundItem.accessibilityLabel = editableItem.accessibilityLabel
        boundItem.preferredOrder = editableItem.preferredOrder
        boundItem.includeInShuffle = editableItem.includeInShuffle
        boundItem.pointsOfInterest = editableItem.pointsOfInterest
        boundItem.showInTopLevel = editableItem.showInTopLevel
        boundItem.videoURL = editableItem.videoURL
        boundItem.previewImage = editableItem.previewImage
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
                boundItem.videoURL = success.absoluteString
                updateVideo()
            case .failure(let failure):
                print(failure)
                errorAlertItem = failure
            }
        }
        .alert(for: $errorAlertItem)
        .buttonStyle(.plain)
        .onChange(of: boundItem.videoURL, initial: true) { oldValue, newValue in
            guard oldValue != newValue || videoItem == nil else {
                return
            }
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
        guard let appDir = getApplicationSupportDirectory() else { return nil }
        
        // Save thumbnail
        let fileURL = appDir.appendingPathComponent("\(UUID().uuidString).png")
        try pngData.write(to: fileURL)
        
        return fileURL
    }
}

func getApplicationSupportDirectory() -> URL? {
    // Get the URL for the user's Application Support directory.
    guard let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
        print("Could not find the Application Support directory.")
        return nil
    }

    // Get the bundle identifier of your application.
    guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
        print("Could not get the application's bundle identifier.")
        return nil
    }

    // Append the bundle identifier to create a specific directory for your app.
    let appSpecificSupportURL = appSupportURL.appendingPathComponent(bundleIdentifier)

    // Create the directory if it doesn't exist.
    do {
        try FileManager.default.createDirectory(at: appSpecificSupportURL, withIntermediateDirectories: true, attributes: nil)
        return appSpecificSupportURL
    } catch {
        print("Error creating application support directory: \(error.localizedDescription)")
        return nil
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
            queuePlayer.removeAllItems()
            
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

