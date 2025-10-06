//
//  ShortenerViewModel.swift
//  NuLink
//
//  Created by Natália Arantes on 03/10/25.
//

import Foundation
import Combine

@MainActor
final class ShortenerViewModel: ObservableObject {
    
    @Published var inputText: String = ""
    @Published var isLoading: Bool = false
    @Published var items: [ShortItemViewData] = []
    @Published var errorMessage: String? = nil
    
    private let service: URLShortenerServicing
    
    init (service: URLShortenerServicing = URLShortenerService()) {
        self.service = service
    }
    
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
            
            // Se por algum motivo não for HTTP, mapeia certo:
            guard let http = response as? HTTPURLResponse else {
#if DEBUG
                print("❌ [Shortener] resposta sem HTTPURLResponse")
#endif
                throw URLShortenerError.badResponse
            }
            
#if DEBUG
            // Logs úteis só em Debug
            let sample = String(data: data.prefix(200), encoding: .utf8) ?? ""
            print("🔎 [Shortener] status=\(http.statusCode) body=\(sample)")
#endif
            
            // Aceita qualquer 2xx (alguns backends devolvem 200/201)
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

    
    func delete(itemID: UUID) {
        items.removeAll { $0.id == itemID }
    }
    
    func clearAll() {
        items.removeAll()
    }
}

struct ShortItemViewData: Identifiable, Hashable {
    let id: UUID
    let originalURL: String
    let shortURL: String
    let alias: String
    
    init(id: UUID = UUID(), originalURL: String, shortURL: String, alias: String) {
        self.id = id
        self.originalURL = originalURL
        self.shortURL = shortURL
        self.alias = alias
    }
}
