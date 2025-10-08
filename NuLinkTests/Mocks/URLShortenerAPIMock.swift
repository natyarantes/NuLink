//
//  Untitled.swift
//  NuLink
//
//  Created by Natália Arantes on 08/10/25.
//

import XCTest
@testable import NuLink

final class URLShortenerAPIMock: URLShortenerAPIProtocol {
    var receivedURL: URL?
    var shortenResult: Result<ShortenResponseDTO, Error>!

    func shorten(url: URL) async throws -> ShortenResponseDTO {
        receivedURL = url
        return try shortenResult.get()
    }
}
