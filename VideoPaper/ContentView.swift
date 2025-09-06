//
//  ContentView.swift
//  VideoPaper
//
//  Created by Testy McTestface on 9/6/25.
//

import SwiftUI
import SwiftData
import WrappingHStack

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [SDWallpaperVideo]
    @State var jsonWallpaperCoordinator = JsonWallpaperCoordinator()
    @State private var isPresentingInspector = true
    @State private var inspectedAsset: Binding<JsonAsset>?

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [.init(.adaptive(minimum: 150, maximum: 150))], alignment: .leading) {
                    ForEach($jsonWallpaperCoordinator.filteredAssets) { $asset in
                        if let thumbnailImage = asset.thumbnailImage {
                            Button {
                                inspectedAsset = $asset
                                isPresentingInspector = true
                            } label: {
                                Image(nsImage: thumbnailImage)
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fill)
                            }
                            .frame(width: 150, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 26))
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding()
            }
            .inspector(isPresented: $isPresentingInspector, content: {
                Group {
                    if let inspectedAsset {
                        WallpaperDetailView(boundItem: inspectedAsset)
                    } else {
                        Text("Select a Wallpaper")
                    }
                }
                .inspectorColumnWidth(min: 150, ideal: 225, max: 400)
            })
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("\(isPresentingInspector ? "Hide" : "Show") Inspector", systemImage: "sidebar.right") {
                        isPresentingInspector.toggle()
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
    }
}

#Preview {
    ContentView()
        .modelContainer(for: SDWallpaperVideo.self, inMemory: true)
}
