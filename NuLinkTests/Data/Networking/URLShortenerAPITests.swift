//
//  URLShortenerAPITests.swift
//  NuLink
//
//  Created by Natália Arantes on 08/10/25.
//

import XCTest
@testable import NuLink

final class FailingJSONEncoder: JSONEncoder, @unchecked Sendable {
    enum StubError: Error { case encodeFail }
    override func encode<T>(_ value: T) throws -> Data where T : Encodable {
        throw StubError.encodeFail
    }
}

final class URLShortenerAPITests: XCTestCase {

    private func makeSUT(encoder: JSONEncoder = .init(),
                         decoder: JSONDecoder = .init()) -> (URLShortenerAPI, MockHTTPClient) {
        let client = MockHTTPClient()
        let sut = URLShortenerAPI(client: client, decoder: decoder, encoder: encoder)
        return (sut, client)
    }

    private func httpResponse(_ code: Int) -> HTTPURLResponse {
        HTTPURLResponse(url: URL(string: "https://url-shortener-server.onrender.com/api/alias")!,
                        statusCode: code,
                        httpVersion: nil,
                        headerFields: nil)!
    }

    func test_shorten_buildsPOSTRequestWithJSONBody() async throws {
        let (sut, client) = makeSUT()
        let payload = """
        {"alias":"a","_links":{"self":"https://a","short":"https://b"}}
        """.data(using: .utf8)!
        client.result = .success((payload, httpResponse(200)))

        _ = try await sut.shorten(url: URL(string: "https://example.com/long")!)

        let req = try XCTUnwrap(client.lastRequest)
        XCTAssertEqual(req.httpMethod, "POST")
        XCTAssertEqual(req.url?.path, "/api/alias")
        XCTAssertEqual(req.value(forHTTPHeaderField: "Content-Type"), "application/json; charset=utf-8")
        XCTAssertEqual(req.value(forHTTPHeaderField: "Accept"), "application/json")
        // Confere corpo JSON
        struct Body: Decodable { let url: String }
        let body = try JSONDecoder().decode(Body.self, from: try XCTUnwrap(req.httpBody))
        XCTAssertEqual(body.url, "https://example.com/long")
    }

    func test_shorten_acceptsAny2xx() async throws {
        let (sut, client) = makeSUT()
        let json = """
        {"alias":"some123","_links":{"self":"https://x","short":"https://s"}}
        """.data(using: .utf8)!
        client.result = .success((json, httpResponse(201)))
        let dto = try await sut.shorten(url: URL(string: "https://x")!)
        XCTAssertEqual(dto.alias, "some123")

        client.result = .success((json, httpResponse(200)))
        let dto2 = try await sut.shorten(url: URL(string: "https://x")!)
        XCTAssertEqual(dto2.links.short, "https://s")
    }

    func test_shorten_throwsRequestFailedOnNon2xx() async {
        let (sut, client) = makeSUT()
        client.result = .success((Data("Bad".utf8), httpResponse(400)))

        do {
            _ = try await sut.shorten(url: URL(string: "https://x")!)
            XCTFail("Expected error")
        } catch let NetworkError.requestFailed(status, body) {
            XCTAssertEqual(status, 400)
            XCTAssertEqual(body, "Bad")
        } catch {
            XCTFail("Unexpected \(error)")
        }
    }

    func test_shorten_throwsDecodingOnInvalidJSON() async {
        let (sut, client) = makeSUT()
        client.result = .success((Data("not json".utf8), httpResponse(200)))

        do {
            _ = try await sut.shorten(url: URL(string: "https://x")!)
            XCTFail("Expected decoding error")
        } catch let NetworkError.decoding(_) {
            // ok
        } catch {
            XCTFail("Unexpected \(error)")
        }
    }

    func test_shorten_throwsEncodingOnFailingEncoder() async {
        let failingEncoder = FailingJSONEncoder()
        let (sut, _) = makeSUT(encoder: failingEncoder)

        do {
            _ = try await sut.shorten(url: URL(string: "https://x")!)
            XCTFail("Expected encoding error")
        } catch let NetworkError.encodingFailed(error as FailingJSONEncoder.StubError) {
            XCTAssertEqual(error, .encodeFail)
        } catch {
            XCTFail("Unexpected \(error)")
        }
    }
}
