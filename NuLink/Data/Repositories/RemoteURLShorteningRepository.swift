//
//  RemoteURLShorteningRepository.swift
//  NuLink
//
//  Created by Natália Arantes on 07/10/25.
//

import Foundation

public final class RemoteURLShorteningRepository: URLShorteningRepository {
    private let api: URLShortenerAPIProtocol

    init(api: URLShortenerAPIProtocol) {
        self.api = api
    }

    public func shorten(url: URL) async throws -> ShortLink {
        let dto = try await api.shorten(url: url)
        return ShortenMapper.toDomain(dto)
    }
}
