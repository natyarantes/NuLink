//
//  URLShorteningRepositoryMock.swift
//  NuLink
//
//  Created by Natália Arantes on 08/10/25.
//

import XCTest
@testable import NuLink

final class URLShorteningRepositoryMock: URLShorteningRepository {
    var calledWith: URL?
    var result: Result<ShortLink, Error> = .success(
        ShortLink(alias: "a1", original: "https://long", short: "https://sho.rt/a1")
    )
    var delayNanoseconds: UInt64 = 0

    func shorten(url: URL) async throws -> ShortLink {
        calledWith = url
        if delayNanoseconds > 0 {
            try await Task.sleep(nanoseconds: delayNanoseconds)
        }
        return try result.get()
    }
}
