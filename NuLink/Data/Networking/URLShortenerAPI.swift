//
//  URLShortenerAPI.swift
//  NuLink
//
//  Created by Natália Arantes on 06/10/25.
//

import Foundation

// MARK: - Errors

enum URLShortenerError: Error, LocalizedError {
    case invalidBaseURL
    case badResponse
    case badStatus(Int)
    case decoding
    case transport(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidBaseURL: return "Invalid service base URL."
        case .badResponse: return "Invalid server response."
        case .badStatus(let code): return "Server returned status \(code)."
        case .decoding: return "Failed to decode server response."
        case .transport(let underlying): return underlying.localizedDescription
        }
    }
}

// MARK: - DTOs

struct ShortenRequest: Encodable { let url: String }

struct ShortenResponse: Decodable {
    let alias: String
    let _links: Links
    
    struct Links: Decodable {
        let selfLink: String
        let short: String
        
        enum CodingKeys: String, CodingKey {
            case selfLink = "self"
            case short
        }
    }
}

// MARK: - Protocol

protocol URLShortenerServicing {
    func shorten(url: URL) async throws -> ShortenResponse
}

// MARK: - Implementation

final class URLShortenerService: URLShortenerServicing {
    
    // MARK: Properties
    private let baseURLString: String
    private let session: URLSession
    
    // MARK: Init
    init(
        baseURLString: String = "https://url-shortener-server.onrender.com",
        session: URLSession? = nil
    ) {
        self.baseURLString = baseURLString
        if let session {
            self.session = session
        } else {
            let config = URLSessionConfiguration.ephemeral
            config.waitsForConnectivity = true
            config.timeoutIntervalForRequest = 20
            config.timeoutIntervalForResource = 30
            self.session = URLSession(configuration: config)
        }
    }
    
    // MARK: - Method
    func shorten(url: URL) async throws -> ShortenResponse {
        guard let baseURL = URL(string: baseURLString) else {
            throw URLShortenerError.invalidBaseURL
        }
        
        let endpoint = baseURL.appendingPathComponent("api/alias")
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(ShortenRequest(url: url.absoluteString))
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let http = response as? HTTPURLResponse else {
#if DEBUG
                print("❌ [Shortener] resposta sem HTTPURLResponse")
#endif
                throw URLShortenerError.badResponse
            }
            
#if DEBUG
            let snippet = String(data: data.prefix(200), encoding: .utf8) ?? ""
            print("🔎 [Shortener] status=\(http.statusCode) body=\(snippet)")
#endif
            
            guard (200...299).contains(http.statusCode) else {
                throw URLShortenerError.badStatus(http.statusCode)
            }
            
            do {
                return try JSONDecoder().decode(ShortenResponse.self, from: data)
            } catch {
                throw URLShortenerError.decoding
            }
            
        } catch let e as URLShortenerError {
            throw e
        } catch {
            throw URLShortenerError.transport(error)
        }
    }
}

