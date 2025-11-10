//
//  String+readableFileName.swift
//  VideoPaper
//
//  Created by Matt Heaney on 22/10/2025.
//

import Foundation

extension String {
    /// Extracts a cleaned filename (without extension) if this string
    /// represents a valid file path or URL. Returns `nil` otherwise.
    var readableFileName: String? {
        // Try to interpret as URL
        guard let url = URL(string: self) ?? URL(fileURLWithPath: self, isDirectory: false) as URL? else {
            return nil
        }

        // Ensure it actually has a filename
        let fileNameWithExt = url.lastPathComponent
        guard !fileNameWithExt.isEmpty else { return nil }

        // Remove the extension
        let fileName = (fileNameWithExt as NSString).deletingPathExtension

        // Clean up spacing
        let cleaned = fileName
            .replacingOccurrences(of: "%20", with: " ")
            .replacingOccurrences(of: "_", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return cleaned.isEmpty ? nil : cleaned
    }
}
