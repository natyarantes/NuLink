//
//  URLValidationTests.swift
//  NuLink
//
//  Created by Natália Arantes on 08/10/25.
//

import XCTest
@testable import NuLink

final class URLValidationTests: XCTestCase {
    
    private func assertSanitized(_ input: String,
                                 equals expected: String?,
                                 file: StaticString = #filePath,
                                 line: UInt = #line) {
        let result = URLValidation.sanitizedURL(from: input)?.absoluteString
        XCTAssertEqual(result, expected, file: file, line: line)
    }
    
    func test_returnsSameURL_whenInputAlreadyHasValidScheme() {
        assertSanitized("https://example.com", equals: "https://example.com")
        assertSanitized("http://example.com", equals: "http://example.com")
        assertSanitized("HTTP://example.com/path", equals: "HTTP://example.com/path")
    }
    
    func test_trimsWhitespaceBeforeParsing() {
        assertSanitized("   https://example.com  ", equals: "https://example.com")
        assertSanitized("\n\t http://example.com/path \t", equals: "http://example.com/path")
    }
    
    func test_prefixesHTTPS_whenMissingSchemeAndHostIsValid() {
        assertSanitized("example.com", equals: "https://example.com")
        assertSanitized("www.example.com", equals: "https://www.example.com")
        assertSanitized("sub.domain.co.uk", equals: "https://sub.domain.co.uk")
        assertSanitized("localhost", equals: "https://localhost")
    }
    
    func test_preservesPathQueryFragment_whenAutoPrefixed() {
        assertSanitized("example.com/a/b?x=1#frag",
                        equals: "https://example.com/a/b?x=1#frag")
    }
    
    func test_returnsNil_forEmptyOrWhitespaceOnly() {
        XCTAssertNil(URLValidation.sanitizedURL(from: ""))
        XCTAssertNil(URLValidation.sanitizedURL(from: "   \n\t "))
    }
    
    func test_returnsNil_forClearlyInvalidInputs() {
        XCTAssertNil(URLValidation.sanitizedURL(from: "not a url"))
        XCTAssertNil(URLValidation.sanitizedURL(from: "%%%/bad"))
        
        assertSanitized("http://", equals: "http://")
        assertSanitized("://missing-scheme", equals: "://missing-scheme")
    }
    
    func test_doesNotDoublePrefix_whenSchemeExists() {
        assertSanitized("https://example.com/path", equals: "https://example.com/path")
        assertSanitized("http://example.com?x=1", equals: "http://example.com?x=1")
    }
}
