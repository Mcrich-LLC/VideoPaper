//
//  Error+FileDropError.swift
//  VideoPaper
//
//  Created by Matt Heaney on 21/10/2025.
//

import Foundation

enum FileDropError: LocalizedError {
    case noMatchingProvider
    case failedToLoadItem
    case nonFileURL
    case invalidExtension(acceptedTypes: [String])

    var errorDescription: String? {
        switch self {
        case .noMatchingProvider:
            return "No compatible item was found in the drop."
        case .failedToLoadItem:
            return "Could not load the dropped file."
        case .nonFileURL:
            return "The dropped item wasn’t a valid file URL."
        case .invalidExtension(let acceptedTypes):
            return "Invalid file format. Supported formats: \(acceptedTypes.joined(separator: ", "))."
        }
    }
}
