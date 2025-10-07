//
//  URLShortenerAPI.swift
//  NuLink
//
//  Created by Natália Arantes on 06/10/25.
//

import Foundation

protocol URLShortenerAPIProtocol {
    func shorten(url: URL) async throws -> ShortenResponseDTO
}

public final class URLShortenerAPI: URLShortenerAPIProtocol {
    private let baseURL: URL
    private let client: HTTPClient
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    public init(baseURL: URL = URL(string: "https://url-shortener-server.onrender.com")!,
                client: HTTPClient,
                decoder: JSONDecoder = .init(),
                encoder: JSONEncoder = .init()) {
        self.baseURL = baseURL
        self.client = client
        self.decoder = decoder
        self.encoder = encoder
    }

    func shorten(url: URL) async throws -> ShortenResponseDTO {
        struct Body: Encodable { let url: String }
        let body: Data
        do {
            body = try encoder.encode(Body(url: url.absoluteString))
        } catch {
            throw NetworkError.encodingFailed(error)
        }

        let endpoint = Endpoint(
            path: "/api/alias",
            method: "POST",
            headers: [
                "Content-Type": "application/json; charset=utf-8",
                "Accept": "application/json"
            ],
            body: body
        )

        let request = try endpoint.urlRequest(baseURL: baseURL)
        let (data, response) = try await client.send(request)
        
        guard (200...299).contains(response.statusCode) else {
            throw NetworkError.requestFailed(status: response.statusCode,
                                             body: String(data: data, encoding: .utf8))
        }

        do {
            return try decoder.decode(ShortenResponseDTO.self, from: data)
        } catch {
            throw NetworkError.decoding(error)
        }
    }
}
