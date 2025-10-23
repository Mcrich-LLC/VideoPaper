//
//  ContentView.swift
//  VideoPaper
//
//  Created by Testy McTestface on 9/6/25.
//

import SwiftUI
import SwiftData
import AVKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var sdAssets: [SDWallpaperVideo]
    @Query private var sdCategories: [SDCategory]
    @State var jsonWallpaperCoordinator = JsonWallpaperCoordinator()
    @State private var isPresentingInspector = true
    @State private var inspectedAsset: UUID?
    @State private var errorAlertItem: Error?

    @State var activeDragger: JsonAsset?
    
    @ViewBuilder
    var assetView: some View {
        if jsonWallpaperCoordinator.filteredAssets.isEmpty {
            Text("You don't have any custom wallpapers. Press the + button to get started.")
                .frame(maxWidth: .infinity,
                       maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVGrid(columns: [.init(.adaptive(minimum: 150, maximum: 150))], alignment: .leading) {
                    ReorderableForEach(jsonWallpaperCoordinator.filteredAssets.sorted(by: { $0.preferredOrder < $1.preferredOrder }), active: $activeDragger) { asset in
                        if let thumbnailImage = asset.thumbnailImage {
                            Button {
                                withAnimation {
                                    inspectedAsset = asset.id
                                    isPresentingInspector = true
                                }
                            } label: {
                                VStack {
                                    Image(nsImage: thumbnailImage)
                                        .resizable()
                                        .aspectRatio(1, contentMode: .fill)
                                        .frame(width: 150, height: 150)
                                        .clipShape(RoundedRectangle(cornerRadius: 26))
                                    Text(asset.localizedNameKey)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    } moveAction: { from, to in
                        for index in from {
                            jsonWallpaperCoordinator.filteredAssets[index].preferredOrder = to
                        }
                    }
                    .onChange(of: activeDragger) { oldValue, newValue in
                        guard oldValue != newValue && newValue == nil else { return }
                        try? jsonWallpaperCoordinator.saveData()
                    }
                }
                .padding()
            }
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if jsonWallpaperCoordinator.assets.isEmpty {
                    ProgressView("Fetching Wallpapers...")
                } else {
                    assetView
                        .onAppear {
                            loadSwiftData()
                        }
                        .onChange(of: jsonWallpaperCoordinator.filteredAssets) { _, newValue in
                            for asset in newValue where !sdAssets.contains(where: { $0.id == asset.id }) {
                                do {
                                    let model = try asset.asModel()
                                    modelContext.insert(model)
                                } catch {
                                    print("❌ Swift Data Model Saving: \(error)")
                                }
                            }
                            
                            try? modelContext.save()
                        }
                        .onChange(of: jsonWallpaperCoordinator.filteredCategories) { _, newValue in
                            for category in newValue where !sdCategories.contains(where: { $0.id == category.id }) {
                                let model = category.asModel()
                                modelContext.insert(model)
                            }
                            
                            try? modelContext.save()
                        }
                }
            }
            .onAssetDrop(
                acceptedTypes: [.movie],
                allowedExtensions: ["mov"],
                perform: { url in
                    Task {
                        await addNewVideo(startingVideoURL: url.absoluteString)
                    }
                },
                onError: { error in
                    errorAlertItem = error
                }
            )

            .inspector(isPresented: $isPresentingInspector, content: {
                inspectorView
                .inspectorColumnWidth(min: 200, ideal: 225, max: 400)
            })
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("\(isPresentingInspector ? "Hide" : "Show") Inspector", systemImage: "sidebar.right") {
                        isPresentingInspector.toggle()
                    }
                    .labelStyle(.iconOnly)
                }
                ToolbarItem(placement: .navigation) {
                    Button("Create Wallpaper", systemImage: "plus") {
                        Task {
                            await addNewVideo()
                        }
                    }
                    .labelStyle(.iconOnly)
                }
            }
        }
        .alert(for: $errorAlertItem)
        .onAppear {
            do {
                try jsonWallpaperCoordinator.fetchData()
            } catch {
                print(error)
            }
        }
        .environment(jsonWallpaperCoordinator)
    }
    
    @ViewBuilder
    var inspectorView: some View {
        if let inspectedAsset {
            let newBinding: Binding<JsonAsset?> = Binding {
                jsonWallpaperCoordinator.assets.first(where: { $0.id == inspectedAsset })
            } set: { newValue in
                guard let index = jsonWallpaperCoordinator.assets.firstIndex(where: { $0.id == inspectedAsset }), let newValue else { return }
                jsonWallpaperCoordinator.assets[index] = newValue
            }

            if let binding = Binding(newBinding) {
                WallpaperDetailView(boundItem: binding) {
                    self.inspectedAsset = nil
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(10)) {
                        try? jsonWallpaperCoordinator.deleteAsset(for: inspectedAsset)
                        if let sdObject = sdAssets.first(where: { $0.id == inspectedAsset }) {
                            modelContext.delete(sdObject)
                            try? modelContext.save()
                        }
                    }
                }
            } else {
                Text("Select a Wallpaper")
            }
        } else {
            Text("Select a Wallpaper")
        }
    }

    func addNewVideo(startingVideoURL: String? = nil) async {
        do {
            let newId = try await jsonWallpaperCoordinator.createNewAsset(startingVideoURL: startingVideoURL)
            self.inspectedAsset = newId

           withAnimation {
                isPresentingInspector = true
            }
        } catch {
            print(error)
        }
    }

    func loadSwiftData() {
        let preAdjustFilteredCategories = jsonWallpaperCoordinator.filteredCategories
        let preAdjustFilteredAssets = jsonWallpaperCoordinator.filteredAssets
        
        // Add missing Assets
        for sdAsset in sdAssets where !jsonWallpaperCoordinator.assets.contains(where: { $0.id == sdAsset.id }) {
            guard let appDir = getApplicationSupportDirectory() else { continue }
            
            if !FileManager.default.fileExists(atPath: sdAsset.videoURL) {
                do {
                    let newUrl = appDir.appending(path: "\(UUID().uuidString).mov")
                    try sdAsset.video.write(to: newUrl)
                    sdAsset.videoURL = newUrl.absoluteString
                } catch {
                    print("❌ Swift Data Video Recovery: \(error)")
                }
            }
            if !FileManager.default.fileExists(atPath: sdAsset.previewImage) {
                do {
                    let newUrl = appDir.appending(path: "\(UUID().uuidString).png")
                    try sdAsset.thumbnail.write(to: newUrl)
                    sdAsset.previewImage = newUrl.absoluteString
                } catch {
                    print("❌ Swift Data Thumbnail Recovery: \(error)")
                }
            }
            guard let category = jsonWallpaperCoordinator.filteredCategories.last else { continue }
            sdAsset.categories = [category.id.uuidString]
            sdAsset.subcategories = (category.subcategories ?? []).map({ $0.id.uuidString })
            jsonWallpaperCoordinator.filteredAssets.append(sdAsset.asJson())
        }
        
        for sdCategory in sdCategories where !jsonWallpaperCoordinator.categories.contains(where: { $0.id == sdCategory.id }) {
            jsonWallpaperCoordinator.filteredCategories.append(sdCategory.asJson())
        }
        
        try? modelContext.save()
        
        if jsonWallpaperCoordinator.filteredAssets != preAdjustFilteredAssets || jsonWallpaperCoordinator.filteredCategories != preAdjustFilteredCategories {
            try? jsonWallpaperCoordinator.saveData()
        }
    }
}



#Preview {
    ContentView()
        .modelContainer(for: SDWallpaperVideo.self, inMemory: true)
}
