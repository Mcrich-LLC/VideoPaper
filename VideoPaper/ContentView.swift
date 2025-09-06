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

    var body: some View {
        NavigationStack {
            ScrollView {
                WrappingHStack(alignment: .leading, horizontalSpacing: 15, verticalSpacing: 15) {
                    ForEach(jsonWallpaperCoordinator.assets) { asset in
                        if let thumbnailImage = asset.thumbnailImage {
                            Image(nsImage: thumbnailImage)
                                .resizable()
                                .aspectRatio(1, contentMode: .fill)
                                .frame(width: 150, height: 150)
                                .clipShape(RoundedRectangle(cornerRadius: 26))
                        }
                    }
                }
                .padding()
            }
            .inspector(isPresented: $isPresentingInspector, content: {
                Text("Test")
            })
            .inspectorColumnWidth(ideal: 150)
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
