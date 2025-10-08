//
//  MockHTTPClient.swift
//  NuLink
//
//  Created by Natália Arantes on 08/10/25.
//

import XCTest
@testable import NuLink

final class MockHTTPClient: HTTPClient {
    var lastRequest: URLRequest?
    var result: Result<(Data, HTTPURLResponse), Error>!

    func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        self.lastRequest = request
        switch result! {
        case .success(let ok): return ok
        case .failure(let err): throw err
        }
    }
}
