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

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                    ForEach(0..<10) { _ in
                        RoundedRectangle(cornerRadius: 26)
                            .frame(minWidth: 100, maxWidth: .infinity, minHeight: 100, maxHeight: .infinity)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: SDWallpaperVideo.self, inMemory: true)
}
