//
//  URLSessionHTTPClientTests.swift
//  NuLink
//
//  Created by Natália Arantes on 08/10/25.
//

import XCTest
@testable import NuLink

final class URLProtocolStub: URLProtocol {
    struct Stub {
        let data: Data?
        let response: URLResponse?
        let error: Error?
    }
    
    static var stub: Stub?
    static var requestObserver: ((URLRequest) -> Void)?
    
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    override func startLoading() {
        if let observer = URLProtocolStub.requestObserver {
            observer(request)
        }
        
        if let error = URLProtocolStub.stub?.error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
    }
    
    override func stopLoading() {}
}

final class URLSessionHTTPClientTests: XCTestCase {
    
    private func makeSUT() -> URLSessionHTTPClient {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: config)
        return URLSessionHTTPClient(session: session)
    }
    
    private func httpURL(_ path: String = "/") -> URL {
        URL(string: "https://example.com\(path)")!
    }
    
    private func httpResponse(_ code: Int = 200, url: URL? = nil) -> HTTPURLResponse {
        HTTPURLResponse(
            url: url ?? httpURL(),
            statusCode: code,
            httpVersion: nil,
            headerFields: nil
        )!
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stub = nil
        URLProtocolStub.requestObserver = nil
    }
    
    func test_send_deliversTransportErrorOnURLSessionError() async {
        let sut = makeSUT()
        URLProtocolStub.stub = .init(data: nil, response: nil, error: URLError(.timedOut))
        
        do {
            _ = try await sut.send(URLRequest(url: httpURL()))
            XCTFail( "Expected to throw, but it succeeded")
        } catch let NetworkError.transport(err as URLError) {
            XCTAssertEqual(err.code, .timedOut)
        } catch {
            XCTFail("Expected URLError, but got \(error)")
        }
    }
    
    func test_send_throwsRequestFailedWrappedInTransport_whenNotHTTPURLResponse() async {
        let sut = makeSUT()
        let nonHTTP = URLResponse(url: httpURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        let body = Data("some".utf8)
        URLProtocolStub.stub = .init(data: body, response: nonHTTP, error: nil)

        do {
            _ = try await sut.send(URLRequest(url: httpURL()))
            XCTFail("Expected to throw, but it succeeded")
        } catch let NetworkError.transport(inner) {
            guard case let NetworkError.requestFailed(status, receivedBody)? = inner as? NetworkError else {
                return XCTFail("Expected transport wrapping requestFailed, got \(inner)")
            }
            XCTAssertEqual(status, -1)
            XCTAssertEqual(receivedBody, "some")
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }

    
    func test_send_returnsDataAndHTTPURLResponseOnSuccess() async throws {
        let sut = makeSUT()
        let data = Data("{}".utf8)
        let resp = httpResponse(204)
        URLProtocolStub.stub = .init(data: data, response: resp, error: nil)
        
        let (receivedData, receivedResp) = try await sut.send(URLRequest(url: httpURL()))
        XCTAssertEqual(receivedData, data)
        XCTAssertEqual(receivedResp.statusCode, 204)
    }
    
    func test_send_observesRequestURLMethodAndHeaders() async throws {
        let sut = makeSUT()
        let reqURL = httpURL("/api/alias")
        var capturedRequest: URLRequest?

        URLProtocolStub.requestObserver = { capturedRequest = $0 }
        URLProtocolStub.stub = .init(
            data: Data(),
            response: httpResponse(200, url: reqURL),
            error: nil
        )

        var request = URLRequest(url: reqURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        _ = try await sut.send(request)

        let captured = try XCTUnwrap(capturedRequest, "requestObserver não foi chamado")

        XCTAssertEqual(captured.url?.path, "/api/alias")
        XCTAssertEqual(captured.httpMethod, "POST")

        let accept = captured.value(forHTTPHeaderField: "Accept")?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        XCTAssertEqual(accept, "application/json")
    }

}
