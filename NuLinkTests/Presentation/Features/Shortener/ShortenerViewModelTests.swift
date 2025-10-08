//
//  ShortenerViewModelTests.swift
//  NuLink
//
//  Created by Natália Arantes on 08/10/25.
//

import XCTest
import Combine
@testable import NuLink

@MainActor
final class ShortenerViewModelTests: XCTestCase {
    
    private var cancellables = Set<AnyCancellable>()
    
    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }
    
    private func makeSUT(repo: URLShorteningRepositoryMock = .init()) -> (ShortenerViewModel, URLShorteningRepositoryMock) {
        let vm = ShortenerViewModel(repo: repo)
        return (vm, repo)
    }

    @discardableResult
    private func expect<T: Publisher>(
        _ publisher: T,
        dropFirst count: Int = 1,
        toSatisfy predicate: @escaping (T.Output) -> Bool,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> XCTestExpectation where T.Failure == Never {
        let exp = expectation(description: "publisher satisfied")
        var fulfilled = false
        
        publisher
            .dropFirst(count)
            .sink { value in
                guard !fulfilled, predicate(value) else { return }
                fulfilled = true
                exp.fulfill()
            }
            .store(in: &cancellables)
        
        return exp
    }

    
    func test_shorten_withInvalidURL_setsError_andDoesNotCallRepo() async {
        let (vm, repo) = makeSUT()
        vm.inputURL = "not a url"
        
        vm.shorten()
        
        XCTAssertEqual(vm.errorMessage, "URL inválida. Inclua https://")
        XCTAssertNil(repo.calledWith)
        XCTAssertFalse(vm.isLoading)
        XCTAssertTrue(vm.items.isEmpty)
    }
    
    func test_shorten_success_insertsItem_clearsInput_andStopsLoading() async {
        let (vm, repo) = makeSUT()
        vm.inputURL = "https://long.example.com/path"

        let exp = expect(vm.$items) { $0.count == 1 }
        vm.shorten()
        await fulfillment(of: [exp], timeout: 1.0)

        XCTAssertEqual(repo.calledWith?.absoluteString, "https://long.example.com/path")
        XCTAssertEqual(vm.items.count, 1)
        XCTAssertEqual(vm.inputURL, "")
        XCTAssertNil(vm.errorMessage)
        XCTAssertFalse(vm.isLoading)
    }
    
    func test_shorten_setsLoadingTrueWhileInFlight_thenFalseOnFinish() async {
        let repo = URLShorteningRepositoryMock()
        repo.delayNanoseconds = 80_000_000
        let (vm, _) = makeSUT(repo: repo)
        vm.inputURL = "https://x.com"
        
        let exp = expect(vm.$isLoading, dropFirst: 1) { $0 == false }
        vm.shorten()
        XCTAssertTrue(vm.isLoading) 
        await fulfillment(of: [exp], timeout: 1.0)
        XCTAssertFalse(vm.isLoading)
    }
    
    func test_shorten_failure_requestFailed_setsError_keepsInput_andDoesNotAddItems() async {
        let repo = URLShorteningRepositoryMock()
        repo.result = .failure(NetworkError.requestFailed(status: 500, body: "oops"))
        let (vm, _) = makeSUT(repo: repo)
        vm.inputURL = "https://x.com"

        let exp = expect(vm.$errorMessage) { $0 != nil }
        vm.shorten()
        await fulfillment(of: [exp], timeout: 1.0)

        XCTAssertEqual(vm.errorMessage, "Falha 500. oops")
        XCTAssertEqual(vm.inputURL, "https://x.com")
        XCTAssertTrue(vm.items.isEmpty)
        XCTAssertFalse(vm.isLoading)
    }

    
    func test_shorten_failure_decoding_setsFriendlyMessage() async {
        struct DummyDecoding: Error {}
        let repo = URLShorteningRepositoryMock()
        repo.result = .failure(NetworkError.decoding(DummyDecoding()))
        let (vm, _) = makeSUT(repo: repo)
        vm.inputURL = "https://x.com"
        
        let exp = expect(vm.$errorMessage) { $0 != nil }
        vm.shorten()
        await fulfillment(of: [exp], timeout: 1.0)
        
        XCTAssertTrue(vm.errorMessage?.hasPrefix("Erro ao processar a resposta:") == true)
        XCTAssertTrue(vm.items.isEmpty)
    }
    
    func test_shorten_failure_generic_setsNetworkMessage() async {
        let repo = URLShorteningRepositoryMock()
        repo.result = .failure(URLError(.timedOut))
        let (vm, _) = makeSUT(repo: repo)
        vm.inputURL = "https://x.com"
        
        let exp = expect(vm.$errorMessage) { $0 != nil }
        vm.shorten()
        await fulfillment(of: [exp], timeout: 1.0)
        
        XCTAssertTrue(vm.errorMessage?.hasPrefix("Erro de rede:") == true)
        XCTAssertTrue(vm.items.isEmpty)
    }
    
    func test_reset_clearsAll() async {
        let (vm, _) = makeSUT()
        vm.inputURL = "https://x.com"
        vm.errorMessage = "qualquer"
        vm.isLoading = true
        vm.items = [ShortLink(alias: "a", original: "o", short: "s")]
        
        vm.reset()
        
        XCTAssertEqual(vm.inputURL, "")
        XCTAssertNil(vm.errorMessage)
        XCTAssertFalse(vm.isLoading)
        XCTAssertTrue(vm.items.isEmpty)
    }
}
