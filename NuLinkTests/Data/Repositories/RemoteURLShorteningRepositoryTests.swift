//
//  RemoteURLShorteningRepositoryTests.swift
//  NuLink
//
//  Created by Natália Arantes on 08/10/25.
//

import XCTest
@testable import NuLink

final class RemoteURLShorteningRepositoryTests: XCTestCase {
    
    func test_shorte_forwarsURLToAPI_andMapsDTOToDomain() async throws {
        let api = URLShortenerAPIMock()
        let sut = await RemoteURLShorteningRepository(api: api)
        
        let dto = ShortenResponseDTO( alias: "abc123",
                                      links: LinksDTO(original: "https://long.example.com/path",
                                                      short: "http://sho.rt/abc123"))
        api.shortenResult = .success(dto)
        
        let inputURL = URL(string: "https://long.example.com/path")!
        let link = try await sut.shorten(url: inputURL)
        
        XCTAssertEqual(api.receivedURL, inputURL)
        XCTAssertEqual(link.alias, "abc123")
        XCTAssertEqual(link.short, "http://sho.rt/abc123")
        XCTAssertEqual(link.original, "https://long.example.com/path")
    }
    
    func test_shorten_propagtesAPIError() async {
        let api = URLShortenerAPIMock()
        let sut = await RemoteURLShorteningRepository(api: api)
        
        api.shortenResult = .failure(NetworkError.requestFailed(status: 500, body: "some error"))
        
        do {
            _ = try await sut.shorten(url: URL(string: "https://long.example.com/path")!)
            XCTFail( "Expected to throw")
        } catch let NetworkError.requestFailed(status, body) {
            XCTAssertEqual(body, "some error")
            XCTAssertEqual(status, 500)
        } catch {
            XCTFail( "Unexpected error: \(error)")
        }
        
        
    }
}
