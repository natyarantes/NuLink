//
//  URLSessionHTTPClient.swift
//  NuLink
//
//  Created by Natália Arantes on 07/10/25.
//

import Foundation

public final class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    public init(session: URLSession = .shared) { self.session = session }

    public func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw NetworkError.requestFailed(status: -1, body: String(data: data, encoding: .utf8))
            }
            return (data, http)
        } catch {
            throw NetworkError.transport(error)
        }
    }
}
