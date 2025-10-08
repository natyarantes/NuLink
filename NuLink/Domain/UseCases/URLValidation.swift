//
//  URLValidation.swift
//  NuLink
//
//  Created by Natália Arantes on 06/10/25.
//

import Foundation

enum URLValidation {
    static func sanitizedURL(from input: String) -> URL? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        if let url = URL(string: trimmed), url.scheme != nil {
            return url
        }
        if let  url = URL(string: "https://\(trimmed)"), url.host != nil {
            return url
        }
        return nil
    }
}
