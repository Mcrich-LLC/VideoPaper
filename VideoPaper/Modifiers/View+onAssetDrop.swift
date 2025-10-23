//
//  View+onAssetDrop.swift
//  VideoPaper
//
//  Created by Matt Heaney on 20/10/2025.
//

import AVKit
import SwiftUI

public extension View {
    /// - Parameters:
    ///   - acceptedTypes: UTTypes to accept (e.g. `[.image]`, `[.quickTimeMovie]`).
    ///   - allowedExtensions: Optional whitelist of lowercase file extensions (e.g. `["png","jpg"]`).
    ///   - perform: Callback with the resolved file URL.
    ///   - onError: Callback for surfaced errors.
    func onAssetDrop(
        acceptedTypes: [UTType],
        allowedExtensions: [String]? = nil,
        perform: @escaping @MainActor (URL) -> Void,
        onError: @escaping @MainActor (Error) -> Void
    ) -> some View {
        modifier(AssetDropModifier(
            acceptedTypes: acceptedTypes,
            allowedExtensions: allowedExtensions,
            perform: perform,
            onError: onError
        ))
    }
}


private struct AssetDropModifier: ViewModifier {
    @State private var isTargeted = false

    let acceptedTypes: [UTType]
    let allowedExtensions: [String]?
    let perform: @MainActor (URL) -> Void
    let onError: @MainActor (Error) -> Void

    func body(content: Content) -> some View {
        content.onDrop(of: acceptedTypes, isTargeted: $isTargeted) { providers in

            guard let (provider, matchedType) = providers.firstMatchingProvider(of: acceptedTypes) else {
                return false
            }

            provider.loadItem(forTypeIdentifier: matchedType.identifier, options: nil) { item, error in
                Task {
                    do {
                        if let error { throw error }

                        guard let url = ((item as? URL) ?? (item as? Data).flatMap {
                            URL(dataRepresentation: $0, relativeTo: nil)})
                        else {
                            throw FileDropError.failedToLoadItem
                        }

                        guard url.isFileURL else { throw FileDropError.nonFileURL }

                        if let allowed = allowedExtensions {
                            let ext = url.pathExtension.lowercased()
                            if !ext.isEmpty && !allowed.contains(ext) {
                                throw FileDropError.invalidExtension(acceptedTypes: allowed)
                            }
                        }

                        await perform(url)
                    } catch {
                        await onError(error)
                    }
                }
            }

            return true
        }
    }
}

// MARK: - Helpers

extension Array where Element == NSItemProvider {
    fileprivate func firstMatchingProvider(of types: [UTType]) -> (
        NSItemProvider, UTType
    )? {
        for provider in self {
            if let type = types.first(where: {
                provider.hasItemConformingToTypeIdentifier($0.identifier)
            }) {
                return (provider, type)
            }
        }
        return nil
    }
}
