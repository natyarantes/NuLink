//
//  ShortenMapperTests.swift
//  NuLink
//
//  Created by Natália Arantes on 08/10/25.
//

import XCTest
@testable import NuLink

final class ShortenMapperTests: XCTestCase {
    
    func test_toDomain_mapsFieldsCorrectly() {
        let dto = ShortenResponseDTO(
            alias: "abc",
            links: LinksDTO(
                original: "https://example.com/long",
                short: "https://sho.rt/abc"
            )
        )
        
        let link = ShortenMapper.toDomain(dto)
        
        XCTAssertEqual(link.alias, "abc")
        XCTAssertEqual(link.original, "https://example.com/long")
        XCTAssertEqual(link.short, "https://sho.rt/abc")
    }
    
    func test_toDomain_normalizesValidURLsUsingAbsoluteString() {
        let dto = ShortenResponseDTO(
            alias: "u",
            links: LinksDTO(
                original: "https://example.com/search?q=á",
                short: "https://sho.rt/á"
            )
        )
        
        let link = ShortenMapper.toDomain(dto)
        
        XCTAssertEqual(link.original, "https://example.com/search?q=%C3%A1")
        XCTAssertEqual(link.short, "https://sho.rt/%C3%A1")
    }
    
    func test_toDomain_keepsOriginalStringWhenInvalidURL() {
        let badOriginal = "notaurl:/// /"
        let badShort = "www.exemplo.com/sem-esquema"
        
        let dto = ShortenResponseDTO(
            alias: "bad",
            links: LinksDTO(original: badOriginal, short: badShort)
        )
        
        let link = ShortenMapper.toDomain(dto)
        
        XCTAssertNotEqual(link.original, badOriginal)
        XCTAssertEqual(link.short, badShort)       
    }
}
