//
//  EndpointTests.swift
//  NuLink
//
//  Created by Natália Arantes on 08/10/25.
//

import XCTest
@testable import NuLink

final class EndpointTests: XCTestCase {
    
    func test_urlRequest_buildsRelativeToBaseURL() throws {
        let base = URL(string: "https://url-shortener-server.onrender.com")!
        let ep = Endpoint(path: "/api/alias",
                          method: "POST",
                          headers: ["Accept": "application/json"],
                          body: Data("BODY".utf8))
        
        let req = try ep.urlRequest(baseURL: base)
        XCTAssertEqual(req.url, URL(string: "https://url-shortener-server.onrender.com/api/alias")!)
        XCTAssertEqual(req.httpMethod, "POST")
        XCTAssertEqual(req.value(forHTTPHeaderField: "Accept"), "application/json")
        XCTAssertEqual(req.httpBody, Data("BODY".utf8))
    }
    
    func test_urlRequest_throwsOnValidPath() {
        let base = URL(string: "https://example.com")!
        let invalid = Endpoint(path: "://\\INVALID")
        
        XCTAssertThrowsError(try invalid.urlRequest(baseURL: base)) { error in
            guard case NetworkError.invalidURL = error else {
                return XCTFail("Expected NetworkError.invalidURL, got \(error)")
            }
        }
    }
}
