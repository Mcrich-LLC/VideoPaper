//
//  Error+ThumbnailGenerationError.swift
//  VideoPaper
//
//  Created by Matt Heaney on 23/10/2025.
//

import Foundation

enum ThumbnailGenerationError: LocalizedError {
    case nonFileURL
    case failedToConvertError

    var errorDescription: String? {
        switch self {
        case .nonFileURL:
            return "Could not load the URL"
        case .failedToConvertError:
            return "Incorrect file data"
        }
    }
}
