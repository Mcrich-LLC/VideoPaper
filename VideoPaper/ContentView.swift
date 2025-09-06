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

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
                    ForEach(jsonWallpaperCoordinator.filteredAssets) { asset in
                        if let thumbnailImage = asset.thumbnailImage {
                            Image(nsImage: thumbnailImage)
                                .resizable()
                                .aspectRatio(1, contentMode: .fill)
                                .frame(minWidth: 150, maxWidth: .infinity, minHeight: 150, maxHeight: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: 26))
                        }
                    }
                }
                .padding()
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
