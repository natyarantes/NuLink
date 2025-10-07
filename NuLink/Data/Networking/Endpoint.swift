//
//  Endpoint.swift
//  NuLink
//
//  Created by Natália Arantes on 07/10/25.
//

import Foundation

public struct Endpoint {
    public let path: String
    public let method: String
    public let headers: [String: String]
    public let body: Data?

    public init(path: String,
                method: String = "GET",
                headers: [String: String] = [:],
                body: Data? = nil) {
        self.path = path
        self.method = method
        self.headers = headers
        self.body = body
    }

    public func urlRequest(baseURL: URL) throws -> URLRequest {
        guard let url = URL(string: path, relativeTo: baseURL) else {
            throw NetworkError.invalidURL
        }
        var req = URLRequest(url: url)
        req.httpMethod = method
        headers.forEach { key, value in req.setValue(value, forHTTPHeaderField: key) }
        req.httpBody = body
        return req
    }
}
