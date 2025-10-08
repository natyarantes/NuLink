//
//  ShortenDTOTests.swift
//  NuLink
//
//  Created by Natália Arantes on 08/10/25.
//

import XCTest
@testable import NuLink

final class ShortenDTOTests: XCTestCase {
    
    func test_decodesValidJSON_mapsUnderscoredKeys() throws {
        let json = """
                {
                  "alias": "abc123",
                  "_links": {
                    "self": "https://example.com/very/long/url",
                    "short": "https://sho.rt/abc123"
                  }
                }
                """.data(using: .utf8)!
        
        let dto = try JSONDecoder().decode(ShortenResponseDTO.self, from: json)
        
        XCTAssertEqual(dto.alias, "abc123")
        XCTAssertEqual(dto.links.original, "https://example.com/very/long/url")
        XCTAssertEqual(dto.links.short, "https://sho.rt/abc123")
    }
    
    func test_decodeFailsWhenRequiredKeysAreMissing() {
        let json = """
            {
              "_links": { "self": "https://x", "short": "https://s" }
            }
            """.data(using: .utf8)!
        
        XCTAssertThrowsError(try JSONDecoder().decode(ShortenResponseDTO.self, from: json))
    }
    
    func test_decodeFailsWhenTypesMismatch() {
        let json = """
            {
              "alias": 123,
              "_links": { "self": 999, "short": true }
            }
            """.data(using: .utf8)!
        
        XCTAssertThrowsError(try JSONDecoder().decode(ShortenResponseDTO.self, from: json))
    }
}
