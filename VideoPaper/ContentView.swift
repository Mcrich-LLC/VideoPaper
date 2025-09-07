//
//  ContentView.swift
//  VideoPaper
//
//  Created by Testy McTestface on 9/6/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [SDWallpaperVideo]
    @State var jsonWallpaperCoordinator = JsonWallpaperCoordinator()
    @State private var isPresentingInspector = true
    @State private var inspectedAsset: UUID?

    var body: some View {
        NavigationStack {
            Group {
                if jsonWallpaperCoordinator.assets.isEmpty {
                    ProgressView("Fetching Wallpapers...")
                } else if jsonWallpaperCoordinator.filteredAssets.isEmpty {
                    Text("You don't have any custom wallpapers. Press the + button to get started.")
                } else {
                    ScrollView {
                        LazyVGrid(columns: [.init(.adaptive(minimum: 150, maximum: 150))], alignment: .leading) {
                            ForEach(jsonWallpaperCoordinator.filteredAssets) { asset in
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
                            }
                        }
                        .padding()
                    }
                }
            }
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
                        do {
                            let newId = try jsonWallpaperCoordinator.createBlankAsset()
                            withAnimation {
                                self.inspectedAsset = newId
                                isPresentingInspector = true
                            }
                        } catch {
                            print(error)
                        }
                    }
                    .labelStyle(.iconOnly)
                }
            }
        }
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
                    }
                }
            } else {
                Text("Select a Wallpaper")
            }
        } else {
            Text("Select a Wallpaper")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: SDWallpaperVideo.self, inMemory: true)
}
