//
//  URLShorteningRepository.swift
//  NuLink
//
//  Created by Natália Arantes on 07/10/25.
//

import Foundation

public struct ShortLink: Identifiable, Equatable {
    public let id = UUID()
    public let alias: String
    public let original: String
    public let short: String
}

public protocol URLShorteningRepository {
    func shorten(url: URL) async throws -> ShortLink
}
